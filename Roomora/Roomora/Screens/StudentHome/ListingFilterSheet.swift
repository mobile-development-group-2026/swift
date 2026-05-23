//
//  ListingFilterSheet.swift
//  Roomora
//
//  Created by Andy on 23/05/26.
//


import SwiftUI

struct ListingFilterSheet: View {
    @Binding var filter: ListingFilter
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let priceOptions = [500_000, 800_000, 1_200_000, 1_800_000, 2_500_000]
    private let bedroomOptions = [1, 2, 3, 4]
    private let propertyTypes = ["Studio", "Apartment", "Room", "House"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    // Max price
                    filterSection(icon: "dollarsign.circle.fill", title: "MAX PRICE / MONTH") {
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(priceOptions, id: \.self) { price in
                                filterChip(formatPrice(price), selected: filter.maxPrice == price) {
                                    filter.maxPrice = filter.maxPrice == price ? nil : price
                                }
                            }
                        }
                    }

                    // Bedrooms
                    filterSection(icon: "bed.double.fill", title: "BEDROOMS") {
                        HStack(spacing: AppSpacing.md) {
                            ForEach(bedroomOptions, id: \.self) { n in
                                Button {
                                    filter.bedrooms = filter.bedrooms == n ? nil : n
                                } label: {
                                    Text("\(n)")
                                        .font(.body14(.semiBold))
                                        .foregroundStyle(filter.bedrooms == n ? Color(.purple, 700) : Color(.neutral, 700))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(filter.bedrooms == n ? Color(.purple, 100) : .white))
                                        .overlay(Circle().stroke(filter.bedrooms == n ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                    }

                    // Property type
                    filterSection(icon: "building.2.fill", title: "PROPERTY TYPE") {
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(propertyTypes, id: \.self) { type in
                                filterChip(type, selected: filter.propertyType == type) {
                                    filter.propertyType = filter.propertyType == type ? nil : type
                                }
                            }
                        }
                    }

                    // Pets
                    filterSection(icon: "pawprint.fill", title: "PETS") {
                        HStack(spacing: AppSpacing.sm) {
                            filterChip("🐾 Pets allowed", selected: filter.petsAllowed == true) {
                                filter.petsAllowed = filter.petsAllowed == true ? nil : true
                            }
                            filterChip("🚫 No pets", selected: filter.petsAllowed == false) {
                                filter.petsAllowed = filter.petsAllowed == false ? nil : false
                            }
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("Filter Listings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") { filter = ListingFilter() }
                        .foregroundStyle(Color(.neutral, 600))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { onApply(); dismiss() }
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.purple, 500))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.light)
    }

    private func formatPrice(_ p: Int) -> String {
        let m = Double(p) / 1_000_000
        if m >= 1 {
            let s = String(format: "$%.1fM", m)
            return s.hasSuffix(".0M") ? s.replacingOccurrences(of: ".0M", with: "M") : s
        }
        return "$\(p / 1000)K"
    }

    private func filterSection<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.purple, 500))
                Text(title)
                    .font(.body10(.semiBold))
                    .foregroundStyle(Color(.neutral, 600))
            }
            content()
        }
    }

    private func filterChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.body12(.semiBold))
                .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(RoundedRectangle(cornerRadius: 20).fill(selected ? Color(.purple, 100) : .white))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
