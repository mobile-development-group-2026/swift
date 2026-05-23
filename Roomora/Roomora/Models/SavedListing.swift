import SwiftData
import Foundation

/// Persists a favorited listing locally so it survives cache eviction and works offline.
/// The full ListingResponse is stored as JSON so cards and detail sheets render without network.
@Model
final class SavedListing {
    @Attribute(.unique) var listingId: String
    var listingData: Data
    var savedAt: Date

    init(listingId: String, listingData: Data) {
        self.listingId = listingId
        self.listingData = listingData
        self.savedAt = Date()
    }

    var listing: ListingResponse? {
        try? JSONDecoder.api.decode(ListingResponse.self, from: listingData)
    }
}

/// A favorite toggle that failed to reach the server (offline).
/// Replayed in order when connectivity is restored.
@Model
final class PendingFavoriteOp {
    var listingId: String
    var action: String
    var listingData: Data
    var createdAt: Date

    init(listingId: String, action: String, listingData: Data) {
        self.listingId = listingId
        self.action = action
        self.listingData = listingData
        self.createdAt = Date()
    }
}

/// An application that failed to reach the server (offline).
/// Replayed when connectivity is restored.
@Model
final class PendingApplicationOp {
    var listingId: String
    var studentNotes: String?
    var preferredVisitAt: String?
    var createdAt: Date

    init(listingId: String, studentNotes: String?, preferredVisitAt: String?) {
        self.listingId = listingId
        self.studentNotes = studentNotes
        self.preferredVisitAt = preferredVisitAt
        self.createdAt = Date()
    }
}

/// A like that failed to reach the server (offline).
/// Replayed in order when connectivity is restored.
@Model
final class PendingLikeOp {
    var likedUserId: String
    var createdAt: Date

    init(likedUserId: String) {
        self.likedUserId = likedUserId
        self.createdAt = Date()
    }
}

extension ModelContainer {
    static let roomora: ModelContainer = {
        try! ModelContainer(
            for: SavedListing.self,
                PendingFavoriteOp.self,
                PendingApplicationOp.self,
                PendingLikeOp.self
        )
    }()
}
