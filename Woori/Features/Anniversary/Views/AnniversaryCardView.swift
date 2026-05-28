import SwiftUI

struct AnniversaryCardView: View {
    let anniversary: Anniversary
    let daysUntil: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(anniversary.emoji)
                .font(.system(size: 36))
                .accessibilityLabel("이모지")

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.sm) {
                    Text(anniversary.title)
                        .font(.wooriHeadline)
                        .foregroundStyle(.wooriTextPrimary)

                    if anniversary.isPrimary {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.wooriPrimary)
                            .accessibilityLabel("고정된 기념일")
                    }
                }

                Text(DateHelper.formatted(anniversary.date.dateValue()))
                    .font(.wooriCaption)
                    .foregroundStyle(.wooriTextMuted)

                if anniversary.isRecurring {
                    Text("매년 반복")
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriTextSecond)
                }
            }

            Spacer()

            ddayBadge
        }
        .padding(Spacing.md)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }

    private var ddayBadge: some View {
        Text(ddayText)
            .font(.wooriHeadline)
            .foregroundStyle(daysUntil == 0 ? .white : .wooriPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(daysUntil == 0 ? Color.wooriPrimary : Color.wooriPrimaryLight)
            .clipShape(Capsule())
    }

    private var ddayText: String {
        if daysUntil == 0 { return "D-Day!" }
        if daysUntil > 0 { return "D-\(daysUntil)" }
        return "D+\(abs(daysUntil))"
    }
}
