import SwiftUI

struct ExpenseCardView: View {
    let expense: DateExpense

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color.wooriPrimaryLight)
                    .frame(width: 40, height: 40)
                Text(categoryEmoji)
                    .font(.system(size: 18))
            }
            .accessibilityLabel("\(expense.category) 카테고리")

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(expense.title)
                    .font(.wooriBody)
                    .foregroundStyle(.wooriTextPrimary)
                    .lineLimit(1)

                if let memo = expense.memo, !memo.isEmpty {
                    Text(memo)
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriTextMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Amount + paidBy
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text(DateHelper.formattedAmount(expense.amount))
                    .font(.wooriHeadline)
                    .foregroundStyle(.wooriTextPrimary)

                Text(expense.paidBy)
                    .font(.wooriCaption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.wooriPrimary.opacity(0.8))
                    .clipShape(Capsule())
            }
        }
        .padding(Spacing.md)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }

    private var categoryEmoji: String {
        DateExpense.Category(rawValue: expense.category)?.emoji ?? "💰"
    }
}
