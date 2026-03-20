import SwiftUI

enum HousingSituation: String, CaseIterable {
    case havePlace
    case needPlace

    var title: String {
        switch self {
        case .havePlace: "I already have a place"
        case .needPlace: "I need a place"
        }
    }

    var subtitle: String {
        switch self {
        case .havePlace: "Looking for a roommate to join"
        case .needPlace: "Looking for somewhere to live"
        }
    }

    var description: String {
        switch self {
        case .havePlace: "My apartment is set. I need to find the right person to share it with."
        case .needPlace: "I'm looking for a place near campus that fits my budget and lifestyle."
        }
    }

    var icon: String {
        switch self {
        case .havePlace: "house.fill"
        case .needPlace: "mappin.and.ellipse"
        }
    }

    var iconColor: Color {
        switch self {
        case .havePlace: Color(.purple, 500)
        case .needPlace: Color(.yellow, 500)
        }
    }

    var iconBackground: Color {
        switch self {
        case .havePlace: Color(.purple, 100)
        case .needPlace: Color(.yellow, 100)
        }
    }
}

@Observable
class RoommateSituationViewModel {
    var situation: HousingSituation?

    var canContinue: Bool {
        situation != nil
    }
}
