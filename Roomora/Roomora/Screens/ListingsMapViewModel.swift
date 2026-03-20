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

        do {
            let listings = try await ListingService.shared.searchListings(filters: SearchFilters())
            var items: [ListingMapItem] = []

            for listing in listings {
                guard let id = listing.id else { continue }
                guard let coordinate = await GeocodingService.shared.coordinate(for: listing) else { continue }

                let item = ListingMapItem(
                    id: id,
                    title: listing.title,
                    address: listing.address,
                    city: listing.city,
                    rent: listing.rent,
                    coordinate: coordinate,
                    listing: listing
                )

                items.append(item)
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
        } catch {
            print("Failed to load listings for map: \(error)")
        }
    }
}
