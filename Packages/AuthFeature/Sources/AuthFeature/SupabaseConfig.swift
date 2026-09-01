import Foundation

/// Connection details for the Supabase project, injected by the app target so
/// this package stays environment-agnostic.
public struct SupabaseConfig: Sendable {
    public let url: URL
    public let anonKey: String

    /// Sign In with Apple needs the applesignin entitlement, which only paid
    /// Apple Developer teams can sign. False hides the Apple button entirely.
    public let supportsSignInWithApple: Bool

    public init(url: URL, anonKey: String, supportsSignInWithApple: Bool = true) {
        self.url = url
        self.anonKey = anonKey
        self.supportsSignInWithApple = supportsSignInWithApple
    }
}
