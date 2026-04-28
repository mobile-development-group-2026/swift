import UIKit

enum ImageUploadService {
    // MARK: - Cloudinary config
    static let cloudName    = "djaujgtb8"
    static let uploadPreset = "sc860dd6"

    // MARK: - Upload

    /// Compresses imageData to ≤1 MB JPEG, uploads to Cloudinary, returns the secure_url.
    static func upload(_ imageData: Data, folder: String) async throws -> String {
        let jpeg = compress(imageData)

        var request = URLRequest(
            url: URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        )
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()
        body.appendField("upload_preset", value: uploadPreset, boundary: boundary)
        body.appendField("folder",        value: folder,       boundary: boundary)
        body.appendFile(jpeg, name: "file", filename: "photo.jpg",
                        mimeType: "image/jpeg", boundary: boundary)
        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let secureUrl = json["secure_url"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        return secureUrl
    }

    // MARK: - Compression

    private static func compress(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        var quality: CGFloat = 0.8
        var result = image.jpegData(compressionQuality: quality) ?? data
        while result.count > 1_000_000 && quality > 0.15 {
            quality -= 0.15
            result = image.jpegData(compressionQuality: max(quality, 0.1)) ?? result
        }
        return result
    }
}

// MARK: - Multipart helpers

private extension Data {
    mutating func appendField(_ name: String, value: String, boundary: String) {
        appendString("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n")
    }

    mutating func appendFile(_ fileData: Data, name: String, filename: String,
                             mimeType: String, boundary: String) {
        appendString("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\nContent-Type: \(mimeType)\r\n\r\n")
        append(fileData)
        appendString("\r\n")
    }

    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
