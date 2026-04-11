import SwiftUI

struct LetterDetailView: View {
    let letter: Letter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.wooriSurfaceWarm.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        if let title = letter.title {
                            Text(title)
                                .font(.wooriTitle)
                                .foregroundStyle(Color.wooriTextPrimary)
                        }

                        Text(DateHelper.longFormatted(letter.createdAt))
                            .font(.wooriCaption)
                            .foregroundStyle(Color.wooriTextMuted)

                        Divider()
                            .background(Color.wooriBorder)

                        Text(letter.content)
                            .font(.wooriBody)
                            .foregroundStyle(Color.wooriTextPrimary)
                            .lineSpacing(6)
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                        .foregroundStyle(Color.wooriTextSecond)
                }
            }
        }
    }
}
