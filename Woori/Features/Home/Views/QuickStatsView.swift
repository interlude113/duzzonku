import SwiftUI

struct QuickStatsView: View {
    let nextAnniversaryDays: Int
    let nextAnniversaryTitle: String?
    let photoCount: Int
    let placeCount: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            StatCard(
                icon: "calendar.badge.clock",
                value: nextAnniversaryDays > 0 ? "D-\(nextAnniversaryDays)" : "-",
                label: nextAnniversaryTitle ?? "다음 기념일"
            )

            StatCard(
                icon: "photo.fill",
                value: "\(photoCount)",
                label: "사진"
            )

            StatCard(
                icon: "mappin.circle.fill",
                value: "\(placeCount)",
                label: "장소"
            )
        }
    }
}

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.wooriPrimary)
                .accessibilityHidden(true)

            Text(value)
                .font(.wooriHeadline)
                .foregroundStyle(Color.wooriTextPrimary)

            Text(label)
                .font(.wooriCaption)
                .foregroundStyle(Color.wooriTextMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .wooriCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value)")
    }
}
