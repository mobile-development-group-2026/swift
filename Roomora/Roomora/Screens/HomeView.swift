import SwiftUI
import ClerkKitUI

struct HomeView: View {
    @Environment(UserSession.self) private var session

    var body: some View {
        if session.role == "student" {
            StudentHomeView()
        } else {
            LandlordHomeView()
        }
    }
}

