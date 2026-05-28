import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.wooriTextMuted)
                .accessibilityHidden(true)

            Text(title)
                .font(.wooriHeadline)
                .foregroundStyle(.wooriTextPrimary)

            Text(description)
                .font(.wooriCaption)
                .foregroundStyle(.wooriTextSecond)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity)
    }
}
