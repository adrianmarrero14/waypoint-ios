import Auth
import Foundation
import Observation
import WaypointCore

/// Observable wrapper around the Supabase Auth client. Owns the session
/// lifecycle: restores it from the Keychain on launch (the SDK's default
/// storage), tracks state changes, and exposes the sign-in/out flows.
@Observable
public final class SessionStore: SessionProviding {
    /// Registered in the Supabase dashboard's redirect allow-list. The scheme
    /// is consumed at runtime by ASWebAuthenticationSession, so it needs no
    /// Info.plist entry.
    public static let oauthRedirectURL = URL(string: "waypoint://auth-callback")!

    public private(set) var state: SessionState = .unknown

    private let client: AuthClient
    @ObservationIgnored private var observationTask: Task<Void, Never>?

    public init(config: SupabaseConfig) {
        client = AuthClient(
            url: config.url.appendingPathComponent("auth/v1"),
            headers: ["apikey": config.anonKey],
            localStorage: KeychainLocalStorage()
        )
        let client = client
        observationTask = Task { [weak self] in
            for await (event, session) in client.authStateChanges {
                guard let self else { return }
                self.apply(event: event, session: session)
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    private func apply(event: AuthChangeEvent, session: Session?) {
        switch event {
        case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
            if let session, !session.isExpired {
                state = .signedIn(AuthUser(id: session.user.id, email: session.user.email))
            } else {
                state = .signedOut
            }
        case .signedOut, .userDeleted:
            state = .signedOut
        default:
            break
        }
    }

    // MARK: - Email & password

    /// Returns true when the account still needs email confirmation
    /// (no session is returned until the user confirms).
    @discardableResult
    public func signUp(email: String, password: String) async throws -> Bool {
        let response = try await client.signUp(email: email, password: password)
        return response.session == nil
    }

    public func signIn(email: String, password: String) async throws {
        try await client.signIn(email: email, password: password)
    }

    // MARK: - Providers

    public func signInWithApple(idToken: String, nonce: String) async throws {
        try await client.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
    }

    /// `launchFlow` presents the OAuth URL (ASWebAuthenticationSession) and
    /// returns the callback URL the provider redirected to.
    public func signInWithGoogle(
        launchFlow: @escaping @MainActor @Sendable (URL) async throws -> URL
    ) async throws {
        try await client.signInWithOAuth(
            provider: .google,
            redirectTo: Self.oauthRedirectURL,
            launchFlow: launchFlow
        )
    }

    // MARK: - Password reset (OTP flow, no deep links)

    public func sendPasswordResetCode(email: String) async throws {
        try await client.resetPasswordForEmail(email)
    }

    public func verifyPasswordReset(email: String, code: String, newPassword: String) async throws {
        try await client.verifyOTP(email: email, token: code, type: .recovery)
        try await client.update(user: UserAttributes(password: newPassword))
    }

    // MARK: - Sign out

    public func signOut() async throws {
        try await client.signOut()
    }
}
