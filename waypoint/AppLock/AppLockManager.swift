import LocalAuthentication
import Observation
import WaypointCore

/// Drives the app-lock overlay: locked state, biometric/passcode evaluation,
/// and re-locking when the app leaves the foreground.
@MainActor
@Observable
final class AppLockManager {
    private(set) var isLocked = false
    private var isAuthenticating = false

    /// Whether the device can evaluate biometrics or passcode at all.
    /// Used by Settings to verify availability before enabling the toggle.
    static func canAuthenticate() -> Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    func lockIfEnabled(_ settings: AppLockSettings) {
        guard settings.isEnabled, !isAuthenticating else { return }
        isLocked = true
    }

    /// Prompts Face ID / Touch ID with device passcode as fallback.
    @discardableResult
    func unlock() async -> Bool {
        guard isLocked, !isAuthenticating else { return !isLocked }
        isAuthenticating = true
        defer { isAuthenticating = false }

        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            // No biometrics and no passcode set: never brick the app.
            isLocked = false
            return true
        }

        do {
            let reason = String(localized: "applock.reason")
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            if success { isLocked = false }
            return success
        } catch {
            return false
        }
    }
}
