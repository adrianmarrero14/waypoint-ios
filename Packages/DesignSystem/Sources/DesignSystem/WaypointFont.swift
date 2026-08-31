import SwiftUI
import CoreText

/// Registers and exposes the two brand typefaces: Fredoka (headlines) and Nunito (body).
/// Both ship as variable fonts in this package's resources; fonts are registered
/// lazily the first time a brand font is requested.
public enum WaypointFont {
    /// Fredoka named instances. Headlines use 500–700 only, always navy or white.
    public enum Fredoka: String {
        case medium = "Fredoka-Medium"
        case semiBold = "Fredoka-SemiBold"
        case bold = "Fredoka-Bold"
    }

    /// Nunito named instances. Regular for paragraphs, 700–800 for labels and buttons.
    public enum Nunito: String {
        case regular = "Nunito-Regular"
        case semiBold = "Nunito-SemiBold"
        case bold = "Nunito-Bold"
        case extraBold = "Nunito-ExtraBold"
    }

    /// Registers the bundled fonts with CoreText. Safe to call more than once;
    /// it is also triggered automatically by the `Font` helpers below.
    public static func register() {
        _ = registration
    }

    private static let registration: Void = {
        for file in ["Fredoka", "Nunito", "Nunito-Italic"] {
            guard let url = Bundle.module.url(forResource: file, withExtension: "ttf", subdirectory: "Fonts") else {
                assertionFailure("DesignSystem: missing bundled font \(file).ttf")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error),
               let error = error?.takeRetainedValue(),
               CFErrorGetCode(error) != CTFontManagerError.alreadyRegistered.rawValue {
                assertionFailure("DesignSystem: could not register \(file).ttf: \(error)")
            }
        }
    }()
}

public extension Font {
    /// Fredoka, the headline face.
    static func fredoka(_ size: CGFloat, weight: WaypointFont.Fredoka = .semiBold) -> Font {
        WaypointFont.register()
        return .custom(weight.rawValue, size: size)
    }

    /// Nunito, the body face. Minimum 14 pt on screen.
    static func nunito(_ size: CGFloat, weight: WaypointFont.Nunito = .regular) -> Font {
        WaypointFont.register()
        return .custom(weight.rawValue, size: size)
    }

    // Semantic scale from the brand guide.
    /// H1 — Fredoka SemiBold 34 (the guide's 48 is a web size; 34 matches iOS large titles).
    static let wpLargeTitle = Font.fredoka(34)
    /// H2 — Fredoka SemiBold 28.
    static let wpTitle = Font.fredoka(28)
    /// Section heading — Fredoka SemiBold 20.
    static let wpHeading = Font.fredoka(20)
    /// Body — Nunito Regular 16.
    static let wpBody = Font.nunito(16)
    /// Emphasized body — Nunito Bold 16.
    static let wpBodyBold = Font.nunito(16, weight: .bold)
    /// Caption — Nunito SemiBold 14 (brand minimum size).
    static let wpCaption = Font.nunito(14, weight: .semiBold)
    /// Label — Nunito ExtraBold 13; pair with `.waypointLabelStyle()` for tracking and case.
    static let wpLabel = Font.nunito(13, weight: .extraBold)
}

public extension View {
    /// Brand label treatment: uppercase, wide tracking, Ocean Blue.
    /// Apply to short labels like "NEW · DAILY SPLASH".
    func waypointLabelStyle(color: Color = .wpOceanBlue) -> some View {
        font(.wpLabel)
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(color)
    }
}
