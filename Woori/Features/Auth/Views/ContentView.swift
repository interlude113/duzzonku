import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var authService: AuthService

    var body: some View {
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

            GalleryView()
                .tabItem {
                    Label(TabRouter.Tab.gallery.title, systemImage: TabRouter.Tab.gallery.icon)
                }
                .tag(TabRouter.Tab.gallery)

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
        }
        .tint(.wooriPrimary)
    }
}
