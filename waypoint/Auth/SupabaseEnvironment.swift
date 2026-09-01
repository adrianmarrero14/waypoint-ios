import AuthFeature
import Foundation

/// Supabase project credentials. The anon key is publishable by design (Row
/// Level Security is the real boundary), so committing it is acceptable —
/// rotating it requires shipping an app update, though.
enum SupabaseEnvironment {
    static let config = SupabaseConfig(
        url: URL(string: "https://kacjuwrmevghlxgyqyco.supabase.co")!,
        anonKey: "sb_publishable_K4Ax80qnpCA2mVSC1w5uxA_Gz73kxWI"
    )
}
