import SwiftUI

struct TodayMessageView: View {
    @Binding var message: String
    @Binding var isEditing: Bool
    let onSave: () async -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        WooriCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "bubble.left.fill")
                        .foregroundStyle(.wooriPrimary)
                        .accessibilityHidden(true)
                    Text("오늘의 한마디")
                        .font(.wooriHeadline)
                        .foregroundStyle(.wooriTextPrimary)
                    Spacer()
                    if isEditing {
                        Button("완료") {
                            Task { await onSave() }
                        }
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriPrimary)
                    }
                }

                if isEditing {
                    TextField("오늘의 한마디를 적어보세요", text: $message)
                        .font(.wooriBody)
                        .focused($isFocused)
                        .onAppear { isFocused = true }
                        .submitLabel(.done)
                        .onSubmit {
                            Task { await onSave() }
                        }
                } else {
                    Text(message.isEmpty ? "탭해서 오늘의 한마디를 적어보세요 ✨" : message)
                        .font(.wooriBody)
                        .foregroundStyle(message.isEmpty ? .wooriTextMuted : .wooriTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture { isEditing = true }
                }
            }
        }
    }
}
