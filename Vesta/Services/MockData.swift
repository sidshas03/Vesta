import Foundation

// Sample data used by the app.
enum MockData {

    static let assets: [Asset] = [
        Asset(id: "AAPL", symbol: "AAPL", name: "Apple Inc.", kind: .stock,
              price: 232.14, dayChange: 0.0128, marketCap: 3_520_000_000_000, colorIndex: 0,
              about: "Designs and sells consumer electronics, software and services. A classic core holding for long-term investors."),
        Asset(id: "NVDA", symbol: "NVDA", name: "NVIDIA Corp.", kind: .stock,
              price: 178.92, dayChange: 0.0342, marketCap: 4_350_000_000_000, colorIndex: 1,
              about: "Designs GPUs powering gaming and the AI revolution. High growth, higher volatility."),
        Asset(id: "TSLA", symbol: "TSLA", name: "Tesla Inc.", kind: .stock,
              price: 412.55, dayChange: -0.0215, marketCap: 1_310_000_000_000, colorIndex: 2,
              about: "Electric vehicles, energy storage and autonomy. A favorite of younger investors."),
        Asset(id: "AMZN", symbol: "AMZN", name: "Amazon.com Inc.", kind: .stock,
              price: 221.07, dayChange: 0.0061, marketCap: 2_340_000_000_000, colorIndex: 3,
              about: "E-commerce and cloud computing (AWS) leader with diversified revenue streams."),
        Asset(id: "MSFT", symbol: "MSFT", name: "Microsoft Corp.", kind: .stock,
              price: 498.31, dayChange: 0.0044, marketCap: 3_700_000_000_000, colorIndex: 4,
              about: "Enterprise software, cloud (Azure) and AI. Steady compounder with broad exposure."),
        Asset(id: "VOO", symbol: "VOO", name: "Vanguard S&P 500 ETF", kind: .etf,
              price: 585.40, dayChange: 0.0052, marketCap: 1_450_000_000_000, colorIndex: 5,
              about: "Tracks the 500 largest U.S. companies. A diversified, low-cost foundation for any portfolio."),
        Asset(id: "QQQ", symbol: "QQQ", name: "Invesco QQQ Trust", kind: .etf,
              price: 512.88, dayChange: 0.0089, marketCap: 320_000_000_000, colorIndex: 0,
              about: "Tracks the Nasdaq-100 index of large tech companies."),
        Asset(id: "BTC", symbol: "BTC", name: "Bitcoin", kind: .crypto,
              price: 97_420.00, dayChange: 0.0276, marketCap: 1_920_000_000_000, colorIndex: 2,
              about: "The original cryptocurrency and a digital store of value. Highly volatile."),
        Asset(id: "ETH", symbol: "ETH", name: "Ethereum", kind: .crypto,
              price: 3_612.44, dayChange: -0.0143, marketCap: 435_000_000_000, colorIndex: 1,
              about: "A programmable blockchain powering smart contracts and much of DeFi."),
        Asset(id: "SOL", symbol: "SOL", name: "Solana", kind: .crypto,
              price: 214.73, dayChange: 0.0511, marketCap: 103_000_000_000, colorIndex: 3,
              about: "A high-throughput blockchain popular for fast, low-cost transactions.")
    ]

    static func asset(_ symbol: String) -> Asset {
        assets.first { $0.symbol == symbol }!
    }

    // Starting portfolio so the home screen isn't empty.
    static var samplePortfolio: Portfolio {
        Portfolio(
            cash: 1_240.52,
            holdings: [
                Holding(id: "AAPL", asset: asset("AAPL"), shares: 12, averageCost: 198.40),
                Holding(id: "NVDA", asset: asset("NVDA"), shares: 20, averageCost: 120.15),
                Holding(id: "VOO", asset: asset("VOO"), shares: 6, averageCost: 540.10),
                Holding(id: "BTC", asset: asset("BTC"), shares: 0.08, averageCost: 68_000.00),
                Holding(id: "ETH", asset: asset("ETH"), shares: 1.5, averageCost: 3_100.00)
            ]
        )
    }

    static let defaultWatchlist: [String] = ["TSLA", "MSFT", "QQQ", "SOL"]
}
