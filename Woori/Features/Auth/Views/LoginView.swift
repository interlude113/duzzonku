import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.wooriBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxl)

                    // 로고 영역
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.wooriPrimary)
                            .accessibilityLabel("Woori 앱 로고")

                        Text("Woori")
                            .font(.wooriLargeTitle)
                            .foregroundStyle(Color.wooriTextPrimary)

                        Text("우리만의 공간")
                            .font(.wooriBody)
                            .foregroundStyle(Color.wooriTextSecond)
                    }

                    Spacer().frame(height: Spacing.lg)

                    // 입력 폼
                    VStack(spacing: Spacing.md) {
                        WooriTextField(
                            placeholder: "이메일",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        WooriTextField(
                            placeholder: "비밀번호",
                            text: $password,
                            isSecure: true
                        )
                    }

                    // 에러 메시지
                    if let error = errorMessage {
                        Text(error)
                            .font(.wooriCaption)
                            .foregroundStyle(Color.wooriError)
                    }

                    // 버튼
                    VStack(spacing: Spacing.sm) {
                        WooriButton(
                            title: isSignUp ? "회원가입" : "로그인",
                            isLoading: isLoading
                        ) {
                            Task { await authenticate() }
                        }

                        WooriButton(
                            title: isSignUp ? "이미 계정이 있어요" : "새 계정 만들기",
                            style: .text
                        ) {
                            withAnimation { isSignUp.toggle() }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }

    private func authenticate() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력해주세요."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
