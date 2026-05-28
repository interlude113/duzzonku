import SwiftUI

struct CardModifier: ViewModifier {
    var padding: CGFloat = Spacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.wooriSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func wooriCard(padding: CGFloat = Spacing.md) -> some View {
        modifier(CardModifier(padding: padding))
    }
}
