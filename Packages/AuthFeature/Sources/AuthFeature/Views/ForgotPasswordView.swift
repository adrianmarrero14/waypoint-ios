import DesignSystem
import SwiftUI

/// Two-step password reset without deep links: request a 6-digit code by
/// email, then enter the code together with the new password.
struct ForgotPasswordView: View {
    private enum Step {
        case requestCode
        case enterCode
        case done
    }

    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .requestCode
    @State private var email: String
    @State private var code = ""
    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var errorKey: LocalizedStringKey?

    init(initialEmail: String = "") {
        _email = State(initialValue: initialEmail)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch step {
            case .requestCode:
                requestCodeView
            case .enterCode:
                enterCodeView
            case .done:
                doneView
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.wpBackground)
        .navigationTitle(Text("auth.reset.title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var requestCodeView: some View {
        Text("auth.reset.intro", bundle: .module)
            .font(.wpBody)
            .foregroundStyle(Color.wpTextSecondary)

        TextField(
            String(localized: "auth.field.email", bundle: .module),
            text: $email
        )
        .authFieldStyle()
        .textContentType(.username)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()

        errorText

        Button {
            sendCode()
        } label: {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("auth.reset.sendCode", bundle: .module)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.waypointPrimary)
        .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
    }

    @ViewBuilder
    private var enterCodeView: some View {
        Text("auth.reset.codeSent", bundle: .module)
            .font(.wpBody)
            .foregroundStyle(Color.wpTextSecondary)

        TextField(
            String(localized: "auth.field.code", bundle: .module),
            text: $code
        )
        .authFieldStyle()
        .textContentType(.oneTimeCode)
        .keyboardType(.numberPad)

        SecureField(
            String(localized: "auth.field.newPassword", bundle: .module),
            text: $newPassword
        )
        .authFieldStyle()
        .textContentType(.newPassword)

        errorText

        Button {
            resetPassword()
        } label: {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("auth.reset.action", bundle: .module)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.waypointPrimary)
        .disabled(code.isEmpty || newPassword.count < 8 || isLoading)
    }

    private var doneView: some View {
        VStack(spacing: 24) {
            ZStack {
                Bubble(diameter: 72, fill: .wpSplashSky)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.wpOnSplash)
            }
            .padding(.top, 12)

            Text("auth.reset.success", bundle: .module)
                .font(.wpTitle)
                .foregroundStyle(Color.wpTextPrimary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("auth.reset.backToSignIn", bundle: .module)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.waypointPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var errorText: some View {
        if let errorKey {
            Text(errorKey, bundle: .module)
                .font(.wpCaption)
                .foregroundStyle(.red)
        }
    }

    private func sendCode() {
        isLoading = true
        errorKey = nil
        Task {
            defer { isLoading = false }
            do {
                try await sessionStore.sendPasswordResetCode(
                    email: email.trimmingCharacters(in: .whitespaces)
                )
                step = .enterCode
            } catch {
                errorKey = AuthErrorMessage.key(for: error)
            }
        }
    }

    private func resetPassword() {
        isLoading = true
        errorKey = nil
        Task {
            defer { isLoading = false }
            do {
                try await sessionStore.verifyPasswordReset(
                    email: email.trimmingCharacters(in: .whitespaces),
                    code: code.trimmingCharacters(in: .whitespaces),
                    newPassword: newPassword
                )
                step = .done
            } catch {
                errorKey = "auth.error.codeInvalid"
            }
        }
    }
}
