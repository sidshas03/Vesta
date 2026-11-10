import SwiftUI

// Row showing an asset, its price and day change.
struct AssetRow: View {
    let asset: Asset
    var trailingValue: String? = nil
    var trailingSubtitle: String? = nil

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            AssetAvatar(symbol: asset.symbol, colorIndex: asset.colorIndex)

            VStack(alignment: .leading, spacing: 2) {
                Text(asset.symbol)
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                Text(asset.name)
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(trailingValue ?? Formatters.currency(asset.price))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.Palette.textPrimary)
                    .monospacedDigit()
                if let trailingSubtitle {
                    Text(trailingSubtitle)
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.textSecondary)
                } else {
                    ChangeBadge(fraction: asset.dayChange, style: .plain)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.sm)
        .contentShape(Rectangle())
    }
}
