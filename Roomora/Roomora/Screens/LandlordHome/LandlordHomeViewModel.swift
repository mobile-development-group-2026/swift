import SwiftUI
import ClerkKit

@Observable
class LandlordHomeViewModel {
    var listings: [ListingResponse] = []
    var applications: [ApplicationResponse] = []
    var isLoading = false
    var isLoadingApplications = false
    var errorMessage: String?

    func loadListings(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        do {
            listings = try await APIClient.shared.fetchMyListings(clerk: clerk)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadApplications(clerk: Clerk) async {
        isLoadingApplications = true
        do {
            applications = try await APIClient.shared.fetchMyApplications(clerk: clerk)
        } catch {
            // non-fatal: tab shows empty state
        }
        isLoadingApplications = false
    }

    func updateApplication(clerk: Clerk, id: String, status: String, notes: String?) async {
        var fields: [String: Any] = ["status": status]
        if let notes, !notes.isEmpty { fields["landlord_notes"] = notes }
        do {
            let updated = try await APIClient.shared.updateApplication(clerk: clerk, applicationId: id, fields: fields)
            if let idx = applications.firstIndex(where: { $0.id == id }) {
                applications[idx] = updated
            }
        } catch {
            // surface error via a thrown error if we add UI later
        }
    }
}
