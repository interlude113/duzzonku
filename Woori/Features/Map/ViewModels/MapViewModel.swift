import SwiftUI
import MapKit
import FirebaseFirestore

@MainActor
final class MapViewModel: ObservableObject {
    enum MapFilter: String, CaseIterable {
        case all = "전체"
        case places = "일반 장소"
        case courses = "코스 장소"
    }

    @Published var places: [Place] = []
    @Published var coursePlaces: [(course: DateCourse, places: [CoursePlace])] = []
    @Published var filter: MapFilter = .all
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedPlace: Place?
    @Published var selectedCoursePlace: CoursePlace?
    @Published var selectedCourseName: String?
    @Published var showPlaceDetail = false
    @Published var showAddSheet = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Add form
    @Published var newName = ""
    @Published var newAddress = ""
    @Published var newCategory: Place.Category = .cafe
    @Published var newMemo = ""
    @Published var newLatitude: Double = 37.5665
    @Published var newLongitude: Double = 126.9780
    @Published var searchQuery = ""

    private let placeRepository = FirebasePlaceRepository()
    private let dateRepository = FirebaseDateRepository()
    private let mapService = MapService.shared
    private let session = CoupleSession.shared
    private var cancelPlaceListener: (() -> Void)?

    var coupleDocId: String { session.coupleDocId }
    var searchResults: [MKMapItem] { mapService.searchResults }
    var isSearching: Bool { mapService.isSearching }

    // MARK: - Listeners

    func startListening() {
        let result = placeRepository.listenPlaces(coupleDocId: coupleDocId)
        cancelPlaceListener = result.cancel
        Task {
            for await items in result.stream {
                self.places = items
            }
        }
        Task { await loadCoursePlaces() }
    }

    func stopListening() {
        cancelPlaceListener?()
        cancelPlaceListener = nil
    }

    func loadCoursePlaces() async {
        do {
            let courses = try await dateRepository.fetchCourses(coupleDocId: coupleDocId)
            var result: [(course: DateCourse, places: [CoursePlace])] = []
            for course in courses {
                guard let courseId = course.id else { continue }
                let cPlaces = try await dateRepository.fetchCoursePlaces(
                    coupleDocId: coupleDocId, courseId: courseId
                )
                if !cPlaces.isEmpty {
                    result.append((course: course, places: cPlaces))
                }
            }
            self.coursePlaces = result
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search

    func searchPlaces() async {
        await mapService.search(query: searchQuery)
    }

    func selectSearchResult(_ item: MKMapItem) {
        newName = item.name ?? ""
        newAddress = item.placemark.title ?? ""
        newLatitude = item.placemark.coordinate.latitude
        newLongitude = item.placemark.coordinate.longitude
        mapService.clearResults()
        searchQuery = ""
    }

    // MARK: - CRUD

    func addPlace() async {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "장소 이름을 입력해주세요"
            return
        }
        isLoading = true
        do {
            let place = Place(
                name: newName.trimmingCharacters(in: .whitespaces),
                address: newAddress.isEmpty ? nil : newAddress,
                latitude: newLatitude,
                longitude: newLongitude,
                category: newCategory.rawValue,
                memo: newMemo.isEmpty ? nil : newMemo,
                visitedAt: nil,
                createdAt: Timestamp(date: Date())
            )
            _ = try await placeRepository.addPlace(place, coupleDocId: coupleDocId)
            resetForm()
            showAddSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deletePlace(_ place: Place) async {
        guard let id = place.id else { return }
        do {
            try await placeRepository.deletePlace(id: id, coupleDocId: coupleDocId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Focus

    func focusOnPlace(id: String) {
        if let place = places.first(where: { $0.id == id }) {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
            selectedPlace = place
            showPlaceDetail = true
        }
    }

    func resetForm() {
        newName = ""
        newAddress = ""
        newCategory = .cafe
        newMemo = ""
        newLatitude = 37.5665
        newLongitude = 126.9780
        searchQuery = ""
        mapService.clearResults()
    }

    func categoryColor(_ category: String) -> Color {
        switch category {
        case Place.Category.cafe.rawValue: return .brown
        case Place.Category.restaurant.rawValue: return .orange
        case Place.Category.travel.rawValue: return .blue
        default: return .gray
        }
    }
}
