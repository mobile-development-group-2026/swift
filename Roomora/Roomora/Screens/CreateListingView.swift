//
//  CreateListingView.swift
//  
//
//  Created by Jeronimo Cifci on 18/03/26.
//

import SwiftUI

struct CreateListingView: View {
    @State private var currentStep = 1
    private let totalSteps = 4

    // Basic Info
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPropertyType = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var rent = ""
    @State private var securityDeposit = ""
    @State private var bedrooms = ""
    @State private var bathrooms = ""
    @State private var leaseTermMonths = ""
    @State private var availableDate = Date()
    @State private var selectedAmenities: Set<String> = []
    @State private var selectedRules: Set<String> = []
    @State private var navigateToPreview = false

    let propertyTypes = ["Apartment", "House", "Room", "Studio"]
    let amenities = ["WiFi", "Laundry", "Parking", "AC", "Gym", "Pool", "Balcony", "Furnished"]
    let rules = ["No smoking", "No parties", "No pets", "No overnight guests", "Quiet after 10pm", "Students only"]

    var body: some View {
        VStack(spacing: 0) {

            // Stepper
            StepperView(current: currentStep, total: totalSteps)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("New")
                            .font(.h1())
                            .foregroundColor(Color(.neutral, 900))
                        Text("listing")
                            .font(.h1())
                            .foregroundColor(Color(.purple, 500))
                        Text("Fill in your property details. You can edit anytime before publishing.")
                            .font(.body14())
                            .foregroundColor(Color(.neutral, 500))
                    }
                    .padding(.horizontal)

                    // Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionLabel(text: "DETAILS")

                        // Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PROPERTY TITLE")
                                .font(.body12(.semiBold))
                                .foregroundColor(Color(.neutral, 500))
                            TextField("e.g. Bright studio near Uniandes", text: $title)
                                .padding()
                                .background(Color(.neutral, 100))
                                .cornerRadius(10)
                        }

                        // Location Section
                        VStack(alignment: .leading, spacing: 6) {
                            Text("LOCATION")
                                .font(.body12(.semiBold))
                                .foregroundColor(Color(.neutral, 500))
                            
                            TextField("Address (e.g. Cra 1 # 18A-12)", text: $address)
                                .padding()
                                .background(Color(.neutral, 100))
                                .cornerRadius(10)
                                
                            HStack(spacing: 12) {
                                TextField("City", text: $city)
                                    .padding()
                                    .background(Color(.neutral, 100))
                                    .cornerRadius(10)
                                    
                                TextField("State", text: $state)
                                    .padding()
                                    .background(Color(.neutral, 100))
                                    .cornerRadius(10)
                            }
                            
                            TextField("Zip Code", text: $zipCode)
                                .padding()
                                .background(Color(.neutral, 100))
                                .cornerRadius(10)
                        }

