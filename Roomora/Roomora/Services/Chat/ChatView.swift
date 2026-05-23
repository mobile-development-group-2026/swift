import SwiftUI
import ClerkKit

struct ChatView: View {
    let match: RoommateMatch
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var vm: ChatViewModel

    init(match: RoommateMatch) {
        self.match = match
        _vm = State(initialValue: ChatViewModel(
            matchId: match.id,
            currentUserId: ""
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            Divider()

            if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.xs) {
                            ForEach(vm.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromMe: message.senderId == session.profile?.id || vm.myOptimisticIds.contains(message.id)
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.md)
                    }
                    .onChange(of: vm.messages.count) {
                        if let last = vm.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onAppear {
                        if let last = vm.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if let error = vm.errorMessage {
                Text(error)
                    .font(.body12())
                    .foregroundStyle(.red)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xs)
            }

            inputBar
        }
        .background(Color(.neutral, 100))
        .task { await vm.start(clerk: clerk) }
        .onDisappear { vm.stop() }
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack(spacing: AppSpacing.md) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(.neutral, 700))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(.neutral, 100)))
            }
            .buttonStyle(.plain)

            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(.purple, 300), Color(.purple, 600)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)

                if let urlString = match.user.avatarUrl, let url = URL(string: urlString) {
                    CachedAsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Text(match.user.initials)
                            .font(.body14(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Text(match.user.initials)
                        .font(.body14(.bold))
                        .foregroundStyle(.white)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(match.user.fullName)
                    .font(.body16(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                Text("Matched \(match.formattedDate)")
                    .font(.body12())
                    .foregroundStyle(Color(.neutral, 500))
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(.white)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: AppSpacing.sm) {
            TextField("Message...", text: $vm.draftMessage, axis: .vertical)
                .font(.body16())
                .foregroundStyle(Color(.neutral, 900))
                .lineLimit(1...4)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(Color(.neutral, 100))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.purple, 500), lineWidth: 2)
                )

            Button {
                Task { await vm.send(clerk: clerk) }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(.purple, 700))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(
                        vm.draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(.purple, 300)
                            : .white
                    ))
            }
            .buttonStyle(.plain)
            .disabled(vm.draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color(.purple, 500))
        .overlay(alignment: .top) { Divider() }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    let isFromMe: Bool

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 2) {
                Text(message.body)
                    .font(.body16())
                    .foregroundStyle(isFromMe ? .white : Color(.neutral, 900))
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isFromMe ? Color(.purple, 400) : Color(.yellow, 400))
                    )

                Text(message.formattedTime)
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 400))
                    .padding(.horizontal, AppSpacing.xs)
            }

            if !isFromMe { Spacer(minLength: 60) }
        }
    }
}
