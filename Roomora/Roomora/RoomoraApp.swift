import SwiftUI
import ClerkKit

@main
struct RoomoraApp: App {
  init() {
    Clerk.configure(publishableKey: "pk_test_ZXZvbHZpbmctZ2VsZGluZy02MS5jbGVyay5hY2NvdW50cy5kZXYk")
  }

  var body: some Scene {
    // creates the app's window. Everything inside this is what appears on screen.
    WindowGroup {
        // this is the root view
        ContentView()
            // injects the Clerk authentication instance into the environment.
            // This is why any child view anywhere in the app can do
            // @Environment(Clerk.self) var clerk and it works
            .environment(Clerk.shared)
    }
  }
}
