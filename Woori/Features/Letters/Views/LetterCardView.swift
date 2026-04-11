import SwiftUI

struct LetterCardView: View {
    let letter: Letter
    let isFromMe: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(name: isFromMe ? "나" : "상대", size: 40)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(letter.title ?? "제목 없는 편지")
                    .font(.wooriHeadline)
                    .foregroundStyle(Color.wooriTextPrimary)
                    .lineLimit(1)

                Text(DateHelper.formatted(letter.createdAt))
                    .font(.wooriCaption)
                    .foregroundStyle(Color.wooriTextMuted)
            }

            Spacer()

            if !letter.isRead && !isFromMe {
                Circle()
                    .fill(Color.wooriError)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("읽지 않음")
            }
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
