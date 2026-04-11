import SwiftUI
import MapKit

struct WooriMapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabRouter: TabRouter
    @StateObject private var viewModel = MapViewModel()
    @State private var showAddSheet = false
    @State private var showDetailSheet = false

    var body: some View {
        ZStack {
            // 지도
            Map(position: $viewModel.cameraPosition) {
                ForEach(viewModel.filteredPlaces) { place in
                    Annotation(
                        place.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )
                    ) {
                        PlaceAnnotationView(
                            place: place,
                            isSelected: viewModel.selectedPlace?.id == place.id
                        )
                        .onTapGesture {
                            viewModel.selectedPlace = place
                            showDetailSheet = true
                        }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .ignoresSafeArea(edges: .top)

            // 카테고리 필터
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        FilterChip(
                            title: "전체",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectedCategory = nil
                        }

                        ForEach(PlaceCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                .background(.ultraThinMaterial)

                Spacer()
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
                            .shadow(color: Color.wooriPrimary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(Spacing.lg)
                    .accessibilityLabel("장소 추가")
                }
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            if let place = viewModel.selectedPlace {
                PlaceDetailCard(
                    place: place,
                    photos: viewModel.photosForPlace(place.id),
                    onPhotoTap: { placeId in
                        showDetailSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            tabRouter.selectTab(.gallery, placeId: placeId)
                        }
                    },
                    onDelete: {
                        guard let id = place.id,
                              let coupleId = authViewModel.coupleId else { return }
                        Task {
                            await viewModel.deletePlace(coupleId: coupleId, placeId: id)
                        }
                        showDetailSheet = false
                    }
                )
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPlaceSheet { name, coordinate, category, memo, visitedAt in
                guard let coupleId = authViewModel.coupleId else { return }
                Task {
                    await viewModel.addPlace(
                        coupleId: coupleId,
                        name: name,
                        coordinate: coordinate,
                        category: category,
                        memo: memo,
                        visitedAt: visitedAt
                    )
                }
            }
        }
        .task {
            guard let coupleId = authViewModel.coupleId else { return }
            viewModel.startListening(coupleId: coupleId)
            await viewModel.loadPhotos(coupleId: coupleId)
        }
        .onChange(of: tabRouter.mapFocusPlaceId) { _, placeId in
            if let placeId {
                viewModel.focusOnPlace(placeId: placeId)
                showDetailSheet = true
                tabRouter.mapFocusPlaceId = nil
            }
        }
        .alert("오류", isPresented: $viewModel.hasError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
