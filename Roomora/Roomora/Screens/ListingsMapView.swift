//
//  ListingsMapView.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import SwiftUI
import MapKit

struct ListingsMapView: View {
    @StateObject private var viewModel = ListingsMapViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(
                coordinateRegion: $viewModel.region,
                annotationItems: viewModel.mapItems
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button {
                        viewModel.selectedItem = item
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            }
            .ignoresSafeArea()
            .task {
                viewModel.requestLocationAccess()
                await viewModel.loadListings()

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                viewModel.centerOnUserIfAvailable()
            }

            if let selectedItem = viewModel.selectedItem {
                MapListingDetailCard(item: selectedItem) {
                    print("Open details for listing: \(selectedItem.id)")
                }
                .padding()
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}
