import SwiftUI

public extension View {
    /// Brand card: white surface, soft blue border, very rounded corners
    /// and the standard soft navy shadow.
    func waypointCard(padding: CGFloat = 20) -> some View {
        self.padding(padding)
            .background(.white, in: .rect(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.wpSoftBorder, lineWidth: 2))
            .shadow(color: .wpCardShadow, radius: 10, y: 6)
    }

    /// Emphasized card with the logo's thick navy outline, for hero surfaces.
    func waypointOutlinedCard(padding: CGFloat = 20) -> some View {
        self.padding(padding)
            .background(.white, in: .rect(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Color.wpDeepNavy, lineWidth: 3))
            .shadow(color: .wpCardShadow, radius: 14, y: 8)
    }
}

#Preview {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clear space")
                .font(.wpHeading)
                .foregroundStyle(Color.wpDeepNavy)
            Text("Keep a margin around the logo of at least half its diameter.")
                .font(.wpBody)
                .foregroundStyle(Color.wpTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .waypointCard()

        Text("Hero surface")
            .font(.wpTitle)
            .foregroundStyle(Color.wpDeepNavy)
            .frame(maxWidth: .infinity)
            .waypointOutlinedCard()
    }
    .padding(32)
    .background(Color.wpFoam)
}
