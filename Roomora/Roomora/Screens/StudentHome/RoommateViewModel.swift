import SwiftUI
import SwiftData
import Network
import ClerkKit

@MainActor
@Observable
class RoommateViewModel {
    var roommates: [RoommateStudent] = []
    var likedIds: Set<String> = []
    var pendingLikeIds: Set<String> = []
    var isLoading = false
    var errorMessage: String?

    private let networkMonitor = NWPathMonitor()
    private var context: ModelContext { ModelContainer.roomora.mainContext }

    init() {
        // Pre-populate pending likes from disk so they're hidden immediately
        let ops = (try? context.fetch(FetchDescriptor<PendingLikeOp>())) ?? []
        pendingLikeIds = Set(ops.map(\.likedUserId))

        // Flush pending likes when network restores
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            Task { @MainActor [weak self] in
                await self?.flushPendingLikes()
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "dev.roomora.roommate.network"))
    }

    // MARK: - Visible feed (excludes liked + pending)

    var visibleRoommates: [RoommateStudent] {
        roommates.filter {
            !likedIds.contains($0.id) && !pendingLikeIds.contains($0.id)
        }
    }

    // MARK: - Load

    func loadRoommates() async {
        if roommates.isEmpty,
           let cached = CacheService.load([RoommateStudent].self, key: "roommates") {
            roommates = cached
        }
        if likedIds.isEmpty,
           let cachedLikes = CacheService.load([String].self, key: "liked_ids") {
            likedIds = Set(cachedLikes)
        }
        isLoading = roommates.isEmpty
        do {
            async let freshRoommates = APIClient.shared.fetchRoommates(clerk: Clerk.shared)
            async let freshLikedIds = APIClient.shared.fetchLikedIds(clerk: Clerk.shared)
            let (r, l) = try await (freshRoommates, freshLikedIds)
            roommates = r
            likedIds = Set(l)
            CacheService.save(r, key: "roommates")
            CacheService.save(l, key: "liked_ids")
        } catch { }
        isLoading = false
    }

    func refresh() async {
        isLoading = true
        do {
            async let freshRoommates = APIClient.shared.fetchRoommates(clerk: Clerk.shared)
            async let freshLikedIds = APIClient.shared.fetchLikedIds(clerk: Clerk.shared)
            let (r, l) = try await (freshRoommates, freshLikedIds)
            roommates = r
            likedIds = Set(l)
            CacheService.save(r, key: "roommates")
            CacheService.save(l, key: "liked_ids")
            errorMessage = nil
        } catch { }
        isLoading = false
    }

    // MARK: - Like

    /// Returns true if this like created a mutual match.
    func like(roommate: RoommateStudent) async -> Bool {
        // Optimistic: hide card immediately
        pendingLikeIds.insert(roommate.id)

        do {
            let response = try await APIClient.shared.likeUser(
                clerk: Clerk.shared,
                likedId: roommate.id
            )
            // Success — move from pending to confirmed
            likedIds.insert(roommate.id)
            pendingLikeIds.remove(roommate.id)
            CacheService.save(Array(likedIds), key: "liked_ids")
            clearPendingLike(for: roommate.id)
            return response.matched
        } catch {
            // Network failed — queue for later, keep card hidden
            queuePendingLike(for: roommate.id)
            return false
        }
    }

    // MARK: - Offline flush

    func flushPendingLikes() async {
        let descriptor = FetchDescriptor<PendingLikeOp>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        guard let ops = try? context.fetch(descriptor), !ops.isEmpty else { return }

        for op in ops {
            do {
                let response = try await APIClient.shared.likeUser(
                    clerk: Clerk.shared,
                    likedId: op.likedUserId
                )
                likedIds.insert(op.likedUserId)
                pendingLikeIds.remove(op.likedUserId)
                CacheService.save(Array(likedIds), key: "liked_ids")
                context.delete(op)
                try? context.save()

                // If flushing created a match, we can't alert here (no UI context)
                // Matches will appear next time Activity tab loads
                _ = response.matched
            } catch {
                break // still offline — retry next time
            }
        }
    }

    // MARK: - Private

    private func queuePendingLike(for userId: String) {
        let existing = FetchDescriptor<PendingLikeOp>(
            predicate: #Predicate { $0.likedUserId == userId }
        )
        guard (try? context.fetch(existing))?.isEmpty != false else { return }
        context.insert(PendingLikeOp(likedUserId: userId))
        try? context.save()
    }

    private func clearPendingLike(for userId: String) {
        let descriptor = FetchDescriptor<PendingLikeOp>(
            predicate: #Predicate { $0.likedUserId == userId }
        )
        if let ops = try? context.fetch(descriptor) {
            ops.forEach { context.delete($0) }
            try? context.save()
        }
    }
}
