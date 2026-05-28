import Foundation
import FirebaseFirestore

struct CoursePlace: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var category: String
    var order: Int
    var isVisited: Bool
    var linkedPlaceId: String?
    var createdAt: Timestamp
}
