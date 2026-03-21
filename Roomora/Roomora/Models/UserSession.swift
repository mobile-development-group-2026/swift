import SwiftUI
import ClerkKit

@Observable
class UserSession {
    var profile: SyncResponse?
    var isLoaded = false
    var pendingSync: PendingSync?

    struct PendingSync {
        let role: String
        let firstName: String
        let lastName: String
        let email: String
        let phone: String?
    }

    var role: String? { profile?.role }
    var firstName: String? { profile?.firstName }
    var isOnboarded: Bool { profile?.onboarded ?? false }

    /// Load profile from backend. If there's a pending sync (sign-up that didn't finish),
    /// create the user first via POST /auth/sync. Otherwise just GET /profile.
    /// Retries up to 3 times with increasing delays to handle token race / cold starts.
    func load(clerk: Clerk) async {
        if isLoaded { return }

        for attempt in 1...3 {
            // give Clerk time to establish the session token
            try? await Task.sleep(for: .seconds(attempt == 1 ? 1 : 2))

            do {
                if let sync = pendingSync {
                    profile = try await APIClient.shared.syncUser(
                        clerk: clerk,
                        role: sync.role,
                        firstName: sync.firstName,
                        lastName: sync.lastName,
                        email: sync.email,
                        phone: sync.phone
                    )
                    pendingSync = nil
                } else {
                    profile = try await APIClient.shared.fetchProfile(clerk: clerk)
                }
                break // success
            } catch {
                print("load attempt \(attempt) failed: \(error)")
                if attempt == 3 {
                    print("all attempts exhausted")
                }
            }
        }
        isLoaded = true
    }

    func clear() {
        profile = nil
        isLoaded = false
        pendingSync = nil
    }
}
