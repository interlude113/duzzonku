import Foundation

enum Collections {
    static let couples = "couples"
    static let anniversaries = "anniversaries"
    static let photos = "photos"
    static let letters = "letters"
    static let places = "places"
}

enum AppConstants {
    static let inviteCodeLength = 6
    static let maxPhotoBytes = 1_048_576 // 1MB
    static let thumbnailMaxSize: CGFloat = 300
    static let galleryColumns = 3
    static let placePhotoPreviewCount = 5
}
