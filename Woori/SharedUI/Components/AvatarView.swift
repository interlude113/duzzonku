import SwiftUI

struct AvatarView: View {
    let nickname: String
    var size: CGFloat = 40
    var color: Color = .wooriPrimary

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: size, height: size)

            Text(String(nickname.prefix(1)))
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
        }
        .accessibilityLabel("\(nickname) 프로필")
    }
}
