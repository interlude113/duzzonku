import SwiftUI

struct WooriTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .font(.wooriBody)
        .padding(Spacing.md)
        .background(Color.wooriSurfaceWarm)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.wooriBorder, lineWidth: 1)
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}
