import AuthFeature
import Foundation

/// Supabase project credentials. The anon key is publishable by design (Row
/// Level Security is the real boundary), so committing it is acceptable —
/// rotating it requires shipping an app update, though.
enum SupabaseEnvironment {
    // supportsSignInWithApple is off because the current Apple Developer team
    // is a personal (free) one, which cannot sign the applesignin entitlement.
    // With a paid membership: re-add the entitlement in waypoint.entitlements,
    // enable the capability for the App ID, and flip this to true.
    // supportsSignInWithGoogle is off until the Google provider is configured
    // in the Supabase dashboard (Google Cloud OAuth client + redirect URLs).
    static let config = SupabaseConfig(
        url: URL(string: "https://kacjuwrmevghlxgyqyco.supabase.co")!,
        anonKey: "sb_publishable_K4Ax80qnpCA2mVSC1w5uxA_Gz73kxWI",
        supportsSignInWithApple: false,
        supportsSignInWithGoogle: false
    )
}
