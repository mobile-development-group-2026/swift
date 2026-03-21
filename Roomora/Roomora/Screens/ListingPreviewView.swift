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
        isLoading = true
        do {
            let _ = try await APIClient.shared.createListing(clerk: clerk, listing: listing)
            isPublished = true
        } catch {
            errorMessage = "Failed to publish: \(error.localizedDescription)"
        }
        isLoading = false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(listing.title).font(.h1())
                
                if isPublished {
                    VStack(spacing: 12) {
                        Text("Listing Published Successfully! 🎉").font(.h3()).foregroundColor(Color(.green, 500))
                        AppButton(title: "View My Listings") {
                            router.popToRoot()
                            router.navigate(to: .landlordProfile)
                        }
                    }.padding()
                } else {
                    AppButton(title: "Publish Listing") {
                        Task { await publishListing() }
                    }
                    .padding().opacity(isLoading ? 0.6 : 1)
                }
            }.padding()
        }
        .navigationTitle("Preview")
        .alert("Error", isPresented: .constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
    }
}
