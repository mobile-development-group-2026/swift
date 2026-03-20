import SwiftUI
import ClerkKit

@Observable
class UserSession {
    var profile: SyncResponse?
    var isLoaded = false

    var role: String? { profile?.role }
    var firstName: String? { profile?.firstName }
    var isOnboarded: Bool { profile?.onboarded ?? false }

    /// Fetches user profile from the backend. Called when the user is signed in.
    /// Skips if the profile was already set
    func load(clerk: Clerk) async {
        if isLoaded { return }
        // retry once — Clerk token may not be ready immediately after sign-up
        for attempt in 1...2 {
            do {
                profile = try await APIClient.shared.fetchProfile(clerk: clerk)
                break
            } catch {
                print("Failed to load profile (attempt \(attempt)): \(error)")
                if attempt < 2 {
                    try? await Task.sleep(for: .seconds(1))
                }
            }
        }
        isLoaded = true
    }

    func clear() {
        profile = nil
        isLoaded = false
    }
}
