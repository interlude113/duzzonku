import SwiftUI

struct CoupleSetupView: View {
    @StateObject private var viewModel = SetupViewModel()

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    headerSection

                    switch viewModel.step {
                    case .chooseMode:
                        chooseModeSection
                    case .createInput:
                        createInputSection
                    case .showCode:
                        showCodeSection
                    case .joinInput:
                        joinInputSection
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xxl)
            }

            if viewModel.isLoading {
                LoadingOverlay()
            }
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("우리")
                .font(.wooriLargeTitle)
                .foregroundStyle(.wooriPrimary)

            Text("둘만의 특별한 공간")
                .font(.wooriBody)
                .foregroundStyle(.wooriTextSecond)
        }
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Choose Mode

    private var chooseModeSection: some View {
        VStack(spacing: Spacing.md) {
            WooriButton(title: "커플 시작하기 💑", style: .primary) {
                withAnimation { viewModel.step = .createInput }
            }

            WooriButton(title: "코드 입력하기 🔑", style: .outline) {
                withAnimation { viewModel.step = .joinInput }
            }
        }
    }

    // MARK: - Create Input

    private var createInputSection: some View {
        VStack(spacing: Spacing.md) {
            WooriTextField(placeholder: "내 닉네임", text: $viewModel.nickname, icon: "person.fill")

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("사귄 날짜")
                    .font(.wooriCaption)
                    .foregroundStyle(.wooriTextSecond)

                DatePicker("사귄 날짜", selection: $viewModel.startDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.wooriPrimary)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ko_KR"))
            }
            .padding(Spacing.md)
            .background(Color.wooriSurfaceWarm)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            WooriButton(title: "완료", isLoading: viewModel.isLoading) {
                Task { await viewModel.createCouple() }
            }

            backButton
        }
    }

    // MARK: - Show Code

    private var showCodeSection: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.sm) {
                Text("커플 코드")
                    .font(.wooriHeadline)
                    .foregroundStyle(.wooriTextSecond)

                Text(viewModel.generatedKey)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundStyle(.wooriPrimary)
                    .tracking(8)
                    .padding(.vertical, Spacing.md)

                Text("상대방에게 이 코드를 공유해주세요")
                    .font(.wooriCaption)
                    .foregroundStyle(.wooriTextMuted)
            }
            .wooriCard()

            Button {
                UIPasteboard.general.string = viewModel.generatedKey
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "doc.on.doc")
                        .accessibilityLabel("복사")
                    Text("코드 복사하기")
                }
                .font(.wooriHeadline)
                .foregroundStyle(.wooriPrimary)
            }

            WooriButton(title: "시작하기 💕") {
                viewModel.completeSetup()
            }
        }
    }

    // MARK: - Join Input

    private var joinInputSection: some View {
        VStack(spacing: Spacing.md) {
            WooriTextField(placeholder: "내 닉네임", text: $viewModel.nickname, icon: "person.fill")

            WooriTextField(placeholder: "커플 코드 6자리", text: $viewModel.joinCode, icon: "key.fill")
                .textInputAutocapitalization(.characters)

            WooriButton(title: "연결하기", isLoading: viewModel.isLoading) {
                Task { await viewModel.joinCouple() }
            }

            backButton
        }
    }

    // MARK: - Back

    private var backButton: some View {
        Button {
            withAnimation {
                viewModel.step = .chooseMode
                viewModel.nickname = ""
                viewModel.joinCode = ""
            }
        } label: {
            Text("돌아가기")
                .font(.wooriBody)
                .foregroundStyle(.wooriTextMuted)
        }
    }
}
