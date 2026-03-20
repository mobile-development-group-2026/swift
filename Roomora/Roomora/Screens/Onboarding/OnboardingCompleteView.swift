import SwiftUI

struct OnboardingCompleteView: View {
    let firstName: String
    let role: String
    let onContinue: () -> Void

    @State private var showContent = false

    private var isStudent: Bool { role == "student" }

    private var roleLabel: String {
        isStudent ? "student" : "landlord"
    }

    private var perks: [(icon: String, iconBg: Color, iconFg: Color, title: String, subtitle: String)] {
        if isStudent {
            return [
                ("checkmark.shield.fill", Color(.purple, 100), Color(.purple, 500),
                 "Verified badge on your profile",
                 "Other users can trust you're a real student"),
                ("house.fill", Color(.yellow, 100), Color(.yellow, 500),
                 "Access to verified-only listings",
                 "Landlords who only rent to students like you"),
                ("person.2.fill", Color(.purple, 100), Color(.purple, 500),
                 "Roommate compatibility matching",
                 "Find people who actually match your lifestyle"),
            ]
        } else {
            return [
                ("checkmark.shield.fill", Color(.purple, 100), Color(.purple, 500),
                 "Verified landlord badge",
                 "Students can trust your listings are real"),
                ("list.bullet.rectangle.fill", Color(.yellow, 100), Color(.yellow, 500),
                 "Post unlimited listings",
                 "Reach verified students looking for housing"),
                ("person.2.fill", Color(.purple, 100), Color(.purple, 500),
                 "Tenant screening tools",
                 "Find reliable tenants that match your criteria"),
            ]
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // checkmark badge
                ZStack {
                    // outer glow rings
                    Circle()
                        .fill(Color(.green, 100).opacity(0.3))
                        .frame(width: 160, height: 160)
                    Circle()
                        .fill(Color(.green, 100).opacity(0.5))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(Color(.green, 200))
                        .frame(width: 88, height: 88)
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)

                    // role icon badge
                    Image(systemName: isStudent ? "graduationcap.fill" : "house.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(.purple, 500))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(x: 36, y: 36)
                }

                // title
                VStack(spacing: AppSpacing.xs) {
                    Text("You're verified,")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("\(firstName) 🎉")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                    Text("Your \(roleLabel) status is confirmed.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 600))
                        .padding(.top, AppSpacing.xxs)
                    Text("Welcome to Roomora.")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 900))
                }

                // unlocked perks card
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("UNLOCKED FOR YOU")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))

                    ForEach(perks, id: \.title) { perk in
                        HStack(spacing: AppSpacing.md) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(perk.iconBg)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: perk.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(perk.iconFg)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(perk.title)
                                    .font(.body14(.semiBold))
                                    .foregroundStyle(Color(.neutral, 900))
                                Text(perk.subtitle)
                                    .font(.body12())
                                    .foregroundStyle(Color(.neutral, 600))
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(.green, 400))
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.neutral, 200), lineWidth: 1)
                )
                .padding(.horizontal, AppSpacing.lg)

                Spacer()

                // CTA
                AppButton(
                    title: isStudent ? "Find my roommate  →" : "Post a listing  →",
                    variant: .primary,
                    action: onContinue
                )
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            // confetti overlay
            ConfettiView()
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showContent = true
            }
        }
    }
}
