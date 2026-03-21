import SwiftUI

struct RoommatePreferencesView: View {
    @Bindable var vm: RoommatePreferencesViewModel
    let role: String

    private var isStudent: Bool { role == "student" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    if isStudent {
                        Text("Your ideal")
                            .font(.h1(.bold))
                            .foregroundStyle(Color(.neutral, 900))
                        Text("roommate")
                            .font(.h1(.bold))
                            .foregroundStyle(Color(.purple, 500))
                        Text("Help us find someone you'll actually want to live with.")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 600))
                            .padding(.top, AppSpacing.xxs)
                    } else {
                        Text("Landlord")
                            .font(.h1(.bold))
                            .foregroundStyle(Color(.neutral, 900))
                        Text("preferences")
                            .font(.h1(.bold))
                            .foregroundStyle(Color(.purple, 500))
                        Text("Set your listing defaults and tenant preferences.")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 600))
                            .padding(.top, AppSpacing.xxs)
                    }
                }

                if isStudent {
                    studentPreferences
                } else {
                    landlordPreferences
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private var studentPreferences: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            // spots available
            PreferenceSection(icon: "person.2.fill", title: "SPOTS AVAILABLE") {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Roommates needed")
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 600))
                    HStack(spacing: AppSpacing.md) {
                        ForEach(1...4, id: \.self) { n in
                            circleChip("\(n)", selected: vm.spotsAvailable == n) {
                                vm.spotsAvailable = n
                            }
                        }
                    }
                    Text("How many spots do you have?")
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                }
            }

            // move-in month
            PreferenceSection(icon: "calendar.circle.fill", title: "MOVE-IN MONTH") {
                let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(months, id: \.self) { month in
                        selectableChip(month, selected: vm.moveInMonth == month, minWidth: 52) {
                            vm.moveInMonth = vm.moveInMonth == month ? nil : month
                        }
                    }
                }
            }

            // gender preference
            PreferenceSection(icon: "person.crop.circle.fill", title: "GENDER PREFERENCE") {
                let options: [(label: String, value: Int)] = [
                    ("No preference", 0), ("Same as me", 1), ("Women only", 2), ("Men only", 3)
                ]
                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(options, id: \.value) { opt in
                        selectableChip(opt.label, selected: vm.genderPreference == opt.value) {
                            vm.genderPreference = vm.genderPreference == opt.value ? nil : opt.value
                        }
                    }
                }
            }

            // sleep schedule
            PreferenceSection(icon: "moon.stars.fill", title: "SLEEP SCHEDULE") {
                let options: [(emoji: String, label: String, sub: String, value: Int)] = [
                    ("🌅", "Early bird", "Up by 7am", 0),
                    ("🌙", "Night owl", "Up past midnight", 1),
                    ("🎲", "No preference", "Either works", 2),
                ]
                HStack(spacing: AppSpacing.sm) {
                    ForEach(options, id: \.value) { opt in
                        lifestyleCard(
                            emoji: opt.emoji,
                            title: opt.label,
                            subtitle: opt.sub,
                            selected: vm.sleepSchedule == opt.value
                        ) {
                            vm.sleepSchedule = vm.sleepSchedule == opt.value ? nil : opt.value
                        }
                    }
                }
            }

            // cleanliness
            PreferenceSection(icon: "sparkles", title: "CLEANLINESS") {
                let options: [(emoji: String, label: String, sub: String, value: Int)] = [
                    ("✨", "Very tidy", "Always clean", 0),
                    ("🧹", "Moderate", "Clean enough", 1),
                    ("😌", "Relaxed", "Lived-in feel", 2),
                ]
                HStack(spacing: AppSpacing.sm) {
                    ForEach(options, id: \.value) { opt in
                        lifestyleCard(
                            emoji: opt.emoji,
                            title: opt.label,
                            subtitle: opt.sub,
                            selected: vm.cleanliness == opt.value
                        ) {
                            vm.cleanliness = vm.cleanliness == opt.value ? nil : opt.value
                        }
                    }
                }
            }

            // lifestyle
            PreferenceSection(icon: "heart.fill", title: "LIFESTYLE") {
                let options: [(emoji: String, label: String, sub: String)] = [
                    ("🚭", "Non-smoker", "No smoking indoors"),
                    ("🐾", "Pet-friendly", "Fine with animals"),
                    ("💃", "No parties", "Chill home please"),
                    ("📚", "Study buddy", "Respect quiet hours"),
                    ("🍳", "Cooks often", "Shared kitchen use"),
                    ("🫂", "Limited guests", "Rarely brings people"),
                ]
                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(options, id: \.label) { opt in
                        selectableChip(
                            "\(opt.emoji) \(opt.label)",
                            selected: vm.selectedLifestyle.contains(opt.label)
                        ) {
                            vm.toggleLifestyle(opt.label)
                        }
                    }
                }
            }

            // requirements
            PreferenceSection(icon: "checkmark.seal.fill", title: "REQUIREMENTS") {
                let options = ["✅ Verified students", "🎓 Same university", "📅 Flexible move-in"]
                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(options, id: \.self) { option in
                        selectableChip(
                            option,
                            selected: vm.selectedRequirements.contains(option)
                        ) {
                            vm.toggleRequirement(option)
                        }
                    }
                }
            }
        }
    }

    private var landlordPreferences: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            PreferenceSection(icon: "dollarsign.circle.fill", title: "PRICE RANGE") {
                FlowLayout(spacing: AppSpacing.xs) {
                    staticChip("< $500")
                    staticChip("$500–$1000")
                    staticChip("$1000–$2000")
                    staticChip("$2000+")
                }
            }

            PreferenceSection(icon: "clock.fill", title: "LEASE LENGTH") {
                FlowLayout(spacing: AppSpacing.xs) {
                    staticChip("Monthly")
                    staticChip("Semester")
                    staticChip("6 months")
                    staticChip("12 months")
                }
            }

            PreferenceSection(icon: "person.2", title: "TENANT PREFERENCES") {
                FlowLayout(spacing: AppSpacing.xs) {
                    staticChip("Students only")
                    staticChip("Verified ID required")
                    staticChip("No pets")
                    staticChip("No smoking")
                }
            }
        }
    }

    private func selectableChip(_ label: String, selected: Bool, minWidth: CGFloat? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.body14(.medium))
                .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                .frame(minWidth: minWidth)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selected ? Color(.purple, 100) : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func circleChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.body14(.semiBold))
                .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                .frame(width: 40, height: 40)
                .background(
                    Circle().fill(selected ? Color(.purple, 100) : .clear)
                )
                .overlay(
                    Circle().stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func lifestyleCard(emoji: String, title: String, subtitle: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(title)
                    .font(.body14(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                Text(subtitle)
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 600))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? Color(.purple, 100) : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func staticChip(_ label: String) -> some View {
        Text(label)
            .font(.body14(.medium))
            .foregroundStyle(Color(.neutral, 700))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.neutral, 500), lineWidth: 1)
            )
    }
}
