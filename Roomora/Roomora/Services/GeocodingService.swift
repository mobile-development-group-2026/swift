//
//  GeocodingService.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation
import CoreLocation

final class GeocodingService {
    static let shared = GeocodingService()

    private let geocoder = CLGeocoder()
    private init() {}

    func coordinate(for listing: Listing) async -> CLLocationCoordinate2D? {
        if let lat = listing.latitude, let lon = listing.longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        let fullAddress = "\(listing.address), \(listing.city)"

        do {
            let placemarks = try await geocoder.geocodeAddressString(fullAddress)
            return placemarks.first?.location?.coordinate
        } catch {
            print("Geocoding failed for \(fullAddress): \(error)")
            return nil
        }
    }
}
