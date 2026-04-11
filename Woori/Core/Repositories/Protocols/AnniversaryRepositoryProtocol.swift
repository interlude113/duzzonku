import Foundation

protocol AnniversaryRepositoryProtocol {
    func fetchAll(coupleId: String) async throws -> [Anniversary]
    func add(coupleId: String, anniversary: Anniversary) async throws
    func update(coupleId: String, anniversary: Anniversary) async throws
    func delete(coupleId: String, anniversaryId: String) async throws
    func listenToAnniversaries(coupleId: String) -> AsyncStream<[Anniversary]>
}
