import AuthFeature
import Foundation

/// Supabase project credentials. The anon key is publishable by design (Row
/// Level Security is the real boundary), so committing it is acceptable —
/// rotating it requires shipping an app update, though.
enum SupabaseEnvironment {
    // TODO: replace with the real project URL and anon key from
    // https://supabase.com/dashboard → Project Settings → API.
    static let config = SupabaseConfig(
        url: URL(string: "https://YOUR-PROJECT-REF.supabase.co")!,
        anonKey: "YOUR-ANON-KEY"
    )
}
