import Foundation
import FirebaseFirestore

struct Place: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var category: String
    var memo: String?
    var visitedAt: Timestamp?
    var createdAt: Timestamp

    enum Category: String, CaseIterable, Codable {
        case cafe = "카페"
        case restaurant = "식당"
        case travel = "여행지"
        case other = "기타"

        var icon: String {
            switch self {
            case .cafe: return "cup.and.saucer.fill"
            case .restaurant: return "fork.knife"
            case .travel: return "airplane"
            case .other: return "mappin"
            }
        }
    }
}
