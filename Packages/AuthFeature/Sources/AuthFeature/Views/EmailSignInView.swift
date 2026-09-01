import DesignSystem
import SwiftUI

/// Email + password sign-in form, with links to sign-up and password reset.
struct EmailSignInView: View {
    @Environment(SessionStore.self) private var sessionStore

    @Binding var errorKey: LocalizedStringKey?
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty && !isLoading
    }

    var body: some View {
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
            .textContentType(.password)

            if let errorKey {
                Text(errorKey, bundle: .module)
                    .font(.wpCaption)
                    .foregroundStyle(.red)
            }

            Button {
                signIn()
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("auth.signIn.action", bundle: .module)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.waypointPrimary)
            .disabled(!canSubmit)

            NavigationLink {
                ForgotPasswordView(initialEmail: email)
            } label: {
                Text("auth.signIn.forgotPassword", bundle: .module)
                    .font(.wpBodyBold)
                    .foregroundStyle(Color.wpLabelAccent)
                    .frame(maxWidth: .infinity)
            }

            Spacer()

            NavigationLink {
                EmailSignUpView()
            } label: {
                Text("auth.signIn.noAccount", bundle: .module)
                    .font(.wpBodyBold)
                    .foregroundStyle(Color.wpLabelAccent)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .background(Color.wpBackground)
        .navigationTitle(Text("auth.signIn.title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { errorKey = nil }
    }

    private func signIn() {
        isLoading = true
        errorKey = nil
        Task {
            defer { isLoading = false }
            do {
                try await sessionStore.signIn(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                // Dismissal is handled by AuthSheetView observing the session.
            } catch {
                errorKey = AuthErrorMessage.key(for: error)
            }
        }
    }
}
