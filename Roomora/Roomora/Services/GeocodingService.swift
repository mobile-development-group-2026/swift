import Foundation
import CoreLocation

final class GeocodingService: Sendable {
    static let shared = GeocodingService()

    private init() {}

    private struct CachedCoord: Codable {
        let lat: Double
        let lon: Double
    }

    private func cachedCoordinate(for listingId: String) -> CLLocationCoordinate2D? {
        guard let dict = CacheService.load([String: CachedCoord].self, key: "geocoords"),
              let entry = dict[listingId] else { return nil }
        return CLLocationCoordinate2D(latitude: entry.lat, longitude: entry.lon)
    }

    private func persistCoordinate(_ coord: CLLocationCoordinate2D, for listingId: String) {
        var dict = CacheService.load([String: CachedCoord].self, key: "geocoords") ?? [:]
        dict[listingId] = CachedCoord(lat: coord.latitude, lon: coord.longitude)
        CacheService.save(dict, key: "geocoords")
    }

    func coordinate(for listing: ListingResponse) async -> CLLocationCoordinate2D? {
        if let cached = cachedCoordinate(for: listing.id) { return cached }

        let parts = [listing.address, listing.city, listing.state]
            .compactMap { $0 }.filter { !$0.isEmpty }
        guard !parts.isEmpty else { return nil }
        let fullAddress = parts.joined(separator: ", ")

        do {
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.geocodeAddressString(fullAddress)
            if let coord = placemarks.first?.location?.coordinate {
                persistCoordinate(coord, for: listing.id)
                return coord
            }
            return nil
        } catch {
            print("Geocoding failed for \(fullAddress): \(error)")
            return nil
        }
    }
}
