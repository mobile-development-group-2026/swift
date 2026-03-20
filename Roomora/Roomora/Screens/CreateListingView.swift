//
//  CreateListingView.swift
//  
//
//  Created by Jeronimo Cifci on 18/03/26.
//

import SwiftUI

struct CreateListingView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var propertyType = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var rent = ""
    @State private var securityDeposit = ""
    @State private var utilitiesCost = ""
    @State private var utilitiesIncluded = false
    @State private var leaseTermMonths = ""
    @State private var availableDate = Date()
    @State private var bedrooms = 1
    @State private var bathrooms = 1
    @State private var petsAllowed = false
    @State private var partiesAllowed = false
    @State private var smokingAllowed = false
    @State private var navigateToPreview = false

    var body: some View {
        
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    Text("Create Listing")
                        .font(.h1())
                        .padding(.horizontal)

                    // Basic Info
                    Group {
                        SectionHeader(title: "Basic Info")
                        SimpleTextField(label: "Listing Title", text: $title)
                        SimpleTextField(label: "Description", text: $description)
                        SimpleTextField(label: "Property Type (e.g. apartment)", text: $propertyType)
                    }

                    // Location
                    Group {
                        SectionHeader(title: "Location")
                        SimpleTextField(label: "Address", text: $address)
                        SimpleTextField(label: "City", text: $city)
                        SimpleTextField(label: "State", text: $state)
                        SimpleTextField(label: "Zip Code", text: $zipCode)
                    }

                    // Financial
                    Group {
                        SectionHeader(title: "Financial Details")
                        SimpleTextField(label: "Monthly Rent ($)", text: $rent, keyboard: .decimalPad)
                        SimpleTextField(label: "Security Deposit ($)", text: $securityDeposit, keyboard: .decimalPad)
                        Toggle("Utilities Included", isOn: $utilitiesIncluded)
                            .padding(.horizontal)
                        if utilitiesIncluded {
                            SimpleTextField(label: "Utilities Cost ($)", text: $utilitiesCost, keyboard: .decimalPad)
                        }
                    }

                    // Lease
                    Group {
                        SectionHeader(title: "Lease Info")
                        SimpleTextField(label: "Lease Length (months)", text: $leaseTermMonths, keyboard: .numberPad)
                        DatePicker("Available Date", selection: $availableDate, displayedComponents: .date)
                            .padding(.horizontal)
                    }

                    // Details
                    Group {
                        SectionHeader(title: "Details")
                        Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 1...10)
                            .padding(.horizontal)
                        Stepper("Bathrooms: \(bathrooms)", value: $bathrooms, in: 1...10)
                            .padding(.horizontal)
                    }

                    // House Rules
                    Group {
                        SectionHeader(title: "House Rules")
                        Toggle("Pets Allowed", isOn: $petsAllowed).padding(.horizontal)
                        Toggle("Parties Allowed", isOn: $partiesAllowed).padding(.horizontal)
                        Toggle("Smoking Allowed", isOn: $smokingAllowed).padding(.horizontal)
                    }

                    AppButton(title: "Preview Listing") {
                        navigateToPreview = true
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                ListingPreviewView(listing: buildListing())
            }
        
    }

    private func buildListing() -> Listing {
        Listing(
            listingType: "property",
            title: title,
            description: description,
            propertyType: propertyType,
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            rent: Double(rent) ?? 0,
            securityDeposit: Double(securityDeposit) ?? 0,
            utilitiesIncluded: utilitiesIncluded,
            utilitiesCost: Double(utilitiesCost) ?? 0,
            availableDate: availableDate,
            leaseTermMonths: Int(leaseTermMonths) ?? 12,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            petsAllowed: petsAllowed,
            partiesAllowed: partiesAllowed,
            smokingAllowed: smokingAllowed
        )
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.h3())
            .padding(.horizontal)
    }
}

struct SimpleTextField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(label, text: $text)
            .keyboardType(keyboard)
            .padding()
            .background(Color(.neutral, 100))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}
