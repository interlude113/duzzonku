import SwiftUI

struct WooriCard<Content: View>: View {
    var backgroundColor: Color = .wooriSurface
    var cornerRadius: CGFloat = 16
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(Spacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
