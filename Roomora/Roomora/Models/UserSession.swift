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

    private static let cacheKey = "roomora_profile"

    /// Stale-while-revalidate: serve cached profile instantly, refresh from network in background.
    /// Blocks (shows loading) only on first ever launch or when a pendingSync must complete.
    func load(clerk: Clerk) async {
        if isLoaded { return }

        // Hydrate from UserDefaults so returning users never see a loading screen
        if let cached = Self.loadCached() {
            profile = cached
            isLoaded = true
        }

        if pendingSync != nil || !isLoaded {
            // First launch or pending sign-up: must wait for network before showing app
            await fetchFromNetwork(clerk: clerk)
        } else {
            // Returning user: already showing cached data, refresh silently
            Task { await fetchFromNetwork(clerk: clerk) }
        }
    }

    private func fetchFromNetwork(clerk: Clerk) async {
        for attempt in 1...3 {
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
                Self.persist(profile)
                isLoaded = true
                return
            } catch {
                print("load attempt \(attempt) failed: \(error)")
            }
        }
        isLoaded = true
    }

    func clear() {
        profile = nil
        isLoaded = false
        pendingSync = nil
        UserDefaults.standard.removeObject(forKey: Self.cacheKey)
    }

    private static func loadCached() -> SyncResponse? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(SyncResponse.self, from: data)
    }

    private static func persist(_ profile: SyncResponse?) {
        guard let profile, let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}
