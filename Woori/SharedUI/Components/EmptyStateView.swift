import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.wooriTextMuted)
                .accessibilityHidden(true)

            Text(title)
                .font(.wooriHeadline)
                .foregroundStyle(Color.wooriTextPrimary)

            Text(description)
                .font(.wooriCaption)
                .foregroundStyle(Color.wooriTextMuted)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }
}
