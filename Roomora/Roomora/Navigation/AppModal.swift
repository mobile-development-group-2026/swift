/// The three ways a modal can appear on screen.
enum ModalStyle {
    case sheet
    case fullScreenCover
    case popup
}

/// Defines every modal the app can present (sheets, popups, full screen covers).
/// Identifiable is a protocol that has a unique Id property. We need it to use .sheet(item:) and .fullScreenCover(item:)
///
/// (App-level) modals
enum AppModal: Identifiable {
    case signIn
    case testPopup
    case listingPreview(Listing)

    // turns current case name into a string id to satisfy Identifiable type
    var id: String { String(describing: self) }
}
