/// Defines every route in the app. Each page the user can anvigate to gets a case here.
/// NavigationPath requires it
enum AppRoute: Hashable {
    case home
    case signUp
    case designSystem
    case createListing
    case listingPreview(Listing)
    case landlordProfile
}
