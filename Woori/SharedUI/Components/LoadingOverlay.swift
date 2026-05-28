import SwiftUI

struct LoadingOverlay: View {
    var message: String = "로딩 중..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.wooriPrimary)

                Text(message)
                    .font(.wooriCaption)
                    .foregroundStyle(.wooriTextSecond)
            }
            .padding(Spacing.lg)
            .background(Color.wooriSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 16)
        }
    }
}
