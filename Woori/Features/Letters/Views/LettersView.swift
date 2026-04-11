import SwiftUI

struct LettersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LettersViewModel()
    @State private var showWriteSheet = false
    @State private var selectedLetter: Letter?

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Segmented Picker
                Picker("필터", selection: $viewModel.filter) {
                    ForEach(LettersViewModel.LetterFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(Spacing.md)

                if viewModel.filteredLetters.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "envelope.open",
                        title: viewModel.filter == .received ? "받은 편지가 없어요" : "보낸 편지가 없어요",
                        description: "소중한 마음을 편지로 전해보세요"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredLetters) { letter in
                            LetterCardView(
                                letter: letter,
                                isFromMe: letter.fromUserId == viewModel.userId
                            )
                            .onTapGesture {
                                selectedLetter = letter
                                // 받은 편지 읽음 처리
                                if letter.fromUserId != viewModel.userId && !letter.isRead {
                                    guard let coupleId = authViewModel.coupleId,
                                          let letterId = letter.id else { return }
                                    Task {
                                        await viewModel.markAsRead(
                                            coupleId: coupleId,
                                            letterId: letterId
                                        )
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    guard let id = letter.id,
                                          let coupleId = authViewModel.coupleId else { return }
                                    Task {
                                        await viewModel.deleteLetter(
                                            coupleId: coupleId,
                                            letterId: id
                                        )
                                    }
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showWriteSheet = true } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.wooriPrimary)
                            .clipShape(Circle())
                    }
                    .padding(Spacing.lg)
                    .accessibilityLabel("편지 쓰기")
                }
            }
        }
        .sheet(item: $selectedLetter) { letter in
            LetterDetailView(letter: letter)
        }
        .sheet(isPresented: $showWriteSheet) {
            WriteLetterSheet { title, content in
                guard let coupleId = authViewModel.coupleId,
                      let userId = authViewModel.userId,
                      let partnerId = authViewModel.partnerId else { return }
                Task {
                    await viewModel.sendLetter(
                        coupleId: coupleId,
                        userId: userId,
                        partnerId: partnerId,
                        title: title,
                        content: content
                    )
                }
            }
        }
        .task {
            viewModel.userId = authViewModel.userId
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
