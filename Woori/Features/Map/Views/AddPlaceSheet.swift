import SwiftUI
import MapKit

struct AddPlaceSheet: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    searchSection
                    WooriTextField(placeholder: "장소 이름", text: $viewModel.newName, icon: "mappin")
                    WooriTextField(placeholder: "주소 (자동입력)", text: $viewModel.newAddress, icon: "location")
                    categorySection
                    mapPreview
                    WooriTextField(placeholder: "메모 (선택)", text: $viewModel.newMemo, icon: "note.text")

                    WooriButton(title: "장소 저장", isLoading: viewModel.isLoading) {
                        Task { await viewModel.addPlace() }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.wooriBackground)
            .navigationTitle("장소 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.wooriTextSecond)
                }
            }
        }
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("장소 검색")
                .font(.wooriCaption)
                .foregroundStyle(.wooriTextSecond)

            HStack {
                WooriTextField(
                    placeholder: "장소를 검색하세요",
                    text: $viewModel.searchQuery,
                    icon: "magnifyingglass"
                )
                Button {
                    Task { await viewModel.searchPlaces() }
                } label: {
                    Text("검색")
                        .font(.wooriHeadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, 14)
                        .background(Color.wooriPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            if !viewModel.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(viewModel.searchResults, id: \.self) { item in
                        Button {
                            viewModel.selectSearchResult(item)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name ?? "")
                                    .font(.wooriBody)
                                    .foregroundStyle(.wooriTextPrimary)
                                Text(item.placemark.title ?? "")
                                    .font(.wooriCaption)
                                    .foregroundStyle(.wooriTextMuted)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
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
        }
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("카테고리")
                .font(.wooriCaption)
                .foregroundStyle(.wooriTextSecond)

            HStack(spacing: Spacing.sm) {
                ForEach(Place.Category.allCases, id: \.self) { category in
                    Button {
                        viewModel.newCategory = category
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: category.icon)
                                .accessibilityHidden(true)
                            Text(category.rawValue)
                                .font(.wooriCaption)
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            viewModel.newCategory == category
                                ? Color.wooriPrimary : Color.wooriSurfaceWarm
                        )
                        .foregroundStyle(
                            viewModel.newCategory == category
                                ? .white : .wooriTextSecond
                        )
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Map Preview

    private var mapPreview: some View {
        Map(position: .constant(.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: viewModel.newLatitude,
                longitude: viewModel.newLongitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))) {
            Marker(
                viewModel.newName.isEmpty ? "선택된 위치" : viewModel.newName,
                coordinate: CLLocationCoordinate2D(
                    latitude: viewModel.newLatitude,
                    longitude: viewModel.newLongitude
                )
            )
            .tint(.wooriPrimary)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
