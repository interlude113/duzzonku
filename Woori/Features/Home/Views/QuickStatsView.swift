import SwiftUI

struct QuickStatsView: View {
    let nextAnniversary: Anniversary?
    let monthlyExpense: Int
    let incompleteCourses: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            statCard(
                icon: "calendar.badge.clock",
                title: nextAnniversaryText,
                subtitle: "다음 기념일",
                color: .wooriPrimary
            )

            statCard(
                icon: "wonsign.circle.fill",
                title: DateHelper.formattedAmount(monthlyExpense),
                subtitle: "이달 지출",
                color: .wooriSuccess
            )

            statCard(
                icon: "map.fill",
                title: "\(incompleteCourses)개",
                subtitle: "미완료 코스",
                color: .wooriPrimaryDark
            )
        }
    }

    private var nextAnniversaryText: String {
        guard let anniversary = nextAnniversary else { return "-" }
        let days = DateHelper.daysUntilNext(date: anniversary.date.dateValue(), isRecurring: anniversary.isRecurring)
        if days == 0 { return "D-Day!" }
        return "D-\(days)"
    }

    private func statCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .accessibilityHidden(true)

            Text(title)
                .font(.wooriHeadline)
                .foregroundStyle(.wooriTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(subtitle)
                .font(.wooriCaption)
                .foregroundStyle(.wooriTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}
