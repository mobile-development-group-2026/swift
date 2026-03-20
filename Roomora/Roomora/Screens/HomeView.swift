import SwiftUI
import ClerkKitUI
import ClerkKit

struct HomeView: View {
    @Environment(UserSession.self) private var session
    @Environment(Clerk.self) private var clerk

    var body: some View {
        if session.role == "student" {
            StudentHomeView()
        } else {
            // TODO: LandlordHomeView
            VStack {
                HStack {
                    Spacer()
                    Button {
                        let secItemClasses = [
                            kSecClassGenericPassword,
                            kSecClassInternetPassword
                        ]
                        for itemClass in secItemClasses {
                            SecItemDelete([kSecClass: itemClass] as CFDictionary)
                        }
                        session.clear()
                        exit(0)
                    } label: {
                        Text("Sign Out")
                            .font(.body14(.semiBold))
                            .foregroundStyle(Color(.red, 500))
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)

                Spacer()
                Text("Landlord Home")
                    .font(.h3(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                Spacer()
            }
        }
    }
}
