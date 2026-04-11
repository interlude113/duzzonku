import Foundation

protocol PlaceRepositoryProtocol {
    func fetchAll(coupleId: String) async throws -> [Place]
    func fetchByCategory(coupleId: String, category: PlaceCategory) async throws -> [Place]
    func add(coupleId: String, place: Place) async throws
    func update(coupleId: String, place: Place) async throws
    func delete(coupleId: String, placeId: String) async throws
    func listenToPlaces(coupleId: String) -> AsyncStream<[Place]>
    func placeCount(coupleId: String) async throws -> Int
}
