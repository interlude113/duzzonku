import SwiftUI

struct PlaceDetailCard: View {
    let place: Place
    let photos: [Photo]
    let onPhotoTap: (String?) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 헤더
            HStack {
                Image(systemName: place.category.icon)
                    .foregroundStyle(Color.wooriPrimary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(place.name)
                        .font(.wooriHeadline)
                        .foregroundStyle(Color.wooriTextPrimary)

                    Text(place.category.rawValue)
                        .font(.wooriCaption)
                        .foregroundStyle(Color.wooriTextMuted)
                }

                Spacer()

                Menu {
                    Button(role: .destructive) { onDelete() } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.wooriTextMuted)
                        .frame(width: 32, height: 32)
                }
            }

            // 메모
            if let memo = place.memo, !memo.isEmpty {
                Text(memo)
                    .font(.wooriBody)
                    .foregroundStyle(Color.wooriTextSecond)
            }

            // 방문일
            if let visitedAt = place.visitedAt {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.wooriCaption)
                        .accessibilityHidden(true)
                    Text(DateHelper.formatted(visitedAt))
                        .font(.wooriCaption)
                }
                .foregroundStyle(Color.wooriTextMuted)
            }

            // 주소
            if let address = place.address, !address.isEmpty {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "location")
                        .font(.wooriCaption)
                        .accessibilityHidden(true)
                    Text(address)
                        .font(.wooriCaption)
                }
                .foregroundStyle(Color.wooriTextMuted)
            }

            // 연결된 사진 썸네일
            if !photos.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("사진")
                        .font(.wooriCaption)
                        .foregroundStyle(Color.wooriTextMuted)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            ForEach(photos) { photo in
                                AsyncImage(url: URL(string: photo.thumbnailUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        Color.wooriSurfaceWarm
                                    }
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    onPhotoTap(place.id)
                                }
                                .accessibilityLabel(photo.caption ?? "사진")
                            }
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .presentationDetents([.medium])
    }
}
