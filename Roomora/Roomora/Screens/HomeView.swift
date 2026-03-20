import SwiftUI
import ClerkKitUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(UserSession.self) private var session

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            UserButton()

            if let role = session.role, let name = session.firstName {
                Text("Welcome, \(name)!")
                    .font(.h3(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                Text(role.capitalized)
                    .font(.body14())
                    .foregroundStyle(Color(.purple, 500))

                if role == "landlord" {
                    AppButton(title: "My Listings") {
                        router.navigate(to: .landlordProfile)
                    }
                    AppButton(title: "Create Listing", variant: .secondary) {
                        router.navigate(to: .createListing)
                    }
                } else {
                    AppButton(title: "Find a Place") {
                        router.navigate(to: .propertyList)
                    }
                }
            } else {
                Text("Welcome to Roomora!")
                    .font(.title2)
            }

            AppButton(title: "Test Popup", variant: .secondary) {
                router.present(.testPopup, style: .popup)
            }
        }
    }
}
