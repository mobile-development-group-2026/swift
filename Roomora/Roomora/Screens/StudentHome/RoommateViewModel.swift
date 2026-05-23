import SwiftUI
import ClerkKit

@MainActor
@Observable
class RoommateViewModel {
    var roommates: [RoommateStudent] = []
    var isLoading = false
    var errorMessage: String?

    func loadRoommates() async {
        if roommates.isEmpty,
           let cached = CacheService.load([RoommateStudent].self, key: "roommates") {
            roommates = cached
        }
        isLoading = roommates.isEmpty
        do {
            let fresh = try await APIClient.shared.fetchRoommates(clerk: Clerk.shared)
            roommates = fresh
            CacheService.save(fresh, key: "roommates")
            errorMessage = nil
        } catch { }
        isLoading = false
    }

    func refresh() async {
        isLoading = true
        do {
            let fresh = try await APIClient.shared.fetchRoommates(clerk: Clerk.shared)
            roommates = fresh
            CacheService.save(fresh, key: "roommates")
            errorMessage = nil
        } catch { }
        isLoading = false
    }
}
