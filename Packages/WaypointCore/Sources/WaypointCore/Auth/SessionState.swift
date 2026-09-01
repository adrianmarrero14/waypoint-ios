import Foundation

/// Minimal identity of the signed-in user, independent from any auth provider SDK.
public struct AuthUser: Equatable, Sendable {
    public let id: UUID
    public let email: String?

    public init(id: UUID, email: String?) {
        self.id = id
        self.email = email
    }
}

/// Authentication state of the app. `unknown` covers the window between launch
/// and the first session restoration, so UI can avoid flashing a signed-out state.
public enum SessionState: Equatable, Sendable {
    case unknown
    case signedOut
    case signedIn(AuthUser)

    public var user: AuthUser? {
        if case .signedIn(let user) = self { return user }
        return nil
    }
}

/// Read-only view of the auth state, so feature packages can observe the session
/// without depending on the auth provider SDK.
public protocol SessionProviding {
    var state: SessionState { get }
}
