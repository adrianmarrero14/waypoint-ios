import DesignSystem
import SwiftUI

/// Shared field chrome for auth forms: rounded surface with the standard
/// 2 pt border, matching the app's composer fields.
struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.wpBody)
            .foregroundStyle(Color.wpTextPrimary)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.wpSurface)
                    .stroke(Color.wpSurfaceBorder, lineWidth: 2)
            )
    }
}

extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldStyle())
    }
}
