import SwiftUI
import Observation

@Observable
@MainActor
final class DiscoverViewModel {
    private let marketData: MarketDataService

    var query: String = ""
    var selectedKind: Asset.Kind? = nil
    var assets: [Asset] = []
    var isLoading = false

    init(marketData: MarketDataService) {
        self.marketData = marketData
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do { assets = try await marketData.fetchAssets() }
        catch { assets = MockData.assets }
    }

    var filtered: [Asset] {
        assets.filter { asset in
            let matchesKind = selectedKind == nil || asset.kind == selectedKind
            let trimmed = query.trimmingCharacters(in: .whitespaces)
            let matchesQuery = trimmed.isEmpty
                || asset.symbol.localizedCaseInsensitiveContains(trimmed)
                || asset.name.localizedCaseInsensitiveContains(trimmed)
            return matchesKind && matchesQuery
        }
    }

    // Top 5 movers by absolute day change.
    var trending: [Asset] {
        assets.sorted { abs($0.dayChange) > abs($1.dayChange) }.prefix(5).map { $0 }
    }

    func selectKind(_ kind: Asset.Kind?) {
        Haptics.selection()
        withAnimation(.smooth) {
            selectedKind = (selectedKind == kind) ? nil : kind
        }
    }
}
