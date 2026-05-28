import Foundation
import FirebaseFirestore

struct Anniversary: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var date: Timestamp
    var isRecurring: Bool
    var emoji: String
    var isPrimary: Bool
    var createdAt: Timestamp
}
