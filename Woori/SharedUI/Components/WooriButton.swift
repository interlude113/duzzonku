import SwiftUI

struct WooriButton: View {
    let title: String
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(style == .outline ? .wooriPrimary : .white)
                }
                Text(title)
                    .font(.wooriHeadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.wooriPrimary, lineWidth: 1.5)
                }
            }
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .wooriPrimary
        case .secondary: return .wooriPrimaryLight
        case .outline: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .wooriPrimaryDark
        case .outline: return .wooriPrimary
        }
    }
}
