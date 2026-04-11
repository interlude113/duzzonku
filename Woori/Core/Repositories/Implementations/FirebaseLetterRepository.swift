import Foundation
import FirebaseFirestore

final class FirebaseLetterRepository: LetterRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    private func collection(coupleId: String) -> CollectionReference {
        db.collection(Collections.couples)
            .document(coupleId)
            .collection(Collections.letters)
    }

    func fetchAll(coupleId: String) async throws -> [Letter] {
        let snap = try await collection(coupleId: coupleId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: Letter.self) }
    }

    func add(coupleId: String, letter: Letter) async throws {
        let ref = collection(coupleId: coupleId).document()
        try ref.setData(from: letter)
    }

    func markAsRead(coupleId: String, letterId: String) async throws {
        try await collection(coupleId: coupleId).document(letterId).updateData([
            "isRead": true
        ])
    }

    func delete(coupleId: String, letterId: String) async throws {
        try await collection(coupleId: coupleId).document(letterId).delete()
    }

    func listenToLetters(coupleId: String) -> AsyncStream<[Letter]> {
        AsyncStream { continuation in
            listener = collection(coupleId: coupleId)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot, error == nil else {
                        continuation.yield([])
                        return
                    }
                    let items = snapshot.documents.compactMap {
                        try? $0.data(as: Letter.self)
                    }
                    continuation.yield(items)
                }
            continuation.onTermination = { [weak self] _ in
                self?.listener?.remove()
            }
        }
    }
}
