import Foundation
import FirebaseFirestore

struct Couple: Codable, Identifiable {
    @DocumentID var id: String?
    var coupleKey: String
    var startedAt: Timestamp
    var user1Id: String
    var user2Id: String?
    var user1Nickname: String
    var user2Nickname: String?
    var todayMessage: String?
    var todayMessageDate: Timestamp?
    var createdAt: Timestamp
}
