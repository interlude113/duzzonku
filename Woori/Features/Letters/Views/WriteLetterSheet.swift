import SwiftUI

struct WriteLetterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    let onSend: (String?, String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.wooriSurfaceWarm.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        TextField("제목 (선택)", text: $title)
                            .font(.wooriTitle)
                            .foregroundStyle(Color.wooriTextPrimary)

                        Divider()
                            .background(Color.wooriBorder)

                        TextEditor(text: $content)
                            .font(.wooriBody)
                            .foregroundStyle(Color.wooriTextPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 300)
                            .overlay(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("전하고 싶은 마음을 적어보세요...")
                                        .font(.wooriBody)
                                        .foregroundStyle(Color.wooriTextMuted)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("편지 쓰기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(Color.wooriTextSecond)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("보내기") {
                        onSend(title.isEmpty ? nil : title, content)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wooriPrimary)
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}
