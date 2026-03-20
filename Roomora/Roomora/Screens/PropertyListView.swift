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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Active filters summary
                    if !filters.isEmpty {
                        ActiveFiltersView(filters: filters) {
                            filters = SearchFilters()
                        }
                    }

                    // Low match CTA
                    if showRelaxationSuggestions {
                        RelaxationSuggestionsView(
                            suggestions: filters.relaxationSuggestions(),
                            onApply: { action in
                                applyRelaxation(action)
                            }
                        )
                    }

                    // Listings
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if listings.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(listings) { listing in
                            PropertyCard(listing: listing)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Find a Place")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color(.purple, 500))
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

// MARK: - Subviews

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

struct PropertyCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.title)
                .font(.h4())
            Text(listing.address + ", " + listing.city)
                .font(.body14())
                .foregroundColor(Color(.neutral, 400))
            HStack {
                PillBadge(label: "$\(String(format: "%.0f", listing.rent))/mo")
                PillBadge(label: "\(listing.bedrooms) bed")
                if listing.petsAllowed {
                    PillBadge(label: "🐾 Pets ok")
                }
            }
        }
        .padding()
        .background(Color(.neutral, 100))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
