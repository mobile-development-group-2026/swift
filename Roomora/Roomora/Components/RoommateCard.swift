import SwiftUI

struct RoommateCard: View {
    let roommate: RoommateStudent

    private var accentColor: Color {
        switch roommate.sleepSchedule {
        case 0: return Color(.yellow, 500)   // early bird
        case 1: return Color(.purple, 500)   // night owl
        default: return Color(.green, 500)   // flexible
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // ── Left accent bar ──────────────────────────────────────
            RoundedRectangle(cornerRadius: 3)
                .fill(accentColor)
                .frame(width: 4)
                .padding(.vertical, AppSpacing.md)

            // ── Card content ─────────────────────────────────────────
            VStack(alignment: .leading, spacing: AppSpacing.sm) {

                // Header: avatar + name block
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

                    // Move-in badge
                    if let month = roommate.moveInMonth {
                        VStack(spacing: 2) {
                            Text("Move in")
                                .font(.body10())
                                .foregroundStyle(Color(.neutral, 400))
                            Text(month)
                                .font(.body12(.bold))
                                .foregroundStyle(Color(.purple, 600))
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.purple, 100))
                        )
                    }
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

                // Tags
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

                // Footer: budget + view profile hint
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
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }

    // MARK: - Avatar

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(.purple, 300), Color(.purple, 600)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
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
        return chips
    }
}
