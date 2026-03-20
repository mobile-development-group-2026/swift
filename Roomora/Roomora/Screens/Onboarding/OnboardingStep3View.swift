import SwiftUI

struct OnboardingStep3View: View {
    let role: String

    private var isStudent: Bool { role == "student" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(isStudent ? "Student" : "Landlord")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("preferences")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                    Text(isStudent
                         ? "Help us find the right place and roommate for you."
                         : "Set your listing defaults and tenant preferences.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 600))
                        .padding(.top, AppSpacing.xxs)
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
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // budget
            PreferenceSection(icon: "dollarsign.circle", title: "MONTHLY BUDGET") {
                HStack(spacing: AppSpacing.md) {
                    preferenceChip("< $500")
                    preferenceChip("$500–$800")
                    preferenceChip("$800–$1200")
                    preferenceChip("$1200+")
                }
            }

            // move-in
            PreferenceSection(icon: "calendar", title: "MOVE-IN TIMELINE") {
                HStack(spacing: AppSpacing.md) {
                    preferenceChip("ASAP")
                    preferenceChip("1–2 months")
                    preferenceChip("3+ months")
                }
            }

            // lifestyle
            PreferenceSection(icon: "moon.stars", title: "LIVING STYLE") {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    preferenceChip("Early bird")
                    preferenceChip("Night owl")
                    preferenceChip("Quiet & focused")
                    preferenceChip("Social & active")
                }
            }
        }
    }


    private var landlordPreferences: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // price range
            PreferenceSection(icon: "dollarsign.circle", title: "PRICE RANGE") {
                HStack(spacing: AppSpacing.md) {
                    preferenceChip("< $500")
                    preferenceChip("$500–$1000")
                    preferenceChip("$1000–$2000")
                    preferenceChip("$2000+")
                }
            }

            // lease length
            PreferenceSection(icon: "clock", title: "LEASE LENGTH") {
                HStack(spacing: AppSpacing.md) {
                    preferenceChip("Monthly")
                    preferenceChip("Semester")
                    preferenceChip("6 months")
                    preferenceChip("12 months")
                }
            }

            // tenant preferences
            PreferenceSection(icon: "person.2", title: "TENANT PREFERENCES") {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    preferenceChip("Students only")
                    preferenceChip("Verified ID required")
                    preferenceChip("No pets")
                    preferenceChip("No smoking")
                }
            }
        }
    }

    private func preferenceChip(_ label: String) -> some View {
        Text(label)
            .font(.body14(.medium))
            .foregroundStyle(Color(.neutral, 700))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.neutral, 300), lineWidth: 1)
            )
    }
}


private struct PreferenceSection<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.body14())
                    .foregroundStyle(Color(.purple, 500))
                Text(title)
                    .font(.body10(.semiBold))
                    .foregroundStyle(Color(.neutral, 700))
            }

            FlowLayout(spacing: AppSpacing.xs) {
                content
            }
        }
    }
}
