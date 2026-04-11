import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.md) {
                    // 상단 커플 정보
                    coupleHeader

                    // D-day 카드
                    DdayCardView(
                        dday: viewModel.dday,
                        detailedDuration: viewModel.detailedDuration
                    )

                    // 오늘의 한마디
                    TodayMessageView(
                        message: $viewModel.todayMessage,
                        isEditing: $viewModel.isEditingMessage
                    ) {
                        guard let coupleId = authViewModel.coupleId else { return }
                        Task {
                            await viewModel.saveTodayMessage(coupleId: coupleId)
                        }
                    }

                    // 빠른 통계
                    QuickStatsView(
                        nextAnniversaryDays: viewModel.nextAnniversaryDays,
                        nextAnniversaryTitle: viewModel.nextAnniversary?.title,
                        photoCount: viewModel.photoCount,
                        placeCount: viewModel.placeCount
                    )
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
            }
        }
        .task {
            guard let coupleId = authViewModel.coupleId else { return }
            await viewModel.loadData(coupleId: coupleId)
        }
        .refreshable {
            guard let coupleId = authViewModel.coupleId else { return }
            await viewModel.loadData(coupleId: coupleId)
        }
        .alert("오류", isPresented: $viewModel.hasError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var coupleHeader: some View {
        HStack(spacing: Spacing.sm) {
            AvatarView(name: "나", size: 40)

            Image(systemName: "heart.fill")
                .font(.caption)
                .foregroundStyle(Color.wooriPrimary)
                .accessibilityHidden(true)

            AvatarView(name: "상대", size: 40)

            Spacer()

            Text(authViewModel.couple?.coupleName ?? "Woori")
                .font(.wooriHeadline)
                .foregroundStyle(Color.wooriTextPrimary)
        }
        .padding(.horizontal, Spacing.xs)
    }
}
