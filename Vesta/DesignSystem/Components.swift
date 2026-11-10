import SwiftUI

// MARK: - Card container

struct Card<Content: View>: View {
    var padding: CGFloat = Theme.Spacing.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Palette.stroke, lineWidth: 1)
            )
    }
}

// MARK: - Primary button

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.tap()
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon { Image(systemName: icon) }
                    Text(title).fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .fill(Theme.brandGradient)
                    .opacity(isEnabled ? 1 : 0.4)
            )
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Secondary button

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.tap()
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon { Image(systemName: icon) }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(Theme.Palette.textPrimary)
            .background(Theme.Palette.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Palette.stroke, lineWidth: 1)
            )
        }
    }
}

// MARK: - Pill / chip

struct Pill: View {
    let text: String
    var systemImage: String? = nil
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage) }
            Text(text)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .foregroundStyle(isSelected ? Color.white : Theme.Palette.textSecondary)
        .background(isSelected ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Theme.Palette.surfaceElevated))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Theme.Palette.stroke, lineWidth: isSelected ? 0 : 1)
        )
    }
}

// MARK: - Change badge (up/down)

struct ChangeBadge: View {
    let fraction: Double
    var style: Style = .badge

    enum Style { case badge, plain }

    private var isUp: Bool { fraction >= 0 }
    private var color: Color { isUp ? Theme.Palette.up : Theme.Palette.down }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                .font(.caption2.weight(.bold))
            Text(Formatters.signedPercent(fraction))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, style == .badge ? 8 : 0)
        .padding(.vertical, style == .badge ? 4 : 0)
        .background(
            style == .badge
                ? AnyShapeStyle(color.opacity(0.14))
                : AnyShapeStyle(Color.clear)
        )
        .clipShape(Capsule())
    }
}

// MARK: - Asset avatar (ticker monogram)

struct AssetAvatar: View {
    let symbol: String
    let colorIndex: Int
    var size: CGFloat = 44

    private var color: Color {
        Theme.Palette.accents[abs(colorIndex) % Theme.Palette.accents.count]
    }

    var body: some View {
        Text(String(symbol.prefix(symbol.count >= 4 ? 2 : 1)))
            .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.9), color.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.Palette.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.Palette.brandSoft)
            }
        }
    }
}
