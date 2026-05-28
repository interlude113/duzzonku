import Foundation
import FirebaseFirestore

struct DateCourse: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var date: Timestamp?
    var memo: String?
    var isCompleted: Bool
    var createdAt: Timestamp
}
