import SwiftUI

struct AnniversaryView: View {
    @StateObject private var viewModel = AnniversaryViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if viewModel.sortedAnniversaries.isEmpty {
                        ScrollView {
                            EmptyStateView(
                                icon: "calendar.badge.plus",
                                title: "기념일이 없어요",
                                description: "소중한 날들을 기록해보세요"
                            )
                        }
                    } else {
                        // List 필수: swipeActions 동작을 위해
                        List {
                            ForEach(viewModel.sortedAnniversaries) { anniversary in
                                AnniversaryCardView(
                                    anniversary: anniversary,
                                    daysUntil: viewModel.daysUntil(anniversary)
                                )
                                .listRowInsets(EdgeInsets(
                                    top: Spacing.xs,
                                    leading: Spacing.md,
                                    bottom: Spacing.xs,
                                    trailing: Spacing.md
                                ))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if !anniversary.isPrimary {
                                        Button(role: .destructive) {
                                            Task { await viewModel.deleteAnniversary(anniversary) }
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.wooriBackground)
                    }
                }
                .background(Color.wooriBackground)

                // FAB
                Button {
                    viewModel.resetForm()
                    viewModel.showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.wooriPrimary)
                        .clipShape(Circle())
                        .shadow(color: .wooriPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("기념일 추가")
                .padding(Spacing.lg)
            }
            .navigationTitle("기념일")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddAnniversarySheet(viewModel: viewModel)
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
        .task {
            viewModel.startListening()
            _ = await NotificationService.shared.requestPermission()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}
