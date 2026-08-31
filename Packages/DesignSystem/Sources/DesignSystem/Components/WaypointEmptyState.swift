import SwiftUI

/// Full-screen branded placeholder: a card with an outlined icon bubble on a
/// foam background, with the wave motif along the bottom edge.
public struct WaypointEmptyState: View {
    let title: Text
    let message: Text
    let systemImage: String

    public init(title: Text, message: Text, systemImage: String) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.wpSplashSky)
                    .strokeBorder(Color.wpOnSplash, lineWidth: 3)
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.wpOnSplash)
            }
            .frame(width: 76, height: 76)

            title
                .font(.fredoka(24))
                .foregroundStyle(Color.wpTextPrimary)

            message
                .font(.wpBody)
                .foregroundStyle(Color.wpTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 300)
        .waypointCard(padding: 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background {
            ZStack(alignment: .bottom) {
                Color.wpBackground
                WaveShape(wavelength: 150, amplitude: 20, closed: true)
                    .fill(Color.wpWaveFill)
                    .frame(height: 110)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    WaypointEmptyState(
        title: Text(verbatim: "Tasks"),
        message: Text(verbatim: "Coming soon"),
        systemImage: "checklist"
    )
}
