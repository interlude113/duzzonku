import Foundation
import FirebaseFirestore

struct Photo: Codable, Identifiable {
    @DocumentID var id: String?
    var uploadedBy: String
    var storageUrl: String
    var thumbnailUrl: String
    var caption: String?
    var takenAt: Date?
    var placeId: String?
    var createdAt: Date
}
