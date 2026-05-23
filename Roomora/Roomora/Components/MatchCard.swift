import SwiftUI
import ClerkKit

struct MatchCard: View {
    let match: RoommateMatch
    
    @State private var showChat = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(.purple, 300), Color(.purple, 600)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 56, height: 56)

                if let urlString = match.user.avatarUrl, let url = URL(string: urlString) {
                    CachedAsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Text(match.user.initials)
                            .font(.h3(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                } else {
                    Text(match.user.initials)
                        .font(.h3(.bold))
                        .foregroundStyle(.white)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: AppSpacing.xs) {
                    Text("🎉")
                        .font(.system(size: 14))
                    Text("You matched!")
                        .font(.body12(.semiBold))
                        .foregroundStyle(Color(.purple, 500))
                }

                Text(match.user.fullName)
                    .font(.body16(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))

                if let major = match.user.major, let uni = match.user.university {
                    Text("\(major) · \(uni)")
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                        .lineLimit(1)
                } else if let major = match.user.major {
                    Text(major)
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                }

                Text("Matched \(match.formattedDate)")
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 400))
            }

            Spacer()

            // Message button
            Button {
                showChat = true
            } label: {
                Image(systemName: "message.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color(.purple, 500)))
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .sheet(isPresented: $showChat) {
            ChatView(match: match)
                .environment(Clerk.shared)
        }
    }
}
