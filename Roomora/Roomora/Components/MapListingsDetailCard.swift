//
//  MapListingsDetailCard.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import SwiftUI

struct MapListingDetailCard: View {
    let item: ListingMapItem
    var onViewDetails: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)

            Text("\(item.address), \(item.city)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("$\(Int(item.rent))/mo")
                .font(.subheadline)
                .fontWeight(.semibold)

            if let onViewDetails {
                Button("View details") {
                    onViewDetails()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 6)
    }
}
