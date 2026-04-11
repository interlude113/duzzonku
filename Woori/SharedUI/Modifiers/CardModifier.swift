import SwiftUI

struct CardModifier: ViewModifier {
    var backgroundColor: Color = .wooriSurface
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func wooriCard(
        backgroundColor: Color = .wooriSurface,
        cornerRadius: CGFloat = 16
    ) -> some View {
        modifier(CardModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}
