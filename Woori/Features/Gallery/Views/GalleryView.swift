import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabRouter: TabRouter
    @StateObject private var viewModel = GalleryViewModel()
    @State private var showAddSheet = false
    @State private var selectedPhoto: Photo?

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // 필터 바
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        FilterChip(
                            title: "전체",
                            isSelected: viewModel.selectedPlaceId == nil
                        ) {
                            viewModel.filterByPlace(nil)
                        }

                        ForEach(viewModel.places) { place in
                            FilterChip(
                                title: place.name,
                                isSelected: viewModel.selectedPlaceId == place.id
                            ) {
                                viewModel.filterByPlace(place.id)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }

                // 사진 그리드
                if viewModel.filteredPhotos.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "photo.on.rectangle",
                        title: "사진이 없어요",
                        description: "소중한 순간을 기록해보세요"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        PhotoGridView(photos: viewModel.filteredPhotos) { photo in
                            selectedPhoto = photo
                        }
                        .padding(Spacing.sm)
                    }
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.wooriPrimary)
                            .clipShape(Circle())
                    }
                    .padding(Spacing.lg)
                    .accessibilityLabel("사진 추가")
                }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("업로드 중...")
                    .tint(.wooriPrimary)
                    .padding(Spacing.lg)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo, places: viewModel.places)
        }
        .sheet(isPresented: $showAddSheet) {
            AddPhotoSheet(places: viewModel.places) { image, caption, placeId in
                guard let coupleId = authViewModel.coupleId,
                      let userId = authViewModel.userId else { return }
                Task {
                    await viewModel.uploadPhoto(
                        coupleId: coupleId,
                        userId: userId,
                        image: image,
                        caption: caption,
                        placeId: placeId
                    )
                }
            }
        }
        .task {
            guard let coupleId = authViewModel.coupleId else { return }
            viewModel.startListening(coupleId: coupleId)
            await viewModel.loadPlaces(coupleId: coupleId)
        }
        .onChange(of: tabRouter.galleryFilterPlaceId) { _, placeId in
            viewModel.filterByPlace(placeId)
            tabRouter.galleryFilterPlaceId = nil
        }
        .alert("오류", isPresented: $viewModel.hasError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.wooriCaption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : Color.wooriTextSecond)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.wooriPrimary : Color.wooriSurface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.wooriBorder, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}
