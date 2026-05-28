import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var coupleSession: CoupleSession
    @EnvironmentObject private var tabRouter: TabRouter

    var body: some View {
        Group {
            if !authService.isAuthenticated {
                LoadingOverlay(message: "연결 중...")
            } else if !coupleSession.isSetupDone {
                CoupleSetupView()
            } else {
                mainTabView
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
        .animation(.easeInOut, value: coupleSession.isSetupDone)
    }

    private var mainTabView: some View {
        TabView(selection: $tabRouter.selectedTab) {
            HomeView()
                .tabItem {
                    Label(TabRouter.Tab.home.title, systemImage: TabRouter.Tab.home.icon)
                }
                .tag(TabRouter.Tab.home)

            AnniversaryView()
                .tabItem {
                    Label(TabRouter.Tab.anniversary.title, systemImage: TabRouter.Tab.anniversary.icon)
                }
                .tag(TabRouter.Tab.anniversary)

            LettersView()
                .tabItem {
                    Label(TabRouter.Tab.letters.title, systemImage: TabRouter.Tab.letters.icon)
                }
                .tag(TabRouter.Tab.letters)

            WooriMapView()
                .tabItem {
                    Label(TabRouter.Tab.map.title, systemImage: TabRouter.Tab.map.icon)
                }
                .tag(TabRouter.Tab.map)

            DateView()
                .tabItem {
                    Label(TabRouter.Tab.date.title, systemImage: TabRouter.Tab.date.icon)
                }
                .tag(TabRouter.Tab.date)
        }
        .tint(.wooriPrimary)
    }
}
