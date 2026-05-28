import SwiftUI

struct PlaceAnnotationView: View {
    let category: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)

            Image(systemName: iconName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        .accessibilityLabel("\(category) 장소")
    }

    private var iconName: String {
        switch category {
        case Place.Category.cafe.rawValue: return "cup.and.saucer.fill"
        case Place.Category.restaurant.rawValue: return "fork.knife"
        case Place.Category.travel.rawValue: return "airplane"
        default: return "mappin"
        }
    }
}

// MARK: - Course Place Annotation

struct CourseAnnotationView: View {
    let order: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.wooriPrimary)
                .frame(width: 32, height: 32)

            Text("\(order)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .shadow(color: Color.wooriPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
        .accessibilityLabel("코스 \(order)번 장소")
    }
}
