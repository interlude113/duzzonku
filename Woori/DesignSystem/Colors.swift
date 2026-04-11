import SwiftUI

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Woori Color Tokens

extension Color {
    // 배경
    static let wooriBackground   = Color(hex: "#FAF7F2")
    static let wooriSurface      = Color(hex: "#FFFFFF")
    static let wooriSurfaceWarm  = Color(hex: "#F5EFE6")

    // 포인트 컬러 (따뜻한 로즈)
    static let wooriPrimary      = Color(hex: "#D4967A")
    static let wooriPrimaryLight = Color(hex: "#EDD9CC")
    static let wooriPrimaryDark  = Color(hex: "#B8795E")

    // 텍스트
    static let wooriTextPrimary  = Color(hex: "#2D2420")
    static let wooriTextSecond   = Color(hex: "#7A6960")
    static let wooriTextMuted    = Color(hex: "#B5A89E")

    // 기타
    static let wooriBorder       = Color(hex: "#EDE4D8")
    static let wooriError        = Color(hex: "#E07070")
    static let wooriSuccess      = Color(hex: "#7EB89A")
}
