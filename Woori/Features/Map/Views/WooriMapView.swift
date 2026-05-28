import SwiftUI
import MapKit

struct WooriMapView: View {
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject private var tabRouter: TabRouter

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                mapContent
                filterPicker
                fabButton
            }
            .navigationTitle("우리 지도")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showPlaceDetail) {
                PlaceDetailCard(
                    place: viewModel.selectedPlace,
                    coursePlace: viewModel.selectedCoursePlace,
                    courseName: viewModel.selectedCourseName,
                    onDelete: viewModel.selectedPlace != nil ? {
                        if let place = viewModel.selectedPlace {
                            await viewModel.deletePlace(place)
                        }
                    } : nil
                )
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddPlaceSheet(viewModel: viewModel)
            }
            .alert("오류", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .onChange(of: tabRouter.mapFocusPlaceId) { _, newId in
            if let id = newId {
                viewModel.focusOnPlace(id: id)
                tabRouter.mapFocusPlaceId = nil
            }
        }
    }

    // MARK: - Map

    private var mapContent: some View {
        Map(position: $viewModel.cameraPosition) {
            // Normal places
            if viewModel.filter != .courses {
                ForEach(viewModel.places) { place in
                    Annotation(
                        place.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )
                    ) {
                        PlaceAnnotationView(
                            category: place.category,
                            color: viewModel.categoryColor(place.category)
                        )
                        .onTapGesture {
                            viewModel.selectedPlace = place
                            viewModel.selectedCoursePlace = nil
                            viewModel.selectedCourseName = nil
                            viewModel.showPlaceDetail = true
                        }
                    }
                }
            }

            // Course places
            if viewModel.filter != .places {
                ForEach(viewModel.coursePlaces, id: \.course.id) { courseData in
                    ForEach(courseData.places) { coursePlace in
                        Annotation(
                            coursePlace.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: coursePlace.latitude,
                                longitude: coursePlace.longitude
                            )
                        ) {
                            CourseAnnotationView(order: coursePlace.order)
                                .onTapGesture {
                                    viewModel.selectedCoursePlace = coursePlace
                                    viewModel.selectedCourseName = courseData.course.title
                                    viewModel.selectedPlace = nil
                                    viewModel.showPlaceDetail = true
                                }
                        }
                    }

                    // Polyline
                    if courseData.places.count > 1 {
                        let coords = courseData.places
                            .sorted { $0.order < $1.order }
                            .map {
                                CLLocationCoordinate2D(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude
                                )
                            }
                        MapPolyline(coordinates: coords)
                            .stroke(.wooriPrimary.opacity(0.6), lineWidth: 2)
                    }
                }
            }
        }
        .mapStyle(.standard)
    }

    // MARK: - Filter

    private var filterPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(MapViewModel.MapFilter.allCases, id: \.self) { opt in
                Button {
                    withAnimation { viewModel.filter = opt }
                } label: {
                    Text(opt.rawValue)
                        .font(.wooriCaption)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            viewModel.filter == opt
                                ? Color.wooriPrimary : Color.wooriSurface
                        )
                        .foregroundStyle(
                            viewModel.filter == opt
                                ? .white : .wooriTextSecond
                        )
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 2)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    // MARK: - FAB

    private var fabButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.resetForm()
                    viewModel.showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.wooriPrimary)
                        .clipShape(Circle())
                        .shadow(color: .wooriPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("장소 추가")
                .padding(Spacing.lg)
            }
        }
    }
}
