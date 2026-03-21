import SwiftUI
import ClerkKit

@Observable
class OnboardingViewModel {
    var step = 0
    let totalSteps = 3
    var isLoading = false
    var errorMessage: String?
    var showCelebration = false
    private var completedProfile: SyncResponse?

    // child view models
    var buildProfile = BuildYourProfileViewModel()
    var situation = RoommateSituationViewModel()
    var preferences = RoommatePreferencesViewModel()
    var listingPrefs = ListingPreferencesViewModel()

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
        case 1: return situation.canContinue
        default: return true
        }
    }

    func complete(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        do {
            // Save step 3 data based on situation
            if needsPlace {
                await saveListingProfile(clerk: clerk)
            } else {
                await saveLifestyleProfile(clerk: clerk)
            }
            if errorMessage != nil {
                isLoading = false
                return
            }

            let profile = try await APIClient.shared.updateProfile(
                clerk: clerk,
                fields: ["onboarded": true]
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

    func finishOnboarding(session: UserSession) {
        session.profile = completedProfile
    }
}
