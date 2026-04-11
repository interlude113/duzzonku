import SwiftUI

struct DdayCardView: View {
    let dday: Int
    let detailedDuration: String

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("D+\(dday)")
                .font(.wooriDday)
                .foregroundStyle(Color.wooriPrimary)
                .accessibilityLabel("함께한 지 \(dday)일")

            Text("함께한 지 \(detailedDuration)")
                .font(.wooriBody)
                .foregroundStyle(Color.wooriTextSecond)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .wooriCard(backgroundColor: .wooriSurfaceWarm, cornerRadius: 20)
    }
}
