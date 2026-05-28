import SwiftUI

struct ExpenseListView: View {
    @ObservedObject var viewModel: ExpenseViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Summary card
                ExpenseSummaryView(
                    monthlyTotal: viewModel.monthlyTotal,
                    myTotal: viewModel.myTotal,
                    partnerTotal: viewModel.partnerTotal,
                    myNickname: viewModel.myNickname,
                    partnerNickname: viewModel.partnerNickname,
                    dutchPayText: viewModel.dutchPayText
                )

                // Month navigator
                monthNavigator

                // Grouped expenses by date
                if viewModel.groupedExpenses.isEmpty {
                    EmptyStateView(
                        icon: "wonsign.circle",
                        title: "지출 내역이 없어요",
                        description: "데이트 지출을 기록해보세요"
                    )
                } else {
                    ForEach(viewModel.groupedExpenses, id: \.date) { group in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(group.date)
                                .font(.wooriCaption)
                                .foregroundStyle(.wooriTextMuted)
                                .padding(.horizontal, Spacing.xs)

                            // List 필수: swipeActions 동작을 위해
                            List {
                                ForEach(group.items) { expense in
                                    ExpenseCardView(expense: expense)
                                        .listRowInsets(EdgeInsets(
                                            top: Spacing.xs,
                                            leading: 0,
                                            bottom: Spacing.xs,
                                            trailing: 0
                                        ))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                Task { await viewModel.deleteExpense(expense) }
                                            } label: {
                                                Label("삭제", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .frame(height: CGFloat(group.items.count) * 72)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
            .padding(.bottom, 80)
        }
    }

    // MARK: - Month Navigator

    private var monthNavigator: some View {
        HStack {
            Button {
                viewModel.changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.wooriPrimary)
                    .accessibilityLabel("이전 달")
            }

            Spacer()

            Text(DateHelper.monthFormatted(viewModel.selectedMonth))
                .font(.wooriHeadline)
                .foregroundStyle(.wooriTextPrimary)

            Spacer()

            Button {
                viewModel.changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.wooriPrimary)
                    .accessibilityLabel("다음 달")
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
