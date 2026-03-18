enum UserRole: String, CaseIterable {
    case student = "Student"
    case landlord = "Landlord"

    var icon: String {
        switch self {
        case .student: return "🎓"
        case .landlord: return "🏠"
        }
    }
}
