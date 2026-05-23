import SwiftUI

struct RoommateCard: View {
    let roommate: RoommateStudent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top, spacing: AppSpacing.md) {
                avatar

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(roommate.fullName)
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))

                    if let major = roommate.major {
                        HStack(spacing: AppSpacing.xs) {
                            Text(major)
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.purple, 500))
                            if let age = roommate.age {
                                Text("·")
                                    .foregroundStyle(Color(.neutral, 700))
                                Text("\(age) y/o")
                                    .font(.body14())
                                    .foregroundStyle(Color(.neutral, 700))
                            }
                        }
                    }

                    if let uni = roommate.university {
                        HStack(spacing: 4) {
                            Image(systemName: "building.columns")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(.neutral, 700))
                            Text(uni)
                                .font(.body12())
                                .foregroundStyle(Color(.neutral, 700))
                                .lineLimit(1)
                        }
                    }

                    if let budget = roommate.maxBudget, budget > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(.neutral, 700))
                            Text("Up to \(roommate.formattedBudget)/mo")
                                .font(.body12(.semiBold))
                                .foregroundStyle(Color(.neutral, 600))
                        }
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.md)

            let allChips = lifestyleChips + roommate.lifestyleTags
            if !allChips.isEmpty {
                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(allChips, id: \.self) { chip in
                        chipView(chip, isTag: roommate.lifestyleTags.contains(chip))
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        )
        .shadow(color: Color(.purple, 900).opacity(0.06), radius: 12, x: 0, y: 4)
    }

    

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
                .frame(width: 56, height: 56)

            if let urlString = roommate.avatarUrl,
               let url = URL(string: urlString) {
                CachedAsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    initialsView
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            } else {
                initialsView
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if roommate.verified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(Color(.purple, 500))
                    .background(
                        Circle().fill(.white).frame(width: 14, height: 14)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var initialsView: some View {
        Text(roommate.initials)
            .font(.h3(.bold))
            .foregroundStyle(.white)
    }

    private func chipView(_ label: String, isTag: Bool) -> some View {
        Text(label)
            .font(.body12())
            .foregroundStyle(isTag ? Color(.purple, 700) : Color(.neutral, 700))
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isTag ? Color(.purple, 100) : Color(.neutral, 100))
            )
    }

    private var lifestyleChips: [String] {
        var chips: [String] = []
        if roommate.sleepSchedule != nil { chips.append(roommate.sleepScheduleLabel) }
        if roommate.cleanlinessLevel != nil { chips.append(roommate.cleanlinessLabel) }
        if let month = roommate.moveInMonth { chips.append("\(month)") }
        return chips
    }
}
