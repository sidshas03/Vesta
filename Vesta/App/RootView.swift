import SwiftUI

// Shows onboarding first, then the tab bar.
struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Theme.Palette.background.ignoresSafeArea()

            if model.hasOnboarded {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
    }
}

struct MainTabView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        TabView(selection: $model.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppModel.Tab.home)

            DiscoverView()
                .tabItem { Label("Discover", systemImage: "sparkle.magnifyingglass") }
                .tag(AppModel.Tab.discover)

            WatchlistView()
                .tabItem { Label("Watchlist", systemImage: "star.fill") }
                .tag(AppModel.Tab.watchlist)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(AppModel.Tab.profile)
        }
    }
}

#Preview {
    RootView()
        .environment(AppModel())
        .preferredColorScheme(.dark)
}
