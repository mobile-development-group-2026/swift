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
