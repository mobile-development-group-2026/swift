//
//  APIClient+Likes.swift
//  Roomora
//
//  Created by Andy on 22/05/26.
//

import Foundation
import ClerkKit

extension APIClient {

    // POST /api/v1/likes
    struct LikeResponse: Codable {
        let liked: Bool
        let matched: Bool
        let matchId: String?
    }

    func likeUser(clerk: Clerk, likedId: String) async throws -> LikeResponse {
        let data = try await post(
            path: "/likes",
            body: ["liked_id": likedId],
            clerk: clerk
        )
        return try decodeData(LikeResponse.self, from: data)
    }

    // GET /api/v1/likes/sent
    func fetchLikedIds(clerk: Clerk) async throws -> [String] {
        let data = try await get(path: "/likes/sent", clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([String].self, from: innerData)
    }

    // GET /api/v1/matches
    func fetchMatches(clerk: Clerk) async throws -> [RoommateMatch] {
        let data = try await get(path: "/matches", clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([RoommateMatch].self, from: innerData)
    }
}
