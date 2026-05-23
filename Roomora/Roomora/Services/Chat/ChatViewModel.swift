import SwiftUI
import ClerkKit

@Observable
@MainActor
class ChatViewModel {
    var messages: [ChatMessage] = []
    var isLoading = false
    var isSending = false
    var errorMessage: String?
    var conversationId: String?
    var draftMessage = ""
    var myOptimisticIds: Set<String> = []

    private let matchId: String
    private let currentUserId: String
    private var pollingTask: Task<Void, Never>?

    init(matchId: String, currentUserId: String) {
        self.matchId = matchId
        self.currentUserId = currentUserId
    }

    func start(clerk: Clerk) async {
        isLoading = true
        do {
            let conversation = try await APIClient.shared.findOrCreateConversation(
                clerk: clerk,
                matchId: matchId
            )
            conversationId = conversation.id
            let initial = try await APIClient.shared.fetchMessages(
                clerk: clerk,
                conversationId: conversation.id
            )
            messages = initial
            try? await APIClient.shared.markMessagesRead(clerk: clerk, conversationId: conversation.id)
        } catch {
            errorMessage = "Couldn't load messages."
        }
        isLoading = false
        startPolling(clerk: clerk)
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func send(clerk: Clerk) async {
        let body = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty, let conversationId else { return }

        // Optimistic insert
        let optimistic = ChatMessage(
            id: "local-\(UUID().uuidString)",
            body: body,
            senderId: currentUserId,
            readAt: nil,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        messages.append(optimistic)
        myOptimisticIds.insert(optimistic.id)
        draftMessage = ""
        isSending = true

        do {
            let sent = try await APIClient.shared.sendMessage(
                clerk: clerk,
                conversationId: conversationId,
                body: body
            )
            // Replace optimistic with real message
            if let idx = messages.firstIndex(where: { $0.id == optimistic.id }) {
                messages[idx] = sent
            }
            myOptimisticIds.remove(optimistic.id)
        } catch {
            messages.removeAll { $0.id == optimistic.id }
            myOptimisticIds.remove(optimistic.id)
            draftMessage = body
            errorMessage = "Failed to send. Tap send to retry."
        }
        isSending = false
    }

    private func startPolling(clerk: Clerk) {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled, let conversationId else { continue }
                do {
                    let lastId = messages.last?.id
                    let fresh = try await APIClient.shared.fetchMessages(
                        clerk: clerk,
                        conversationId: conversationId,
                        after: lastId
                    )
                    if !fresh.isEmpty {
                        messages.append(contentsOf: fresh)
                        try? await APIClient.shared.markMessagesRead(
                            clerk: clerk,
                            conversationId: conversationId
                        )
                    }
                } catch { }
            }
        }
    }
}
