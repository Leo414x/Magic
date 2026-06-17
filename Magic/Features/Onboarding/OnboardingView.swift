import SwiftUI
struct OnboardingView: View {
    var onComplete: () -> Void
    var body: some View { Text("Onboarding — Phase 2").onAppear { onComplete() } }
}
