import SwiftUI

/// Waypoint brand palette. These are the only colors the brand allows;
/// see the Branding section in the repo's CLAUDE.md for usage ratios.
public extension Color {
    // Core palette
    /// #1E2B85 — outlines and primary text.
    static let wpDeepNavy = Color(wpHex: 0x1E2B85)
    /// #2B8CFF — primary brand color for actions and accents.
    static let wpOceanBlue = Color(wpHex: 0x2B8CFF)
    /// #45AEF5 — the whale's body; hover/secondary accents.
    static let wpWhaleBlue = Color(wpHex: 0x45AEF5)
    /// #8ED8F8 — details and soft fills.
    static let wpSplashSky = Color(wpHex: 0x8ED8F8)
    /// #F4FBFF — light backgrounds.
    static let wpFoam = Color(wpHex: 0xF4FBFF)

    // Supporting tones
    /// #DCEBFA — soft card borders.
    static let wpSoftBorder = Color(wpHex: 0xDCEBFA)
    /// #4A57A0 — secondary text on light backgrounds.
    static let wpTextSecondary = Color(wpHex: 0x4A57A0)
    /// #7B86C2 — tertiary text and captions.
    static let wpTextTertiary = Color(wpHex: 0x7B86C2)
    /// #CFE9FF — light text on blue backgrounds.
    static let wpLightOnBlue = Color(wpHex: 0xCFE9FF)
    /// #EAF5FF — tag and chip fills.
    static let wpTagFill = Color(wpHex: 0xEAF5FF)

    /// rgba(30,43,133,0.12) — the standard soft card shadow.
    static let wpCardShadow = Color(wpHex: 0x1E2B85).opacity(0.12)
}

extension Color {
    init(wpHex hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
