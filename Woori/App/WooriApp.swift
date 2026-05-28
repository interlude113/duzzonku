import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct WooriApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var coupleSession = CoupleSession.shared
    @StateObject private var tabRouter = TabRouter()

    init() {
        FirebaseApp.configure()
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(coupleSession)
                .environmentObject(tabRouter)
                .task {
                    await signInIfNeeded()
                }
        }
    }

    private func signInIfNeeded() async {
        guard Auth.auth().currentUser == nil else {
            authService.currentUserId = Auth.auth().currentUser?.uid
            authService.isAuthenticated = true
            return
        }
        do {
            try await authService.signInAnonymously()
        } catch {
            print("Anonymous sign-in failed: \(error.localizedDescription)")
        }
    }

    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.wooriSurface)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
