import SwiftUI

struct WriteLetterSheet: View {
    @ObservedObject var viewModel: LettersViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    enum Field { case title, content }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    WooriTextField(placeholder: "제목 (선택)", text: $viewModel.newTitle, icon: "pencil")
                        .focused($focusedField, equals: .title)

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("내용")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)

                        TextEditor(text: $viewModel.newContent)
                            .font(.wooriBody)
                            .focused($focusedField, equals: .content)
                            .frame(minHeight: 250)
                            .padding(Spacing.sm)
                            .scrollContentBackground(.hidden)
                            .background(Color.wooriSurfaceWarm)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.wooriBorder, lineWidth: 1)
                            }
                            .overlay(alignment: .topLeading) {
                                if viewModel.newContent.isEmpty {
                                    Text("마음을 담아 편지를 써보세요 💌")
                                        .font(.wooriBody)
                                        .foregroundStyle(.wooriTextMuted)
                                        .padding(.horizontal, Spacing.md)
                                        .padding(.top, Spacing.md)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    WooriButton(title: "편지 보내기 💌", isLoading: viewModel.isLoading) {
                        Task { await viewModel.sendLetter() }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.wooriBackground)
            .navigationTitle("편지 쓰기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.wooriTextSecond)
                }
            }
            .onAppear {
                focusedField = .content
            }
        }
    }
}
