import SwiftUI

struct LoadingOverlay: View {
    var message: String = "로딩 중..."

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.wooriPrimary)
                Text(message)
                    .font(.wooriCaption)
                    .foregroundStyle(Color.wooriTextMuted)
            }
        }
    }
}
