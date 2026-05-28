import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class LettersViewModel: ObservableObject {
    enum LetterFilter: String, CaseIterable {
        case received = "받은 편지"
        case sent = "보낸 편지"
    }

    @Published var letters: [Letter] = []
    @Published var filter: LetterFilter = .received
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showWriteSheet = false

    // Write form
    @Published var newTitle = ""
    @Published var newContent = ""

    private let repository = FirebaseLetterRepository()
    private let session = CoupleSession.shared
    private var cancelListener: (() -> Void)?

    var coupleDocId: String { session.coupleDocId }
    var myUid: String { AuthService.shared.uid ?? "" }

    var filteredLetters: [Letter] {
        switch filter {
        case .received:
            return letters.filter { $0.fromUserId != myUid }
        case .sent:
            return letters.filter { $0.fromUserId == myUid }
        }
    }

    var unreadCount: Int {
        letters.filter { $0.fromUserId != myUid && !$0.isRead }.count
    }

    func startListening() {
        let result = repository.listenLetters(coupleDocId: coupleDocId)
        cancelListener = result.cancel
        Task {
            for await items in result.stream {
                self.letters = items
            }
        }
    }

    func stopListening() {
        cancelListener?()
        cancelListener = nil
    }

    func sendLetter() async {
        guard !newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "편지 내용을 입력해주세요"
            return
        }

        isLoading = true
        do {
            let letter = Letter(
                fromUserId: myUid,
                fromNickname: session.myNickname,
                title: newTitle.trimmingCharacters(in: .whitespaces).isEmpty ? nil : newTitle.trimmingCharacters(in: .whitespaces),
                content: newContent.trimmingCharacters(in: .whitespacesAndNewlines),
                isRead: false,
                createdAt: Timestamp(date: Date())
            )
            _ = try await repository.addLetter(letter, coupleDocId: coupleDocId)

            NotificationService.shared.sendLetterNotification(from: session.myNickname)

            resetForm()
            showWriteSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markAsRead(_ letter: Letter) async {
        guard let id = letter.id, !letter.isRead, letter.fromUserId != myUid else { return }
        do {
            try await repository.markAsRead(letterId: id, coupleDocId: coupleDocId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLetter(_ letter: Letter) async {
        guard let id = letter.id else { return }
        do {
            try await repository.deleteLetter(id: id, coupleDocId: coupleDocId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        newTitle = ""
        newContent = ""
    }
}
