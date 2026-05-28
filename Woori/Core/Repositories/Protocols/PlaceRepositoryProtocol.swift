import Foundation

protocol PlaceRepositoryProtocol {
    func fetchPlaces(coupleDocId: String) async throws -> [Place]
    func addPlace(_ place: Place, coupleDocId: String) async throws -> String
    func updatePlace(_ place: Place, coupleDocId: String) async throws
    func deletePlace(id: String, coupleDocId: String) async throws
    func listenPlaces(coupleDocId: String) -> (stream: AsyncStream<[Place]>, cancel: () -> Void)
}
