import Foundation
import FirebaseFirestore

final class FirebaseLetterRepository: LetterRepositoryProtocol {
    private let service = FirestoreService.shared

    private func collection(coupleDocId: String) -> CollectionReference {
        service.subCollection(coupleDocId: coupleDocId, collection: FirestoreCollection.letters)
    }

    func fetchLetters(coupleDocId: String) async throws -> [Letter] {
        let query = collection(coupleDocId: coupleDocId).order(by: "createdAt", descending: true)
        return try await service.getDocuments(Letter.self, from: query)
    }

    func addLetter(_ letter: Letter, coupleDocId: String) async throws -> String {
        try await service.addDocument(letter, to: collection(coupleDocId: coupleDocId))
    }

    func markAsRead(letterId: String, coupleDocId: String) async throws {
        let ref = collection(coupleDocId: coupleDocId).document(letterId)
        try await service.updateFields(["isRead": true], at: ref)
    }

    func deleteLetter(id: String, coupleDocId: String) async throws {
        let ref = collection(coupleDocId: coupleDocId).document(id)
        try await service.deleteDocument(at: ref)
    }

    func listenLetters(coupleDocId: String) -> (stream: AsyncStream<[Letter]>, cancel: () -> Void) {
        let query = collection(coupleDocId: coupleDocId).order(by: "createdAt", descending: true)
        let result = service.listen(Letter.self, query: query)
        return (result.stream, { result.listener.remove() })
    }
}
