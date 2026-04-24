import SwiftUI
import ClerkKit
import PhotosUI

@Observable
class OnboardingViewModel {
    var step = 0
    var totalSteps: Int { isLandlord ? 2 : 3 }
    var isLoading = false
    var errorMessage: String?
    var showCelebration = false
    private var completedProfile: SyncResponse?

    // child view models
    var buildProfile = BuildYourProfileViewModel()
    var situation = RoommateSituationViewModel()
    var preferences = RoommatePreferencesViewModel()
    var listingPrefs = ListingPreferencesViewModel()
    var newListing = NewListingViewModel()

    /// true when user picked "I need a place" (needPlace)
    var needsPlace: Bool { situation.situation == .needPlace }

    func nextStep(clerk: Clerk, role: String) async {
        if step == 0 {
            if role == "landlord" {
                await saveLandlordProfile(clerk: clerk)
            } else {
                await saveStudentProfile(clerk: clerk)
            }
        }
        if step < totalSteps - 1 {
            step += 1
        }
    }

    private func saveLandlordProfile(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        var fields: [String: Any] = [:]

        let bp = buildProfile
        if let year = bp.birthYear { fields["birth_year"] = year }
        if !bp.bio.isEmpty { fields["bio"] = bp.bio }
        if !bp.selectedHobbies.isEmpty {
            let cleaned = bp.selectedHobbies.map { hobby in
                hobby.drop(while: { !$0.isASCII || $0.isWhitespace })
                    .trimmingCharacters(in: .whitespaces)
            }.sorted()
            fields["hobbies"] = cleaned
        }

        guard !fields.isEmpty else {
            isLoading = false
            return
        }

        do {
            _ = try await APIClient.shared.updateLandlordProfile(clerk: clerk, fields: fields)
        } catch {
            print("saveLandlordProfile failed: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func saveStudentProfile(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        var fields: [String: Any] = [:]

        let bp = buildProfile
        if !bp.university.isEmpty { fields["university"] = bp.university }
        if let major = bp.major { fields["major"] = major }
        if let year = bp.birthYear { fields["birth_year"] = year }
        if let year = bp.graduationYear { fields["graduation_year"] = year }
        if !bp.bio.isEmpty { fields["bio"] = bp.bio }
        if !bp.selectedHobbies.isEmpty {
            // Strip emoji prefixes (e.g. "📚 Reading" → "Reading")
            let cleaned = bp.selectedHobbies.map { hobby in
                hobby.drop(while: { !$0.isASCII || $0.isWhitespace })
                    .trimmingCharacters(in: .whitespaces)
            }.sorted()
            fields["hobbies"] = cleaned
        }

        guard !fields.isEmpty else {
            isLoading = false
            return
        }

        do {
            _ = try await APIClient.shared.updateStudentProfile(clerk: clerk, fields: fields)
        } catch {
            print("saveStudentProfile failed: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func previousStep() {
        if step > 0 {
            step -= 1
        }
    }

    var isLastStep: Bool { step == totalSteps - 1 }

    var canContinue: Bool {
        switch step {
        case 0: return buildProfile.canContinue
        case 1: return isLandlord ? newListing.canContinue : situation.canContinue
        default: return true
        }
    }

    /// Set by the view so the VM can branch on role.
    var isLandlord = false

    func complete(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        do {
            // Save step 3 data based on role & situation
            if isLandlord {
                await saveNewListing(clerk: clerk)
            } else if needsPlace {
                await saveListingProfile(clerk: clerk)
            } else {
                await saveLifestyleProfile(clerk: clerk)
            }
            if errorMessage != nil {
                isLoading = false
                return
            }

            // Upload profile photo and mark onboarded in one call
            var finalFields: [String: Any] = ["onboarded": true]
            if let data = buildProfile.photoData,
               let avatarUrl = try? await ImageUploadService.upload(data, folder: "profiles") {
                finalFields["avatar_url"] = avatarUrl
            }

            let profile = try await APIClient.shared.updateProfile(
                clerk: clerk,
                fields: finalFields
            )
            completedProfile = profile
            showCelebration = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func saveLifestyleProfile(clerk: Clerk) async {
        var fields: [String: Any] = [:]
        let pref = preferences

        fields["spots_available"] = pref.spotsAvailable
        if let month = pref.moveInMonth { fields["move_in_month"] = month }
        if let gender = pref.genderPreference { fields["gender_preference"] = gender }
        if let sleep = pref.sleepSchedule { fields["sleep_schedule"] = sleep }
        if let clean = pref.cleanliness { fields["cleanliness_level"] = clean }

        if !pref.selectedLifestyle.isEmpty {
            let cleaned = pref.selectedLifestyle.map { item in
                item.drop(while: { !$0.isASCII || $0.isWhitespace })
                    .trimmingCharacters(in: .whitespaces)
            }.sorted()
            fields["lifestyle"] = cleaned
        }

        if !pref.selectedRequirements.isEmpty {
            let cleaned = pref.selectedRequirements.map { item in
                item.drop(while: { !$0.isASCII || $0.isWhitespace })
                    .trimmingCharacters(in: .whitespaces)
            }.sorted()
            fields["requirements"] = cleaned
        }

        do {
            _ = try await APIClient.shared.updateLifestyleProfile(clerk: clerk, fields: fields)
        } catch {
            print("saveLifestyleProfile failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    private func saveListingProfile(clerk: Clerk) async {
        var fields: [String: Any] = [:]
        let lp = listingPrefs

        if let budget = lp.maxBudget { fields["max_budget"] = budget }
        if let type = lp.propertyType { fields["property_type"] = type }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        fields["move_in_date"] = formatter.string(from: lp.moveInDate)

        fields["lease_length_months"] = lp.leaseLength
        if let dist = lp.maxDistance { fields["max_distance"] = dist }

        if !lp.selectedAmenities.isEmpty {
            fields["amenities"] = Array(lp.selectedAmenities.sorted())
        }

        if !lp.selectedPreferences.isEmpty {
            fields["preferences"] = Array(lp.selectedPreferences.sorted())
        }

        do {
            _ = try await APIClient.shared.updateListingProfile(clerk: clerk, fields: fields)
        } catch {
            print("saveListingProfile failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    private func saveNewListing(clerk: Clerk) async {
        var fields: [String: Any] = [:]
        let nl = newListing

        fields["listing_type"] = "property"
        fields["title"] = nl.title
        if !nl.description.isEmpty { fields["description"] = nl.description }
        if let rent = Int(nl.monthlyRent) { fields["rent"] = rent }
        if let deposit = Int(nl.securityDeposit), deposit > 0 { fields["security_deposit"] = deposit }
        if let type = nl.propertyType { fields["property_type"] = type }

        // Parse lease length: "12 months" → 12
        if let months = Int(nl.leaseLength.components(separatedBy: " ").first ?? "") {
            fields["lease_term_months"] = months
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        fields["available_date"] = formatter.string(from: nl.availableFrom)

        if !nl.selectedAmenities.isEmpty {
            fields["amenities"] = Array(nl.selectedAmenities.sorted())
        }
        if !nl.selectedRules.isEmpty {
            fields["rules"] = Array(nl.selectedRules.sorted())
        }

        do {
            let listing = try await APIClient.shared.createListing(clerk: clerk, fields: fields)
            // Upload any selected photos sequentially (non-blocking failure)
            for item in nl.selectedPhotos {
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                if let photoUrl = try? await ImageUploadService.upload(data, folder: "listings") {
                    try? await APIClient.shared.postListingPhoto(clerk: clerk, listingId: listing.id, photoUrl: photoUrl)
                }
            }
        } catch {
            print("saveNewListing failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func finishOnboarding(session: UserSession) {
        session.profile = completedProfile
    }
}
