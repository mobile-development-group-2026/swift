import SwiftUI
import ClerkKit

struct CreateListingSheet: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var vm = NewListingViewModel()
    @State private var isLoading = false
    @State private var error: String?

    var onCreated: (ListingResponse) -> Void

    var body: some View {
        NavigationStack {
            NewListingView(vm: vm)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    VStack(spacing: 0) {
                        Divider()
                        VStack(spacing: AppSpacing.sm) {
                            if let error {
                                ErrorMessage(message: error)
                            }
                            AppButton(
                                title: isLoading ? "Posting…" : "Post Listing",
                                variant: .primary
                            ) {
                                Task { await submit() }
                            }
                            .disabled(isLoading || !vm.canSubmit)
                            .opacity(vm.canSubmit ? 1 : 0.5)
                        }
                        .padding(AppSpacing.lg)
                        .background(.white)
                    }
                }
                .navigationTitle("New Listing")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(Color(.neutral, 600))
                    }
                }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Submit

    private func submit() async {
        isLoading = true
        error = nil

        var fields: [String: Any] = [:]
        fields["listing_type"] = "property"
        fields["title"] = vm.title

        if let rent = Int(vm.monthlyRent) { fields["rent"] = rent }
        if let deposit = Int(vm.securityDeposit), deposit > 0 { fields["security_deposit"] = deposit }
        if let type = vm.propertyType { fields["property_type"] = type }
        if !vm.description.isEmpty { fields["description"] = vm.description }

        if !vm.city.isEmpty    { fields["city"] = vm.city }
        if !vm.address.isEmpty { fields["address"] = vm.address }
        if !vm.state.isEmpty   { fields["state"] = vm.state }
        if !vm.zipCode.isEmpty { fields["zip_code"] = vm.zipCode }

        fields["bedrooms"] = vm.bedrooms
        fields["bathrooms"] = vm.bathrooms

        // "12 months" → 12
        if let months = Int(vm.leaseLength.components(separatedBy: " ").first ?? "") {
            fields["lease_term_months"] = months
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        fields["available_date"] = formatter.string(from: vm.availableFrom)

        if !vm.selectedAmenities.isEmpty { fields["amenities"] = Array(vm.selectedAmenities.sorted()) }
        if !vm.selectedRules.isEmpty     { fields["rules"]     = Array(vm.selectedRules.sorted()) }

        do {
            let listing = try await APIClient.shared.createListing(clerk: clerk, fields: fields)
            onCreated(listing)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
