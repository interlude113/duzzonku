import Foundation
import FirebaseFirestore

struct Anniversary: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var date: Date
    var isRecurring: Bool
    var emoji: String
    var isPrimary: Bool
    var createdAt: Date

    /// 다음 기념일까지 남은 일수 (isRecurring인 경우 매년 기준)
    var daysUntilNext: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if isRecurring {
            let thisYear = calendar.component(.year, from: today)
            var components = calendar.dateComponents([.month, .day], from: date)
            components.year = thisYear
            guard let thisYearDate = calendar.date(from: components) else { return 0 }
            let target = thisYearDate < today
                ? calendar.date(byAdding: .year, value: 1, to: thisYearDate)!
                : thisYearDate
            return calendar.dateComponents([.day], from: today, to: target).day ?? 0
        } else {
            let targetDay = calendar.startOfDay(for: date)
            return calendar.dateComponents([.day], from: today, to: targetDay).day ?? 0
        }
    }
}
