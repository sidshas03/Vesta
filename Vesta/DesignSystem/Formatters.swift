import Foundation

// Helpers for formatting money, percentages and share counts.
enum Formatters {

    static func currency(_ value: Double, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = maximumFractionDigits == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    // e.g. 1_250_000 -> "$1.25M"
    static func compactCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.usesSignificantDigits = false

        let absValue = abs(value)
        switch absValue {
        case 1_000_000_000...:
            return sign(value) + "$" + trim(absValue / 1_000_000_000) + "B"
        case 1_000_000...:
            return sign(value) + "$" + trim(absValue / 1_000_000) + "M"
        case 10_000...:
            return sign(value) + "$" + trim(absValue / 1_000) + "K"
        default:
            return currency(value)
        }
    }

    static func signedPercent(_ fraction: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: fraction)) ?? "0%"
    }

    static func signedCurrency(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : "-"
        return prefix + currency(abs(value))
    }

    static func shares(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private static func sign(_ value: Double) -> String { value < 0 ? "-" : "" }

    private static func trim(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
