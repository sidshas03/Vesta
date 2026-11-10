import SwiftUI
import Observation

@Observable
@MainActor
final class AssetDetailViewModel {
    let asset: Asset
    private let marketData: MarketDataService

    var range: ChartRange = .month {
        didSet { Task { await loadSeries() } }
    }
    var series: [PricePoint] = []
    var isLoading = false
    var scrubbedPoint: PricePoint?

    init(asset: Asset, marketData: MarketDataService) {
        self.asset = asset
        self.marketData = marketData
    }

    func load() async { await loadSeries() }

    private func loadSeries() async {
        isLoading = true
        defer { isLoading = false }
        do { series = try await marketData.priceSeries(for: asset, range: range) }
        catch { series = [] }
    }

    var headlinePrice: Double { scrubbedPoint?.value ?? asset.price }

    var rangeChangeFraction: Double {
        guard let first = series.first?.value, first > 0, let last = series.last?.value else {
            return asset.dayChange
        }
        return (last - first) / first
    }
}
