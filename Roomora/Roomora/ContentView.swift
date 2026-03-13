import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
  @Environment(Clerk.self) private var clerk
  @State private var showSignUp = false
  @State private var showSignIn = false

  var body: some View {
    Group {
      if clerk.user != nil {
        HomeView()
      } else {
        LandingView(showSignUp: $showSignUp, showSignIn: $showSignIn)
      }
    }
    .prefetchClerkImages()
    .sheet(isPresented: $showSignUp) {
      SignUpView()
        .environment(Clerk.shared)
    }
    .sheet(isPresented: $showSignIn) {
      SignInView()
        .environment(Clerk.shared)
    }
  }
}

struct LandingView: View {
    @Binding var showSignUp: Bool
    @Binding var showSignIn: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(.purple, 900), Color(.purple, 800), Color(.purple, 900)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Radial glow behind icon
            Circle()
                .fill(Color(.purple, 600).opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -180)

            // Second glow in the middle
            Circle()
                .fill(Color(.purple, 500).opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -40)

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                // App icon
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.purple, 600))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color(.purple, 500).opacity(0.5), radius: 20)

                // Brand
                VStack(spacing: AppSpacing.xs) {
                    Text("roomora")
                        .font(.h2(.bold))
                        .foregroundStyle(.white)

                    Text("Your home search, simplified")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 500))
                }

                Spacer()

                // Headline
                VStack(spacing: AppSpacing.xs) {
                    Text("Housing & roommates")
                        .font(.h1(.bold))
                        .foregroundStyle(.white)

                    Text("made for students")
                        .font(.h1())
                        .foregroundStyle(Color(.purple, 400))
                }
                .multilineTextAlignment(.center)

                // Subtitle
                Text("Verified listings, compatible roommates,\nand zero stress.")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 500))
                    .multilineTextAlignment(.center)

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
                        showSignUp = true
                    }
                    AppButton(title: "I already have an account", variant: .secondary) {
                        showSignIn = true
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

struct HomeView: View {
  var body: some View {
    VStack {
      UserButton()
      Text("Welcome to Roomora!")
        .font(.title2)
    }
  }
}

#Preview {
    LandingView(showSignUp: .constant(false), showSignIn: .constant(false))
}
