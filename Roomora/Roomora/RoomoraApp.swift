import SwiftUI
import SwiftData
import ClerkKit

@main
struct RoomoraApp: App {
  @State private var session = UserSession()

  init() {
    // Image cache: 50 MB memory + 200 MB disk — AsyncImage uses URLCache.shared automatically
    URLCache.shared = URLCache(
      memoryCapacity: 50 * 1024 * 1024,
      diskCapacity: 200 * 1024 * 1024,
      diskPath: "roomora_images"
    )
    Clerk.configure(publishableKey: "pk_test_ZXZvbHZpbmctZ2VsZGluZy02MS5jbGVyay5hY2NvdW50cy5kZXYk")
  }

  var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(Clerk.shared)
            .environment(session)
    }
    .modelContainer(ModelContainer.roomora)
  }
}
