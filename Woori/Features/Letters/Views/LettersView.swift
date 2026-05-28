import SwiftUI

struct LettersView: View {
    @StateObject private var viewModel = LettersViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Segmented filter
                    Picker("필터", selection: $viewModel.filter) {
                        ForEach(LettersViewModel.LetterFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.wooriBackground)

                    if viewModel.filteredLetters.isEmpty {
                        ScrollView {
                            EmptyStateView(
                                icon: viewModel.filter == .received ? "envelope.open" : "paperplane",
                                title: viewModel.filter == .received ? "받은 편지가 없어요" : "보낸 편지가 없어요",
                                description: viewModel.filter == .received
                                    ? "상대방의 편지를 기다려보세요"
                                    : "소중한 마음을 편지로 전해보세요"
                            )
                        }
                    } else {
                        // List 필수: swipeActions 동작을 위해
                        List {
                            ForEach(viewModel.filteredLetters) { letter in
                                NavigationLink {
                                    LetterDetailView(letter: letter) {
                                        await viewModel.markAsRead(letter)
                                    }
                                } label: {
                                    LetterCardView(
                                        letter: letter,
                                        isReceived: viewModel.filter == .received
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets(
                                    top: Spacing.xs,
                                    leading: Spacing.md,
                                    bottom: Spacing.xs,
                                    trailing: Spacing.md
                                ))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { await viewModel.deleteLetter(letter) }
                                    } label: {
                                        Label("삭제", systemImage: "trash")
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
                    viewModel.showWriteSheet = true
                } label: {
                    Image(systemName: "pencil.line")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.wooriPrimary)
                        .clipShape(Circle())
                        .shadow(color: .wooriPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("편지 쓰기")
                .padding(Spacing.lg)
            }
            .navigationTitle("편지")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.unreadCount > 0 {
                        Text("\(viewModel.unreadCount)")
                            .font(.wooriCaption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.wooriError)
                            .clipShape(Capsule())
                            .accessibilityLabel("읽지 않은 편지 \(viewModel.unreadCount)개")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showWriteSheet) {
                WriteLetterSheet(viewModel: viewModel)
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
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}
