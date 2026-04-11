import Foundation

protocol PhotoRepositoryProtocol {
    func fetchAll(coupleId: String) async throws -> [Photo]
    func fetchByPlace(coupleId: String, placeId: String) async throws -> [Photo]
    func add(coupleId: String, photo: Photo) async throws
    func delete(coupleId: String, photoId: String) async throws
    func listenToPhotos(coupleId: String) -> AsyncStream<[Photo]>
    func photoCount(coupleId: String) async throws -> Int
}
