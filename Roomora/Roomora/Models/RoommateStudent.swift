import Foundation

struct RoommateStudent: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let avatarUrl: String?
    let verified: Bool
    let university: String?
    let major: String?
    let graduationYear: Int?
    let age: Int?
    let bio: String?
    let sleepSchedule: Int?       // 0 = early bird, 1 = night owl, 2 = flexible
    let cleanlinessLevel: Int?    // 1–5
    let lifestyleTags: [String]
    let moveInMonth: String?
    let spotsAvailable: Int?
    let requirements: [String]
    let maxBudget: Int?
    let propertyType: String?
    let moveInDate: String?

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))" }

    var sleepScheduleLabel: String {
        switch sleepSchedule {
        case 0:  return "🌅 Early bird"
        case 1:  return "🦉 Night owl"
        case 2:  return "😴 Flexible"
        default: return "—"
        }
    }

    var cleanlinessLabel: String {
        switch cleanlinessLevel {
        case 1, 2: return "🧹 Tidy"
        case 3:    return "🧼 Moderate"
        case 4, 5: return "🎒 Relaxed"
        default:   return "—"
        }
    }

    var formattedBudget: String {
        guard let budget = maxBudget else { return "—" }
        let millions = Double(budget) / 1_000_000
        if millions >= 1 {
            let s = String(format: "$%.1fM", millions)
            return s.hasSuffix(".0M") ? s.replacingOccurrences(of: ".0M", with: "M") : s
        }
        return "$\(budget / 1000)K"
    }
}
