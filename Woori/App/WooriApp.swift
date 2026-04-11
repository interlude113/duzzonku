import SwiftUI

@main
struct WooriApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    @StateObject private var tabRouter = TabRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(tabRouter)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                AuthenticatedRouter()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

struct AuthenticatedRouter: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoading {
                LoadingOverlay()
            } else if authViewModel.coupleId == nil {
                CoupleSetupView()
                    .environmentObject(authViewModel)
            } else {
                ContentView()
                    .environmentObject(authViewModel)
            }
        }
        .task {
            if let userId = authService.userId {
                await authViewModel.loadCouple(for: userId)
            }
        }
    }
}
