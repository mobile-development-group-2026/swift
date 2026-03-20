import SwiftUI
import ClerkKit

@Observable
class UserSession {
    var profile: SyncResponse?
    var isLoaded = false

    var role: String? { profile?.role }
    var firstName: String? { profile?.firstName }
    var isOnboarded: Bool { profile?.onboarded ?? false }

    // read user from backend (app relaunch with existing session)
    func load(clerk: Clerk) async {
        if isLoaded { return }
        do {
            profile = try await APIClient.shared.fetchProfile(clerk: clerk)
        } catch {
            print("load failed: \(error)")
        }
        isLoaded = true
    }

    func clear() {
        profile = nil
        isLoaded = false
    }
}
