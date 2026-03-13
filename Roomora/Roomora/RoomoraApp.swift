import SwiftUI
import ClerkKit

@main
struct RoomoraApp: App {
  init() {
    Clerk.configure(publishableKey: "pk_test_ZXZvbHZpbmctZ2VsZGluZy02MS5jbGVyay5hY2NvdW50cy5kZXYk")
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(Clerk.shared)
    }
  }
}
