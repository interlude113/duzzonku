import SwiftUI

struct PlaceAnnotationView: View {
    let place: Place
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(categoryColor)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: categoryColor.opacity(0.4), radius: isSelected ? 6 : 3)

                Image(systemName: place.category.icon)
                    .font(.system(size: isSelected ? 18 : 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // 핀 아래 삼각형
            Triangle()
                .fill(categoryColor)
                .frame(width: 12, height: 8)
        }
        .animation(.spring(response: 0.3), value: isSelected)
        .accessibilityLabel("\(place.name), \(place.category.rawValue)")
    }

    private var categoryColor: Color {
        switch place.category {
        case .cafe:       return Color(hex: "#C8956D")
        case .restaurant: return Color(hex: "#E07070")
        case .travel:     return Color(hex: "#6BA3D6")
        case .etc:        return Color(hex: "#7EB89A")
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
