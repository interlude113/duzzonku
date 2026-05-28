import SwiftUI

struct AddAnniversarySheet: View {
    @ObservedObject var viewModel: AnniversaryViewModel
    @Environment(\.dismiss) private var dismiss

    private let emojiOptions = ["🎉", "💍", "🎂", "✈️", "🏠", "🎄", "🌸", "🎓", "💝", "🥂", "🎁", "⭐️", "🌈", "🎵", "📸", "🍰"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    WooriTextField(placeholder: "기념일 제목", text: $viewModel.newTitle, icon: "pencil")

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("날짜")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)

                        DatePicker("날짜", selection: $viewModel.newDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.wooriPrimary)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("이모지")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: Spacing.sm) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .padding(Spacing.xs)
                                    .background(viewModel.newEmoji == emoji ? Color.wooriPrimaryLight : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture { viewModel.newEmoji = emoji }
                            }
                        }
                    }

                    Toggle(isOn: $viewModel.newIsRecurring) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.wooriPrimary)
                                .accessibilityHidden(true)
                            Text("매년 반복")
                                .font(.wooriBody)
                        }
                    }
                    .tint(.wooriPrimary)

                    WooriButton(title: "추가하기", isLoading: viewModel.isLoading) {
                        Task { await viewModel.addAnniversary() }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.wooriBackground)
            .navigationTitle("기념일 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.wooriTextSecond)
                }
            }
        }
    }
}
