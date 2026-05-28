import Foundation
import FirebaseFirestore

struct DateExpense: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var amount: Int
    var category: String
    var paidBy: String
    var date: Timestamp
    var memo: String?
    var courseId: String?
    var createdAt: Timestamp

    enum Category: String, CaseIterable, Codable {
        case food = "식비"
        case transport = "교통"
        case ticket = "입장료"
        case shopping = "쇼핑"
        case other = "기타"

        var emoji: String {
            switch self {
            case .food: return "🍽"
            case .transport: return "🚗"
            case .ticket: return "🎟"
            case .shopping: return "🛍"
            case .other: return "💰"
            }
        }

        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .transport: return "car.fill"
            case .ticket: return "ticket.fill"
            case .shopping: return "bag.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
}
