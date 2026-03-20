//
//  FilterView.swift
//  Roomora
//
//  Created by Jeronimo Cifci on 20/03/26.
//
import SwiftUI

struct FilterView: View {
    @Binding var filters: SearchFilters
    @Environment(\.dismiss) private var dismiss

    @State private var city: String = ""
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 5000
    @State private var bedrooms: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // City
                    VStack(alignment: .leading, spacing: 8) {
                        Text("City")
                            .font(.h4())
                        TextField("e.g. Bogotá", text: $city)
                            .padding()
                            .background(Color(.neutral, 100))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Price Range
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price Range")
                            .font(.h4())
                        HStack {
                            Text("$\(Int(minPrice))")
                                .font(.body14())
                            Spacer()
                            Text("$\(Int(maxPrice))")
                                .font(.body14())
                        }
                        .padding(.horizontal)

                        VStack(spacing: 8) {
                            HStack {
                                Text("Min:")
                                    .font(.body14())
                                    .foregroundColor(Color(.neutral, 400))
                                Slider(value: $minPrice, in: 0...maxPrice, step: 100)
                                    .tint(Color(.purple, 500))
                            }
                            HStack {
                                Text("Max:")
                                    .font(.body14())
                                    .foregroundColor(Color(.neutral, 400))
                                Slider(value: $maxPrice, in: minPrice...5000, step: 100)
                                    .tint(Color(.purple, 500))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)

                    // Bedrooms
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bedrooms")
                            .font(.h4())
                        HStack(spacing: 12) {
                            ForEach([0, 1, 2, 3, 4], id: \.self) { num in
                                Button {
                                    bedrooms = num
                                } label: {
                                    Text(num == 0 ? "Any" : "\(num)")
                                        .font(.body14(.semiBold))
                                        .foregroundColor(bedrooms == num ? .white : Color(.purple, 500))
                                        .frame(width: 50, height: 40)
                                        .background(bedrooms == num ? Color(.purple, 500) : Color(.purple, 100))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Apply Button
                    AppButton(title: "Apply Filters") {
                        filters.city = city
                        filters.minPrice = minPrice
                        filters.maxPrice = maxPrice
                        filters.bedrooms = bedrooms == 0 ? nil : bedrooms
                        dismiss()
                    }
                    .padding()

                    // Reset Button
                    AppButton(title: "Reset", variant: .secondary) {
                        filters = SearchFilters()
                        city = ""
                        minPrice = 0
                        maxPrice = 5000
                        bedrooms = 0
                        dismiss()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                city = filters.city
                minPrice = filters.minPrice
                maxPrice = filters.maxPrice
                bedrooms = filters.bedrooms ?? 0
            }
        }
    }
}
