import SwiftUI

struct LetterDetailView: View {
    let letter: Letter
    let onMarkRead: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    if let title = letter.title {
                        Text(title)
                            .font(.wooriTitle)
                            .foregroundStyle(.wooriTextPrimary)
                    }

                    HStack(spacing: Spacing.sm) {
                        AvatarView(nickname: letter.fromNickname, size: 28)

                        Text(letter.fromNickname)
                            .font(.wooriHeadline)
                            .foregroundStyle(.wooriPrimary)

                        Spacer()

                        Text(DateHelper.formatted(letter.createdAt.dateValue()))
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextMuted)
                    }
                }

                Divider()
                    .foregroundStyle(.wooriBorder)

                // Content
                Text(letter.content)
                    .font(.wooriBody)
                    .foregroundStyle(.wooriTextPrimary)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Spacing.lg)
        }
        .background(Color.wooriBackground)
        .navigationTitle("편지")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await onMarkRead()
        }
    }
}
