import SwiftUI
import MapKit

struct AddPlaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: PlaceCategory = .cafe
    @State private var memo = ""
    @State private var visitedAt = Date()
    @State private var hasVisitDate = false
    @State private var searchQuery = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchResults: [MKMapItem] = []
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.978),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    private let mapService = MapService()
    let onSave: (String, CLLocationCoordinate2D, PlaceCategory, String?, Date?) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.wooriBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        // 지도에서 위치 선택
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("위치 선택")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextSecond)

                            // 검색
                            HStack {
                                TextField("주소 검색", text: $searchQuery)
                                    .font(.wooriBody)
                                    .textFieldStyle(.plain)

                                Button {
                                    Task { await search() }
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(Color.wooriPrimary)
                                }
                            }
                            .padding(Spacing.sm)
                            .background(Color.wooriSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            // 검색 결과
                            if !searchResults.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(searchResults, id: \.self) { item in
                                        Button {
                                            selectMapItem(item)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name ?? "")
                                                    .font(.wooriBody)
                                                    .foregroundStyle(Color.wooriTextPrimary)
                                                Text(item.placemark.title ?? "")
                                                    .font(.wooriCaption)
                                                    .foregroundStyle(Color.wooriTextMuted)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, Spacing.sm)
                                        }
                                        Divider()
                                    }
                                }
                                .padding(.horizontal, Spacing.sm)
                            }

                            // 미니 맵
                            Map(position: $cameraPosition) {
                                if let coord = selectedCoordinate {
                                    Marker(name, coordinate: coord)
                                        .tint(.wooriPrimary)
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture { location in
                                // 맵 탭으로 핀 설정 (MapReader 활용 가능)
                            }
                        }
                        .wooriCard()

                        WooriTextField(placeholder: "장소 이름", text: $name)

                        // 카테고리
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("카테고리")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextSecond)

                            Picker("카테고리", selection: $category) {
                                ForEach(PlaceCategory.allCases, id: \.self) { cat in
                                    Label(cat.rawValue, systemImage: cat.icon)
                                        .tag(cat)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .wooriCard()

                        // 메모
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("메모 (선택)")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextSecond)

                            TextEditor(text: $memo)
                                .font(.wooriBody)
                                .frame(minHeight: 80)
                                .scrollContentBackground(.hidden)
                                .padding(Spacing.sm)
                                .background(Color.wooriBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .wooriCard()

                        // 방문일
                        Toggle(isOn: $hasVisitDate) {
                            Text("방문일 기록")
                                .font(.wooriHeadline)
                        }
                        .tint(.wooriPrimary)
                        .wooriCard()

                        if hasVisitDate {
                            DatePicker("방문일", selection: $visitedAt, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.wooriPrimary)
                                .wooriCard()
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("장소 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(Color.wooriTextSecond)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        guard let coord = selectedCoordinate, !name.isEmpty else { return }
                        onSave(
                            name,
                            coord,
                            category,
                            memo.isEmpty ? nil : memo,
                            hasVisitDate ? visitedAt : nil
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wooriPrimary)
                    .disabled(name.isEmpty || selectedCoordinate == nil)
                }
            }
        }
    }

    private func search() async {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.978),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        do {
            searchResults = try await mapService.searchPlaces(query: searchQuery, region: region)
        } catch {
            searchResults = []
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        selectedCoordinate = item.placemark.coordinate
        if name.isEmpty { name = item.name ?? "" }
        searchResults = []
        searchQuery = ""
        cameraPosition = .region(MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
}
