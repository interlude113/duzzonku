import Foundation
import MapKit

final class MapService {
    /// 주소 문자열로 좌표 검색
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location?.coordinate else {
            throw MapServiceError.noResults
        }
        return location
    }

    /// 좌표로 주소 역검색
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw MapServiceError.noResults
        }
        return [placemark.locality, placemark.subLocality, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    /// 장소 검색 (MKLocalSearch)
    func searchPlaces(query: String, region: MKCoordinateRegion) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems
    }
}

enum MapServiceError: LocalizedError {
    case noResults

    var errorDescription: String? {
        switch self {
        case .noResults: return "검색 결과가 없습니다."
        }
    }
}
