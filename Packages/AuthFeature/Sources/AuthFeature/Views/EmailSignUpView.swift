import DesignSystem
import SwiftUI

/// Account creation form. When email confirmation is enabled on the server,
/// shows a "check your inbox" state instead of dismissing.
struct EmailSignUpView: View {
    @Environment(SessionStore.self) private var sessionStore

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var awaitingConfirmation = false
    @State private var errorKey: LocalizedStringKey?

    private static let minPasswordLength = 8

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
            && password.count >= Self.minPasswordLength
            && password == confirmPassword
            && !isLoading
    }

    var body: some View {
        Group {
            if awaitingConfirmation {
                confirmationSentView
            } else {
                formView
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.wpBackground)
        .navigationTitle(Text("auth.signUp.title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formView: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField(
                String(localized: "auth.field.email", bundle: .module),
                text: $email
            )
            .authFieldStyle()
            .textContentType(.username)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            SecureField(
                String(localized: "auth.field.password", bundle: .module),
                text: $password
            )
            .authFieldStyle()
            .textContentType(.newPassword)

            SecureField(
                String(localized: "auth.field.confirmPassword", bundle: .module),
                text: $confirmPassword
            )
            .authFieldStyle()
            .textContentType(.newPassword)

            if !confirmPassword.isEmpty, password != confirmPassword {
                Text("auth.error.passwordMismatch", bundle: .module)
                    .font(.wpCaption)
                    .foregroundStyle(.red)
            } else if !password.isEmpty, password.count < Self.minPasswordLength {
                Text("auth.error.weakPassword", bundle: .module)
                    .font(.wpCaption)
                    .foregroundStyle(.red)
            } else if let errorKey {
                Text(errorKey, bundle: .module)
                    .font(.wpCaption)
                    .foregroundStyle(.red)
            }

            Button {
                signUp()
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("auth.signUp.action", bundle: .module)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.waypointPrimary)
            .disabled(!canSubmit)
        }
    }

    private var confirmationSentView: some View {
        VStack(spacing: 24) {
            ZStack {
                Bubble(diameter: 72, fill: .wpSplashSky)
                Image(systemName: "envelope.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.wpOnSplash)
            }
            .padding(.top, 12)

            VStack(spacing: 12) {
                Text("auth.signUp.checkInbox.title", bundle: .module)
                    .font(.wpTitle)
                    .foregroundStyle(Color.wpTextPrimary)
                    .multilineTextAlignment(.center)
                Text("auth.signUp.checkInbox.message", bundle: .module)
                    .font(.wpBody)
                    .foregroundStyle(Color.wpTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func signUp() {
        isLoading = true
        errorKey = nil
        Task {
            defer { isLoading = false }
            do {
                let needsConfirmation = try await sessionStore.signUp(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                if needsConfirmation {
                    awaitingConfirmation = true
                }
                // Otherwise a session exists and AuthSheetView dismisses.
            } catch {
                errorKey = AuthErrorMessage.key(for: error)
            }
        }
    }
}
