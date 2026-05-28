import SwiftUI
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var couple: Couple?
    @Published var todayMessage: String = ""
    @Published var isEditingMessage = false
    @Published var nextAnniversary: Anniversary?
    @Published var monthlyExpenseTotal: Int = 0
    @Published var incompleteCourseCount: Int = 0
    @Published var errorMessage: String?
    @Published var daysCount: Int = 0
    @Published var detailedDuration: String = ""

    private let firestoreService = FirestoreService.shared
    private let session = CoupleSession.shared
    private var coupleListener: ListenerRegistration?

    var myNickname: String { session.myNickname }
    var partnerNickname: String { session.partnerNickname }
    var coupleDocId: String { session.coupleDocId }

    func loadData() async {
        await loadCouple()
        await loadNextAnniversary()
        await loadMonthlyExpense()
        await loadIncompleteCourses()
    }

    func startListening() {
        let ref = firestoreService.coupleDocument(coupleDocId: coupleDocId)
        coupleListener = ref.addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let snapshot, let couple = try? snapshot.data(as: Couple.self) else { return }
            Task { @MainActor in
                self.couple = couple
                self.todayMessage = couple.todayMessage ?? ""
                self.updateDday(startedAt: couple.startedAt.dateValue())
                // Update partner nickname if available
                if let uid = AuthService.shared.uid {
                    if couple.user1Id == uid {
                        if let partnerNick = couple.user2Nickname {
                            CoupleSession.shared.savePartnerNickname(partnerNick)
                        }
                    } else {
                        CoupleSession.shared.savePartnerNickname(couple.user1Nickname)
                    }
                }
            }
        }
    }

    func stopListening() {
        coupleListener?.remove()
        coupleListener = nil
    }

    private func loadCouple() async {
        do {
            let ref = firestoreService.coupleDocument(coupleDocId: coupleDocId)
            couple = try await firestoreService.getDocument(Couple.self, from: ref)
            if let couple {
                todayMessage = couple.todayMessage ?? ""
                updateDday(startedAt: couple.startedAt.dateValue())
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateDday(startedAt: Date) {
        daysCount = DateHelper.daysSince(startedAt)
        detailedDuration = DateHelper.detailedDuration(from: startedAt)
    }

    func refreshDday() {
        guard let couple else { return }
        updateDday(startedAt: couple.startedAt.dateValue())
    }

    func saveTodayMessage() async {
        do {
            let ref = firestoreService.coupleDocument(coupleDocId: coupleDocId)
            try await firestoreService.updateFields([
                "todayMessage": todayMessage,
                "todayMessageDate": Timestamp(date: Date())
            ], at: ref)
            isEditingMessage = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadNextAnniversary() async {
        do {
            let repo = FirebaseAnniversaryRepository()
            let all = try await repo.fetchAnniversaries(coupleDocId: coupleDocId)
            nextAnniversary = all
                .filter { DateHelper.daysUntilNext(date: $0.date.dateValue(), isRecurring: $0.isRecurring) >= 0 }
                .min { DateHelper.daysUntilNext(date: $0.date.dateValue(), isRecurring: $0.isRecurring) < DateHelper.daysUntilNext(date: $1.date.dateValue(), isRecurring: $1.isRecurring) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadMonthlyExpense() async {
        do {
            let repo = FirebaseDateRepository()
            let expenses = try await repo.fetchExpenses(coupleDocId: coupleDocId, month: Date())
            monthlyExpenseTotal = expenses.reduce(0) { $0 + $1.amount }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadIncompleteCourses() async {
        do {
            let repo = FirebaseDateRepository()
            let courses = try await repo.fetchCourses(coupleDocId: coupleDocId)
            incompleteCourseCount = courses.filter { !$0.isCompleted }.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
