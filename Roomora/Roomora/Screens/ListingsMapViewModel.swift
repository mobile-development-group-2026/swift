//
//  ListingsMapViewModel.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation
import MapKit
import Combine
import CoreLocation
import ClerkKit

@MainActor
final class ListingsMapViewModel: ObservableObject {
    @Published var mapItems: [ListingMapItem] = []
    @Published var selectedItem: ListingMapItem?
    @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 4.6097, longitude: -74.0817),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @Published var isLoading = false

    func requestLocationAccess() {
        LocationManager.shared.requestPermissions()
        LocationManager.shared.startUpdatingLocation()
    }

    func centerOnUserIfAvailable() {
            guard let location = LocationManager.shared.currentLocation else { return }

            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }

    func loadListings() async {
        isLoading = true
        defer { isLoading = false }

        // Use cached listings immediately so pins appear without a network round-trip.
        // Fall back to a fresh fetch only when the cache is empty.
        let listings: [ListingResponse]
        if let cached = CacheService.load([ListingResponse].self, key: "listings"), !cached.isEmpty {
            listings = cached
        } else {
            do {
                listings = try await APIClient.shared.fetchListings(clerk: Clerk.shared)
            } catch {
                print("Failed to load listings for map: \(error)")
                return
            }
        }

        let items = await withTaskGroup(of: ListingMapItem?.self, returning: [ListingMapItem].self) { group in
            for listing in listings {
                group.addTask {
                    guard let coordinate = await GeocodingService.shared.coordinate(for: listing) else {
                        return nil
                    }
                    return ListingMapItem(
                        id: listing.id,
                        title: listing.title,
                        address: listing.address ?? "",
                        city: listing.city ?? "",
                        rent: Double(listing.rent) ?? 0,
                        coordinate: coordinate,
                        listing: listing
                    )
                }
            }
            var results: [ListingMapItem] = []
            for await item in group {
                if let item { results.append(item) }
            }
            return results
        }

        mapItems = items

        if LocationManager.shared.currentLocation != nil {
            centerOnUserIfAvailable()
        } else if let first = items.first {
            region = MKCoordinateRegion(
                center: first.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }
    }
}
