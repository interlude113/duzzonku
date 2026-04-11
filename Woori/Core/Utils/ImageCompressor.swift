import UIKit

enum ImageCompressor {
    /// UIImage를 JPEG 데이터로 압축 (기본 최대 1MB)
    static func compress(image: UIImage, maxBytes: Int = 1_048_576) -> Data? {
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.1
        var data = image.jpegData(compressionQuality: compression)

        while let currentData = data, currentData.count > maxBytes, compression > step {
            compression -= step
            data = image.jpegData(compressionQuality: compression)
        }

        // 압축률만으로 부족하면 리사이즈
        if let currentData = data, currentData.count > maxBytes {
            let ratio = sqrt(Double(maxBytes) / Double(currentData.count))
            let newSize = CGSize(
                width: image.size.width * ratio,
                height: image.size.height * ratio
            )
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            data = resized.jpegData(compressionQuality: 0.8)
        }

        return data
    }
}
