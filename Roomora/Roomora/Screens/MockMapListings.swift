//
//  MockMapListings.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation

enum MockMapListings {
    static let listings: [Listing] = [
        Listing(
            id: "mock-1",
            listingType: "property",
            title: "Studio near Chapinero",
            description: "Nice studio close to universities.",
            propertyType: "apartment",
            address: "Cra. 13 #54-10",
            city: "Bogotá",
            state: "Cundinamarca",
            zipCode: "110231",
            latitude: nil,
            longitude: nil,
            rent: 1800000,
            securityDeposit: 500000,
            utilitiesIncluded: true,
            utilitiesCost: 0,
            availableDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            leaseTermMonths: 12,
            bedrooms: 1,
            bathrooms: 1,
            petsAllowed: false,
            partiesAllowed: false,
            smokingAllowed: false,
            status: "active"
        ),
        Listing(
            id: "mock-2",
            listingType: "property",
            title: "Shared apartment in Teusaquillo",
            description: "Two-bedroom apartment with good lighting.",
            propertyType: "apartment",
            address: "Cl. 45 #19-32",
            city: "Bogotá",
            state: "Cundinamarca",
            zipCode: "111311",
            latitude: nil,
            longitude: nil,
            rent: 2200000,
            securityDeposit: 700000,
            utilitiesIncluded: false,
            utilitiesCost: 180000,
            availableDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            leaseTermMonths: 6,
            bedrooms: 2,
            bathrooms: 1,
            petsAllowed: true,
            partiesAllowed: false,
            smokingAllowed: false,
            status: "active"
        ),
        Listing(
            id: "mock-3",
            listingType: "property",
            title: "Loft near Parque Nacional",
            description: "Modern loft with great lighting.",
            propertyType: "loft",
            address: "Cra. 5 #39-50",
            city: "Bogotá",
            state: "Cundinamarca",
            zipCode: "110311",
            latitude: nil,
            longitude: nil,
            rent: 2500000,
            securityDeposit: 800000,
            utilitiesIncluded: true,
            utilitiesCost: 0,
            availableDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
            leaseTermMonths: 12,
            bedrooms: 1,
            bathrooms: 1,
            petsAllowed: false,
            partiesAllowed: false,
            smokingAllowed: false,
            status: "active"
        ),
        Listing(
            id: "mock-4",
            listingType: "property",
            title: "Room near Javeriana",
            description: "Private room in shared apartment.",
            propertyType: "room",
            address: "Cl. 41 #7-43",
            city: "Bogotá",
            state: "Cundinamarca",
            zipCode: "110231",
            latitude: nil,
            longitude: nil,
            rent: 1300000,
            securityDeposit: 300000,
            utilitiesIncluded: true,
            utilitiesCost: 0,
            availableDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            leaseTermMonths: 6,
            bedrooms: 1,
            bathrooms: 1,
            petsAllowed: false,
            partiesAllowed: false,
            smokingAllowed: false,
            status: "active"
        )
    ]
}
