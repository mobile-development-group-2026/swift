//
//  LandlordProfileView.swift
//  
//
//  Created by Jeronimo Cifci on 18/03/26.
//

import SwiftUI

struct LandlordProfileView: View {
    let landlordName: String
    let listings: [Listing]

    var activeListings: [Listing] {
        listings.filter { $0.status == "active" }
    }
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Profile Header
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color(.purple, 500))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text(String(landlordName.prefix(1)))
                                .font(.h2())
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(landlordName)
                            .font(.h3())
                        Text("\(activeListings.count) active listing\(activeListings.count == 1 ? "" : "s")")
                            .font(.body16())
                            .foregroundColor(Color(.neutral, 400))
                    }
                }
                .padding(.horizontal)

                Divider()

                // Active Listings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Active Listings")
                        .font(.h3())
                        .padding(.horizontal)

                    if activeListings.isEmpty {
                        Text("No active listings yet.")
                            .font(.body16())
                            .foregroundColor(Color(.neutral, 400))
                            .padding(.horizontal)
                    } else {
                        ForEach(activeListings) { listing in
                            ListingCard(listing: listing)
                        }
                    }
                }

                // Add New Listing
                AppButton(title: "Add New Listing") {
                    router.navigate(to: .createListing)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
