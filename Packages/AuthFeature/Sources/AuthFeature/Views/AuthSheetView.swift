import AuthenticationServices
import CryptoKit
import DesignSystem
import SwiftUI
import WaypointCore

/// Modal entry point for signing in: Apple, Google, or email. Dismisses
/// itself as soon as a session is established by any flow.
public struct AuthSheetView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    @State private var appleNonce = ""
    @State private var isGoogleFlowRunning = false
    @State private var errorKey: LocalizedStringKey?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Bubble(diameter: 72, fill: .wpSplashSky)
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.wpOnSplash)
                }
                .padding(.top, 12)

                VStack(spacing: 12) {
                    Text("auth.landing.title", bundle: .module)
                        .font(.wpTitle)
                        .foregroundStyle(Color.wpTextPrimary)
                        .multilineTextAlignment(.center)
                    Text("auth.landing.subtitle", bundle: .module)
                        .font(.wpBody)
                        .foregroundStyle(Color.wpTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 8)

                if let errorKey {
                    Text(errorKey, bundle: .module)
                        .font(.wpCaption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: 12) {
                    appleButton
                    googleButton
                    NavigationLink {
                        EmailSignInView(errorKey: $errorKey)
                    } label: {
                        Text("auth.landing.continueWithEmail", bundle: .module)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.waypointPrimary)

                    Button {
                        dismiss()
                    } label: {
                        Text("auth.landing.notNow", bundle: .module)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.waypointTertiary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.wpBackground)
        }
        .onChange(of: sessionStore.state) { _, state in
            if case .signedIn = state {
                dismiss()
            }
        }
    }

    // MARK: - Apple

    private var appleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            appleNonce = Self.randomNonce()
            request.requestedScopes = [.email, .fullName]
            request.nonce = Self.sha256(appleNonce)
        } onCompletion: { result in
            handleAppleResult(result)
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .clipShape(Capsule())
    }

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                errorKey = "auth.error.appleFailed"
                return
            }
            let nonce = appleNonce
            Task {
                do {
                    try await sessionStore.signInWithApple(idToken: idToken, nonce: nonce)
                } catch {
                    errorKey = AuthErrorMessage.key(for: error)
                }
            }
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            errorKey = "auth.error.appleFailed"
        }
    }

    // MARK: - Google

    private var googleButton: some View {
        Button {
            signInWithGoogle()
        } label: {
            Label {
                Text("auth.landing.continueWithGoogle", bundle: .module)
            } icon: {
                Image(systemName: "globe")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.waypointSecondary)
        .disabled(isGoogleFlowRunning)
    }

    private func signInWithGoogle() {
        guard !isGoogleFlowRunning else { return }
        isGoogleFlowRunning = true
        errorKey = nil
        let session = webAuthenticationSession
        Task {
            defer { isGoogleFlowRunning = false }
            do {
                try await sessionStore.signInWithGoogle { url in
                    try await session.authenticate(
                        using: url,
                        callbackURLScheme: SessionStore.oauthRedirectURL.scheme!
                    )
                }
            } catch let error as ASWebAuthenticationSessionError where error.code == .canceledLogin {
                // User closed the sheet; not an error.
            } catch {
                errorKey = AuthErrorMessage.key(for: error)
            }
        }
    }

    // MARK: - Nonce helpers

    private static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._")
        return String((0..<length).map { _ in charset.randomElement()! })
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
