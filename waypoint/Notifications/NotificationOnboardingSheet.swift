import DesignSystem
import SwiftUI

/// First-launch explainer shown before requesting notification permission,
/// so the system prompt never appears without context.
struct NotificationOnboardingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let scheduler: NotificationScheduler

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Bubble(diameter: 72, fill: .wpSplashSky)
                Image(systemName: "bell.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.wpOnSplash)
            }
            .padding(.top, 12)

            VStack(spacing: 12) {
                Text("onboarding.notifications.title")
                    .font(.wpTitle)
                    .foregroundStyle(Color.wpTextPrimary)
                    .multilineTextAlignment(.center)
                Text("onboarding.notifications.message")
                    .font(.wpBody)
                    .foregroundStyle(Color.wpTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 12) {
                Button {
                    Task {
                        if await scheduler.requestAuthorization() {
                            scheduler.scheduleReminders()
                        }
                        dismiss()
                    }
                } label: {
                    Text("onboarding.notifications.accept")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.waypointPrimary)

                Button {
                    dismiss()
                } label: {
                    Text("onboarding.notifications.decline")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.waypointTertiary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.wpBackground)
        .interactiveDismissDisabled()
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        NotificationOnboardingSheet(scheduler: NotificationScheduler())
            .presentationDetents([.medium])
    }
}
