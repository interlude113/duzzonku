import SwiftUI
import FirebaseFirestore

@MainActor
final class AnniversaryViewModel: ObservableObject {
    @Published var anniversaries: [Anniversary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddSheet = false

    // Add form
    @Published var newTitle = ""
    @Published var newDate = Date()
    @Published var newEmoji = "🎉"
    @Published var newIsRecurring = true

    private let repository = FirebaseAnniversaryRepository()
    private let session = CoupleSession.shared
    private var cancelListener: (() -> Void)?

    var coupleDocId: String { session.coupleDocId }

    var sortedAnniversaries: [Anniversary] {
        let primary = anniversaries.filter { $0.isPrimary }
        let others = anniversaries.filter { !$0.isPrimary }
            .sorted {
                DateHelper.daysUntilNext(date: $0.date.dateValue(), isRecurring: $0.isRecurring)
                < DateHelper.daysUntilNext(date: $1.date.dateValue(), isRecurring: $1.isRecurring)
            }
        return primary + others
    }

    func startListening() {
        let result = repository.listenAnniversaries(coupleDocId: coupleDocId)
        cancelListener = result.cancel
        Task {
            for await items in result.stream {
                self.anniversaries = items
            }
        }
    }

    func stopListening() {
        cancelListener?()
        cancelListener = nil
    }

    func addAnniversary() async {
        guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "제목을 입력해주세요"
            return
        }

        isLoading = true
        do {
            let anniversary = Anniversary(
                title: newTitle.trimmingCharacters(in: .whitespaces),
                date: Timestamp(date: newDate),
                isRecurring: newIsRecurring,
                emoji: newEmoji,
                isPrimary: false,
                createdAt: Timestamp(date: Date())
            )
            _ = try await repository.addAnniversary(anniversary, coupleDocId: coupleDocId)

            // Schedule notification
            NotificationService.shared.scheduleAnniversaryReminder(
                id: UUID().uuidString,
                title: newTitle,
                date: newDate
            )

            resetForm()
            showAddSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteAnniversary(_ anniversary: Anniversary) async {
        guard let id = anniversary.id, !anniversary.isPrimary else { return }
        do {
            try await repository.deleteAnniversary(id: id, coupleDocId: coupleDocId)
            NotificationService.shared.cancelNotification(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        newTitle = ""
        newDate = Date()
        newEmoji = "🎉"
        newIsRecurring = true
    }

    func daysUntil(_ anniversary: Anniversary) -> Int {
        DateHelper.daysUntilNext(date: anniversary.date.dateValue(), isRecurring: anniversary.isRecurring)
    }
}
