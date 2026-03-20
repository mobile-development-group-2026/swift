import SwiftUI
import ClerkKitUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            UserButton()
            Text("Welcome to Roomora!")
                .font(.title2)
            AppButton(title: "Find a Place") {
                router.navigate(to: .propertyList)
            }
            AppButton(title: "Test Popup", variant: .secondary) {
                router.present(.testPopup, style: .popup)
            
            }
        }
    }
}
