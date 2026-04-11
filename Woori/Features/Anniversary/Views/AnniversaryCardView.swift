import SwiftUI

struct AnniversaryCardView: View {
    let anniversary: Anniversary

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(anniversary.emoji)
                .font(.title)
                .frame(width: 44, height: 44)
                .background(Color.wooriSurfaceWarm)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(anniversary.title)
                    .font(.wooriHeadline)
                    .foregroundStyle(Color.wooriTextPrimary)

                HStack(spacing: Spacing.xs) {
                    Text(DateHelper.formatted(anniversary.date))
                        .font(.wooriCaption)
                        .foregroundStyle(Color.wooriTextMuted)

                    if anniversary.isRecurring {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.wooriTextMuted)
                            .accessibilityLabel("매년 반복")
                    }
                }
            }

            Spacer()

            CountdownBadge(days: anniversary.daysUntilNext)
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}

private struct CountdownBadge: View {
    let days: Int

    var body: some View {
        Text(days == 0 ? "TODAY" : "D-\(days)")
            .font(.wooriCaption)
            .fontWeight(.semibold)
            .foregroundStyle(days == 0 ? .white : Color.wooriPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(days == 0 ? Color.wooriPrimary : Color.wooriPrimaryLight)
            .clipShape(Capsule())
    }
}
