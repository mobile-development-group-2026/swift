//
//  SearchFilters.swift
//  Roomora
//
//  Created by Jeronimo Cifci on 20/03/26.
//

import Foundation

struct SearchFilters: Equatable {
    var city: String = ""
    var minPrice: Double = 0
    var maxPrice: Double = 5000
    var bedrooms: Int? = nil
    
    var isEmpty: Bool {
        city.isEmpty && minPrice == 0 && maxPrice == 5000 && bedrooms == nil
    }
    
    func toQueryParams() -> [String: String] {
        var params: [String: String] = ["status": "active"]
        if !city.isEmpty { params["city"] = city }
        if minPrice > 0 { params["min_price"] = String(minPrice) }
        if maxPrice < 5000 { params["max_price"] = String(maxPrice) }
        if let bedrooms { params["bedrooms"] = String(bedrooms) }
        return params
    }
    
    func relaxationSuggestions() -> [RelaxationSuggestion] {
        var suggestions: [RelaxationSuggestion] = []
        
        if maxPrice < 5000 {
            suggestions.append(RelaxationSuggestion(
                title: "Increase budget",
                description: "Expand max price to $\(Int(maxPrice + 500))",
                action: .increaseMaxPrice(by: 500)
            ))
        }
        if let beds = bedrooms, beds > 1 {
            suggestions.append(RelaxationSuggestion(
                title: "Fewer bedrooms",
                description: "Try \(beds - 1) bedroom\(beds - 1 == 1 ? "" : "s")",
                action: .decreaseBedrooms
            ))
        }
        if !city.isEmpty {
            suggestions.append(RelaxationSuggestion(
                title: "Expand location",
                description: "Remove city filter",
                action: .removeCity
            ))
        }
        return suggestions
    }
}

struct RelaxationSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: RelaxationAction
}

enum RelaxationAction {
    case increaseMaxPrice(by: Double)
    case decreaseBedrooms
    case removeCity
}
