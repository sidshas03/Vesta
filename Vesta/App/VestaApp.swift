import SwiftUI

@main
struct VestaApp: App {
    @State private var model = AppModel.makeForLaunch()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .preferredColorScheme(.dark)
                .tint(Theme.Palette.brand)
        }
    }
}

extension AppModel {
    // Lets us launch straight into a given screen for screenshots/demos.
    // Set the DEMO_SCREEN env var (home / discover / watchlist / profile).
    // Normal launches ignore this and start at onboarding.
    static func makeForLaunch() -> AppModel {
        let model = AppModel()
        guard let screen = ProcessInfo.processInfo.environment["DEMO_SCREEN"] else {
            return model
        }
        model.profile = UserProfile(name: "Sid",
                                    goals: [.buildWealth, .retirement],
                                    risk: .aggressive,
                                    monthlyContribution: 250)
        model.hasOnboarded = true
        switch screen {
        case "discover": model.selectedTab = .discover
        case "watchlist": model.selectedTab = .watchlist
        case "profile": model.selectedTab = .profile
        default: model.selectedTab = .home
        }
        return model
    }
}
