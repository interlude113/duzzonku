import SwiftUI
import MapKit

struct AddCourseSheet: View {
    @ObservedObject var viewModel: CourseViewModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var mapService = MapService.shared
    @State private var savedPlaces: [Place] = []
    @State private var showSavedPlacePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Title
                    WooriTextField(
                        placeholder: "코스 이름 (예: 성수 데이트)",
                        text: $viewModel.newTitle,
                        icon: "map"
                    )

                    // Date toggle
                    Toggle(isOn: $viewModel.newHasDate) {
                        Text("날짜 지정")
                            .font(.wooriBody)
                    }
                    .tint(.wooriPrimary)

                    if viewModel.newHasDate {
                        DatePicker(
                            "날짜",
                            selection: $viewModel.newDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .tint(.wooriPrimary)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                    }

                    // Places section
                    placesSection

                    // Memo
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("메모")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)
                        TextEditor(text: $viewModel.newMemo)
                            .font(.wooriBody)
                            .frame(minHeight: 80)
                            .padding(Spacing.sm)
                            .scrollContentBackground(.hidden)
                            .background(Color.wooriSurfaceWarm)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.wooriBorder, lineWidth: 1)
                            }
                    }

                    WooriButton(title: "코스 만들기", isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.addCourse()
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.wooriBackground)
            .navigationTitle("코스 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.wooriTextSecond)
                }
            }
            .sheet(isPresented: $showSavedPlacePicker) {
                savedPlacePickerSheet
            }
        }
        .task {
            savedPlaces = await viewModel.fetchSavedPlaces()
        }
    }

    // MARK: - Places Section

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("장소 (\(viewModel.newPlaces.count))")
                    .font(.wooriHeadline)
                    .foregroundStyle(.wooriTextPrimary)
                Spacer()
            }

            // Search bar
            HStack {
                WooriTextField(
                    placeholder: "장소 검색",
                    text: $viewModel.searchQuery,
                    icon: "magnifyingglass"
                )
                Button {
                    Task { await mapService.search(query: viewModel.searchQuery) }
                } label: {
                    Text("검색")
                        .font(.wooriCaption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, 14)
                        .background(Color.wooriPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Search results
            if !mapService.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(
                        mapService.searchResults.prefix(5),
                        id: \.self
                    ) { item in
                        Button {
                            let wrapper = MKMapItemWrapper(
                                name: item.name ?? "",
                                address: item.placemark.title,
                                latitude: item.placemark.coordinate.latitude,
                                longitude: item.placemark.coordinate.longitude
                            )
                            viewModel.addSearchResultPlace(wrapper)
                            mapService.clearResults()
                            viewModel.searchQuery = ""
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "")
                                        .font(.wooriBody)
                                        .foregroundStyle(.wooriTextPrimary)
                                    Text(item.placemark.title ?? "")
                                        .font(.wooriCaption)
                                        .foregroundStyle(.wooriTextMuted)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.wooriPrimary)
                                    .accessibilityLabel("추가")
                            }
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.md)
                        }
                        Divider()
                    }
                }
                .background(Color.wooriSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.wooriBorder, lineWidth: 1)
                }
            }

            // Import from saved places
            Button {
                showSavedPlacePicker = true
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "bookmark.fill")
                        .accessibilityHidden(true)
                    Text("우리 지도에서 불러오기")
                        .font(.wooriCaption)
                }
                .foregroundStyle(.wooriPrimary)
            }

            // Added places list (draggable)
            if !viewModel.newPlaces.isEmpty {
                List {
                    ForEach(viewModel.newPlaces) { place in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.wooriTextMuted)
                                .accessibilityLabel("드래그하여 순서 변경")
                            Text("\(place.order).")
                                .font(.wooriCaption)
                                .foregroundStyle(.wooriPrimary)
                            Text(place.name)
                                .font(.wooriBody)
                                .foregroundStyle(.wooriTextPrimary)
                            Spacer()
                            Text(place.category)
                                .font(.wooriCaption)
                                .foregroundStyle(.wooriTextMuted)
                        }
                        .listRowBackground(Color.wooriSurface)
                    }
                    .onMove { from, to in
                        viewModel.movePlaces(from: from, to: to)
                    }
                    .onDelete { offsets in
                        viewModel.removePlaceFromForm(at: offsets)
                    }
                }
                .listStyle(.plain)
                .frame(height: CGFloat(viewModel.newPlaces.count) * 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Saved Place Picker

    private var savedPlacePickerSheet: some View {
        NavigationStack {
            List(savedPlaces) { place in
                Button {
                    viewModel.addFromSavedPlace(place)
                    showSavedPlacePicker = false
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.name)
                                .font(.wooriBody)
                                .foregroundStyle(.wooriTextPrimary)
                            if let addr = place.address {
                                Text(addr)
                                    .font(.wooriCaption)
                                    .foregroundStyle(.wooriTextMuted)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Text(place.category)
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriPrimary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("우리 장소")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { showSavedPlacePicker = false }
                        .foregroundStyle(.wooriTextSecond)
                }
            }
        }
    }
}
