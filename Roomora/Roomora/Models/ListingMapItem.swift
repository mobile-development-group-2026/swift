//
//  ListingMapItem.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation
import CoreLocation

struct ListingMapItem: Identifiable {
    let id: String
    let title: String
    let address: String
    let city: String
    let rent: Double
    let coordinate: CLLocationCoordinate2D
    let listing: ListingResponse
}
