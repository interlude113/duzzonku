import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var coupleSession: CoupleSession
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    coupleHeader

                    DdayCardView(
                        daysCount: viewModel.daysCount,
                        detailedDuration: viewModel.detailedDuration
                    )

                    TodayMessageView(
                        message: $viewModel.todayMessage,
                        isEditing: $viewModel.isEditingMessage,
                        onSave: { await viewModel.saveTodayMessage() }
                    )

                    QuickStatsView(
                        nextAnniversary: viewModel.nextAnniversary,
                        monthlyExpense: viewModel.monthlyExpenseTotal,
                        incompleteCourses: viewModel.incompleteCourseCount
                    )
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
            }
            .background(Color.wooriBackground)
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .refreshable {
                await viewModel.loadData()
            }
        }
        .task {
            await viewModel.loadData()
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .onReceive(timer) { _ in
            viewModel.refreshDday()
        }
        .alert("오류", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var coupleHeader: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(nickname: coupleSession.myNickname, size: 48, color: .wooriPrimary)

            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.sm) {
                    Text(coupleSession.myNickname)
                        .font(.wooriHeadline)
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.wooriPrimary)
                        .accessibilityHidden(true)
                    Text(coupleSession.partnerNickname.isEmpty ? "상대방" : coupleSession.partnerNickname)
                        .font(.wooriHeadline)
                }
                .foregroundStyle(.wooriTextPrimary)
            }

            Spacer()

            AvatarView(
                nickname: coupleSession.partnerNickname.isEmpty ? "?" : coupleSession.partnerNickname,
                size: 48,
                color: .wooriPrimaryDark
            )
        }
        .wooriCard()
    }
}
