import SwiftUI

struct AddExpenseSheet: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Title
                    WooriTextField(
                        placeholder: "지출 내용 (예: 저녁 식사)",
                        text: $viewModel.newTitle,
                        icon: "pencil"
                    )

                    // Amount
                    WooriTextField(
                        placeholder: "금액",
                        text: $viewModel.newAmount,
                        keyboardType: .numberPad,
                        icon: "wonsign"
                    )

                    // Category
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("카테고리")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(DateExpense.Category.allCases, id: \.self) { cat in
                                    Button {
                                        viewModel.newCategory = cat
                                    } label: {
                                        HStack(spacing: Spacing.xs) {
                                            Text(cat.emoji)
                                            Text(cat.rawValue)
                                                .font(.wooriCaption)
                                        }
                                        .padding(.horizontal, Spacing.sm)
                                        .padding(.vertical, Spacing.sm)
                                        .background(
                                            viewModel.newCategory == cat
                                                ? Color.wooriPrimary : Color.wooriSurfaceWarm
                                        )
                                        .foregroundStyle(
                                            viewModel.newCategory == cat
                                                ? .white : .wooriTextSecond
                                        )
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    // Paid by
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("누가 냈나요?")
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)

                        HStack(spacing: Spacing.sm) {
                            paidByButton(viewModel.myNickname)
                            if !viewModel.partnerNickname.isEmpty {
                                paidByButton(viewModel.partnerNickname)
                            }
                        }
                    }

                    // Date
                    DatePicker(
                        "날짜",
                        selection: $viewModel.newDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(.wooriPrimary)
                    .environment(\.locale, Locale(identifier: "ko_KR"))

                    // Course link
                    if !viewModel.courses.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("코스 연결 (선택)")
                                .font(.wooriCaption)
                                .foregroundStyle(.wooriTextSecond)

                            Picker("코스", selection: $viewModel.newCourseId) {
                                Text("없음").tag(nil as String?)
                                ForEach(viewModel.courses) { course in
                                    Text(course.title).tag(course.id as String?)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.wooriPrimary)
                        }
                    }

                    // Memo
                    WooriTextField(
                        placeholder: "메모 (선택)",
                        text: $viewModel.newMemo,
                        icon: "note.text"
                    )

                    WooriButton(title: "지출 추가", isLoading: viewModel.isLoading) {
                        Task { await viewModel.addExpense() }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.wooriBackground)
            .navigationTitle("지출 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.wooriTextSecond)
                }
            }
        }
        .onAppear {
            if viewModel.newPaidBy.isEmpty {
                viewModel.newPaidBy = viewModel.myNickname
            }
        }
    }

    private func paidByButton(_ nickname: String) -> some View {
        Button {
            viewModel.newPaidBy = nickname
        } label: {
            HStack(spacing: Spacing.xs) {
                AvatarView(
                    nickname: nickname,
                    size: 24,
                    color: viewModel.newPaidBy == nickname
                        ? .white : .wooriPrimary
                )
                Text(nickname)
                    .font(.wooriBody)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                viewModel.newPaidBy == nickname
                    ? Color.wooriPrimary : Color.wooriSurfaceWarm
            )
            .foregroundStyle(
                viewModel.newPaidBy == nickname
                    ? .white : .wooriTextPrimary
            )
            .clipShape(Capsule())
        }
    }
}
