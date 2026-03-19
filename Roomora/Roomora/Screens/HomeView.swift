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
