import Foundation
import FirebaseFirestore

final class FirebasePlaceRepository: PlaceRepositoryProtocol {
    private let service = FirestoreService.shared

    private func collection(coupleDocId: String) -> CollectionReference {
        service.subCollection(coupleDocId: coupleDocId, collection: FirestoreCollection.places)
    }

    func fetchPlaces(coupleDocId: String) async throws -> [Place] {
        let query = collection(coupleDocId: coupleDocId).order(by: "createdAt", descending: true)
        return try await service.getDocuments(Place.self, from: query)
    }

    func addPlace(_ place: Place, coupleDocId: String) async throws -> String {
        try await service.addDocument(place, to: collection(coupleDocId: coupleDocId))
    }

    func updatePlace(_ place: Place, coupleDocId: String) async throws {
        guard let id = place.id else { return }
        let ref = collection(coupleDocId: coupleDocId).document(id)
        try await service.setDocument(place, at: ref)
    }

    func deletePlace(id: String, coupleDocId: String) async throws {
        let ref = collection(coupleDocId: coupleDocId).document(id)
        try await service.deleteDocument(at: ref)
    }

    func listenPlaces(coupleDocId: String) -> (stream: AsyncStream<[Place]>, cancel: () -> Void) {
        let query = collection(coupleDocId: coupleDocId).order(by: "createdAt", descending: true)
        let result = service.listen(Place.self, query: query)
        return (result.stream, { result.listener.remove() })
    }
}
