//
//  ListingsMapView.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import SwiftUI
import MapKit
import ClerkKit

struct ListingsMapView: View {
    @StateObject private var viewModel = ListingsMapViewModel()
    @State private var selectedListing: ListingResponse?
    @State private var favoritedIds: Set<String> = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: .constant(.region(viewModel.region))) {
                ForEach(viewModel.mapItems) { item in
                    Annotation(item.title, coordinate: item.coordinate) {
                        Button {
                            viewModel.selectedItem = item
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .task {
                viewModel.requestLocationAccess()
                async let listings: () = viewModel.loadListings()
                async let favorites: [ListingResponse] = (try? APIClient.shared.fetchFavorites(clerk: Clerk.shared)) ?? []
                let (_, favs) = await (listings, favorites)
                favoritedIds = Set(favs.map { $0.id })

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                viewModel.centerOnUserIfAvailable()
            }

            if let selectedItem = viewModel.selectedItem {
                MapListingDetailCard(item: selectedItem) {
                    selectedListing = selectedItem.listing
                }
                .padding()
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedListing) { listing in
            ListingDetailSheet(
                listing: listing,
                showApplyButton: true,
                initiallyFavorited: favoritedIds.contains(listing.id),
                onFavoriteToggled: {
                    let isFav = favoritedIds.contains(listing.id)
                    if isFav {
                        favoritedIds.remove(listing.id)
                        try? await APIClient.shared.removeFavorite(clerk: Clerk.shared, listingId: listing.id)
                    } else {
                        favoritedIds.insert(listing.id)
                        try? await APIClient.shared.addFavorite(clerk: Clerk.shared, listingId: listing.id)
                    }
                }
            )
        }
    }
}
