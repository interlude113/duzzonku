import SwiftUI

struct AddAnniversarySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Date()
    @State private var emoji = "🎉"
    @State private var isRecurring = true
    let onSave: (String, Date, String, Bool) -> Void

    private let emojiOptions = [
        "🎉", "❤️", "💍", "🎂", "✈️", "🌸",
        "🎄", "🎁", "💐", "🥂", "🏠", "👶",
        "📸", "🎵", "⭐️", "🌙", "☀️", "🦋"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.wooriBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        WooriTextField(placeholder: "기념일 이름", text: $title)

                        // Emoji Picker
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("이모지")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextSecond)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.sm) {
                                ForEach(emojiOptions, id: \.self) { option in
                                    Text(option)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            emoji == option
                                                ? Color.wooriPrimaryLight
                                                : Color.wooriSurface
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .onTapGesture { emoji = option }
                                }
                            }
                        }
                        .wooriCard()

                        // Date Picker
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("날짜")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextSecond)

                            DatePicker("날짜 선택", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.wooriPrimary)
                                .labelsHidden()
                        }
                        .wooriCard()

                        // Recurring Toggle
                        Toggle(isOn: $isRecurring) {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("매년 반복")
                                    .font(.wooriHeadline)
                                    .foregroundStyle(Color.wooriTextPrimary)
                                Text("매년 같은 날에 알림을 받아요")
                                    .font(.wooriCaption)
                                    .foregroundStyle(Color.wooriTextMuted)
                            }
                        }
                        .tint(.wooriPrimary)
                        .wooriCard()
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("기념일 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(Color.wooriTextSecond)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        guard !title.isEmpty else { return }
                        onSave(title, date, emoji, isRecurring)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wooriPrimary)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
