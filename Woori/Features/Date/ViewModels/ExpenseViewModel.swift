import SwiftUI
import FirebaseFirestore

@MainActor
final class ExpenseViewModel: ObservableObject {
    @Published var expenses: [DateExpense] = []
    @Published var courses: [DateCourse] = []
    @Published var selectedMonth = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddSheet = false

    // Add form
    @Published var newTitle = ""
    @Published var newAmount = ""
    @Published var newCategory: DateExpense.Category = .food
    @Published var newPaidBy = ""
    @Published var newDate = Date()
    @Published var newMemo = ""
    @Published var newCourseId: String?

    private let repository = FirebaseDateRepository()
    private let session = CoupleSession.shared
    private var cancelListener: (() -> Void)?

    var coupleDocId: String { session.coupleDocId }
    var myNickname: String { session.myNickname }
    var partnerNickname: String { session.partnerNickname }

    // MARK: - Computed

    var monthlyTotal: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var myTotal: Int {
        expenses.filter { $0.paidBy == myNickname }.reduce(0) { $0 + $1.amount }
    }

    var partnerTotal: Int {
        expenses.filter { $0.paidBy == partnerNickname }.reduce(0) { $0 + $1.amount }
    }

    /// 더치페이 잔액 (양수: 내가 더 냄, 음수: 상대가 더 냄)
    var dutchPayBalance: Int {
        (myTotal - partnerTotal) / 2
    }

    var dutchPayText: String {
        let balance = dutchPayBalance
        if balance == 0 { return "정산 완료! ✨" }
        if balance > 0 {
            return "\(myNickname)이(가) \(DateHelper.formattedAmount(balance)) 더 냄"
        }
        return "\(partnerNickname)이(가) \(DateHelper.formattedAmount(abs(balance))) 더 냄"
    }

    /// 날짜별 그룹핑
    var groupedExpenses: [(date: String, items: [DateExpense])] {
        let grouped = Dictionary(
            grouping: expenses,
            by: { DateHelper.formatted($0.date.dateValue()) }
        )
        return grouped
            .map { (date: $0.key, items: $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Data

    func startListening() {
        let result = repository.listenExpenses(coupleDocId: coupleDocId)
        cancelListener = result.cancel
        Task {
            for await _ in result.stream {
                await loadMonthExpenses()
            }
        }
        Task { await loadMonthExpenses() }
        Task { await loadCourses() }
    }

    func stopListening() {
        cancelListener?()
        cancelListener = nil
    }

    func loadMonthExpenses() async {
        do {
            expenses = try await repository.fetchExpenses(
                coupleDocId: coupleDocId, month: selectedMonth
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadCourses() async {
        do {
            courses = try await repository.fetchCourses(coupleDocId: coupleDocId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(
            byAdding: .month, value: value, to: selectedMonth
        ) {
            selectedMonth = newMonth
            Task { await loadMonthExpenses() }
        }
    }

    // MARK: - CRUD

    func addExpense() async {
        guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "지출 내용을 입력해주세요"
            return
        }
        guard let amount = Int(newAmount), amount > 0 else {
            errorMessage = "올바른 금액을 입력해주세요"
            return
        }
        guard !newPaidBy.isEmpty else {
            errorMessage = "누가 냈는지 선택해주세요"
            return
        }

        isLoading = true
        do {
            let expense = DateExpense(
                title: newTitle.trimmingCharacters(in: .whitespaces),
                amount: amount,
                category: newCategory.rawValue,
                paidBy: newPaidBy,
                date: Timestamp(date: newDate),
                memo: newMemo.isEmpty ? nil : newMemo,
                courseId: newCourseId,
                createdAt: Timestamp(date: Date())
            )
            _ = try await repository.addExpense(expense, coupleDocId: coupleDocId)
            resetForm()
            showAddSheet = false
            await loadMonthExpenses()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteExpense(_ expense: DateExpense) async {
        guard let id = expense.id else { return }
        do {
            try await repository.deleteExpense(id: id, coupleDocId: coupleDocId)
            await loadMonthExpenses()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        newTitle = ""
        newAmount = ""
        newCategory = .food
        newPaidBy = myNickname
        newDate = Date()
        newMemo = ""
        newCourseId = nil
    }
}
