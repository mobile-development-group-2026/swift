import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
  @Environment(Clerk.self) private var clerk
  @State private var showAuth = false

  var body: some View {
    Group {
      if clerk.user != nil {
        HomeView()
      } else {
        LandingView(showAuth: $showAuth)
      }
    }
    .prefetchClerkImages()
    .sheet(isPresented: $showAuth) {
      AuthView()
    }
  }
}

struct LandingView: View {
  @Binding var showAuth: Bool

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      Text("Roomora")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Find your perfect roommate")
        .font(.title3)
        .foregroundStyle(.secondary)

      Spacer()

      Button {
        showAuth = true
      } label: {
        Text("Get Started")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 48)
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
