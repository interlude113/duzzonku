import SwiftUI
import MapKit

struct CourseDetailView: View {
    @ObservedObject var viewModel: CourseViewModel
    @EnvironmentObject private var tabRouter: TabRouter
    let course: DateCourse

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Map with numbered markers
                mapSection

                // Expense total
                if viewModel.detailExpenseTotal > 0 {
                    HStack {
                        Image(systemName: "wonsign.circle.fill")
                            .foregroundStyle(.wooriSuccess)
                            .accessibilityHidden(true)
                        Text("이 코스 지출")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)
                        Spacer()
                        Text(DateHelper.formattedAmount(viewModel.detailExpenseTotal))
                            .font(.wooriHeadline)
                            .foregroundStyle(.wooriTextPrimary)
                    }
                    .wooriCard()
                }

                // Memo
                if let memo = course.memo, !memo.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("메모")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextMuted)
                        Text(memo)
                            .font(.wooriBody)
                            .foregroundStyle(.wooriTextSecond)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .wooriCard()
                }

                // Place list
                placesSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
        }
        .background(Color.wooriBackground)
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.detailExpenseTotal > 0 {
                    Text(DateHelper.formattedAmount(viewModel.detailExpenseTotal))
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriPrimary)
                }
            }
        }
        .task {
            await viewModel.loadDetail(for: course)
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        Group {
            if !viewModel.detailPlaces.isEmpty {
                Map {
                    ForEach(viewModel.detailPlaces) { place in
                        Annotation(
                            place.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: place.latitude,
                                longitude: place.longitude
                            )
                        ) {
                            CourseAnnotationView(order: place.order)
                        }
                    }

                    if viewModel.detailPlaces.count > 1 {
                        let coords = viewModel.detailPlaces
                            .sorted { $0.order < $1.order }
                            .map {
                                CLLocationCoordinate2D(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude
                                )
                            }
                        MapPolyline(coordinates: coords)
                            .stroke(.wooriPrimary, lineWidth: 3)
                    }
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Places

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("장소 목록")
                .font(.wooriHeadline)
                .foregroundStyle(.wooriTextPrimary)
                .padding(.horizontal, Spacing.xs)

            ForEach(viewModel.detailPlaces.sorted { $0.order < $1.order }) { place in
                placeRow(place)
            }
        }
    }

    private func placeRow(_ place: CoursePlace) -> some View {
        HStack(spacing: Spacing.md) {
            // Order number
            ZStack {
                Circle()
                    .fill(place.isVisited ? Color.wooriSuccess : Color.wooriPrimaryLight)
                    .frame(width: 32, height: 32)
                Text("\(place.order)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(place.isVisited ? .white : .wooriPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.wooriBody)
                    .foregroundStyle(.wooriTextPrimary)
                    .strikethrough(place.isVisited)

                Text(place.category)
                    .font(.wooriCaption)
                    .foregroundStyle(.wooriTextMuted)
            }

            Spacer()

            // Navigate to map
            Button {
                if let linkedId = place.linkedPlaceId {
                    tabRouter.selectTab(.map, placeId: linkedId)
                }
            } label: {
                Image(systemName: "map")
                    .font(.caption)
                    .foregroundStyle(.wooriTextMuted)
            }
            .opacity(place.linkedPlaceId != nil ? 1 : 0)
            .accessibilityLabel("지도에서 보기")

            // Visited checkbox
            Button {
                Task { await viewModel.togglePlaceVisited(place) }
            } label: {
                Image(systemName: place.isVisited ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(place.isVisited ? .wooriSuccess : .wooriTextMuted)
            }
            .accessibilityLabel(place.isVisited ? "방문 완료" : "미방문")
        }
        .padding(Spacing.sm)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
