import Foundation

enum DateHelper {
    private static let calendar = Calendar.current

    /// 사귄 날짜 기준 D+N 계산 (당일 = D+1)
    static func calculateDday(from startDate: Date) -> Int {
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return days + 1 // 사귄 당일이 1일
    }

    /// "N년 M개월 D일" 형식 문자열
    static func detailedDuration(from startDate: Date) -> String {
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.year, .month, .day], from: start, to: today)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        var parts: [String] = []
        if years > 0 { parts.append("\(years)년") }
        if months > 0 { parts.append("\(months)개월") }
        parts.append("\(days)일")
        return parts.joined(separator: " ")
    }

    /// Date → "yyyy.MM.dd" 포맷
    static func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    /// Date → "M월 d일" 포맷
    static func shortFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }

    /// Date → "yyyy년 M월 d일" 포맷
    static func longFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }

    /// 다음 기념일이 가장 가까운 날짜 찾기
    static func nextOccurrence(of date: Date) -> Date {
        let today = calendar.startOfDay(for: Date())
        let thisYear = calendar.component(.year, from: today)
        var components = calendar.dateComponents([.month, .day], from: date)
        components.year = thisYear
        guard let thisYearDate = calendar.date(from: components) else { return date }
        if thisYearDate >= today {
            return thisYearDate
        }
        return calendar.date(byAdding: .year, value: 1, to: thisYearDate) ?? date
    }
}
