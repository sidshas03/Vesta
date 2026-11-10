import SwiftUI

// Detail for one asset: price chart, your position, stats and buy/sell.
struct AssetDetailView: View {
    @Environment(AppModel.self) private var model
    let asset: Asset

    @State private var vm: AssetDetailViewModel?
    @State private var showTrade = false
    @State private var tradeSide: TradeSheet.Side = .buy

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                if let vm {
                    priceHeader(vm)
                    PriceChart(points: vm.series, isUp: vm.rangeChangeFraction >= 0) { point in
                        vm.scrubbedPoint = point
                    }
                    .frame(height: 240)
                    .overlay {
                        if vm.isLoading && vm.series.isEmpty {
                            ProgressView().tint(Theme.Palette.brand)
                        }
                    }
                    RangeSelector(selection: Binding(
                        get: { vm.range },
                        set: { vm.range = $0 }
                    ))

                    if let holding = model.portfolio.holding(for: asset.symbol) {
                        positionCard(holding)
                    }

                    statsCard
                    aboutCard
                } else {
                    ProgressView().tint(Theme.Palette.brand).padding(.top, 80)
                }
            }
            .padding(Theme.Spacing.lg)
            .padding(.bottom, 100)
        }
        .background(Theme.Palette.background)
        .navigationTitle(asset.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    model.toggleWatch(asset)
                } label: {
                    Image(systemName: model.isWatched(asset) ? "star.fill" : "star")
                        .foregroundStyle(model.isWatched(asset) ? Theme.Palette.brandSoft : Theme.Palette.textSecondary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { tradeBar }
        .sheet(isPresented: $showTrade) {
            TradeSheet(asset: asset, side: tradeSide)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task {
            if vm == nil { vm = AssetDetailViewModel(asset: asset, marketData: model.marketData) }
            await vm?.load()
        }
    }

    // MARK: - Header

    private func priceHeader(_ vm: AssetDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.md) {
                AssetAvatar(symbol: asset.symbol, colorIndex: asset.colorIndex, size: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.name)
                        .font(.headline)
                        .foregroundStyle(Theme.Palette.textPrimary)
                    Text(asset.kind.rawValue)
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.textSecondary)
                }
            }
            Text(Formatters.currency(vm.headlinePrice))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Palette.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText(value: vm.headlinePrice))
                .animation(.smooth, value: vm.headlinePrice)
            HStack(spacing: Theme.Spacing.sm) {
                ChangeBadge(fraction: vm.rangeChangeFraction)
                Text(vm.range.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textTertiary)
            }
        }
    }

    // MARK: - Position

    private func positionCard(_ holding: Holding) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Your position")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                HStack {
                    statPair("Value", Formatters.currency(holding.marketValue))
                    Spacer()
                    statPair("Shares", Formatters.shares(holding.shares))
                    Spacer()
                    statPair("Return", Formatters.signedPercent(holding.totalReturnFraction),
                             color: holding.totalReturn >= 0 ? Theme.Palette.up : Theme.Palette.down)
                }
            }
        }
    }

    // MARK: - Stats

    private var statsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Key stats")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                HStack {
                    statPair("Price", Formatters.currency(asset.price))
                    Spacer()
                    statPair("Day", Formatters.signedPercent(asset.dayChange),
                             color: asset.dayChange >= 0 ? Theme.Palette.up : Theme.Palette.down)
                    Spacer()
                    statPair("Mkt cap", Formatters.compactCurrency(asset.marketCap))
                }
            }
        }
    }

    private var aboutCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("About \(asset.symbol)")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                Text(asset.about)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }
        }
    }

    private func statPair(_ label: String, _ value: String, color: Color = Theme.Palette.textPrimary) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.Palette.textTertiary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }

    // MARK: - Trade bar

    private var tradeBar: some View {
        HStack(spacing: Theme.Spacing.md) {
            SecondaryButton(title: "Sell") {
                tradeSide = .sell
                showTrade = true
            }
            PrimaryButton(title: "Buy") {
                tradeSide = .buy
                showTrade = true
            }
        }
        .padding(Theme.Spacing.lg)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        AssetDetailView(asset: MockData.asset("AAPL"))
    }
    .environment(AppModel())
    .preferredColorScheme(.dark)
}
