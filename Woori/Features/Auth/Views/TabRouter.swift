import SwiftUI

@MainActor
final class TabRouter: ObservableObject {
    enum Tab: String, CaseIterable {
        case home, anniversary, gallery, letters, map

        var title: String {
            switch self {
            case .home:        return "홈"
            case .anniversary: return "기념일"
            case .gallery:     return "갤러리"
            case .letters:     return "편지"
            case .map:         return "지도"
            }
        }

        var icon: String {
            switch self {
            case .home:        return "house.fill"
            case .anniversary: return "calendar.badge.clock"
            case .gallery:     return "photo.on.rectangle.angled"
            case .letters:     return "envelope.fill"
            case .map:         return "map.fill"
            }
        }
    }

    @Published var selectedTab: Tab = .home
    @Published var mapFocusPlaceId: String?
    @Published var galleryFilterPlaceId: String?

    func selectTab(_ tab: Tab, placeId: String? = nil) {
        selectedTab = tab
        if tab == .map { mapFocusPlaceId = placeId }
        if tab == .gallery { galleryFilterPlaceId = placeId }
    }
}
