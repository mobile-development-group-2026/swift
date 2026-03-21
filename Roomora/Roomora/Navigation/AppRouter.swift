import SwiftUI

/// Centralized navigation controller for the app.
/// Manages route navigation (stack of pages, forward/back) and modal presentation (sheets, popups, full screen covers).
/// Injected into the environment so any view can navigate without needing bindings passed down from parents.
///
/// SwiftUI watches every property in this class since its @Observable (kindof like what we use Zustand for in React)
/// This class is final so no other class can inherit from this
@Observable
final class AppRouter {
    
    // These instance properties hold a piece of the navigation state.
    // SwiftUI requires a separate binding for each presentation style
    
    // the stack of pages the user has navigated into
    var path = NavigationPath()
    
    // which modal is currently showing as a bottom sheet, or nil if none
    var presentedSheet: AppModal?
    
    // which modal is currently showing as a full screen takeover, or nil if none
    var presentedFullScreenCover: AppModal?
    
    // which modal is currently showing as a centered popup with blurred background, or nil if none
    var presentedPopup: AppModal?

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func present(_ modal: AppModal, style: ModalStyle) {
        switch style {
        case .sheet:
            presentedSheet = modal
        case .fullScreenCover:
            presentedFullScreenCover = modal
        case .popup:
            withAnimation(.easeInOut(duration: 0.25)) {
                presentedPopup = modal
            }
        }
    }

    func dismissModal() {
        presentedSheet = nil
        presentedFullScreenCover = nil
        withAnimation(.easeInOut(duration: 0.25)) {
            presentedPopup = nil
        }
    }
}
