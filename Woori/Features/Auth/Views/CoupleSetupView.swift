import SwiftUI

struct CoupleSetupView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var mode: SetupMode = .select
    @State private var coupleName = ""
    @State private var startDate = Date()
    @State private var inviteCode = ""

    enum SetupMode {
        case select, create, join
    }

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xl)

                    Image(systemName: "person.2.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.wooriPrimary)
                        .accessibilityHidden(true)

                    Text("커플 연결")
                        .font(.wooriTitle)
                        .foregroundStyle(Color.wooriTextPrimary)

                    switch mode {
                    case .select:
                        selectView
                    case .create:
                        createView
                    case .join:
                        joinView
                    }

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.wooriCaption)
                            .foregroundStyle(Color.wooriError)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }

    // MARK: - Select Mode

    private var selectView: some View {
        VStack(spacing: Spacing.md) {
            Text("상대방과 함께 우리만의 공간을 만들어보세요")
                .font(.wooriBody)
                .foregroundStyle(Color.wooriTextSecond)
                .multilineTextAlignment(.center)

            WooriButton(title: "새 커플 시작하기") {
                withAnimation { mode = .create }
            }

            WooriButton(title: "초대 코드 입력하기", style: .secondary) {
                withAnimation { mode = .join }
            }

            WooriButton(title: "로그아웃", style: .text) {
                try? authService.signOut()
            }
        }
    }

    // MARK: - Create Couple

    private var createView: some View {
        VStack(spacing: Spacing.md) {
            WooriTextField(placeholder: "커플 이름 (예: 우리 커플)", text: $coupleName)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("사귄 날짜")
                    .font(.wooriCaption)
                    .foregroundStyle(Color.wooriTextSecond)
                DatePicker(
                    "사귄 날짜",
                    selection: $startDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.wooriPrimary)
                .labelsHidden()
            }
            .wooriCard(backgroundColor: .wooriSurfaceWarm)

            WooriButton(
                title: "시작하기",
                isLoading: authViewModel.isLoading
            ) {
                guard let userId = authService.userId else { return }
                Task {
                    await authViewModel.createCouple(
                        name: coupleName.isEmpty ? "우리 커플" : coupleName,
                        startDate: startDate,
                        userId: userId
                    )
                }
            }

            WooriButton(title: "뒤로", style: .text) {
                withAnimation { mode = .select }
            }
        }
    }

    // MARK: - Join Couple

    private var joinView: some View {
        VStack(spacing: Spacing.md) {
            Text("상대방에게 받은 초대 코드를 입력해주세요")
                .font(.wooriBody)
                .foregroundStyle(Color.wooriTextSecond)
                .multilineTextAlignment(.center)

            WooriTextField(placeholder: "초대 코드 6자리", text: $inviteCode)
                .textInputAutocapitalization(.characters)

            WooriButton(
                title: "연결하기",
                isLoading: authViewModel.isLoading
            ) {
                guard let userId = authService.userId else { return }
                Task {
                    await authViewModel.joinCouple(
                        inviteCode: inviteCode.uppercased(),
                        userId: userId
                    )
                }
            }

            WooriButton(title: "뒤로", style: .text) {
                withAnimation { mode = .select }
            }
        }
    }
}
