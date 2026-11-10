import SwiftUI

// Saved assets, with swipe to remove and an empty state.
struct WatchlistView: View {
    @Environment(AppModel.self) private var model
    @State private var selectedAsset: Asset?

    var body: some View {
        NavigationStack {
            Group {
                if model.watchlist.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(model.watchlist) { asset in
                            Button { selectedAsset = asset } label: {
                                AssetRow(asset: asset)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Theme.Palette.surface)
                            .listRowSeparatorTint(Theme.Palette.stroke)
                            .swipeActions {
                                Button(role: .destructive) {
                                    model.toggleWatch(asset)
                                } label: {
                                    Label("Remove", systemImage: "star.slash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.Palette.background)
            .navigationTitle("Watchlist")
            .navigationDestination(item: $selectedAsset) { asset in
                AssetDetailView(asset: asset)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "star")
                .font(.system(size: 52))
                .foregroundStyle(Theme.Palette.brandSoft)
            Text("Your watchlist is empty")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.Palette.textPrimary)
            Text("Tap the star on any asset to follow its price here.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.textSecondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Explore assets", icon: "sparkle.magnifyingglass") {
                model.selectedTab = .discover
            }
            .padding(.top, Theme.Spacing.md)
            .frame(maxWidth: 260)
        }
        .padding(Theme.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WatchlistView()
        .environment(AppModel())
        .preferredColorScheme(.dark)
}
