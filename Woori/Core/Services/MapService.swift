import Foundation
import MapKit

@MainActor
final class MapService: ObservableObject {
    static let shared = MapService()

    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching = false

    private init() {}

    /// MKLocalSearch로 장소 검색
    func search(query: String, region: MKCoordinateRegion? = nil) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let region = region {
            request.region = region
        }

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            searchResults = response.mapItems
        } catch {
            searchResults = []
        }
    }

    /// 검색 결과 초기화
    func clearResults() {
        searchResults = []
    }
}
