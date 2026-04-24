import SwiftUI
import ClerkKit

@Observable
class StudentHomeViewModel {
    var listings: [ListingResponse] = []
    var applications: [ApplicationResponse] = []
    var favoriteListings: [ListingResponse] = []
    var favoritedIds: Set<String> = []
    var isLoading = false
    var isLoadingApplications = false
    var isLoadingFavorites = false
    var proximityStatusText = "Idle"
    var pendingProximityEvents = 0
    
    func loadListings() async {
        // Show cached listings immediately — no spinner on returning visits
        if listings.isEmpty,
           let cached = CacheService.load([ListingResponse].self, key: "listings") {
            listings = cached
            // Prefetch cover photos into NSCache so grid renders without placeholders
            let urls = cached.compactMap { $0.coverPhotoUrl }.compactMap { URL(string: $0) }
            ImageMemoryCache.shared.prefetch(urls)
        }

        isLoading = listings.isEmpty // spinner only when there's truly nothing to show
        do {
            let fresh = try await APIClient.shared.fetchListings(clerk: Clerk.shared)
            listings = fresh
            CacheService.save(Array(fresh.prefix(50)), key: "listings")
            StudentProximityTracker.shared.configure(with: listings)
            StudentProximityTracker.shared.start(clerk: Clerk.shared)
        } catch {
            // non-fatal — cached data stays visible
        }
        isLoading = false
    }

    func loadMyApplications() async {
        isLoadingApplications = true
        do {
            applications = try await APIClient.shared.fetchMyApplications(clerk: Clerk.shared)
        } catch {
            // non-fatal
        }
        isLoadingApplications = false
    }

    func loadFavorites() async {
        isLoadingFavorites = true
        do {
            favoriteListings = try await APIClient.shared.fetchFavorites(clerk: Clerk.shared)
            favoritedIds = Set(favoriteListings.map { $0.id })
        } catch {
            // non-fatal
        }
        isLoadingFavorites = false
    }

    
    func syncProximityTrackingState() {
        proximityStatusText = StudentProximityTracker.shared.status.label
        pendingProximityEvents = StudentProximityTracker.shared.pendingEventsCount
    }
    
    func isFavorited(_ listingId: String) -> Bool {
        favoritedIds.contains(listingId)
    }

    /// Optimistic toggle — flips local state immediately, rolls back on error.
    func toggleFavorite(listing: ListingResponse) async {
        let wasOn = favoritedIds.contains(listing.id)
        // optimistic update
        if wasOn {
            favoritedIds.remove(listing.id)
            favoriteListings.removeAll { $0.id == listing.id }
        } else {
            favoritedIds.insert(listing.id)
            favoriteListings.insert(listing, at: 0)
        }

        do {
            if wasOn {
                try await APIClient.shared.removeFavorite(clerk: Clerk.shared, listingId: listing.id)
            } else {
                try await APIClient.shared.addFavorite(clerk: Clerk.shared, listingId: listing.id)
            }
        } catch {
            // rollback
            if wasOn {
                favoritedIds.insert(listing.id)
                favoriteListings.insert(listing, at: 0)
            } else {
                favoritedIds.remove(listing.id)
                favoriteListings.removeAll { $0.id == listing.id }
            }
        }
    }

    /// Returns the cached ListingResponse for a given application, or nil if not loaded yet.
    func listing(for app: ApplicationResponse) -> ListingResponse? {
        listings.first { $0.id == app.listingId }
    }

    /// Returns the student's application status for a listing, or nil if not applied.
    func applicationStatus(for listingId: String) -> String? {
        applications.first { $0.listingId == listingId }?.status
    }
}
