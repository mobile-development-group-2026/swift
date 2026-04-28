import Foundation

/// Lightweight disk JSON cache. Uses the system Caches directory
/// (OS can evict under storage pressure, never on normal conditions).
enum CacheService {
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder() // camelCase — matches encoded output

    private static func url(for key: String) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("roomora_\(key).json")
    }

    /// Persist any Encodable value to disk under `key`.
    static func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url(for: key), options: .atomic)
    }

    /// Load a previously saved value. Returns nil on miss or decode failure.
    static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = try? Data(contentsOf: url(for: key)) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    /// Remove a cached entry.
    static func clear(key: String) {
        try? FileManager.default.removeItem(at: url(for: key))
    }
}
