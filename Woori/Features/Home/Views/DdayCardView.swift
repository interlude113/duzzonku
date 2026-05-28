import SwiftUI

struct DdayCardView: View {
    let daysCount: Int
    let detailedDuration: String

    var body: some View {
        WooriCard {
            VStack(spacing: Spacing.sm) {
                Text("D+\(daysCount)")
                    .font(.wooriDday)
                    .foregroundStyle(.wooriPrimary)
                    .accessibilityLabel("디데이 플러스 \(daysCount)일")

                Text("함께한 지 \(detailedDuration)")
                    .font(.wooriBody)
                    .foregroundStyle(.wooriTextSecond)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
        }
    }
}
