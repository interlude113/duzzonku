import Foundation
import MapKit

@MainActor
final class MapViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var photos: [Photo] = []
    @Published var selectedPlace: Place?
    @Published var selectedCategory: PlaceCategory?
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var isLoading = false
    @Published var errorMessage: String?

    // AddPlaceSheet
    @Published var searchResults: [MKMapItem] = []

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    var filteredPlaces: [Place] {
        guard let category = selectedCategory else { return places }
        return places.filter { $0.category == category }
    }

    private let placeRepo: PlaceRepositoryProtocol
    private let photoRepo: PhotoRepositoryProtocol
    private let mapService = MapService()
    private var listenTask: Task<Void, Never>?

    init(
        placeRepo: PlaceRepositoryProtocol = FirebasePlaceRepository(),
        photoRepo: PhotoRepositoryProtocol = FirebasePhotoRepository()
    ) {
        self.placeRepo = placeRepo
        self.photoRepo = photoRepo
    }

    func startListening(coupleId: String) {
        listenTask?.cancel()
        listenTask = Task {
            for await items in placeRepo.listenToPlaces(coupleId: coupleId) {
                guard !Task.isCancelled else { break }
                self.places = items
            }
        }
    }

    func loadPhotos(coupleId: String) async {
        do {
            photos = try await photoRepo.fetchAll(coupleId: coupleId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func photosForPlace(_ placeId: String?) -> [Photo] {
        guard let placeId else { return [] }
        return Array(photos.filter { $0.placeId == placeId }.prefix(AppConstants.placePhotoPreviewCount))
    }

    func focusOnPlace(placeId: String) {
        guard let place = places.first(where: { $0.id == placeId }) else { return }
        selectedPlace = place
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    func addPlace(
        coupleId: String,
        name: String,
        coordinate: CLLocationCoordinate2D,
        category: PlaceCategory,
        memo: String?,
        visitedAt: Date?
    ) async {
        isLoading = true
        do {
            let address = try? await mapService.reverseGeocode(coordinate: coordinate)
            let place = Place(
                name: name,
                address: address,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                category: category,
                memo: memo,
                visitedAt: visitedAt,
                createdAt: Date()
            )
            try await placeRepo.add(coupleId: coupleId, place: place)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func searchAddress(query: String, region: MKCoordinateRegion) async {
        do {
            searchResults = try await mapService.searchPlaces(query: query, region: region)
        } catch {
            searchResults = []
        }
    }

    func deletePlace(coupleId: String, placeId: String) async {
        do {
            try await placeRepo.delete(coupleId: coupleId, placeId: placeId)
            if selectedPlace?.id == placeId { selectedPlace = nil }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
