import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener

    private func listenToAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }

    // MARK: - Email/Password Sign Up

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        currentUser = result.user
        isAuthenticated = true
    }

    // MARK: - Email/Password Sign In

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        currentUser = result.user
        isAuthenticated = true
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Helpers

    var userId: String? { currentUser?.uid }
}
