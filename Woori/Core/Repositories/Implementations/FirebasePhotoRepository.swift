import Foundation
import FirebaseFirestore

final class FirebasePhotoRepository: PhotoRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    private func collection(coupleId: String) -> CollectionReference {
        db.collection(Collections.couples)
            .document(coupleId)
            .collection(Collections.photos)
    }

    func fetchAll(coupleId: String) async throws -> [Photo] {
        let snap = try await collection(coupleId: coupleId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: Photo.self) }
    }

    func fetchByPlace(coupleId: String, placeId: String) async throws -> [Photo] {
        let snap = try await collection(coupleId: coupleId)
            .whereField("placeId", isEqualTo: placeId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: Photo.self) }
    }

    func add(coupleId: String, photo: Photo) async throws {
        let ref = collection(coupleId: coupleId).document()
        try ref.setData(from: photo)
    }

    func delete(coupleId: String, photoId: String) async throws {
        try await collection(coupleId: coupleId).document(photoId).delete()
    }

    func listenToPhotos(coupleId: String) -> AsyncStream<[Photo]> {
        AsyncStream { continuation in
            listener = collection(coupleId: coupleId)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot, error == nil else {
                        continuation.yield([])
                        return
                    }
                    let items = snapshot.documents.compactMap {
                        try? $0.data(as: Photo.self)
                    }
                    continuation.yield(items)
                }
            continuation.onTermination = { [weak self] _ in
                self?.listener?.remove()
            }
        }
    }

    func photoCount(coupleId: String) async throws -> Int {
        let snap = try await collection(coupleId: coupleId).getDocuments()
        return snap.count
    }
}
