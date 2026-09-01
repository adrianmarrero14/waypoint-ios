import DesignSystem
import SwiftUI

/// Opaque overlay shown while the app is locked. Attempts biometric unlock
/// automatically on appear; the button retries after a failure or cancel.
struct AppLockView: View {
    @Environment(AppLockManager.self) private var appLockManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Bubble(diameter: 72, fill: .wpSplashSky)
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.wpOnSplash)
            }

            Text("applock.title")
                .font(.wpTitle)
                .foregroundStyle(Color.wpTextPrimary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                Task { await appLockManager.unlock() }
            } label: {
                Text("applock.unlock")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.waypointPrimary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.wpBackground)
        .task {
            await appLockManager.unlock()
        }
    }
}

#Preview {
    AppLockView()
        .environment(AppLockManager())
}
