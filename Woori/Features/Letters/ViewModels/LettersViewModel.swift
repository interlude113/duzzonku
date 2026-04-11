import Foundation

@MainActor
final class LettersViewModel: ObservableObject {
    @Published var letters: [Letter] = []
    @Published var filter: LetterFilter = .received
    @Published var isLoading = false
    @Published var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    enum LetterFilter: String, CaseIterable {
        case received = "받은 편지"
        case sent = "보낸 편지"
    }

    private let repo: LetterRepositoryProtocol
    private var listenTask: Task<Void, Never>?

    init(repo: LetterRepositoryProtocol = FirebaseLetterRepository()) {
        self.repo = repo
    }

    var filteredLetters: [Letter] {
        guard let userId else { return [] }
        switch filter {
        case .received: return letters.filter { $0.fromUserId != userId }
        case .sent:     return letters.filter { $0.fromUserId == userId }
        }
    }

    var userId: String?

    func startListening(coupleId: String) {
        listenTask?.cancel()
        listenTask = Task {
            for await items in repo.listenToLetters(coupleId: coupleId) {
                guard !Task.isCancelled else { break }
                self.letters = items
            }
        }
    }

    func sendLetter(coupleId: String, userId: String, partnerId: String, title: String?, content: String) async {
        let letter = Letter(
            fromUserId: userId,
            title: title,
            content: content,
            isRead: false,
            createdAt: Date()
        )
        do {
            try await repo.add(coupleId: coupleId, letter: letter)
            await NotificationService.shared.sendPush(
                to: partnerId,
                title: "새 편지가 도착했어요",
                body: title ?? "상대방이 편지를 보냈어요"
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(coupleId: String, letterId: String) async {
        do {
            try await repo.markAsRead(coupleId: coupleId, letterId: letterId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLetter(coupleId: String, letterId: String) async {
        do {
            try await repo.delete(coupleId: coupleId, letterId: letterId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
