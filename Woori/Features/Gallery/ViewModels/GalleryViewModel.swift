import Foundation
import UIKit

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var filteredPhotos: [Photo] = []
    @Published var places: [Place] = []
    @Published var selectedPlaceId: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    private let photoRepo: PhotoRepositoryProtocol
    private let placeRepo: PlaceRepositoryProtocol
    private let storageService = StorageService()
    private var listenTask: Task<Void, Never>?

    init(
        photoRepo: PhotoRepositoryProtocol = FirebasePhotoRepository(),
        placeRepo: PlaceRepositoryProtocol = FirebasePlaceRepository()
    ) {
        self.photoRepo = photoRepo
        self.placeRepo = placeRepo
    }

    func startListening(coupleId: String) {
        listenTask?.cancel()
        listenTask = Task {
            for await items in photoRepo.listenToPhotos(coupleId: coupleId) {
                guard !Task.isCancelled else { break }
                self.photos = items
                applyFilter()
            }
        }
    }

    func loadPlaces(coupleId: String) async {
        do {
            places = try await placeRepo.fetchAll(coupleId: coupleId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func filterByPlace(_ placeId: String?) {
        selectedPlaceId = placeId
        applyFilter()
    }

    private func applyFilter() {
        if let placeId = selectedPlaceId {
            filteredPhotos = photos.filter { $0.placeId == placeId }
        } else {
            filteredPhotos = photos
        }
    }

    func uploadPhoto(
        coupleId: String,
        userId: String,
        image: UIImage,
        caption: String?,
        placeId: String?
    ) async {
        isLoading = true
        do {
            guard let data = ImageCompressor.compress(image: image) else {
                errorMessage = "이미지 압축에 실패했습니다."
                isLoading = false
                return
            }
            let fileName = "\(UUID().uuidString).jpg"
            let urls = try await storageService.uploadPhoto(
                coupleId: coupleId,
                imageData: data,
                fileName: fileName
            )
            let photo = Photo(
                uploadedBy: userId,
                storageUrl: urls.url,
                thumbnailUrl: urls.thumbnailUrl,
                caption: caption,
                takenAt: Date(),
                placeId: placeId,
                createdAt: Date()
            )
            try await photoRepo.add(coupleId: coupleId, photo: photo)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deletePhoto(coupleId: String, photo: Photo) async {
        guard let id = photo.id else { return }
        do {
            try await photoRepo.delete(coupleId: coupleId, photoId: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
