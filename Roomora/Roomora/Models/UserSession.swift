import SwiftUI
import ClerkKit

@Observable
class UserSession {
    var profile: SyncResponse?
    var isLoaded = false

    var role: String? { profile?.role }
    var firstName: String? { profile?.firstName }
    var isOnboarded: Bool { profile?.onboarded ?? false }

    /// Fetches the profile from the backend. Call when the user is signed in.
    /// Skips if the profile was already set (e.g., by sign-up or sign-in flow).
    func load(clerk: Clerk) async {
        if profile != nil {
            isLoaded = true
            return
        }
        do {
            profile = try await APIClient.shared.fetchProfile(clerk: clerk)
        } catch {
            print("Failed to load profile: \(error)")
            try? await clerk.auth.signOut()
        }
        isLoaded = true
    }

    func clear() {
        profile = nil
        isLoaded = false
    }
}
