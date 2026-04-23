import SwiftUI
import ClerkKit

@Observable
class LandlordHomeViewModel {
    var listings: [ListingResponse] = []
    var applications: [ApplicationResponse] = []
    var isLoading = false
    var isLoadingApplications = false
    var isLoadingAnalytics = false
    var errorMessage: String?
    var sectorAnalytics: [SectorInterestAnalytics] = []
    var hourlyPeaks: [HourlyTrafficAnalytics] = []
    var dailyPeaks: [DailyTrafficAnalytics] = []
    var totalProximityVisits = 0
    var uniqueTrackedSectors = 0
    var analyticsLastSyncedAt: String?
    
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

    func loadProximityAnalytics(clerk: Clerk) async {
        isLoadingAnalytics = true
        defer { isLoadingAnalytics = false }
        do {
            let response = try await APIClient.shared.fetchLandlordProximityAnalytics(clerk: clerk)
            sectorAnalytics = response.sectorAnalytics
            hourlyPeaks = response.hourlyPeaks.sorted { $0.hour < $1.hour }
            dailyPeaks = response.dailyPeaks.sorted { $0.visits > $1.visits }
            totalProximityVisits = response.totalVisits
            uniqueTrackedSectors = response.uniqueSectors
            analyticsLastSyncedAt = response.lastSyncedAt
        } catch {
            // Keep previous values if endpoint is not available yet.
        }
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
    var topSectorLabel: String {
        sectorAnalytics.max(by: { $0.visitCount < $1.visitCount })?.sector ?? "No data"
    }

    var peakHourLabel: String {
        guard let hour = hourlyPeaks.max(by: { $0.visits < $1.visits })?.hour else { return "No data" }
        return String(format: "%02d:00", hour)
    }

    var peakDayLabel: String {
        dailyPeaks.max(by: { $0.visits < $1.visits })?.day ?? "No data"
    }
}
