import Foundation
import FirebaseFirestore

final class FirebaseAnniversaryRepository: AnniversaryRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    private func collection(coupleId: String) -> CollectionReference {
        db.collection(Collections.couples)
            .document(coupleId)
            .collection(Collections.anniversaries)
    }

    func fetchAll(coupleId: String) async throws -> [Anniversary] {
        let snap = try await collection(coupleId: coupleId)
            .order(by: "date")
            .getDocuments()
        return try snap.documents.map { try $0.data(as: Anniversary.self) }
    }

    func add(coupleId: String, anniversary: Anniversary) async throws {
        let ref = collection(coupleId: coupleId).document()
        try ref.setData(from: anniversary)
    }

    func update(coupleId: String, anniversary: Anniversary) async throws {
        guard let id = anniversary.id else { return }
        try collection(coupleId: coupleId).document(id).setData(from: anniversary, merge: true)
    }

    func delete(coupleId: String, anniversaryId: String) async throws {
        try await collection(coupleId: coupleId).document(anniversaryId).delete()
    }

    func listenToAnniversaries(coupleId: String) -> AsyncStream<[Anniversary]> {
        AsyncStream { continuation in
            listener = collection(coupleId: coupleId)
                .order(by: "date")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot, error == nil else {
                        continuation.yield([])
                        return
                    }
                    let items = snapshot.documents.compactMap {
                        try? $0.data(as: Anniversary.self)
                    }
                    continuation.yield(items)
                }
            continuation.onTermination = { [weak self] _ in
                self?.listener?.remove()
            }
        }
    }
}
