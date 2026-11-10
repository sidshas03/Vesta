import SwiftUI
import Observation

@Observable
@MainActor
final class HomeViewModel {
    private let marketData: MarketDataService

    var range: ChartRange = .week {
        didSet { Task { await loadSeries() } }
    }
    var series: [PricePoint] = []
    var isLoading = false

    // Point the user is currently dragging over on the chart.
    var scrubbedPoint: PricePoint?

    init(marketData: MarketDataService) {
        self.marketData = marketData
    }

    func load(for portfolio: Portfolio) async {
        self.portfolio = portfolio
        await loadSeries()
    }

    private var portfolio: Portfolio?

    private func loadSeries() async {
        guard let portfolio else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            series = try await marketData.portfolioSeries(for: portfolio, range: range)
        } catch {
            series = []
        }
    }

    func headlineValue(for portfolio: Portfolio) -> Double {
        scrubbedPoint?.value ?? portfolio.totalValue
    }

    // Change from the first to the last point of the series.
    var rangeChangeFraction: Double {
        guard let first = series.first?.value, first > 0, let last = series.last?.value else { return 0 }
        return (last - first) / first
    }

    var rangeChangeValue: Double {
        guard let first = series.first?.value, let last = series.last?.value else { return 0 }
        return last - first
    }
}
