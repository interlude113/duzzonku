import Foundation
import FirebaseFirestore

struct Letter: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUserId: String
    var title: String?
    var content: String
    var isRead: Bool
    var createdAt: Date
}
