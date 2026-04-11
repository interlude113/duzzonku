import SwiftUI

struct TodayMessageView: View {
    @Binding var message: String
    @Binding var isEditing: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("오늘의 한마디")
                    .font(.wooriHeadline)
                    .foregroundStyle(Color.wooriTextPrimary)
                Spacer()
                if isEditing {
                    Button("완료") { onSave() }
                        .font(.wooriCaption)
                        .foregroundStyle(Color.wooriPrimary)
                }
            }

            if isEditing {
                TextField("오늘 하고 싶은 말을 적어보세요", text: $message)
                    .font(.wooriBody)
                    .padding(Spacing.sm)
                    .background(Color.wooriBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(message.isEmpty ? "탭하여 오늘의 한마디를 남겨보세요" : message)
                    .font(.wooriBody)
                    .foregroundStyle(
                        message.isEmpty ? Color.wooriTextMuted : Color.wooriTextPrimary
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture { isEditing = true }
            }
        }
        .wooriCard()
    }
}
