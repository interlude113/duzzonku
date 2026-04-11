import Foundation
import FirebaseFirestore

struct Couple: Codable, Identifiable {
    @DocumentID var id: String?
    var coupleName: String
    var startedAt: Date
    var user1Id: String
    var user2Id: String?
    var inviteCode: String
    var todayMessage: String?
    var todayMessageDate: Date?
    var createdAt: Date

    var coupleId: String { id ?? "" }

    enum CodingKeys: String, CodingKey {
        case id
        case coupleName
        case startedAt
        case user1Id
        case user2Id
        case inviteCode
        case todayMessage
        case todayMessageDate
        case createdAt
    }
}
