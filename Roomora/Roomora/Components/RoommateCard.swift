import SwiftUI

struct RoommateCard: View {
    let roommate: RoommateStudent
    var onLike: () async -> Bool = { false }

    @State private var isLiking = false
    @State private var showMatch = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            // Header: avatar + name block + heart
            HStack(alignment: .center, spacing: AppSpacing.md) {
                avatar

                VStack(alignment: .leading, spacing: 4) {
                    Text(roommate.fullName)
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))

                    HStack(spacing: 6) {
                        if let major = roommate.major {
                            Text(major)
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.purple, 500))
                        }
                        if let age = roommate.age {
                            Text("·")
                                .foregroundStyle(Color(.neutral, 400))
                            Text("\(age) y/o")
                                .font(.body14())
                                .foregroundStyle(Color(.neutral, 600))
                        }
                    }

                    if let uni = roommate.university {
                        HStack(spacing: 4) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(.neutral, 400))
                            Text(uni)
                                .font(.body12())
                                .foregroundStyle(Color(.neutral, 600))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Heart button
                Button {
                    guard !isLiking else { return }
                    isLiking = true
                    Task {
                        let matched = await onLike()
                        if matched { showMatch = true }
                        isLiking = false
                    }
                } label: {
                    Image(systemName: isLiking ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundStyle(isLiking ? Color(.red, 500) : Color(.neutral, 400))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color(.neutral, 100)))
                }
                .buttonStyle(.plain)
                .disabled(isLiking)
            }

            // Bio preview
            if let bio = roommate.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body12())
                    .foregroundStyle(Color(.neutral, 600))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Lifestyle chips
            let chips = lifestyleChips
            if !chips.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    ForEach(chips, id: \.self) { chip in
                        Text(chip)
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 700))
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color(.neutral, 100)))
                    }
                    Spacer()
                }
            }

            // Lifestyle tags
            if !roommate.lifestyleTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(roommate.lifestyleTags, id: \.self) { tag in
                            Text(tag)
                                .font(.body12())
                                .foregroundStyle(Color(.purple, 700))
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Color(.purple, 100)))
                        }
                    }
                }
            }

            // Footer
            HStack {
                if let budget = roommate.maxBudget, budget > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(.green, 500))
                        Text("Up to \(roommate.formattedBudget)/mo")
                            .font(.body12(.semiBold))
                            .foregroundStyle(Color(.neutral, 600))
                    }
                }
                Spacer()
                HStack(spacing: 3) {
                    Text("View profile")
                        .font(.body12(.semiBold))
                        .foregroundStyle(Color(.purple, 500))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(.purple, 400))
                }
            }
        }
        .padding(AppSpacing.md)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
        .alert("It's a match! 🎉", isPresented: $showMatch) {
            Button("Awesome!") { }
        } message: {
            Text("You and \(roommate.firstName) liked each other. Check Activity to message them.")
        }
    }

    // MARK: - Avatar

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(.purple, 300), Color(.purple, 600)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)

            if let urlString = roommate.avatarUrl, let url = URL(string: urlString) {
                CachedAsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    initialsView
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                initialsView
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if roommate.verified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(.purple, 500))
                    .background(Circle().fill(.white).frame(width: 13, height: 13))
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var initialsView: some View {
        Text(roommate.initials)
            .font(.h3(.bold))
            .foregroundStyle(.white)
    }

    private var lifestyleChips: [String] {
        var chips: [String] = []
        if roommate.sleepSchedule != nil { chips.append(roommate.sleepScheduleLabel) }
        if roommate.cleanlinessLevel != nil { chips.append(roommate.cleanlinessLabel) }
        if let month = roommate.moveInMonth { chips.append("📅 \(month)") }
        return chips
    }
}
