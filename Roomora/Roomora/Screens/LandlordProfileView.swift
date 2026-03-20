//
//  LandlordProfileView.swift
//
//
//  Created by Jeronimo Cifci on 18/03/26.
//

import SwiftUI
import ClerkKit

struct LandlordProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(UserSession.self) private var session
    @Environment(Clerk.self) private var clerk
    @State private var listings: [Listing] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Profile Header
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color(.purple, 500))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text("L")
                                .font(.h2())
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Listings")
                            .font(.h3())
                        Text("\(listings.count) listing\(listings.count == 1 ? "" : "s")")
                            .font(.body16())
                            .foregroundColor(Color(.neutral, 400))
                    }
                }
                .padding(.horizontal)

                Divider()

                // Listings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Active Listings")
                        .font(.h3())
                        .padding(.horizontal)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if listings.isEmpty {
                        Text("No listings yet.")
                            .font(.body16())
                            .foregroundColor(Color(.neutral, 400))
                            .padding(.horizontal)
                    } else {
                        ForEach(listings) { listing in
                            ListingCard(listing: listing)
                        }
                    }
                }

                AppButton(title: "Add New Listing") {
                    router.navigate(to: .createListing)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadListings()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func loadListings() async {
        isLoading = true
        print("📥 [LandlordProfile] Loading listings...")
        do {
            let response = try await APIClient.shared.getListings(clerk: clerk)
            let allListings = response.data
            print("📥 [LandlordProfile] Fetched \(allListings.count) total listings")
            
            // Filter by current user ID if available
            if let myUserId = session.profile?.id {
                print("👤 [LandlordProfile] Filtering for user ID: \(myUserId)")
                listings = allListings.filter { $0.userId == myUserId }
            } else {
                print("⚠️ [LandlordProfile] No user ID found in session, showing all")
                listings = allListings
            }
            print("✅ [LandlordProfile] Showing \(listings.count) listings")
        } catch {
            print("❌ [LandlordProfile] Error loading listings: \(error)")
            errorMessage = "Failed to load listings: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
