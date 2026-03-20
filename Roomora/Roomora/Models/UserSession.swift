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
    func load(clerk: Clerk) async {
        if isLoaded { return }
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
        } catch {
            print("load failed: \(error)")
        }
        isLoaded = true
    }

    func clear() {
        profile = nil
        isLoaded = false
        pendingSync = nil
    }
}
