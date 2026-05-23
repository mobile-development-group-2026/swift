import Foundation

struct RoommateProfileResponse: Codable {
    let id: String
    let role: String
    let firstName: String
    let lastName: String
    let avatarUrl: String?
    let verified: Bool
    let createdAt: String
    let studentProfile: RoommateStudentProfile?
    let lifestyleProfile: RoommateLifestyleProfile?
    let listingProfile: RoommateListingProfile?

    var fullName: String { "\(firstName) \(lastName)" }

    var age: Int? {
        guard let year = studentProfile?.birthYear else { return nil }
        return Calendar.current.component(.year, from: Date()) - year
    }
}

struct RoommateStudentProfile: Codable {
    let university: String?
    let major: String?
    let birthYear: Int?
    let graduationYear: Int?
    let bio: String?
    let hobbies: [String]?
}

struct RoommateLifestyleProfile: Codable {
    let spotsAvailable: Int?
    let moveInMonth: String?
    let genderPreference: Int?
    let sleepSchedule: Int?
    let cleanlinessLevel: Int?
    let lifestyle: [String]?
    let requirements: [String]?

    var sleepScheduleLabel: String {
        switch sleepSchedule {
        case 0: return "Early bird"
        case 1: return "Night owl"
        case 2: return "Flexible"
        default: return "Unknown"
        }
    }

    var cleanlinessLabel: String {
        switch cleanlinessLevel {
        case 0: return "Relaxed"
        case 1: return "Tidy"
        case 2: return "Very clean"
        default: return "Unknown"
        }
    }

    var genderPreferenceLabel: String {
        switch genderPreference {
        case 0: return "No preference"
        case 1: return "Male"
        case 2: return "Female"
        case 3: return "Other"
        default: return "No preference"
        }
    }
}

struct RoommateListingProfile: Codable {
    let maxBudget: Int?
    let propertyType: String?
    let moveInDate: String?
    let leaseLengthMonths: Int?
    let amenities: [String]?
    let preferences: [String]?

    var formattedBudget: String {
        guard let budget = maxBudget, budget > 0 else { return "Not specified" }
        let millions = Double(budget) / 1_000_000
        if millions >= 1 {
            return String(format: "$%.1fM/mo", millions)
        } else {
            return "$\(budget / 1000)K/mo"
        }
    }
}
