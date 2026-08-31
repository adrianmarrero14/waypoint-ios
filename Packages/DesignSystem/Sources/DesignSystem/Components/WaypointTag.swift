import SwiftUI

/// Small pill tag, always outlined per the brand's drawn style.
public struct WaypointTag: View {
    public enum Style {
        /// Blue-tinted fill with an accent border (the guide's "New").
        case accent
        /// Solid brand blue (the guide's "Pro").
        case solid
        /// Quiet outline-only look (the guide's "Friendly").
        case subtle
    }

    let text: LocalizedStringResource
    let style: Style

    public init(_ text: LocalizedStringResource, style: Style = .accent) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        Text(text)
            .font(.nunito(13, weight: .extraBold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(fill, in: .capsule)
            .overlay(Capsule().strokeBorder(border, lineWidth: 2))
    }

    private var fill: Color {
        switch style {
        case .accent: .wpAdaptive(light: 0xEAF5FF, dark: 0x1E2B85)
        case .solid: .wpAdaptive(light: 0x1E2B85, dark: 0x2B8CFF)
        case .subtle: .wpAdaptive(light: 0xFFFFFF, dark: 0x000000, darkAlpha: 0)
        }
    }

    private var foreground: Color {
        switch style {
        case .accent: .wpAdaptive(light: 0x2B8CFF, dark: 0x8ED8F8)
        case .solid: .white
        case .subtle: .wpAdaptive(light: 0x1E2B85, dark: 0x8ED8F8)
        }
    }

    private var border: Color {
        switch style {
        case .accent: .wpAdaptive(light: 0x2B8CFF, dark: 0x45AEF5)
        case .solid: .wpAdaptive(light: 0x1E2B85, dark: 0x2B8CFF)
        case .subtle: .wpSplashSky
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        WaypointTag("New", style: .accent)
        WaypointTag("Pro", style: .solid)
        WaypointTag("Friendly", style: .subtle)
    }
    .padding(32)
    .background(Color.wpBackground)
}
