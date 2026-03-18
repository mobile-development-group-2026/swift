import SwiftUI
/// The View protocol requires body.
struct LandingView: View {
    // pulls the AppRouter instance from the environment. Same as useContext in React
    // the parent (ContentView) injected it with .environment(router)
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            // background gradient
            LinearGradient(
                colors: [Color(.purple, 900), Color(.purple, 800), Color(.purple, 900)],
                startPoint: .top,
                endPoint: .bottom
            )
            // this makes it 100% vh
            .ignoresSafeArea()

            // radial glow
            Circle()
                .fill(Color(.purple, 600).opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -180)

            // radial glow
            Circle()
                .fill(Color(.purple, 500).opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -40)

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                // app icon
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.purple, 600))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color(.purple, 500).opacity(0.5), radius: 24)

                // brand text
                VStack(spacing: AppSpacing.xs) {
                    Text("roomora")
                        .font(.h2(.bold))
                        .foregroundStyle(.white)

                    Text("Your home search, simplified")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 500))
                }

                Spacer()

                // headline
                VStack(spacing: AppSpacing.xs) {
                    Text("Housing &\nroommates")
                        .font(.h1(.bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: true, vertical: true)

                    Text("made for students")
                        .font(.h1())
                        .foregroundStyle(Color(.purple, 400))
                        .fixedSize(horizontal: true, vertical: true)
                }
                .multilineTextAlignment(.center)

                // Subtitle
                Text("Verified listings, compatible roommates,\nand zero stress.")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 500))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: true)

                // Pills
                VStack(spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.sm) {
                        PillBadge(label: "Verified landlords", dotColor: Color(.green, 500))
                        PillBadge(label: "Roommate matching", dotColor: Color(.yellow, 500))
                    }
                    PillBadge(label: "Map search", dotColor: Color(.purple, 400))
                }

                Spacer()

                // Buttons
                VStack(spacing: AppSpacing.sm) {
                    AppButton(title: "Get Started — It's Free", variant: .primary) {
                        router.navigate(to: .signUp)
                    }
                    AppButton(title: "I already have an account", variant: .secondary) {
                        router.present(.signIn, style: .sheet)
                    }

                    Text("By continuing you agree to our Terms & Privacy Policy")
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 600))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xxl)
        }
    }
}

#Preview {
    LandingView()
        .environment(AppRouter())
}
