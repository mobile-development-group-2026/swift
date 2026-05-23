//
//  ChatModels.swift
//  Roomora
//
//  Created by Andy on 23/05/26.
//

import Foundation

struct ConversationResponse: Identifiable, Codable {
    let id: String
    let matchId: String
    let otherUser: ChatUser
    let lastMessage: ChatMessage?
    let updatedAt: String

    struct ChatUser: Codable {
        let id: String
        let firstName: String
        let lastName: String
        let avatarUrl: String?
        let verified: Bool

        var fullName: String { "\(firstName) \(lastName)" }
        var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))" }
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let body: String
    let senderId: String
    let readAt: String?
    let createdAt: String

    var formattedTime: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: createdAt) {
            let df = DateFormatter()
            df.dateFormat = "h:mm a"
            return df.string(from: d)
        }
        return ""
    }
}
