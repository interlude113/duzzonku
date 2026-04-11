import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    let places: [Place]
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.dismiss) private var dismiss

    var linkedPlace: Place? {
        guard let placeId = photo.placeId else { return nil }
        return places.first { $0.id == placeId }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // 사진
                AsyncImage(url: URL(string: photo.storageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 정보 영역
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    if let caption = photo.caption, !caption.isEmpty {
                        Text(caption)
                            .font(.wooriBody)
                            .foregroundStyle(.white)
                    }

                    if let takenAt = photo.takenAt {
                        Text(DateHelper.longFormatted(takenAt))
                            .font(.wooriCaption)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    // 연결된 장소 뱃지
                    if let place = linkedPlace {
                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                tabRouter.selectTab(.map, placeId: place.id)
                            }
                        } label: {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "mappin.circle.fill")
                                Text(place.name)
                            }
                            .font(.wooriCaption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .accessibilityLabel("\(place.name) 지도에서 보기")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.md)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(Spacing.md)
            }
            .accessibilityLabel("닫기")
        }
    }
}
