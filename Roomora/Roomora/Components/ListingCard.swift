import SwiftUI

struct ListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.title)
                .font(.h3())

            Text(listing.address)
                .font(.body16())
                .foregroundColor(Color(.neutral, 400))

            HStack {
                PillBadge(label: "$\(String(format: "%.0f", listing.rent))/mo")
                if let leaseTermMonths = listing.leaseTermMonths {
                    PillBadge(label: "\(leaseTermMonths) months")
                }
                if let availableDate = listing.availableDate {
                    PillBadge(label: availableDate.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .padding()
        .background(Color(.neutral, 100))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
