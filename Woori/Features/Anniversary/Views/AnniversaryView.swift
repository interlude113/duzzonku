import SwiftUI

struct AnniversaryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AnniversaryViewModel()
    @State private var showAddSheet = false

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            if viewModel.anniversaries.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.plus",
                    title: "기념일이 없어요",
                    description: "소중한 기념일을 추가해보세요"
                )
            } else {
                List {
                    // Primary (처음 만난 날) pinned
                    if let primary = viewModel.primaryAnniversary {
                        Section {
                            AnniversaryCardView(anniversary: primary)
                        } header: {
                            Text("처음 만난 날")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextMuted)
                        }
                        .listRowBackground(Color.wooriSurfaceWarm)
                    }

                    // 기타 기념일
                    Section {
                        ForEach(viewModel.otherAnniversaries) { anniversary in
                            AnniversaryCardView(anniversary: anniversary)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        guard let id = anniversary.id,
                                              let coupleId = authViewModel.coupleId else { return }
                                        Task {
                                            await viewModel.delete(
                                                coupleId: coupleId,
                                                anniversaryId: id
                                            )
                                        }
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        Text("기념일 목록")
                            .font(.wooriCaption)
                            .foregroundStyle(Color.wooriTextMuted)
                    }
                    .listRowBackground(Color.wooriSurface)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.wooriPrimary)
                            .clipShape(Circle())
                    }
                    .padding(Spacing.lg)
                    .accessibilityLabel("기념일 추가")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddAnniversarySheet { title, date, emoji, isRecurring in
                guard let coupleId = authViewModel.coupleId else { return }
                Task {
                    await viewModel.add(
                        coupleId: coupleId,
                        title: title,
                        date: date,
                        emoji: emoji,
                        isRecurring: isRecurring
                    )
                }
            }
        }
        .task {
            guard let coupleId = authViewModel.coupleId else { return }
            viewModel.startListening(coupleId: coupleId)
        }
        .alert("오류", isPresented: $viewModel.hasError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
