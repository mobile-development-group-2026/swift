import SwiftUI
import ClerkKit

struct ListingPreviewView: View {
    let listing: Listing
    @Environment(AppRouter.self) private var router
    @Environment(Clerk.self) private var clerk
    @State private var isPublished = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private func publishListing() async {
        print("=== PUBLISH TAPPED ===")
        isLoading = true
        
        do {
            let _ = try await APIClient.shared.createListing(
                clerk: clerk,
                listing: listing
            )
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
                    let fullAddress = buildFullAddress()
                    Text(fullAddress)
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
                    if let leaseTermMonths = listing.leaseTermMonths {
                        InfoRow(label: "Lease Length", value: "\(leaseTermMonths) months")
                    }
                    if let availableDate = listing.availableDate {
                        InfoRow(label: "Available Date", value: availableDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
                .padding(.horizontal)

                Divider()

                // Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.h3())
                    InfoRow(label: "Bedrooms", value: "\(listing.bedrooms)")
                    InfoRow(label: "Bathrooms", value: "\(listing.bathrooms)")
                    InfoRow(label: "Property Type", value: listing.propertyType.capitalized)
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

                if isPublished {
                    VStack(spacing: 12) {
                        Text("Listing Published Successfully! 🎉")
                            .font(.h3())
                            .foregroundColor(Color(.green, 500))
                        
                        AppButton(title: "View My Listings") {
                            // Pop create flow and go to profile
                            router.popToRoot()
                            router.navigate(to: .landlordProfile)
                        }
                    }
                    .padding()
                } else {
                    AppButton(title: "Publish Listing") {
                        Task {
                            await publishListing()
                        }
                    }
                    .padding()
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.6 : 1)
                }
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

    private func buildFullAddress() -> String {
        let address = listing.address
        let city = listing.city
        let state = listing.state
        return "\(address), \(city), \(state)"
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
