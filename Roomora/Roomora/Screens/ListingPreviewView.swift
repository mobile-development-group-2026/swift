//
//  ListingPreviewView.swift
//  
//
//  Created by Jeronimo Cifci on 18/03/26.
//

import SwiftUI
import ClerkKit

struct ListingPreviewView: View {
    let listing: Listing
    @State private var isPublished = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    

    private func publishListing() async {
        print("=== PUBLISH TAPPED ===")
        isLoading = true
        
        isLoading = true
        do {
            let token = try await Clerk.shared.session?.getToken() ?? ""
            if token.isEmpty {
                errorMessage = "No auth token found — are you logged in?"
                isLoading = false
                return
            }
            try await ListingService.shared.syncUser(token: token)
            let _ = try await ListingService.shared.createListing(listing, token: token)
            isPublished = true
        } catch {
            errorMessage = "Failed to publish: \(error.localizedDescription)"
        }
        isLoading = false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(listing.title)
                        .font(.h1())
                    Text(listing.address + ", " + listing.city + ", " + listing.state)
                        .font(.body16())
                        .foregroundColor(Color(.neutral, 400))
                }
                .padding(.horizontal)

                Divider()

                // Financial
                VStack(alignment: .leading, spacing: 12) {
                    Text("Financial Details")
                        .font(.h3())
                    InfoRow(label: "Monthly Rent", value: "$\(String(format: "%.0f", listing.rent))")
                    InfoRow(label: "Security Deposit", value: "$\(String(format: "%.0f", listing.securityDeposit))")
                    if listing.utilitiesIncluded {
                        InfoRow(label: "Utilities", value: "Included ($\(String(format: "%.0f", listing.utilitiesCost)))")
                    } else {
                        InfoRow(label: "Utilities", value: "Not included")
                    }
                }
                .padding(.horizontal)

                Divider()

                // Lease
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lease Info")
                        .font(.h3())
                    InfoRow(label: "Lease Length", value: "\(listing.leaseTermMonths) months")
                    InfoRow(label: "Available Date", value: listing.availableDate.formatted(date: .abbreviated, time: .omitted))
                }
                .padding(.horizontal)

                Divider()

                // Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.h3())
                    InfoRow(label: "Bedrooms", value: "\(listing.bedrooms)")
                    InfoRow(label: "Bathrooms", value: "\(listing.bathrooms)")
                    InfoRow(label: "Property Type", value: listing.propertyType)
                }
                .padding(.horizontal)

                Divider()

                // House Rules
                VStack(alignment: .leading, spacing: 12) {
                    Text("House Rules")
                        .font(.h3())
                    InfoRow(label: "Pets", value: listing.petsAllowed ? "Allowed" : "Not allowed")
                    InfoRow(label: "Parties", value: listing.partiesAllowed ? "Allowed" : "Not allowed")
                    InfoRow(label: "Smoking", value: listing.smokingAllowed ? "Allowed" : "Not allowed")
                }
                .padding(.horizontal)

                Divider()

                AppButton(title: isPublished ? "✓ Published" : "Publish Listing") {
                    Task {
                        await publishListing()
                    }
                }
                .padding()
                .opacity(isPublished ? 0.6 : 1)
            }
            .padding(.vertical)
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body16())
                .foregroundColor(Color(.neutral, 400))
            Spacer()
            Text(value)
                .font(.body16(.semiBold))
        }
    }
}
