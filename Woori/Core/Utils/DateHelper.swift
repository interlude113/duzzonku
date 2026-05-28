import Foundation

enum DateHelper {
    private static let calendar = Calendar.current

    /// 사귄 날짜로부터 D+N 일수 계산
    static func daysSince(_ date: Date) -> Int {
        let start = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: today)
        return (components.day ?? 0) + 1
    }

    /// N년 M개월 D일 형식 문자열
    static func detailedDuration(from date: Date) -> String {
        let start = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.year, .month, .day], from: start, to: today)

        var parts: [String] = []
        if let year = components.year, year > 0 { parts.append("\(year)년") }
        if let month = components.month, month > 0 { parts.append("\(month)개월") }
        if let day = components.day, day > 0 { parts.append("\(day)일") }

        return parts.isEmpty ? "오늘부터" : parts.joined(separator: " ")
    }

    /// 다음 기념일까지 남은 일수 (isRecurring일 경우 올해/내년 기준)
    static func daysUntilNext(date: Date, isRecurring: Bool) -> Int {
        let today = calendar.startOfDay(for: Date())

        if !isRecurring {
            let target = calendar.startOfDay(for: date)
            let days = calendar.dateComponents([.day], from: today, to: target).day ?? 0
            return days
        }

        // 매년 반복: 올해 날짜 기준
        var components = calendar.dateComponents([.month, .day], from: date)
        components.year = calendar.component(.year, from: today)

        guard let thisYear = calendar.date(from: components) else { return 0 }
        let thisYearStart = calendar.startOfDay(for: thisYear)

        if thisYearStart >= today {
            return calendar.dateComponents([.day], from: today, to: thisYearStart).day ?? 0
        } else {
            components.year = calendar.component(.year, from: today) + 1
            guard let nextYear = calendar.date(from: components) else { return 0 }
            return calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: nextYear)).day ?? 0
        }
    }

    /// 날짜를 "yyyy.MM.dd" 형식으로
    static func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    /// 날짜를 "M월 d일" 형식으로
    static func shortFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    /// 날짜를 "yyyy년 M월" 형식으로
    static func monthFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    /// 금액 포맷 (1000 → "1,000원")
    static func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted)원"
    }

    /// 해당 월의 시작/끝 Date
    static func monthRange(for date: Date) -> (start: Date, end: Date) {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
        return (start, calendar.startOfDay(for: end))
    }
}
