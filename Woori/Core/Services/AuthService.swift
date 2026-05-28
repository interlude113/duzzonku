import Foundation
import FirebaseAuth

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUserId: String?
    @Published var isAuthenticated = false

    private init() {
        if let user = Auth.auth().currentUser {
            self.currentUserId = user.uid
            self.isAuthenticated = true
        }
    }

    /// 익명 로그인 수행
    func signInAnonymously() async throws {
        let result = try await Auth.auth().signInAnonymously()
        self.currentUserId = result.user.uid
        self.isAuthenticated = true
    }

    /// 현재 uid 반환 (미인증 시 nil)
    var uid: String? {
        Auth.auth().currentUser?.uid
    }
}
