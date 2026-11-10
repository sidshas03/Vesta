import SwiftUI
import Observation

// Shared state for the app: session, portfolio, watchlist and trades.
@Observable
@MainActor
final class AppModel {

    // MARK: - Dependencies

    let marketData: MarketDataService

    // MARK: - Session

    var hasOnboarded: Bool = false
    var profile: UserProfile?
    var selectedTab: Tab = .home

    // MARK: - Data

    var portfolio: Portfolio
    var assets: [Asset] = MockData.assets
    var watchlistSymbols: [String] = MockData.defaultWatchlist

    enum Tab: Hashable { case home, discover, watchlist, profile }

    init(marketData: MarketDataService = MockMarketDataService(),
         portfolio: Portfolio = MockData.samplePortfolio) {
        self.marketData = marketData
        self.portfolio = portfolio
    }

    // MARK: - Onboarding

    func completeOnboarding(with profile: UserProfile) {
        self.profile = profile
        withAnimation(.smooth) { hasOnboarded = true }
        Haptics.success()
    }

    // MARK: - Watchlist

    func isWatched(_ asset: Asset) -> Bool {
        watchlistSymbols.contains(asset.symbol)
    }

    func toggleWatch(_ asset: Asset) {
        Haptics.selection()
        if let index = watchlistSymbols.firstIndex(of: asset.symbol) {
            watchlistSymbols.remove(at: index)
        } else {
            watchlistSymbols.append(asset.symbol)
        }
    }

    var watchlist: [Asset] {
        watchlistSymbols.compactMap { symbol in assets.first { $0.symbol == symbol } }
    }

    // MARK: - Trading

    enum TradeError: LocalizedError {
        case insufficientFunds
        case insufficientShares
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .insufficientFunds: return "You don't have enough buying power."
            case .insufficientShares: return "You don't own that many shares."
            case .invalidAmount: return "Enter an amount greater than zero."
            }
        }
    }

    // Buy a dollar amount of an asset and update cash + average cost.
    func buy(_ asset: Asset, dollarAmount: Double) throws {
        guard dollarAmount > 0 else { throw TradeError.invalidAmount }
        guard dollarAmount <= portfolio.cash else { throw TradeError.insufficientFunds }

        let shares = dollarAmount / asset.price
        if let index = portfolio.holdings.firstIndex(where: { $0.id == asset.symbol }) {
            var holding = portfolio.holdings[index]
            let newShares = holding.shares + shares
            holding.averageCost = (holding.costValue + dollarAmount) / newShares
            holding.shares = newShares
            portfolio.holdings[index] = holding
        } else {
            portfolio.holdings.append(
                Holding(id: asset.symbol, asset: asset, shares: shares, averageCost: asset.price)
            )
        }
        portfolio.cash -= dollarAmount
        Haptics.success()
    }

    // Sell a dollar amount of an asset and add the proceeds to cash.
    func sell(_ asset: Asset, dollarAmount: Double) throws {
        guard dollarAmount > 0 else { throw TradeError.invalidAmount }
        guard let index = portfolio.holdings.firstIndex(where: { $0.id == asset.symbol }) else {
            throw TradeError.insufficientShares
        }
        var holding = portfolio.holdings[index]
        guard dollarAmount <= holding.marketValue + 0.001 else { throw TradeError.insufficientShares }

        let shares = dollarAmount / asset.price
        holding.shares = max(0, holding.shares - shares)
        if holding.shares < 0.0001 {
            portfolio.holdings.remove(at: index)
        } else {
            portfolio.holdings[index] = holding
        }
        portfolio.cash += dollarAmount
        Haptics.success()
    }
}
