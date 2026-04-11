import Foundation

protocol CoupleRepositoryProtocol {
    func createCouple(_ couple: Couple) async throws -> String
    func fetchCouple(for userId: String) async throws -> Couple?
    func fetchCoupleById(_ coupleId: String) async throws -> Couple?
    func joinCouple(inviteCode: String, userId: String) async throws -> Couple
    func updateTodayMessage(coupleId: String, message: String) async throws
    func listenToCouple(coupleId: String) -> AsyncStream<Couple?>
}
