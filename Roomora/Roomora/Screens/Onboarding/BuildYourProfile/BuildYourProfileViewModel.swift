import SwiftUI
import PhotosUI

@Observable
class BuildYourProfileViewModel {
    var bio = ""
    var university = ""
    var birthYear = ""
    var graduationYear = ""
    var selectedHobbies: Set<String> = []
    let maxHobbies = 5
    var profilePhoto: Image?
    var photoPickerItem: PhotosPickerItem?

    static let hobbies = [
        "📚 Reading", "😴 Sleeping", "🎣 Fishing", "🌙 Star gazing",
        "🧗 Rock climbing", "👾 Netflix", "🏃 Running", "🏕 Camping",
        "🎮 Video games", "🍳 Cooking", "✍️ Journaling", "🥳 Partying"
    ]

    private static var photoURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile_photo.jpg")
    }

    init() {
        loadPhoto()
    }

    func savePhoto(data: Data) {
        guard let uiImage = UIImage(data: data) else { return }
        profilePhoto = Image(uiImage: uiImage)
        // save compressed JPEG to disk
        if let jpeg = uiImage.jpegData(compressionQuality: 0.8) {
            try? jpeg.write(to: Self.photoURL)
        }
    }

    private func loadPhoto() {
        guard FileManager.default.fileExists(atPath: Self.photoURL.path),
              let data = try? Data(contentsOf: Self.photoURL),
              let uiImage = UIImage(data: data) else { return }
        profilePhoto = Image(uiImage: uiImage)
    }

    static func deletePhoto() {
        try? FileManager.default.removeItem(at: photoURL)
    }

    func toggleHobby(_ hobby: String) {
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else if selectedHobbies.count < maxHobbies {
            selectedHobbies.insert(hobby)
        }
    }

    var canContinue: Bool {
        selectedHobbies.count > 0
    }
}
