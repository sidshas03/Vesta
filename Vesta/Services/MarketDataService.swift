import Foundation

// Protocol so the views don't depend on a concrete data source.
// A real network client could replace the mock later.
protocol MarketDataService: Sendable {
    func fetchAssets() async throws -> [Asset]
    func priceSeries(for asset: Asset, range: ChartRange) async throws -> [PricePoint]
    func portfolioSeries(for portfolio: Portfolio, range: ChartRange) async throws -> [PricePoint]
}

// Offline data source. Prices use a seeded random walk so the charts
// look the same every launch.
struct MockMarketDataService: MarketDataService {

    func fetchAssets() async throws -> [Asset] {
        try await Task.sleep(nanoseconds: 250_000_000) // fake network delay
        return MockData.assets
    }

    func priceSeries(for asset: Asset, range: ChartRange) async throws -> [PricePoint] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return Self.randomWalk(
            end: asset.price,
            change: asset.dayChange,
            range: range,
            seed: UInt64(abs(asset.symbol.hashValue & 0xFFFFFF))
        )
    }

    func portfolioSeries(for portfolio: Portfolio, range: ChartRange) async throws -> [PricePoint] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return Self.randomWalk(
            end: portfolio.totalValue,
            change: portfolio.dayChangeFraction,
            range: range,
            seed: 7_412
        )
    }

    // MARK: - Series generation

    // Builds a random walk that ends exactly on `end` so the chart matches
    // the price/value shown in the header.
    static func randomWalk(end: Double, change: Double, range: ChartRange, seed: UInt64) -> [PricePoint] {
        let count = range.sampleCount
        guard count > 1 else { return [] }

        var rng = SeededGenerator(seed: seed == 0 ? 1 : seed)
        let volatility = volatility(for: range, dayChange: change)

        var values = [Double](repeating: 0, count: count)
        values[0] = 1.0
        for i in 1..<count {
            let shock = Double.random(in: -volatility...volatility, using: &rng)
            let drift = change / Double(count)
            values[i] = max(0.05, values[i - 1] * (1 + shock + drift))
        }

        // Scale so the last value equals `end`.
        let scale = end / values[count - 1]
        let now = Date()
        return values.enumerated().map { index, raw in
            let date = now.addingTimeInterval(-Double(count - 1 - index) * range.interval)
            return PricePoint(date: date, value: raw * scale)
        }
    }

    private static func volatility(for range: ChartRange, dayChange: Double) -> Double {
        let base: Double
        switch range {
        case .day: base = 0.004
        case .week: base = 0.008
        case .month: base = 0.012
        case .threeMonths: base = 0.016
        case .year: base = 0.022
        }
        return base + abs(dayChange) * 0.5
    }
}

// SplitMix64 PRNG so the random data is reproducible.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
