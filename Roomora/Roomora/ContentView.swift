import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
    @Environment(Clerk.self) private var clerk
    @State private var router = AppRouter()

    var body: some View {
        Group {
            if clerk.user != nil {
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
                            case .createListing:
                                CreateListingView()
                            case .listingPreview(let listing):
                                ListingPreviewView(listing: listing)
                            case .landlordProfile:
                                LandlordProfileView(landlordName: clerk.user?.firstName ?? "Landlord", listings: [])
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
                            case .createListing:
                                CreateListingView()
                            case .listingPreview(let listing):
                                ListingPreviewView(listing: listing)
                            case .landlordProfile:
                                LandlordProfileView(landlordName: clerk.user?.firstName ?? "Landlord", listings: [])
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
                .presentationDetents([.fraction(0.65)])
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
        .onChange(of: clerk.user != nil) {
            router.popToRoot()
            router.dismissModal()
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
