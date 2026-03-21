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
                HStack {
                    Circle().fill(Color(.purple, 500)).frame(width: 70, height: 70)
                    VStack(alignment: .leading) {
                        Text("My Listings").font(.h3())
                        Text("\(listings.count) active").font(.body16()).foregroundColor(Color(.neutral, 400))
                    }
                }.padding()

                if isLoading { ProgressView().padding() }
                else {
                    ForEach(listings) { listing in
                        ListingCard(listing: listing)
                    }
                }
                
                AppButton(title: "Add New Listing") { router.navigate(to: .createListing) }.padding()
            }
        }
        .navigationTitle("Profile")
        .task { await loadListings() }
    }

    private func loadListings() async {
        isLoading = true
        do {
            let response = try await APIClient.shared.getListings(clerk: clerk)
            if let myUserId = session.profile?.id {
                listings = response.data.filter { $0.userId == myUserId }
            } else {
                listings = response.data
            }
        } catch {
            errorMessage = "Failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
