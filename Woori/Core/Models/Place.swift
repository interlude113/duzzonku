import Foundation
import FirebaseFirestore

enum PlaceCategory: String, Codable, CaseIterable {
    case cafe = "카페"
    case restaurant = "식당"
    case travel = "여행지"
    case etc = "기타"

    var icon: String {
        switch self {
        case .cafe:       return "cup.and.saucer.fill"
        case .restaurant: return "fork.knife"
        case .travel:     return "airplane"
        case .etc:        return "mappin"
        }
    }
}

struct Place: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var category: PlaceCategory
    var memo: String?
    var visitedAt: Date?
    var createdAt: Date
}
