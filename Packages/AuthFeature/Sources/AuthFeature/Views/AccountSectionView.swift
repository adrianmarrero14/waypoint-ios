import DesignSystem
import SwiftUI
import WaypointCore

/// Content of the Account section in Settings: a sign-in entry point when
/// signed out; the account email and sign-out when signed in.
public struct AccountSectionView: View {
    @Environment(SessionStore.self) private var sessionStore

    @State private var isAuthSheetPresented = false
    @State private var isSignOutConfirmationPresented = false
    @State private var isDeleteConfirmationPresented = false
    @State private var isDeletingAccount = false
    @State private var deleteFailed = false

    public init() {}

    public var body: some View {
        Group {
            switch sessionStore.state {
            case .signedIn(let user):
                signedInRows(user: user)
            case .signedOut, .unknown:
                signInRow
            }
        }
        .sheet(isPresented: $isAuthSheetPresented) {
            AuthSheetView()
        }
    }

    private var signInRow: some View {
        Button {
            isAuthSheetPresented = true
        } label: {
            Label {
                Text("auth.account.signIn", bundle: .module)
                    .font(.wpBody)
                    .foregroundStyle(Color.wpTextPrimary)
            } icon: {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(Color.wpLabelAccent)
            }
        }
        .disabled(sessionStore.state == .unknown)
    }

    @ViewBuilder
    private func signedInRows(user: AuthUser) -> some View {
        Label {
            Text(user.email ?? String(localized: "auth.account.noEmail", bundle: .module))
                .font(.wpBody)
                .foregroundStyle(Color.wpTextPrimary)
        } icon: {
            Image(systemName: "person.crop.circle.fill")
                .foregroundStyle(Color.wpLabelAccent)
        }

        Button {
            isSignOutConfirmationPresented = true
        } label: {
            Label {
                Text("auth.account.signOut", bundle: .module)
                    .font(.wpBody)
                    .foregroundStyle(.red)
            } icon: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(.red)
            }
        }
        .confirmationDialog(
            Text("auth.account.signOut.confirmTitle", bundle: .module),
            isPresented: $isSignOutConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                Task { try? await sessionStore.signOut() }
            } label: {
                Text("auth.account.signOut", bundle: .module)
            }
        }

        Button {
            isDeleteConfirmationPresented = true
        } label: {
            Label {
                Text("auth.account.delete", bundle: .module)
                    .font(.wpBody)
                    .foregroundStyle(.red)
            } icon: {
                if isDeletingAccount {
                    ProgressView()
                } else {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .disabled(isDeletingAccount)
        .confirmationDialog(
            Text("auth.account.delete.confirmTitle", bundle: .module),
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                deleteAccount()
            } label: {
                Text("auth.account.delete", bundle: .module)
            }
        } message: {
            Text("auth.account.delete.confirmMessage", bundle: .module)
        }
        .alert(
            Text("auth.account.delete.failed", bundle: .module),
            isPresented: $deleteFailed
        ) {
            Button(role: .cancel) {} label: {
                Text("auth.account.delete.failedDismiss", bundle: .module)
            }
        }
    }

    private func deleteAccount() {
        isDeletingAccount = true
        Task {
            defer { isDeletingAccount = false }
            do {
                try await sessionStore.deleteAccount()
            } catch {
                deleteFailed = true
            }
        }
    }
}
