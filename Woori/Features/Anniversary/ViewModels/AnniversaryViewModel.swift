import Foundation

@MainActor
final class AnniversaryViewModel: ObservableObject {
    @Published var anniversaries: [Anniversary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    private let repo: AnniversaryRepositoryProtocol
    private var listenTask: Task<Void, Never>?

    init(repo: AnniversaryRepositoryProtocol = FirebaseAnniversaryRepository()) {
        self.repo = repo
    }

    var primaryAnniversary: Anniversary? {
        anniversaries.first(where: { $0.isPrimary })
    }

    var otherAnniversaries: [Anniversary] {
        anniversaries.filter { !$0.isPrimary }
            .sorted { $0.daysUntilNext < $1.daysUntilNext }
    }

    func startListening(coupleId: String) {
        listenTask?.cancel()
        listenTask = Task {
            for await items in repo.listenToAnniversaries(coupleId: coupleId) {
                guard !Task.isCancelled else { break }
                self.anniversaries = items
            }
        }
    }

    func add(coupleId: String, title: String, date: Date, emoji: String, isRecurring: Bool) async {
        let anniversary = Anniversary(
            title: title,
            date: date,
            isRecurring: isRecurring,
            emoji: emoji,
            isPrimary: false,
            createdAt: Date()
        )
        do {
            try await repo.add(coupleId: coupleId, anniversary: anniversary)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(coupleId: String, anniversaryId: String) async {
        do {
            try await repo.delete(coupleId: coupleId, anniversaryId: anniversaryId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
