import SwiftUI
import ClerkKit

@Observable
class LandlordHomeViewModel {
    var listings: [ListingResponse] = []
    var isLoading = false
    var errorMessage: String?

    func loadListings(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        do {
            listings = try await APIClient.shared.fetchMyListings(clerk: clerk)
        } catch {
            print("loadListings failed: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
