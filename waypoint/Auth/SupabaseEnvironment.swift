import AuthFeature
import Foundation

/// Supabase project credentials. The anon key is publishable by design (Row
/// Level Security is the real boundary), so committing it is acceptable —
/// rotating it requires shipping an app update, though.
enum SupabaseEnvironment {
    // TODO: replace the anon key with the real one from
    // https://supabase.com/dashboard → Project Settings → API Keys.
    static let config = SupabaseConfig(
        url: URL(string: "https://kacjuwrmevghlxgyqyco.supabase.co")!,
        anonKey: "YOUR-ANON-KEY"
    )
}
