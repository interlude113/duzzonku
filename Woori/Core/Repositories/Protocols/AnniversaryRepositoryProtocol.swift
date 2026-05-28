import Foundation

protocol AnniversaryRepositoryProtocol {
    func fetchAnniversaries(coupleDocId: String) async throws -> [Anniversary]
    func addAnniversary(_ anniversary: Anniversary, coupleDocId: String) async throws -> String
    func deleteAnniversary(id: String, coupleDocId: String) async throws
    func listenAnniversaries(coupleDocId: String) -> (stream: AsyncStream<[Anniversary]>, cancel: () -> Void)
}
