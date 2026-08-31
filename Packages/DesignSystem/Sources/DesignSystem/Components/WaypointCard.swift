import SwiftUI

public extension View {
    /// Brand card: surface fill, soft border, very rounded corners and the
    /// standard soft shadow. Adapts between the light and dark guides.
    func waypointCard(padding: CGFloat = 20) -> some View {
        self.padding(padding)
            .background(Color.wpSurface, in: .rect(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.wpSurfaceBorder, lineWidth: 2))
            .shadow(color: .wpCardShadow, radius: 10, y: 6)
    }

    /// Emphasized card with the brand's thick drawn outline, for hero surfaces.
    func waypointOutlinedCard(padding: CGFloat = 20) -> some View {
        self.padding(padding)
            .background(Color.wpSurface, in: .rect(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Color.wpOutline, lineWidth: 3))
            .shadow(color: .wpCardShadow, radius: 14, y: 8)
    }
}

#Preview {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clear space")
                .font(.wpHeading)
                .foregroundStyle(Color.wpTextPrimary)
            Text("Keep a margin around the logo of at least half its diameter.")
                .font(.wpBody)
                .foregroundStyle(Color.wpTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .waypointCard()

        Text("Hero surface")
            .font(.wpTitle)
            .foregroundStyle(Color.wpTextPrimary)
            .frame(maxWidth: .infinity)
            .waypointOutlinedCard()
    }
    .padding(32)
    .background(Color.wpBackground)
}
