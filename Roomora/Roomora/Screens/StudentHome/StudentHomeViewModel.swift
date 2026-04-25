import SwiftUI
import SwiftData
import Network
import ClerkKit

@MainActor
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

    private let networkMonitor = NWPathMonitor()
    private var context: ModelContext { ModelContainer.roomora.mainContext }

    init() {
        // Pre-populate synchronously so first render has stars and status ready.
        let saved = (try? context.fetch(FetchDescriptor<SavedListing>())) ?? []
        favoriteListings = saved.compactMap { $0.listing }
        favoritedIds = Set(saved.map(\.listingId))

        if let cached = CacheService.load([ApplicationResponse].self, key: "applications") {
            applications = cached
        }

        // Re-inject synthetics for any ops that survived a kill — they stay until flush succeeds.
        let pendingAppOps = (try? context.fetch(FetchDescriptor<PendingApplicationOp>())) ?? []
        let now = ISO8601DateFormatter().string(from: Date())
        for op in pendingAppOps where !applications.contains(where: { $0.listingId == op.listingId }) {
            applications.insert(ApplicationResponse(
                id: "local-\(op.listingId)",
                listingId: op.listingId,
                studentId: "",
                status: "pending",
                preferredVisitAt: op.preferredVisitAt,
                studentNotes: op.studentNotes,
                landlordNotes: nil,
                reviewedAt: nil,
                createdAt: now,
                updatedAt: now,
                listing: nil,
                student: nil
            ), at: 0)
        }

        // Flush all pending ops whenever network is restored.
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            Task { @MainActor [weak self] in
                await self?.flushPendingOps()
                await self?.flushPendingApplicationOps()
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "dev.roomora.network"))
    }

    // MARK: - Listings

    func loadListings() async {
        if listings.isEmpty,
           let cached = CacheService.load([ListingResponse].self, key: "listings") {
            listings = cached
            let urls = cached.compactMap { $0.coverPhotoUrl }.compactMap { URL(string: $0) }
            ImageMemoryCache.shared.prefetch(urls)
        }
        isLoading = listings.isEmpty
        do {
            let fresh = try await APIClient.shared.fetchListings(clerk: Clerk.shared)
            listings = fresh
            CacheService.save(Array(fresh.prefix(50)), key: "listings")
            StudentProximityTracker.shared.configure(with: listings)
            StudentProximityTracker.shared.start(clerk: Clerk.shared)
        } catch { }
        isLoading = false
    }

    // MARK: - Applications

    func loadMyApplications() async {
        isLoadingApplications = applications.isEmpty
        do {
            let fresh = try await APIClient.shared.fetchMyApplications(clerk: Clerk.shared)
            applications = fresh
            CacheService.save(fresh, key: "applications")
        } catch { }
        isLoadingApplications = false
    }

    // MARK: - Favorites

    func loadFavorites() async {
        isLoadingFavorites = false
        do {
            let fresh = try await APIClient.shared.fetchFavorites(clerk: Clerk.shared)
            mergeFavoritesFromServer(fresh)
        } catch { }
    }

    func isFavorited(_ listingId: String) -> Bool {
        favoritedIds.contains(listingId)
    }

    /// Writes to SwiftData immediately. On network failure queues the op instead of rolling back.
    func toggleFavorite(listing: ListingResponse) async {
        let wasOn = favoritedIds.contains(listing.id)

        // Optimistic UI + SwiftData update
        if wasOn {
            favoritedIds.remove(listing.id)
            favoriteListings.removeAll { $0.id == listing.id }
            deleteFromStore(listingId: listing.id)
        } else {
            favoritedIds.insert(listing.id)
            favoriteListings.insert(listing, at: 0)
            insertIntoStore(listing)
        }

        do {
            if wasOn {
                try await APIClient.shared.removeFavorite(clerk: Clerk.shared, listingId: listing.id)
            } else {
                try await APIClient.shared.addFavorite(clerk: Clerk.shared, listingId: listing.id)
            }
            clearPendingOp(for: listing.id)
        } catch {
            // Network failed — queue for later, keep SwiftData state as-is (no rollback).
            let data = (try? JSONEncoder().encode(listing)) ?? Data()
            clearPendingOp(for: listing.id)
            context.insert(PendingFavoriteOp(
                listingId: listing.id,
                action: wasOn ? "remove" : "add",
                listingData: data
            ))
            try? context.save()
        }
    }

    /// Replays pending ops in chronological order when network is restored.
    func flushPendingOps() async {
        let descriptor = FetchDescriptor<PendingFavoriteOp>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        guard let ops = try? context.fetch(descriptor), !ops.isEmpty else { return }

        for op in ops {
            do {
                if op.action == "add" {
                    try await APIClient.shared.addFavorite(clerk: Clerk.shared, listingId: op.listingId)
                } else {
                    try await APIClient.shared.removeFavorite(clerk: Clerk.shared, listingId: op.listingId)
                }
                context.delete(op)
                try? context.save()
            } catch {
                break // still offline — retry next time network returns
            }
        }

        // Pull fresh server state after flush
        if let fresh = try? await APIClient.shared.fetchFavorites(clerk: Clerk.shared) {
            mergeFavoritesFromServer(fresh)
        }
    }

    // MARK: - Private

    /// Merges server favorites into SwiftData, preserving any pending offline ops.
    private func mergeFavoritesFromServer(_ fresh: [ListingResponse]) {
        let pendingOps      = (try? context.fetch(FetchDescriptor<PendingFavoriteOp>())) ?? []
        let pendingAddIds   = Set(pendingOps.filter { $0.action == "add"    }.map { $0.listingId })
        let pendingRemoveIds = Set(pendingOps.filter { $0.action == "remove" }.map { $0.listingId })

        let freshIds    = Set(fresh.map { $0.id })
        let existing    = (try? context.fetch(FetchDescriptor<SavedListing>())) ?? []
        let existingIds = Set(existing.map { $0.listingId })

        // Add server items not yet in SwiftData — skip pending removes (user deleted offline)
        for listing in fresh where !pendingRemoveIds.contains(listing.id) {
            if !existingIds.contains(listing.id),
               let data = try? JSONEncoder().encode(listing) {
                context.insert(SavedListing(listingId: listing.id, listingData: data))
            }
        }

        // Remove items gone from server — skip pending adds (user favorited offline)
        for item in existing where !freshIds.contains(item.listingId) && !pendingAddIds.contains(item.listingId) {
            context.delete(item)
        }

        try? context.save()

        let updated = (try? context.fetch(FetchDescriptor<SavedListing>())) ?? []
        favoriteListings = updated.compactMap { $0.listing }
        favoritedIds = Set(updated.map(\.listingId))
    }

    private func insertIntoStore(_ listing: ListingResponse) {
        guard let data = try? JSONEncoder().encode(listing) else { return }
        let id = listing.id
        let existing = FetchDescriptor<SavedListing>(predicate: #Predicate { $0.listingId == id })
        if (try? context.fetch(existing).first) == nil {
            context.insert(SavedListing(listingId: id, listingData: data))
        }
        try? context.save()
    }

    private func deleteFromStore(listingId: String) {
        let descriptor = FetchDescriptor<SavedListing>(predicate: #Predicate { $0.listingId == listingId })
        if let item = try? context.fetch(descriptor).first {
            context.delete(item)
            try? context.save()
        }
    }

    private func clearPendingOp(for listingId: String) {
        let descriptor = FetchDescriptor<PendingFavoriteOp>(predicate: #Predicate { $0.listingId == listingId })
        if let ops = try? context.fetch(descriptor) {
            ops.forEach { context.delete($0) }
            try? context.save()
        }
    }

    /// Inserts a synthetic pending application immediately so the card chip and Activity tab
    /// update before the server is reachable. Replaced by real data after flush.
    func addLocalPendingApplication(for listing: ListingResponse) {
        guard !applications.contains(where: { $0.listingId == listing.id }) else { return }
        let now = ISO8601DateFormatter().string(from: Date())
        let synthetic = ApplicationResponse(
            id: "local-\(listing.id)",
            listingId: listing.id,
            studentId: "",
            status: "pending",
            preferredVisitAt: nil,
            studentNotes: nil,
            landlordNotes: nil,
            reviewedAt: nil,
            createdAt: now,
            updatedAt: now,
            listing: ApplicationListingInfo(id: listing.id, title: listing.title),
            student: nil
        )
        applications.insert(synthetic, at: 0)
    }

    // MARK: - Pending Applications

    /// Submits any applications that were queued while offline, in chronological order.
    func flushPendingApplicationOps() async {
        let descriptor = FetchDescriptor<PendingApplicationOp>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        guard let ops = try? context.fetch(descriptor), !ops.isEmpty else { return }

        for op in ops {
            var fields: [String: Any] = [:]
            if let notes = op.studentNotes       { fields["student_notes"]      = notes }
            if let visit = op.preferredVisitAt   { fields["preferred_visit_at"] = visit }

            do {
                try await APIClient.shared.createApplication(
                    clerk: Clerk.shared,
                    listingId: op.listingId,
                    fields: fields
                )
                context.delete(op)
                try? context.save()
            } catch {
                break // still offline — retry next time
            }
        }

        // Refresh applications list after flush
        await loadMyApplications()
    }

    // MARK: - Proximity

    func syncProximityTrackingState() {
        proximityStatusText = StudentProximityTracker.shared.status.label
        pendingProximityEvents = StudentProximityTracker.shared.pendingEventsCount
    }

    func listing(for app: ApplicationResponse) -> ListingResponse? {
        listings.first { $0.id == app.listingId }
    }

    func applicationStatus(for listingId: String) -> String? {
        applications.first { $0.listingId == listingId }?.status
    }
}
