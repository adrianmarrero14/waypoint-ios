import Auth
import Foundation
import SwiftUI

/// Maps SDK errors to user-facing localized messages, so views never surface
/// raw server strings.
enum AuthErrorMessage {
    static func key(for error: Error) -> LocalizedStringKey {
        if error is URLError {
            return "auth.error.network"
        }
        guard let authError = error as? AuthError else {
            return "auth.error.generic"
        }
        switch authError.errorCode {
        case .invalidCredentials:
            return "auth.error.invalidCredentials"
        case .emailNotConfirmed:
            return "auth.error.emailNotConfirmed"
        case .weakPassword:
            return "auth.error.weakPassword"
        case .userAlreadyExists, .emailExists:
            return "auth.error.emailInUse"
        case .overRequestRateLimit, .overEmailSendRateLimit:
            return "auth.error.rateLimited"
        case .otpExpired:
            return "auth.error.codeInvalid"
        default:
            return "auth.error.generic"
        }
    }
}
