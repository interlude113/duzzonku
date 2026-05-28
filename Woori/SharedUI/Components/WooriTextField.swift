import SwiftUI

struct WooriTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var icon: String? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(.wooriTextMuted)
                    .frame(width: 20)
            }
            TextField(placeholder, text: $text)
                .font(.wooriBody)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 14)
        .background(Color.wooriSurfaceWarm)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.wooriBorder, lineWidth: 1)
        }
    }
}
