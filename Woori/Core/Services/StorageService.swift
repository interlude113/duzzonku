import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    private let storage = Storage.storage()

    /// 이미지를 Firebase Storage에 업로드하고 다운로드 URL을 반환
    func uploadPhoto(
        coupleId: String,
        imageData: Data,
        fileName: String
    ) async throws -> (url: String, thumbnailUrl: String) {
        let fullRef = storage.reference()
            .child("couples/\(coupleId)/photos/\(fileName)")
        let thumbnailRef = storage.reference()
            .child("couples/\(coupleId)/thumbnails/\(fileName)")

        // 원본 업로드
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await fullRef.putDataAsync(imageData, metadata: metadata)
        let fullUrl = try await fullRef.downloadURL().absoluteString

        // 썸네일 생성 및 업로드
        let thumbnailData = createThumbnail(from: imageData, maxSize: 300)
        _ = try await thumbnailRef.putDataAsync(thumbnailData, metadata: metadata)
        let thumbnailUrl = try await thumbnailRef.downloadURL().absoluteString

        return (fullUrl, thumbnailUrl)
    }

    /// 이미지 삭제
    func deletePhoto(coupleId: String, fileName: String) async throws {
        let fullRef = storage.reference()
            .child("couples/\(coupleId)/photos/\(fileName)")
        let thumbnailRef = storage.reference()
            .child("couples/\(coupleId)/thumbnails/\(fileName)")
        try await fullRef.delete()
        try await thumbnailRef.delete()
    }

    // MARK: - Private

    private func createThumbnail(from data: Data, maxSize: CGFloat) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: 0.7) ?? data
    }
}
