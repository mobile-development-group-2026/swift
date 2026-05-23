import Foundation
import ClerkKit

extension APIClient {

    // POST /api/v1/conversations
    func findOrCreateConversation(clerk: Clerk, matchId: String) async throws -> ConversationResponse {
        let data = try await post(path: "/conversations", body: ["match_id": matchId], clerk: clerk)
        return try decodeData(ConversationResponse.self, from: data)
    }

    // GET /api/v1/conversations/:id/messages
    func fetchMessages(clerk: Clerk, conversationId: String, after: String? = nil) async throws -> [ChatMessage] {
        var path = "/conversations/\(conversationId)/messages"
        if let after { path += "?after=\(after)" }
        let data = try await get(path: path, clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([ChatMessage].self, from: innerData)
    }

    // POST /api/v1/conversations/:id/messages
    func sendMessage(clerk: Clerk, conversationId: String, body: String) async throws -> ChatMessage {
        let data = try await post(
            path: "/conversations/\(conversationId)/messages",
            body: ["body": body],
            clerk: clerk
        )
        return try decodeData(ChatMessage.self, from: data)
    }

    // PATCH /api/v1/conversations/:id/messages/read
    func markMessagesRead(clerk: Clerk, conversationId: String) async throws {
        _ = try await patch(
            path: "/conversations/\(conversationId)/messages/read",
            body: [:],
            clerk: clerk
        )
    }
}
