import SwiftUI

extension Color {
    /// 앱 전체 배경색
    static let wooriBackground   = Color.adaptive(light: "#FAF7F2", dark: "#1A1614")
    /// 카드/시트 배경
    static let wooriSurface      = Color.adaptive(light: "#FFFFFF", dark: "#2A2420")
    /// 따뜻한 톤 서피스
    static let wooriSurfaceWarm  = Color.adaptive(light: "#F5EFE6", dark: "#332C26")
    /// 메인 브랜드 컬러
    static let wooriPrimary      = Color(hex: "#D4967A")
    /// 연한 브랜드 컬러
    static let wooriPrimaryLight = Color.adaptive(light: "#EDD9CC", dark: "#4A362A")
    /// 진한 브랜드 컬러
    static let wooriPrimaryDark  = Color(hex: "#B8795E")
    /// 본문 텍스트
    static let wooriTextPrimary  = Color.adaptive(light: "#2D2420", dark: "#F0E8E0")
    /// 보조 텍스트
    static let wooriTextSecond   = Color.adaptive(light: "#7A6960", dark: "#B5A89E")
    /// 비활성 텍스트
    static let wooriTextMuted    = Color.adaptive(light: "#B5A89E", dark: "#7A6960")
    /// 테두리
    static let wooriBorder       = Color.adaptive(light: "#EDE4D8", dark: "#3D342C")
    /// 에러
    static let wooriError        = Color(hex: "#E07070")
    /// 성공
    static let wooriSuccess      = Color(hex: "#7EB89A")
}

// MARK: - Adaptive Color Helper

extension Color {
    /// 라이트/다크 모드별 적응형 컬러 생성
    static func adaptive(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
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
