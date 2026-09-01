import Foundation

/// Connection details for the Supabase project, injected by the app target so
/// this package stays environment-agnostic.
public struct SupabaseConfig: Sendable {
    public let url: URL
    public let anonKey: String

    public init(url: URL, anonKey: String) {
        self.url = url
        self.anonKey = anonKey
    }
}
