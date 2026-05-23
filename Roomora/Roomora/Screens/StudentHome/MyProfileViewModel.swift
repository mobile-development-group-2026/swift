//
//  MyProfileViewModel.swift
//  Roomora
//
//  Created by Andy on 23/05/26.
//


import SwiftUI
import PhotosUI
import ClerkKit

@Observable
@MainActor
class MyProfileViewModel {
    // Build profile
    var university: String?
    var major: String?
    var bio = ""
    var selectedHobbies: Set<String> = []
    var profilePhoto: Image?
    var photoPickerItem: PhotosPickerItem?
    var photoData: Data?

    // Lifestyle
    var sleepSchedule: Int?
    var cleanliness: Int?
    var genderPreference: Int?
    var lifestyleTags: Set<String> = []
    var requirements: Set<String> = []

    // havePlace extras
    var spotsAvailable: Int = 1
    var moveInMonth: String?

    // needPlace extras
    var maxBudget: Int?
    var propertyType: String?
    var moveInDate: Date = Date()

    // State
    var isSaving = false
    var saveSuccess = false
    var errorMessage: String?

    func populate(from profile: SyncResponse?) {
        guard let profile else { return }

        if let sp = profile.studentProfile {
            university = sp.university
            major = sp.major
            bio = sp.bio ?? ""
            selectedHobbies = Set(sp.hobbies ?? [])
        }

        if let lp = profile.lifestyleProfile {
            sleepSchedule = lp.sleepSchedule
            cleanliness = lp.cleanlinessLevel.map { c in
                c <= 2 ? 0 : c == 3 ? 1 : 2
            }
            genderPreference = lp.genderPreference
            lifestyleTags = Set(lp.lifestyle ?? [])
            requirements = Set(lp.requirements ?? [])
            spotsAvailable = lp.spotsAvailable ?? 1
            moveInMonth = lp.moveInMonth
        }

        if let lsp = profile.listingProfile {
            maxBudget = lsp.maxBudget
            propertyType = lsp.propertyType
            if let dateStr = lsp.moveInDate,
               let date = ISO8601DateFormatter().date(from: dateStr + "T00:00:00Z") {
                moveInDate = date
            }
        }
    }

    func toggleHobby(_ hobby: String) {
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else if selectedHobbies.count < 5 {
            selectedHobbies.insert(hobby)
        }
    }

    func toggleLifestyleTag(_ tag: String) {
        if lifestyleTags.contains(tag) { lifestyleTags.remove(tag) }
        else { lifestyleTags.insert(tag) }
    }

    func toggleRequirement(_ req: String) {
        if requirements.contains(req) { requirements.remove(req) }
        else { requirements.insert(req) }
    }

    func savePhoto(data: Data) {
        photoData = data
        if let uiImage = UIImage(data: data) {
            profilePhoto = Image(uiImage: uiImage)
        }
    }

    func save(clerk: Clerk, session: UserSession) async {
        isSaving = true
        errorMessage = nil
        saveSuccess = false

        do {
            // Student profile
            var studentFields: [String: Any] = [:]
            if let u = university { studentFields["university"] = u }
            if let m = major { studentFields["major"] = m }
            if !bio.isEmpty { studentFields["bio"] = bio }
            if !selectedHobbies.isEmpty {
                studentFields["hobbies"] = Array(selectedHobbies).sorted()
            }
            if !studentFields.isEmpty {
                _ = try await APIClient.shared.updateStudentProfile(clerk: clerk, fields: studentFields)
            }

            // Lifestyle profile
            var lifestyleFields: [String: Any] = [:]
            if let s = sleepSchedule { lifestyleFields["sleep_schedule"] = s }
            if let c = cleanliness { lifestyleFields["cleanliness_level"] = c }
            if let g = genderPreference { lifestyleFields["gender_preference"] = g }
            if !lifestyleTags.isEmpty { lifestyleFields["lifestyle"] = Array(lifestyleTags).sorted() }
            if !requirements.isEmpty { lifestyleFields["requirements"] = Array(requirements).sorted() }
            lifestyleFields["spots_available"] = spotsAvailable
            if let m = moveInMonth { lifestyleFields["move_in_month"] = m }
            _ = try await APIClient.shared.updateLifestyleProfile(clerk: clerk, fields: lifestyleFields)

            // Listing profile (needPlace users)
            var listingFields: [String: Any] = [:]
            if let b = maxBudget { listingFields["max_budget"] = b }
            if let pt = propertyType { listingFields["property_type"] = pt }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            listingFields["move_in_date"] = formatter.string(from: moveInDate)
            if !listingFields.isEmpty {
                _ = try await APIClient.shared.updateListingProfile(clerk: clerk, fields: listingFields)
            }

            // Avatar upload
            var profileFields: [String: Any] = [:]
            if let data = photoData,
               let avatarUrl = try? await ImageUploadService.upload(data, folder: "profiles") {
                profileFields["avatar_url"] = avatarUrl
            }
            if !profileFields.isEmpty {
                let updated = try await APIClient.shared.updateProfile(clerk: clerk, fields: profileFields)
                session.commit(updated)
            } else {
                // Refresh profile to reflect changes
                let fresh = try await APIClient.shared.fetchProfile(clerk: clerk)
                session.commit(fresh)
            }

            saveSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
