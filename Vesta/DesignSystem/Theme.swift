import SwiftUI

// Colors, spacing, radii and gradients used across the app.
enum Theme {

    // MARK: - Palette

    enum Palette {
        static let brand = Color(hex: 0x6C5CE7)
        static let brandSoft = Color(hex: 0x8F7CF0)
        static let brandDeep = Color(hex: 0x4B3FCB)

        static let background = Color(hex: 0x0B0B12)
        static let surface = Color(hex: 0x15151F)
        static let surfaceElevated = Color(hex: 0x1E1E2B)
        static let stroke = Color.white.opacity(0.08)

        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.62)
        static let textTertiary = Color.white.opacity(0.38)

        static let up = Color(hex: 0x2BD576)
        static let down = Color(hex: 0xFF5C6C)

        // Accent colors for charts and avatars.
        static let accents: [Color] = [
            Color(hex: 0x6C5CE7),
            Color(hex: 0x2BD576),
            Color(hex: 0xFFB020),
            Color(hex: 0x3AA0FF),
            Color(hex: 0xFF6FB5),
            Color(hex: 0x00D1C1)
        ]
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Radius

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let pill: CGFloat = 999
    }

    // MARK: - Gradients

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [Palette.brandSoft, Palette.brand, Palette.brandDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func directionGradient(isUp: Bool) -> LinearGradient {
        let base = isUp ? Palette.up : Palette.down
        return LinearGradient(
            colors: [base.opacity(0.35), base.opacity(0.0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
