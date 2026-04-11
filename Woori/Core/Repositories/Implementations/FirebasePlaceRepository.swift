import Foundation
import FirebaseFirestore

final class FirebasePlaceRepository: PlaceRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    private func collection(coupleId: String) -> CollectionReference {
        db.collection(Collections.couples)
            .document(coupleId)
            .collection(Collections.places)
    }

    func fetchAll(coupleId: String) async throws -> [Place] {
        let snap = try await collection(coupleId: coupleId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: Place.self) }
    }

    func fetchByCategory(coupleId: String, category: PlaceCategory) async throws -> [Place] {
        let snap = try await collection(coupleId: coupleId)
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: Place.self) }
    }

    func add(coupleId: String, place: Place) async throws {
        let ref = collection(coupleId: coupleId).document()
        try ref.setData(from: place)
    }

    func update(coupleId: String, place: Place) async throws {
        guard let id = place.id else { return }
        try collection(coupleId: coupleId).document(id).setData(from: place, merge: true)
    }

    func delete(coupleId: String, placeId: String) async throws {
        try await collection(coupleId: coupleId).document(placeId).delete()
    }

    func listenToPlaces(coupleId: String) -> AsyncStream<[Place]> {
        AsyncStream { continuation in
            listener = collection(coupleId: coupleId)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot, error == nil else {
                        continuation.yield([])
                        return
                    }
                    let items = snapshot.documents.compactMap {
                        try? $0.data(as: Place.self)
                    }
                    continuation.yield(items)
                }
            continuation.onTermination = { [weak self] _ in
                self?.listener?.remove()
            }
        }
    }

    func placeCount(coupleId: String) async throws -> Int {
        let snap = try await collection(coupleId: coupleId).getDocuments()
        return snap.count
    }
}
