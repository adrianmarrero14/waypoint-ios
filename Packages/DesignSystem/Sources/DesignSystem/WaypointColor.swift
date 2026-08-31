import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Waypoint brand palette. These are the only colors the brand allows;
/// see the Branding section in the repo's CLAUDE.md for usage ratios.
///
/// The `wp`-prefixed fixed colors are the raw palette. The semantic tokens
/// below them adapt between the light and dark brand guides — components
/// should use the semantic tokens so they work in both modes.
public extension Color {
    // MARK: Fixed palette
    /// #1E2B85 — light mode: outlines & text; dark mode: surfaces & accents.
    static let wpDeepNavy = Color(wpHex: 0x1E2B85)
    /// #2B8CFF — primary brand color for actions, in both modes.
    static let wpOceanBlue = Color(wpHex: 0x2B8CFF)
    /// #45AEF5 — the whale's body; highlights & labels in dark mode.
    static let wpWhaleBlue = Color(wpHex: 0x45AEF5)
    /// #8ED8F8 — soft fills in light mode; outlines & details in dark mode.
    static let wpSplashSky = Color(wpHex: 0x8ED8F8)
    /// #F4FBFF — the light-mode ground.
    static let wpFoam = Color(wpHex: 0xF4FBFF)
    /// #0E1330 — the dark-mode ground.
    static let wpMidnight = Color(wpHex: 0x0E1330)

    // MARK: Semantic tokens (light / dark)
    /// Screen background: Foam / Midnight.
    static let wpBackground = wpAdaptive(light: 0xF4FBFF, dark: 0x0E1330)
    /// Card and control surface: white / #161C40.
    static let wpSurface = wpAdaptive(light: 0xFFFFFF, dark: 0x161C40)
    /// Soft card border: #DCEBFA / #262E5C.
    static let wpSurfaceBorder = wpAdaptive(light: 0xDCEBFA, dark: 0x262E5C)
    /// The drawn outline on buttons and hero surfaces: Deep Navy / Splash Sky.
    static let wpOutline = wpAdaptive(light: 0x1E2B85, dark: 0x8ED8F8)
    /// Primary text: Deep Navy / near-white #E8ECFF.
    static let wpTextPrimary = wpAdaptive(light: 0x1E2B85, dark: 0xE8ECFF)
    /// Secondary text: #4A57A0 / #A9B2E0.
    static let wpTextSecondary = wpAdaptive(light: 0x4A57A0, dark: 0xA9B2E0)
    /// Tertiary text and captions: #7B86C2 / #8891C7.
    static let wpTextTertiary = wpAdaptive(light: 0x7B86C2, dark: 0x8891C7)
    /// Uppercase label accent: Ocean Blue / Whale Blue.
    static let wpLabelAccent = wpAdaptive(light: 0x2B8CFF, dark: 0x45AEF5)
    /// Text sitting on a Splash Sky fill: Deep Navy / Midnight.
    static let wpOnSplash = wpAdaptive(light: 0x1E2B85, dark: 0x0E1330)
    /// The buttons' hard bottom shadow: Deep Navy / near-black #0A0E24.
    static let wpButtonShadow = wpAdaptive(light: 0x1E2B85, dark: 0x0A0E24)
    /// Soft card shadow: navy at 12% / black at 35%.
    static let wpCardShadow = wpAdaptive(light: 0x1E2B85, lightAlpha: 0.12, dark: 0x000000, darkAlpha: 0.35)
    /// Decorative wave fill on the ground: Splash Sky 50% / Deep Navy 60%.
    static let wpWaveFill = wpAdaptive(light: 0x8ED8F8, lightAlpha: 0.5, dark: 0x1E2B85, darkAlpha: 0.6)
    /// Light text on blue surfaces (#CFE9FF), both modes.
    static let wpLightOnBlue = Color(wpHex: 0xCFE9FF)
}

extension Color {
    init(wpHex hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    /// A color that resolves per color scheme, following the light and dark brand guides.
    static func wpAdaptive(
        light: UInt32, lightAlpha: Double = 1,
        dark: UInt32, darkAlpha: Double = 1
    ) -> Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(wpHex: dark, alpha: darkAlpha)
                : UIColor(wpHex: light, alpha: lightAlpha)
        })
        #elseif canImport(AppKit)
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(wpHex: dark, alpha: darkAlpha)
                : NSColor(wpHex: light, alpha: lightAlpha)
        })
        #else
        Color(wpHex: light, alpha: lightAlpha)
        #endif
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(wpHex hex: UInt32, alpha: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
#elseif canImport(AppKit)
extension NSColor {
    convenience init(wpHex hex: UInt32, alpha: Double = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
#endif
