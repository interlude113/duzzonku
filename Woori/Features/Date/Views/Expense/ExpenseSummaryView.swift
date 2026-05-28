import SwiftUI

struct ExpenseSummaryView: View {
    let monthlyTotal: Int
    let myTotal: Int
    let partnerTotal: Int
    let myNickname: String
    let partnerNickname: String
    let dutchPayText: String

    var body: some View {
        WooriCard {
            VStack(spacing: Spacing.md) {
                // Total
                VStack(spacing: Spacing.xs) {
                    Text("이번 달 총 지출")
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriTextMuted)
                    Text(DateHelper.formattedAmount(monthlyTotal))
                        .font(.wooriTitle)
                        .foregroundStyle(.wooriTextPrimary)
                }

                Divider()
                    .foregroundStyle(.wooriBorder)

                // Per person
                HStack(spacing: Spacing.xl) {
                    personColumn(
                        nickname: myNickname,
                        amount: myTotal,
                        color: .wooriPrimary
                    )
                    personColumn(
                        nickname: partnerNickname.isEmpty ? "상대방" : partnerNickname,
                        amount: partnerTotal,
                        color: .wooriPrimaryDark
                    )
                }

                // Dutch pay
                Text(dutchPayText)
                    .font(.wooriCaption)
                    .foregroundStyle(.wooriPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.wooriPrimaryLight.opacity(0.5))
                    .clipShape(Capsule())
            }
        }
    }

    private func personColumn(nickname: String, amount: Int, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            AvatarView(nickname: nickname, size: 32, color: color)
            Text(nickname)
                .font(.wooriCaption)
                .foregroundStyle(.wooriTextSecond)
            Text(DateHelper.formattedAmount(amount))
                .font(.wooriHeadline)
                .foregroundStyle(.wooriTextPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}
