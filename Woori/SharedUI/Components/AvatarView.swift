import SwiftUI

struct AvatarView: View {
    var imageUrl: String?
    var name: String
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let url = imageUrl, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel("\(name)의 프로필 사진")
    }

    private var placeholder: some View {
        ZStack {
            Circle()
                .fill(Color.wooriPrimaryLight)
            Text(String(name.prefix(1)))
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.wooriPrimaryDark)
        }
    }
}
