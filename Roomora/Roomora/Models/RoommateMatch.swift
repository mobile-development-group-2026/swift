//
//  RoommateMatch.swift
//  Roomora
//
//  Created by Andy on 22/05/26.
//


import Foundation

// MARK: - Match response from API

struct RoommateMatch: Identifiable, Codable {
    let id: String
    let matchedAt: String
    let user: MatchedUser

    struct MatchedUser: Codable {
        let id: String
        let firstName: String
        let lastName: String
        let avatarUrl: String?
        let verified: Bool
        let university: String?
        let major: String?

        var fullName: String { "\(firstName) \(lastName)" }
        var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))" }
    }

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: matchedAt) {
            let display = DateFormatter()
            display.dateFormat = "MMM d, yyyy"
            return display.string(from: date)
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: matchedAt) {
            let display = DateFormatter()
            display.dateFormat = "MMM d, yyyy"
            return display.string(from: date)
        }
        return String(matchedAt.prefix(10))
    }
}
