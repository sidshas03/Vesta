import SwiftUI

// Buy/sell sheet with a keypad, quick amounts and basic validation.
struct TradeSheet: View {
    enum Side { case buy, sell

        var title: String { self == .buy ? "Buy" : "Sell" }
        var verb: String { self == .buy ? "Buy" : "Sell" }
    }

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let asset: Asset
    @State var side: Side
    @State private var amountString: String = "0"
    @State private var errorMessage: String?
    @State private var didComplete = false

    private var amount: Double { Double(amountString) ?? 0 }

    private var availableLabel: String {
        switch side {
        case .buy:
            return "Buying power \(Formatters.currency(model.portfolio.cash))"
        case .sell:
            let value = model.portfolio.holding(for: asset.symbol)?.marketValue ?? 0
            return "You own \(Formatters.currency(value))"
        }
    }

    private var estimatedShares: Double { asset.price > 0 ? amount / asset.price : 0 }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            if didComplete {
                successView
            } else {
                sideToggle
                amountDisplay
                quickAmounts
                Keypad(amountString: $amountString) { errorMessage = nil }
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.down)
                }
                PrimaryButton(title: "\(side.verb) \(asset.symbol)", isEnabled: amount > 0) {
                    execute()
                }
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Theme.Palette.background)
    }

    // MARK: - Side toggle

    private var sideToggle: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach([Side.buy, Side.sell], id: \.title) { option in
                Button {
                    Haptics.selection()
                    withAnimation(.smooth) { side = option; errorMessage = nil }
                } label: {
                    Text(option.title)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .foregroundStyle(side == option ? .white : Theme.Palette.textSecondary)
                        .background(
                            side == option ? AnyShapeStyle(Theme.Palette.brand) : AnyShapeStyle(Color.clear),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Theme.Palette.surface, in: Capsule())
    }

    // MARK: - Amount display

    private var amountDisplay: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("$\(amountString)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Palette.textPrimary)
                .contentTransition(.numericText(value: amount))
                .animation(.smooth, value: amount)
            Text("≈ \(Formatters.shares(estimatedShares)) \(asset.symbol) · \(availableLabel)")
                .font(.footnote)
                .foregroundStyle(Theme.Palette.textSecondary)
        }
        .padding(.top, Theme.Spacing.md)
    }

    private var quickAmounts: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach([25.0, 50.0, 100.0, 250.0], id: \.self) { value in
                Button {
                    Haptics.selection()
                    amountString = String(Int(value))
                    errorMessage = nil
                } label: {
                    Text("$\(Int(value))")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .foregroundStyle(Theme.Palette.textPrimary)
                        .background(Theme.Palette.surface, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Success

    private var successView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.Palette.up)
            Text("\(side.verb) order placed")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.Palette.textPrimary)
            Text("\(Formatters.currency(amount)) of \(asset.symbol)")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.textSecondary)
            Spacer()
            PrimaryButton(title: "Done") { dismiss() }
        }
    }

    // MARK: - Execution

    private func execute() {
        do {
            switch side {
            case .buy: try model.buy(asset, dollarAmount: amount)
            case .sell: try model.sell(asset, dollarAmount: amount)
            }
            withAnimation(.smooth) { didComplete = true }
        } catch {
            errorMessage = error.localizedDescription
            Haptics.selection()
        }
    }
}

// MARK: - Keypad

private struct Keypad: View {
    @Binding var amountString: String
    var onChange: () -> Void

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            Haptics.tap()
                            handle(key)
                            onChange()
                        } label: {
                            Text(key)
                                .font(.title2.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundStyle(Theme.Palette.textPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func handle(_ key: String) {
        switch key {
        case "⌫":
            amountString = String(amountString.dropLast())
            if amountString.isEmpty { amountString = "0" }
        case ".":
            if !amountString.contains(".") { amountString += "." }
        default:
            if amountString == "0" { amountString = key }
            else if amountString.count < 9 { amountString += key }
        }
    }
}

#Preview {
    TradeSheet(asset: MockData.asset("AAPL"), side: .buy)
        .environment(AppModel())
        .preferredColorScheme(.dark)
}
