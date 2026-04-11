import SwiftUI

struct PhotoGridView: View {
    let photos: [Photo]
    let onTap: (Photo) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: Spacing.xs)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(photos) { photo in
                PhotoCell(photo: photo)
                    .onTapGesture { onTap(photo) }
            }
        }
    }
}

private struct PhotoCell: View {
    let photo: Photo

    var body: some View {
        AsyncImage(url: URL(string: photo.thumbnailUrl)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder
            default:
                Rectangle()
                    .fill(Color.wooriSurfaceWarm)
                    .shimmer()
            }
        }
        .frame(minHeight: 110)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .bottomLeading) {
            if let caption = photo.caption, !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 10))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(4)
            }
        }
        .accessibilityLabel(photo.caption ?? "사진")
    }

    private var placeholder: some View {
        ZStack {
            Color.wooriSurfaceWarm
            Image(systemName: "photo")
                .foregroundStyle(Color.wooriTextMuted)
        }
    }
}
