import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session
    @State private var router = AppRouter()

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .signUp:
            SignUpView()
                .environment(Clerk.shared)
        case .designSystem:
            DesignSystemTestView()
        case .createListing:
            CreateListingView()
        case .listingPreview(let listing):
            ListingPreviewView(listing: listing)
        case .landlordProfile:
            LandlordProfileView()
        }
    }

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
                                destination(for: route)
                            }
                    }
                }
            } else {
                NavigationStack(path: $router.path) {
                    LandingView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destination(for: route)
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
            if newId == nil {
                router.popToRoot()
                router.dismissModal()
                session.clear()
            }
        }
        .task {
            // only for app relaunch with existing session
                await session.load(clerk: clerk)
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
