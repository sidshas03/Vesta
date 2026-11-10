import SwiftUI

// Home screen: portfolio balance, chart, quick actions and holdings.
struct HomeView: View {
    @Environment(AppModel.self) private var model
    @State private var vm: HomeViewModel?
    @State private var selectedAsset: Asset?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    if let vm {
                        balanceHeader(vm)
                        PriceChart(points: vm.series, isUp: vm.rangeChangeFraction >= 0) { point in
                            vm.scrubbedPoint = point
                        }
                        .frame(height: 220)
                        .overlay {
                            if vm.isLoading && vm.series.isEmpty {
                                ProgressView().tint(Theme.Palette.brand)
                            }
                        }

                        RangeSelector(selection: Binding(
                            get: { vm.range },
                            set: { vm.range = $0 }
                        ))

                        quickActions
                        holdingsSection
                    } else {
                        ProgressView().tint(Theme.Palette.brand).padding(.top, 80)
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Palette.background)
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    avatarButton
                }
            }
            .navigationDestination(item: $selectedAsset) { asset in
                AssetDetailView(asset: asset)
            }
        }
        .task {
            if vm == nil { vm = HomeViewModel(marketData: model.marketData) }
            await vm?.load(for: model.portfolio)
        }
        // Reload the chart after a trade changes the total.
        .onChange(of: model.portfolio.totalValue) { _, _ in
            Task { await vm?.load(for: model.portfolio) }
        }
    }

    private var greeting: String {
        let name = model.profile?.name ?? "there"
        return "Hey, \(name) 👋"
    }

    // MARK: - Header

    private func balanceHeader(_ vm: HomeViewModel) -> some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(vm.scrubbedPoint == nil ? "Portfolio value" : "On \(vm.scrubbedPoint!.date.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.textSecondary)

            Text(Formatters.currency(vm.headlineValue(for: model.portfolio)))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Palette.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText(value: vm.headlineValue(for: model.portfolio)))
                .animation(.smooth, value: vm.headlineValue(for: model.portfolio))

            HStack(spacing: Theme.Spacing.sm) {
                ChangeBadge(fraction: vm.rangeChangeFraction)
                Text(Formatters.signedCurrency(vm.rangeChangeValue))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(vm.rangeChangeFraction >= 0 ? Theme.Palette.up : Theme.Palette.down)
                    .monospacedDigit()
                Text(vm.range.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textTertiary)
            }
        }
    }

    private var avatarButton: some View {
        Button {
            model.selectedTab = .profile
        } label: {
            Text(String((model.profile?.name ?? "V").prefix(1)))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Theme.brandGradient, in: Circle())
        }
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        HStack(spacing: Theme.Spacing.md) {
            QuickActionCard(title: "Invest", systemImage: "plus.circle.fill") {
                model.selectedTab = .discover
            }
            QuickActionCard(title: "Cash", systemImage: "dollarsign.circle.fill",
                            subtitle: Formatters.currency(model.portfolio.cash)) {
                model.selectedTab = .profile
            }
        }
    }

    // MARK: - Holdings

    private var holdingsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(title: "Your holdings")

            if model.portfolio.holdings.isEmpty {
                Card {
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("No positions yet")
                            .font(.headline)
                            .foregroundStyle(Theme.Palette.textPrimary)
                        Text("Head to Discover to buy your first asset.")
                            .font(.footnote)
                            .foregroundStyle(Theme.Palette.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.lg)
                }
            } else {
                Card(padding: Theme.Spacing.md) {
                    VStack(spacing: 0) {
                        ForEach(Array(sortedHoldings.enumerated()), id: \.element.id) { index, holding in
                            Button {
                                selectedAsset = holding.asset
                            } label: {
                                AssetRow(
                                    asset: holding.asset,
                                    trailingValue: Formatters.currency(holding.marketValue),
                                    trailingSubtitle: Formatters.signedPercent(holding.totalReturnFraction)
                                )
                            }
                            .buttonStyle(.plain)

                            if index < sortedHoldings.count - 1 {
                                Divider().overlay(Theme.Palette.stroke)
                            }
                        }
                    }
                }
            }
        }
    }

    private var sortedHoldings: [Holding] {
        model.portfolio.holdings.sorted { $0.marketValue > $1.marketValue }
    }
}

// MARK: - Quick action card

private struct QuickActionCard: View {
    let title: String
    let systemImage: String
    var subtitle: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(Theme.Palette.brandSoft)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.textSecondary)
                        .monospacedDigit()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.lg)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Palette.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environment(AppModel())
        .preferredColorScheme(.dark)
}
