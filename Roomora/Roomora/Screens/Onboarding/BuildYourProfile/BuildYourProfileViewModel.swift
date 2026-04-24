import SwiftUI
import PhotosUI

@Observable
class BuildYourProfileViewModel {
    var bio = ""
    var university = ""
    var major: String?
    var birthYear: Int?
    var graduationYear: Int?
    var selectedHobbies: Set<String> = []
    let maxHobbies = 5
    var profilePhoto: Image?
    var photoPickerItem: PhotosPickerItem?
    var photoData: Data?

    static let birthYears = Array(1970...Calendar.current.component(.year, from: Date()))
    static let gradYears = Array(1970...Calendar.current.component(.year, from: Date()) + 5)

    static let majors = [
        "Computer Science",
        "Business Administration",
        "Mechanical Engineering",
        "Electrical Engineering",
        "Civil Engineering",
        "Economics",
        "Psychology",
        "Biology",
        "Chemistry",
        "Mathematics",
        "Physics",
        "Political Science",
        "Communications",
        "Architecture",
        "Law",
        "Medicine",
        "Nursing",
        "Finance",
        "Marketing",
        "Graphic Design",
        "Industrial Engineering",
        "Environmental Science",
        "International Relations",
        "Data Science",
        "Philosophy",
        "Sociology",
        "Art History",
        "Music",
        "Education",
        "Other"
    ]

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
        photoData = data // store raw bytes for Cloudinary upload later
        guard let uiImage = UIImage(data: data) else { return }
        profilePhoto = Image(uiImage: uiImage)
        // save compressed JPEG to disk for local fallback
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
