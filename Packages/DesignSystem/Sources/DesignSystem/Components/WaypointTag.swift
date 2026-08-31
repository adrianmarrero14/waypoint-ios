import SwiftUI

/// Small pill tag, always outlined per the brand's drawn style.
public struct WaypointTag: View {
    public enum Style {
        /// Light blue fill, Ocean Blue text and border (the guide's "New").
        case accent
        /// Solid navy (the guide's "Pro").
        case solid
        /// White fill, navy text, Splash Sky border (the guide's "Friendly").
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
        case .accent: .wpTagFill
        case .solid: .wpDeepNavy
        case .subtle: .white
        }
    }

    private var foreground: Color {
        switch style {
        case .accent: .wpOceanBlue
        case .solid: .white
        case .subtle: .wpDeepNavy
        }
    }

    private var border: Color {
        switch style {
        case .accent: .wpOceanBlue
        case .solid: .wpDeepNavy
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
    .background(Color.wpFoam)
}
