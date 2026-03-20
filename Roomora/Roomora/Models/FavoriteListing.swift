//
//  FavoriteListing.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation

struct FavoriteListing: Codable, Identifiable, Hashable {
    let id: String
    let listingId: String
    let title: String
    let address: String
    let city: String
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case id
        case listingId = "listing_id"
        case title
        case address
        case city
        case latitude
        case longitude
    }
}