                        // Rent + Deposit
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("SECURITY DEPOSIT")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                HStack {
                                    Text("$")
                                        .foregroundColor(Color(.neutral, 400))
                                    TextField("850", text: $securityDeposit)
                                        .keyboardType(.decimalPad)
                                }
                                .padding()
                                .background(Color(.neutral, 100))
                                .cornerRadius(10)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("MONTHLY RENT")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                HStack {
                                    Text("$")
                                        .foregroundColor(Color(.neutral, 400))
                                    TextField("850", text: $rent)
                                        .keyboardType(.decimalPad)
                                }
                                .padding()
                                .background(Color(.neutral, 100))
                                .cornerRadius(10)
                            }
                        }

                        // Property Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PROPERTY TYPE")
                                .font(.body12(.semiBold))
                                .foregroundColor(Color(.neutral, 500))
                            FlexibleChips(
                                options: propertyTypes,
                                selected: Binding(
                                    get: { selectedPropertyType.isEmpty ? [] : [selectedPropertyType] },
                                    set: { selectedPropertyType = $0.first ?? "" }
                                ),
                                multiSelect: false,
                                selectedColor: Color(.purple, 500)
                            )
                        }

                        // Bedrooms & Bathrooms
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("BEDROOMS")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                TextField("e.g. 3", text: $bedrooms)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.neutral, 100))
                                    .cornerRadius(10)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("BATHROOMS")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                TextField("e.g. 2", text: $bathrooms)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.neutral, 100))
                                    .cornerRadius(10)
                            }
                        }

                        // Lease + Available
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("LEASE LENGTH")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                TextField("12 months", text: $leaseTermMonths)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.neutral, 100))
                                    .cornerRadius(10)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("AVAILABLE FROM")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                DatePicker("", selection: $availableDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .padding()
                                    .background(Color(.neutral, 100))
                                    .cornerRadius(10)
                            }
                        }

                        // Amenities
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AMENITIES")
                                .font(.body12(.semiBold))
                                .foregroundColor(Color(.neutral, 500))
                            FlexibleChips(
                                options: amenities,
                                selected: $selectedAmenities,
                                multiSelect: true,
                                selectedColor: Color(.purple, 500)
                            )
                        }

                        // Rules
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NON-NEGOTIABLE RULES")
                                .font(.body12(.semiBold))
                                .foregroundColor(Color(.neutral, 500))
                            FlexibleChips(
                                options: rules,
                                selected: $selectedRules,
                                multiSelect: true,
                                selectedColor: Color(.green, 500)
                            )
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("DESCRIPTION")
                                    .font(.body12(.semiBold))
                                    .foregroundColor(Color(.neutral, 500))
                                Spacer()
                                Text("\(description.count) / 80 min")
                                    .font(.body12())
                                    .foregroundColor(Color(.neutral, 400))
                            }
                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding()
                                .background(Color(.neutral, 100))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }

            // Bottom Buttons
            VStack(spacing: 8) {
                AppButton(title: "Publish listing →") {
                    navigateToPreview = true
                }
                Button("Save as draft") {}
                    .font(.body14(.semiBold))
                    .foregroundColor(Color(.neutral, 500))
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(.white)
        }
        .navigationDestination(isPresented: $navigateToPreview) {
            ListingPreviewView(listing: buildListing())
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func buildListing() -> Listing {
        Listing(
            listingType: "property",
            title: title,
            description: description,
            propertyType: selectedPropertyType.lowercased(),
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            rent: Double(rent) ?? 0,
            securityDeposit: Double(securityDeposit) ?? 0,
            availableDate: availableDate,
            leaseTermMonths: Int(leaseTermMonths) ?? 12,
            bedrooms: Int(bedrooms) ?? 1,
            bathrooms: Int(bathrooms) ?? 1
        )
    }
}

// MARK: - Helper Views

struct StepperView: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...total, id: \.self) { step in
                Circle()
                    .fill(step <= current ? Color(.purple, 500) : Color(.neutral, 200))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("\(step)")
                            .font(.body12(.semiBold))
                            .foregroundColor(step <= current ? .white : Color(.neutral, 400))
                    )
                if step < total {
                    Rectangle()
                        .fill(step < current ? Color(.purple, 500) : Color(.neutral, 200))
                        .frame(height: 2)
                }
            }
        }
    }
}

struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.body12(.semiBold))
            .foregroundColor(Color(.neutral, 400))
    }
}

struct FlexibleChips: View {
    let options: [String]
    @Binding var selected: Set<String>
    let multiSelect: Bool
    let selectedColor: Color

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    if multiSelect {
                        if selected.contains(option) {
                            selected.remove(option)
                        } else {
                            selected.insert(option)
                        }
                    } else {
                        selected = [option]
                    }
                } label: {
                    Text(option)
                        .font(.body14())
                        .foregroundColor(selected.contains(option) ? .white : Color(.neutral, 700))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selected.contains(option) ? selectedColor : Color(.neutral, 100))
                        .cornerRadius(20)
                }
            }
        }
    }
}
