//
//  RoommateFilter.swift
//  Roomora
//
//  Created by Andy on 23/05/26.
//


import SwiftUI

// MARK: - Roommate Filter

struct RoommateFilter {
    var sleepSchedule: Int? = nil       // 0=early bird, 1=night owl, 2=flexible
    var cleanlinessLevel: Int? = nil    // 0=very tidy, 1=moderate, 2=relaxed
    var moveInMonth: String? = nil
    var university: String? = nil

    var isActive: Bool {
        sleepSchedule != nil || cleanlinessLevel != nil ||
        moveInMonth != nil || university != nil
    }

    func apply(to roommates: [RoommateStudent]) -> [RoommateStudent] {
        roommates.filter { r in
            if let s = sleepSchedule, r.sleepSchedule != s { return false }
            if let c = cleanlinessLevel {
                // map filter value (0,1,2) to DB range (1-2, 3, 4-5)
                switch c {
                case 0: if let lvl = r.cleanlinessLevel, !(1...2).contains(lvl) { return false }
                case 1: if r.cleanlinessLevel != 3 { return false }
                case 2: if let lvl = r.cleanlinessLevel, !(4...5).contains(lvl) { return false }
                default: break
                }
            }
            if let m = moveInMonth, r.moveInMonth != m { return false }
            if let u = university, r.university != u { return false }
            return true
        }
    }
}

// MARK: - Listing Filter

struct ListingFilter {
    var maxPrice: Int? = nil
    var bedrooms: Int? = nil
    var propertyType: String? = nil
    var petsAllowed: Bool? = nil

    var isActive: Bool {
        maxPrice != nil || bedrooms != nil || propertyType != nil || petsAllowed != nil
    }

    func apply(to listings: [ListingResponse]) -> [ListingResponse] {
        listings.filter { l in
            if let p = maxPrice, let rent = Double(l.rent), Int(rent) > p { return false }
            if let b = bedrooms, l.bedrooms != b { return false }
            if let pt = propertyType, l.propertyType?.lowercased() != pt.lowercased() { return false }
            return true
        }
    }
}
