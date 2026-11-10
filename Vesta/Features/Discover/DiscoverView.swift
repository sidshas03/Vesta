import SwiftUI

// Search and browse assets, with category filters and a trending row.
struct DiscoverView: View {
    @Environment(AppModel.self) private var model
    @State private var vm: DiscoverViewModel?
    @State private var selectedAsset: Asset?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    if let vm {
                        categoryFilters(vm)

                        if vm.query.isEmpty && vm.selectedKind == nil {
                            trendingStrip(vm)
                        }

                        resultsSection(vm)
                    } else {
                        ProgressView().tint(Theme.Palette.brand).padding(.top, 80)
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Palette.background)
            .navigationTitle("Discover")
            .searchable(text: Binding(
                get: { vm?.query ?? "" },
                set: { vm?.query = $0 }
            ), prompt: "Search stocks, ETFs, crypto")
            .navigationDestination(item: $selectedAsset) { asset in
                AssetDetailView(asset: asset)
            }
        }
        .task {
            if vm == nil { vm = DiscoverViewModel(marketData: model.marketData) }
            await vm?.load()
        }
    }

    // MARK: - Category filters

    private func categoryFilters(_ vm: DiscoverViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(Asset.Kind.allCases) { kind in
                    Button {
                        vm.selectKind(kind)
                    } label: {
                        Pill(text: kind.rawValue, systemImage: kind.systemImage,
                             isSelected: vm.selectedKind == kind)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Trending

    private func trendingStrip(_ vm: DiscoverViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(title: "Trending today")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(vm.trending) { asset in
                        Button { selectedAsset = asset } label: {
                            TrendingCard(asset: asset)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Results

    private func resultsSection(_ vm: DiscoverViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(title: vm.selectedKind?.rawValue ?? "All assets")

            if vm.filtered.isEmpty {
                Card {
                    Text("No results for \"\(vm.query)\"")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.lg)
                }
            } else {
                Card(padding: Theme.Spacing.md) {
                    VStack(spacing: 0) {
                        ForEach(Array(vm.filtered.enumerated()), id: \.element.id) { index, asset in
                            Button { selectedAsset = asset } label: {
                                AssetRow(asset: asset)
                            }
                            .buttonStyle(.plain)
                            if index < vm.filtered.count - 1 {
                                Divider().overlay(Theme.Palette.stroke)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Trending card

private struct TrendingCard: View {
    let asset: Asset

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                AssetAvatar(symbol: asset.symbol, colorIndex: asset.colorIndex, size: 36)
                Spacer()
                ChangeBadge(fraction: asset.dayChange)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.symbol)
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                Text(Formatters.currency(asset.price))
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textSecondary)
                    .monospacedDigit()
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(width: 160, alignment: .leading)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .stroke(Theme.Palette.stroke, lineWidth: 1)
        )
    }
}

#Preview {
    DiscoverView()
        .environment(AppModel())
        .preferredColorScheme(.dark)
}
