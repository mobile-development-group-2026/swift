import SwiftUI

// MARK: - In-memory image cache (NSCache, evicted when memory is low)

final class ImageMemoryCache {
    static let shared = ImageMemoryCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 150                       // max images
        cache.totalCostLimit = 50 * 1024 * 1024     // 50 MB
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func store(_ img: UIImage, for url: URL) {
        let cost = Int(img.size.width * img.size.height * 4)
        cache.setObject(img, forKey: url as NSURL, cost: cost)
    }

    /// Fire-and-forget: load a batch of URLs into the cache in the background.
    func prefetch(_ urls: [URL]) {
        Task.detached(priority: .background) {
            for url in urls {
                guard self.image(for: url) == nil else { continue }
                guard let (data, _) = try? await URLSession.shared.data(from: url),
                      let img = UIImage(data: data) else { continue }
                self.store(img, for: url)
            }
        }
    }
}

// MARK: - View

/// Drop-in replacement for AsyncImage that checks NSCache first (instant, no flicker),
/// then falls through to URLCache on disk, then the network.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .task(id: url) { await load() }
            }
        }
    }

    private func load() async {
        guard let url else { return }

        // 1. In-memory — zero latency
        if let cached = ImageMemoryCache.shared.image(for: url) {
            uiImage = cached
            return
        }

        // 2. URLSession respects URLCache.shared (200 MB disk) before hitting network
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let img = UIImage(data: data) else { return }

        ImageMemoryCache.shared.store(img, for: url)
        uiImage = img
    }
}
