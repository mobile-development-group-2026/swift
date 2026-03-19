import SwiftUI
import ClerkKit

@Observable
class UserSession {
    var profile: SyncResponse?

    var role: String? { profile?.role }
    var firstName: String? { profile?.firstName }

    /// Fetches the profile from the backend. Call when the user is signed in.
    func load(clerk: Clerk) async {
        do {
            profile = try await APIClient.shared.fetchProfile(clerk: clerk)
        } catch {
            print("Failed to load profile: \(error.localizedDescription)")
        }
    }

    func clear() {
        profile = nil
    }
}
