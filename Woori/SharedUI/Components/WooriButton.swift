import SwiftUI

struct WooriButton: View {
    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    let action: () -> Void

    enum Style {
        case primary, secondary, text
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .white : .wooriPrimary)
                } else {
                    Text(title)
                        .font(.wooriHeadline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
        }
        .disabled(isLoading)
    }

    private var background: Color {
        switch style {
        case .primary:   return .wooriPrimary
        case .secondary: return .clear
        case .text:      return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:   return .white
        case .secondary: return .wooriPrimary
        case .text:      return .wooriPrimary
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return .wooriPrimary
        default:         return .clear
        }
    }
}
