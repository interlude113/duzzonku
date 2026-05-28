import SwiftUI

@MainActor
final class TabRouter: ObservableObject {
    enum Tab: String, CaseIterable {
        case home, anniversary, letters, map, date

        var title: String {
            switch self {
            case .home: return "홈"
            case .anniversary: return "기념일"
            case .letters: return "편지"
            case .map: return "지도"
            case .date: return "데이트"
            }
        }

        var icon: String {
            switch self {
            case .home: return "heart.fill"
            case .anniversary: return "calendar.badge.clock"
            case .letters: return "envelope.fill"
            case .map: return "map.fill"
            case .date: return "sparkles"
            }
        }
    }

    @Published var selectedTab: Tab = .home
    @Published var mapFocusPlaceId: String?
    @Published var dateFilterCourseId: String?

    func selectTab(_ tab: Tab, placeId: String? = nil, courseId: String? = nil) {
        selectedTab = tab
        if tab == .map { mapFocusPlaceId = placeId }
        if tab == .date { dateFilterCourseId = courseId }
    }
}
