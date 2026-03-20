//
//  PropertyListView.swift
//  Roomora
//
//  Created by Jeronimo Cifci on 20/03/26.
//

import SwiftUI

struct PropertyListView: View {
    @State private var listings: [Listing] = []
    @State private var filters = SearchFilters()
    @State private var isLoading = false
    @State private var showFilters = false
    @State private var errorMessage: String?

    private let lowMatchThreshold = 3

    var showRelaxationSuggestions: Bool {
        !isLoading && listings.count < lowMatchThreshold && !filters.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {

            // Top Toggle
            HStack(spacing: 0) {
                Button {
                    // roommate tab
                } label: {
                    HStack {
                        Image(systemName: "person")
                        Text("Roommate")
                    }
                    .font(.body14(.semiBold))
                    .foregroundColor(Color(.neutral, 500))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.neutral, 100))
                    .cornerRadius(20)
                }

                Button {
                    // housing tab - active
                } label: {
                    HStack {
                        Image(systemName: "house")
                        Text("Housing")
                    }
                    .font(.body14(.semiBold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.purple, 500))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header row
                    HStack {
                        Text("LISTINGS NEAR CAMPUS")
                            .font(.body12(.semiBold))
                            .foregroundColor(Color(.purple, 500))
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "house")
                                .font(.body12())
                            Text("\(listings.count) available")
                                .font(.body12(.semiBold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.neutral, 100))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)

                    // Active filters
                    if !filters.isEmpty {
                        ActiveFiltersView(filters: filters) {
                            filters = SearchFilters()
                        }
                    }

                    // Relaxation suggestions
                    if showRelaxationSuggestions {
                        RelaxationSuggestionsView(
                            suggestions: filters.relaxationSuggestions(),
                            onApply: applyRelaxation
                        )
                    }

                    // Featured card
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if listings.isEmpty {
                        EmptyStateView()
                    } else {
                        // First listing as featured
                        if let featured = listings.first {
                            FeaturedListingCard(listing: featured)
                                .padding(.horizontal)
                        }

                        // More near you
                        if listings.count > 1 {
                            HStack {
                                Text("More near you")
                                    .font(.h4(.semiBold))
                                Spacer()
                                Button("See all") {}
                                    .font(.body14(.semiBold))
                                    .foregroundColor(Color(.purple, 500))
                            }
                            .padding(.horizontal)

                            ForEach(listings.dropFirst()) { listing in
                                CompactListingCard(listing: listing)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color(.neutral, 700))
                        .padding(8)
                        .background(Color(.neutral, 100))
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterView(filters: $filters)
        }
        .task {
            await loadListings()
        }
        .onChange(of: filters) {
            Task { await loadListings() }
        }
    }

    private func loadListings() async {
        isLoading = true
        do {
            listings = try await ListingService.shared.searchListings(filters: filters)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func applyRelaxation(_ action: RelaxationAction) {
        switch action {
        case .increaseMaxPrice(let amount):
            filters.maxPrice += amount
        case .decreaseBedrooms:
            if let beds = filters.bedrooms, beds > 1 {
                filters.bedrooms = beds - 1
            } else {
                filters.bedrooms = nil
            }
        case .removeCity:
            filters.city = ""
        }
    }
}

// MARK: - Featured Card
struct FeaturedListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Photo placeholder
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color(.neutral, 200))
                    .frame(height: 200)
                    .cornerRadius(16)

                PillBadge(label: "Verified landlord")
                    .padding(12)

                Text("$\(String(format: "%.0f", listing.rent))")
                    .font(.h2(.bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(listing.title)
                        .font(.h4(.semiBold))
                    Spacer()
                    Image(systemName: "heart")
                        .foregroundColor(Color(.neutral, 400))
                }

                Text("\(listing.city), \(listing.state) · \(listing.propertyType)")
                    .font(.body14())
                    .foregroundColor(Color(.neutral, 500))

                // Compatibility bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Compatibility")
                            .font(.body14(.semiBold))
                            .foregroundColor(Color(.purple, 500))
                        Spacer()
                        Text("87%")
                            .font(.body14(.semiBold))
                            .foregroundColor(Color(.purple, 500))
                    }
                    ProgressView(value: 0.87)
                        .tint(Color(.purple, 500))
                }

                HStack(spacing: 8) {
                    AppButton(title: "Schedule visit", variant: .secondary) {}
                    AppButton(title: "Apply now →") {}
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        }
    }
}

// MARK: - Compact Card
struct CompactListingCard: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(.neutral, 200))
                .frame(width: 80, height: 80)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("$\(String(format: "%.0f", listing.rent))/mo")
                        .font(.body14(.semiBold))
                    Spacer()
                    Image(systemName: "heart")
                        .foregroundColor(Color(.neutral, 400))
                }

                Text(listing.title)
                    .font(.body14())
                    .foregroundColor(Color(.neutral, 700))

                Text("\(listing.city) · \(listing.propertyType)")
                    .font(.body12())
                    .foregroundColor(Color(.neutral, 400))

                HStack(spacing: 4) {
                    PillBadge(label: "\(listing.leaseTermMonths) months")
                    if listing.petsAllowed {
                        PillBadge(label: "Pets ok")
                    }
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
    
}
// MARK: - Active Filters
struct ActiveFiltersView: View {
    let filters: SearchFilters
    let onClear: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(Color(.purple, 500))
            Text("Filters active")
                .font(.body14(.semiBold))
            Spacer()
            Button("Clear all", action: onClear)
                .font(.body14())
                .foregroundColor(Color(.purple, 500))
        }
        .padding()
        .background(Color(.purple, 100))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Relaxation Suggestions
struct RelaxationSuggestionsView: View {
    let suggestions: [RelaxationSuggestion]
    let onApply: (RelaxationAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(.yellow, 500))
                Text("Not many results — try adjusting:")
                    .font(.body14(.semiBold))
            }
            ForEach(suggestions) { suggestion in
                Button {
                    onApply(suggestion.action)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.body14(.semiBold))
                                .foregroundColor(Color(.purple, 500))
                            Text(suggestion.description)
                                .font(.body12())
                                .foregroundColor(Color(.neutral, 400))
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color(.purple, 500))
                    }
                    .padding()
                    .background(Color(.neutral, 100))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.yellow, 100))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.slash")
                .font(.system(size: 48))
                .foregroundColor(Color(.neutral, 300))
            Text("No listings found")
                .font(.h3())
            Text("Try adjusting your filters")
                .font(.body16())
                .foregroundColor(Color(.neutral, 400))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
