import SwiftUI
import ClerkKit

@Observable
@MainActor
class RoommateProfileViewModel {
    var profile: RoommateProfileResponse?
    var isLoading = false
    var errorMessage: String?

    private let userId: String

    init(userId: String) {
        self.userId = userId
        self.profile = APIClient.shared.cachedRoommateProfile(id: userId)
    }

    func load(clerk: Clerk) async {
        if profile != nil {
            Task {
                await revalidate(clerk: clerk)
            }
            return
        }

        isLoading = true
        await revalidate(clerk: clerk)
        isLoading = false
    }

    private func revalidate(clerk: Clerk) async {
        do {
            async let freshProfile = APIClient.shared.fetchRoommateProfile(id: userId, clerk: clerk)
            async let _ = warmAvatarCache(profile?.avatarUrl)

            profile = try await freshProfile
            errorMessage = nil
        } catch {
            if profile == nil {
                errorMessage = "Couldn't load profile. Check your connection."
            }
        }
    }

    private func warmAvatarCache(_ urlString: String?) async {
        guard let urlString,
              let url = URL(string: urlString),
              ImageMemoryCache.shared.image(for: url) == nil else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let img = UIImage(data: data) else { return }
        ImageMemoryCache.shared.store(img, for: url)
    }
}
