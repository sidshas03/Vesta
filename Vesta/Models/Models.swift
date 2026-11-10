import Foundation

// MARK: - Asset

struct Asset: Identifiable, Hashable {
    let id: String          // symbol, e.g. "AAPL"
    let symbol: String
    let name: String
    let kind: Kind
    let price: Double
    let dayChange: Double   // fraction, e.g. 0.0123 == +1.23%
    let marketCap: Double
    let colorIndex: Int
    let about: String

    enum Kind: String, CaseIterable, Identifiable {
        case stock = "Stocks"
        case etf = "ETFs"
        case crypto = "Crypto"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .stock: return "building.2.fill"
            case .etf: return "chart.pie.fill"
            case .crypto: return "bitcoinsign.circle.fill"
            }
        }
    }
}

// MARK: - Price series

struct PricePoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum ChartRange: String, CaseIterable, Identifiable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case year = "1Y"

    var id: String { rawValue }

    // Number of points to draw for this range.
    var sampleCount: Int {
        switch self {
        case .day: return 48
        case .week: return 56
        case .month: return 60
        case .threeMonths: return 66
        case .year: return 72
        }
    }

    var interval: TimeInterval {
        switch self {
        case .day: return 60 * 30
        case .week: return 60 * 60 * 3
        case .month: return 60 * 60 * 12
        case .threeMonths: return 60 * 60 * 36
        case .year: return 60 * 60 * 24 * 5
        }
    }
}

// MARK: - Holding & Portfolio

struct Holding: Identifiable, Hashable {
    let id: String          // asset symbol
    let asset: Asset
    var shares: Double
    var averageCost: Double // average cost per share

    var marketValue: Double { shares * asset.price }
    var costValue: Double { shares * averageCost }
    var totalReturn: Double { marketValue - costValue }
    var totalReturnFraction: Double {
        guard costValue > 0 else { return 0 }
        return totalReturn / costValue
    }
    var dayChangeValue: Double {
        marketValue - (marketValue / (1 + asset.dayChange))
    }
}

struct Portfolio {
    var cash: Double
    var holdings: [Holding]

    var investedValue: Double { holdings.reduce(0) { $0 + $1.marketValue } }
    var totalValue: Double { cash + investedValue }

    var totalCostBasis: Double { holdings.reduce(0) { $0 + $1.costValue } }
    var totalReturn: Double { investedValue - totalCostBasis }
    var totalReturnFraction: Double {
        guard totalCostBasis > 0 else { return 0 }
        return totalReturn / totalCostBasis
    }

    var dayChangeValue: Double { holdings.reduce(0) { $0 + $1.dayChangeValue } }
    var dayChangeFraction: Double {
        let previous = investedValue - dayChangeValue
        guard previous > 0 else { return 0 }
        return dayChangeValue / previous
    }

    // Slices (including cash) sorted by size, used by the donut chart.
    var allocation: [AllocationSlice] {
        var slices = holdings.map {
            AllocationSlice(label: $0.asset.symbol, value: $0.marketValue, colorIndex: $0.asset.colorIndex)
        }
        if cash > 0 {
            slices.append(AllocationSlice(label: "Cash", value: cash, colorIndex: 99))
        }
        return slices.sorted { $0.value > $1.value }
    }

    func holding(for symbol: String) -> Holding? {
        holdings.first { $0.id == symbol }
    }
}

struct AllocationSlice: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let value: Double
    let colorIndex: Int
}

// MARK: - User & onboarding preferences

struct UserProfile {
    var name: String
    var goals: Set<InvestingGoal>
    var risk: RiskLevel
    var monthlyContribution: Double
}

enum InvestingGoal: String, CaseIterable, Identifiable {
    case retirement = "Retirement"
    case buildWealth = "Build wealth"
    case bigPurchase = "Big purchase"
    case learn = "Learn investing"
    case emergencyFund = "Emergency fund"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .retirement: return "beach.umbrella.fill"
        case .buildWealth: return "chart.line.uptrend.xyaxis"
        case .bigPurchase: return "house.fill"
        case .learn: return "graduationcap.fill"
        case .emergencyFund: return "shield.lefthalf.filled"
        }
    }
}

enum RiskLevel: String, CaseIterable, Identifiable {
    case conservative = "Conservative"
    case balanced = "Balanced"
    case aggressive = "Aggressive"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .conservative: return "Steady growth, lower swings"
        case .balanced: return "A healthy mix of growth and stability"
        case .aggressive: return "Maximize growth, embrace volatility"
        }
    }

    var systemImage: String {
        switch self {
        case .conservative: return "tortoise.fill"
        case .balanced: return "scalemass.fill"
        case .aggressive: return "hare.fill"
        }
    }
}
