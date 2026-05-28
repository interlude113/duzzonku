import Foundation

protocol LetterRepositoryProtocol {
    func fetchLetters(coupleDocId: String) async throws -> [Letter]
    func addLetter(_ letter: Letter, coupleDocId: String) async throws -> String
    func markAsRead(letterId: String, coupleDocId: String) async throws
    func deleteLetter(id: String, coupleDocId: String) async throws
    func listenLetters(coupleDocId: String) -> (stream: AsyncStream<[Letter]>, cancel: () -> Void)
}
