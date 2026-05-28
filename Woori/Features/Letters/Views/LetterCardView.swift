import SwiftUI

struct LetterCardView: View {
    let letter: Letter
    let isReceived: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.sm) {
                    if isReceived && !letter.isRead {
                        Circle()
                            .fill(Color.wooriError)
                            .frame(width: 8, height: 8)
                            .accessibilityLabel("읽지 않음")
                    }

                    Text(letter.title ?? "제목 없음")
                        .font(.wooriHeadline)
                        .foregroundStyle(.wooriTextPrimary)
                        .lineLimit(1)
                }

                Text(letter.content)
                    .font(.wooriBody)
                    .foregroundStyle(.wooriTextSecond)
                    .lineLimit(2)

                HStack(spacing: Spacing.sm) {
                    Text(letter.fromNickname)
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriPrimary)

                    Text(DateHelper.shortFormatted(letter.createdAt.dateValue()))
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriTextMuted)
                }
            }

            Spacer()

            Image(systemName: isReceived ? "envelope.fill" : "paperplane.fill")
                .font(.title3)
                .foregroundStyle(.wooriPrimaryLight)
                .accessibilityHidden(true)
        }
        .padding(Spacing.md)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}
