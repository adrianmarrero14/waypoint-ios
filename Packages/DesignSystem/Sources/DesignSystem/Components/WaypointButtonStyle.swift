import SwiftUI

/// The brand's "drawn" pill button: thick navy outline and a hard navy
/// drop shadow that the button sinks into when pressed.
public struct WaypointButtonStyle: ButtonStyle {
    public enum Variant {
        /// Ocean Blue fill, white text — the main action.
        case primary
        /// White fill, navy text.
        case secondary
        /// Splash Sky fill, navy text.
        case tertiary
    }

    public enum Size {
        case regular
        case compact

        var font: Font { self == .regular ? .nunito(16, weight: .extraBold) : .nunito(14, weight: .extraBold) }
        var horizontalPadding: CGFloat { self == .regular ? 26 : 20 }
        var verticalPadding: CGFloat { self == .regular ? 12 : 9 }
    }

    let variant: Variant
    let size: Size

    public init(variant: Variant = .primary, size: Size = .regular) {
        self.variant = variant
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .font(size.font)
            .foregroundStyle(foreground)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(fill, in: .capsule)
            .overlay(Capsule().strokeBorder(Color.wpDeepNavy, lineWidth: 3))
            .background(Capsule().fill(Color.wpDeepNavy).offset(y: pressed ? 1 : 4))
            .offset(y: pressed ? 3 : 0)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }

    private var fill: Color {
        switch variant {
        case .primary: .wpOceanBlue
        case .secondary: .white
        case .tertiary: .wpSplashSky
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary: .white
        case .secondary, .tertiary: .wpDeepNavy
        }
    }
}

public extension ButtonStyle where Self == WaypointButtonStyle {
    static var waypointPrimary: WaypointButtonStyle { .init(variant: .primary) }
    static var waypointSecondary: WaypointButtonStyle { .init(variant: .secondary) }
    static var waypointTertiary: WaypointButtonStyle { .init(variant: .tertiary) }
    static func waypoint(_ variant: WaypointButtonStyle.Variant, size: WaypointButtonStyle.Size = .regular) -> WaypointButtonStyle {
        .init(variant: variant, size: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Dive in") {}.buttonStyle(.waypointPrimary)
        Button("Learn more") {}.buttonStyle(.waypointSecondary)
        Button("Splash") {}.buttonStyle(.waypointTertiary)
        Button("Compact") {}.buttonStyle(.waypoint(.primary, size: .compact))
    }
    .padding(40)
    .background(Color.wpFoam)
}
