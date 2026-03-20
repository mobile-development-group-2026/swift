import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session
    @State private var router = AppRouter()

    var body: some View {
        Group {
            if clerk.user != nil {
                if !session.isLoaded {
                    VStack(spacing: AppSpacing.md) {
                        ProgressView()
                            .tint(Color(.purple, 500))
                        Text("Setting up your account...")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                } else if !session.isOnboarded {
                    OnboardingView()
                        .environment(Clerk.shared)
                } else {
                    NavigationStack(path: $router.path) {
                        HomeView()
                            .navigationDestination(for: AppRoute.self) { route in
                                switch route {
                                case .home:
                                    HomeView()
                                case .signUp:
                                    SignUpView()
                                        .environment(Clerk.shared)
                                case .designSystem:
                                    DesignSystemTestView()
                                }
                            }
                    }
                }
            } else {
                NavigationStack(path: $router.path) {
                    LandingView()
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .home:
                                HomeView()
                            case .signUp:
                                SignUpView()
                                    .environment(Clerk.shared)
                            case .designSystem:
                                DesignSystemTestView()
                            }
                        }
                }
            }
        }
        // available to each child in the Group
        .environment(router)
        .prefetchClerkImages()
        .sheet(item: $router.presentedSheet) { modal in
            switch modal {
            case .signIn:
                NavigationStack {
                    SignInView()
                        .navigationBarHidden(true)
                }
                .environment(Clerk.shared)
                .presentationDetents([.fraction(0.65), .large])
                .presentationCornerRadius(24)
                .presentationBackground(.white)
            default:
                EmptyView()
            }
        }
        .overlay {
            if let popup = router.presentedPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { router.dismissModal() }

                popupContent(for: popup)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: clerk.user?.id) { oldId, newId in
            router.popToRoot()
            router.dismissModal()

            if newId == nil {
                session.clear()
            }
        }
        .task {
            // on app launch, load profile if already signed in
            if clerk.user != nil && !session.isLoaded {
                await session.load(clerk: clerk)
            }
        }
    }

    @ViewBuilder
    private func popupContent(for modal: AppModal) -> some View {
        switch modal {
        case .testPopup:
            VStack(spacing: AppSpacing.md) {
                Text("Popup Test")
                    .font(.h3(.bold))
                AppButton(title: "Dismiss", variant: .secondary) {
                    router.dismissModal()
                }
            }
            .padding(AppSpacing.xl)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .padding(.horizontal, AppSpacing.xl)
        default:
            EmptyView()
        }
    }
}

#Preview {
    LandingView()
        .environment(AppRouter())
}
