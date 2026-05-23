import SwiftUI
import PhotosUI
import Network
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
    var queuedOffline = false

    // Snapshot for dirty checking
    private var snapshot: Snapshot?

    private struct Snapshot {
        var university: String?
        var major: String?
        var bio: String
        var selectedHobbies: Set<String>
        var sleepSchedule: Int?
        var cleanliness: Int?
        var genderPreference: Int?
        var lifestyleTags: Set<String>
        var requirements: Set<String>
        var spotsAvailable: Int
        var moveInMonth: String?
        var maxBudget: Int?
        var propertyType: String?
        var moveInDate: Date
    }

    var isDirty: Bool {
        guard let s = snapshot else { return false }
        return university != s.university ||
               major != s.major ||
               bio != s.bio ||
               selectedHobbies != s.selectedHobbies ||
               sleepSchedule != s.sleepSchedule ||
               cleanliness != s.cleanliness ||
               genderPreference != s.genderPreference ||
               lifestyleTags != s.lifestyleTags ||
               requirements != s.requirements ||
               spotsAvailable != s.spotsAvailable ||
               moveInMonth != s.moveInMonth ||
               maxBudget != s.maxBudget ||
               propertyType != s.propertyType ||
               Calendar.current.isDate(moveInDate, inSameDayAs: s.moveInDate) == false ||
               photoData != nil
    }

    private let networkMonitor = NWPathMonitor()
    private static let pendingKey = "roomora_pending_profile_save"

    init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            Task { @MainActor [weak self] in
                await self?.flushIfPending()
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "dev.roomora.profile.network"))
    }

    // MARK: - Populate

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

        // Take snapshot after populating
        snapshot = Snapshot(
            university: university,
            major: major,
            bio: bio,
            selectedHobbies: selectedHobbies,
            sleepSchedule: sleepSchedule,
            cleanliness: cleanliness,
            genderPreference: genderPreference,
            lifestyleTags: lifestyleTags,
            requirements: requirements,
            spotsAvailable: spotsAvailable,
            moveInMonth: moveInMonth,
            maxBudget: maxBudget,
            propertyType: propertyType,
            moveInDate: moveInDate
        )
    }

    // MARK: - Toggles

    func toggleHobby(_ hobby: String) {
        if selectedHobbies.contains(hobby) { selectedHobbies.remove(hobby) }
        else if selectedHobbies.count < 5 { selectedHobbies.insert(hobby) }
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

    // MARK: - Save

    func save(clerk: Clerk, session: UserSession) async {
        isSaving = true
        errorMessage = nil
        saveSuccess = false
        queuedOffline = false

        do {
            try await pushToServer(clerk: clerk, session: session)
            clearPending()
            saveSuccess = true
            // Update snapshot to new saved state
            snapshot = Snapshot(
                university: university, major: major, bio: bio,
                selectedHobbies: selectedHobbies, sleepSchedule: sleepSchedule,
                cleanliness: cleanliness, genderPreference: genderPreference,
                lifestyleTags: lifestyleTags, requirements: requirements,
                spotsAvailable: spotsAvailable, moveInMonth: moveInMonth,
                maxBudget: maxBudget, propertyType: propertyType, moveInDate: moveInDate
            )
            photoData = nil
        } catch {
            persistPending()
            queuedOffline = true
            saveSuccess = true
            errorMessage = nil
        }

        isSaving = false
    }

    // MARK: - Server push

    private func pushToServer(clerk: Clerk, session: UserSession) async throws {
        var studentFields: [String: Any] = [:]
        if let u = university { studentFields["university"] = u }
        if let m = major { studentFields["major"] = m }
        if !bio.isEmpty { studentFields["bio"] = bio }
        if !selectedHobbies.isEmpty { studentFields["hobbies"] = Array(selectedHobbies).sorted() }
        if !studentFields.isEmpty {
            _ = try await APIClient.shared.updateStudentProfile(clerk: clerk, fields: studentFields)
        }

        var lifestyleFields: [String: Any] = [:]
        if let s = sleepSchedule { lifestyleFields["sleep_schedule"] = s }
        if let c = cleanliness { lifestyleFields["cleanliness_level"] = c }
        if let g = genderPreference { lifestyleFields["gender_preference"] = g }
        if !lifestyleTags.isEmpty { lifestyleFields["lifestyle"] = Array(lifestyleTags).sorted() }
        if !requirements.isEmpty { lifestyleFields["requirements"] = Array(requirements).sorted() }
        lifestyleFields["spots_available"] = spotsAvailable
        if let m = moveInMonth { lifestyleFields["move_in_month"] = m }
        _ = try await APIClient.shared.updateLifestyleProfile(clerk: clerk, fields: lifestyleFields)

        var listingFields: [String: Any] = [:]
        if let b = maxBudget { listingFields["max_budget"] = b }
        if let pt = propertyType { listingFields["property_type"] = pt }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        listingFields["move_in_date"] = formatter.string(from: moveInDate)
        if !listingFields.isEmpty {
            _ = try await APIClient.shared.updateListingProfile(clerk: clerk, fields: listingFields)
        }

        var profileFields: [String: Any] = [:]
        if let data = photoData,
           let avatarUrl = try? await ImageUploadService.upload(data, folder: "profiles") {
            profileFields["avatar_url"] = avatarUrl
        }

        if !profileFields.isEmpty {
            let updated = try await APIClient.shared.updateProfile(clerk: clerk, fields: profileFields)
            session.commit(updated)
        } else {
            let fresh = try await APIClient.shared.fetchProfile(clerk: clerk)
            session.commit(fresh)
        }
    }

    // MARK: - Offline persistence

    private struct PendingProfileSave: Codable {
        var university: String?
        var major: String?
        var bio: String
        var hobbies: [String]
        var sleepSchedule: Int?
        var cleanliness: Int?
        var genderPreference: Int?
        var lifestyleTags: [String]
        var requirements: [String]
        var spotsAvailable: Int
        var moveInMonth: String?
        var maxBudget: Int?
        var propertyType: String?
        var moveInDate: String
    }

    private func persistPending() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let pending = PendingProfileSave(
            university: university, major: major, bio: bio,
            hobbies: Array(selectedHobbies).sorted(),
            sleepSchedule: sleepSchedule, cleanliness: cleanliness,
            genderPreference: genderPreference,
            lifestyleTags: Array(lifestyleTags).sorted(),
            requirements: Array(requirements).sorted(),
            spotsAvailable: spotsAvailable, moveInMonth: moveInMonth,
            maxBudget: maxBudget, propertyType: propertyType,
            moveInDate: formatter.string(from: moveInDate)
        )
        CacheService.save(pending, key: Self.pendingKey)
    }

    private func clearPending() {
        CacheService.clear(key: Self.pendingKey)
    }

    private func flushIfPending() async {
        guard CacheService.load(PendingProfileSave.self, key: Self.pendingKey) != nil else { return }
        guard let clerk = try? Clerk.shared as Clerk else { return }
        do {
            var studentFields: [String: Any] = [:]
            if let u = university { studentFields["university"] = u }
            if let m = major { studentFields["major"] = m }
            if !bio.isEmpty { studentFields["bio"] = bio }
            if !selectedHobbies.isEmpty { studentFields["hobbies"] = Array(selectedHobbies).sorted() }
            if !studentFields.isEmpty {
                _ = try await APIClient.shared.updateStudentProfile(clerk: clerk, fields: studentFields)
            }

            var lifestyleFields: [String: Any] = [:]
            if let s = sleepSchedule { lifestyleFields["sleep_schedule"] = s }
            if let c = cleanliness { lifestyleFields["cleanliness_level"] = c }
            if let g = genderPreference { lifestyleFields["gender_preference"] = g }
            if !lifestyleTags.isEmpty { lifestyleFields["lifestyle"] = Array(lifestyleTags).sorted() }
            if !requirements.isEmpty { lifestyleFields["requirements"] = Array(requirements).sorted() }
            lifestyleFields["spots_available"] = spotsAvailable
            if let m = moveInMonth { lifestyleFields["move_in_month"] = m }
            _ = try await APIClient.shared.updateLifestyleProfile(clerk: clerk, fields: lifestyleFields)

            clearPending()
            queuedOffline = false
        } catch { }
    }
}
