import Foundation

protocol LetterRepositoryProtocol {
    func fetchAll(coupleId: String) async throws -> [Letter]
    func add(coupleId: String, letter: Letter) async throws
    func markAsRead(coupleId: String, letterId: String) async throws
    func delete(coupleId: String, letterId: String) async throws
    func listenToLetters(coupleId: String) -> AsyncStream<[Letter]>
}
