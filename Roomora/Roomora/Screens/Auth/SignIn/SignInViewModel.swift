import SwiftUI
@_spi(Internal) import ClerkKit

@Observable
class SignInViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let publishableKey = "pk_test_ZXZvbHZpbmctZ2VsZGluZy02MS5jbGVyay5hY2NvdW50cy5kZXYk"

    var buttonTitle: String {
        isLoading ? "Signing in..." : "Sign In  →"
    }

    func signIn(clerk: Clerk, session: UserSession) async -> Bool {
            isLoading = true
            errorMessage = nil
            do {
                // 1. Initial Sign-In Attempt
                var result = try await clerk.auth.signInWithPassword(
                    identifier: email,
                    password: password
                )

                // 2. Graceful Client Trust Handling
                            if result.status == SignIn.Status.needsClientTrust {
                                print("🔄 needsClientTrust detected. Syncing new device token...")
                                
                                // Wait briefly for the SDK to save the new device token to the Keychain
                                try? await Task.sleep(for: .milliseconds(500))
                                                                
                                // Retry the sign in using the SAME instance
                                print("🔄 Retrying sign-in...")
                                result = try await clerk.auth.signInWithPassword(
                                    identifier: email,
                                    password: password
                                )
                            }

                // 3. STRICT GUARD: Ensure the sign-in actually completed
                guard let targetSessionId = result.createdSessionId else {
                    print("❌ Sign-in did not yield a session ID. Status: \(result.status)")
                    errorMessage = "Sign in incomplete. Status: \(result.status)"
                    isLoading = false
                    return false
                }

                print("✅ Sign-in successful. Setting active session: \(targetSessionId)")
                
                // From here down, we use the instance passed into the function to ensure consistency
                try await clerk.auth.setActive(sessionId: targetSessionId)

                // 4. DIAGNOSTIC POLLING LOOP
                var token: String? = nil
                for i in 0..<60 {
                    let currentSession = clerk.session
                    
                    if let currentSession = currentSession, currentSession.id == targetSessionId {
                        do {
                            token = try await currentSession.getToken()
                            if token != nil {
                                print("✅ Token successfully retrieved on attempt \(i)")
                                break
                            }
                        } catch {
                            print("⚠️ getToken() threw an error on attempt \(i): \(error)")
                        }
                    } else {
                        if i % 10 == 0 {
                            print("⏳ Waiting for session to sync... (Current: \(currentSession?.id ?? "nil"), Target: \(targetSessionId))")
                        }
                    }
                    try? await Task.sleep(for: .milliseconds(100))
                }

                // 5. Final verification
                guard token != nil else {
                    print("❌ Failed to retrieve session token after 6 seconds")
                    errorMessage = "Session initialization timed out. Please try again."
                    isLoading = false
                    return false
                }

                print("🚀 Token acquired. Fetching profile from remote DB...")
                // Ensure APIClient uses the instance that actually has the token
                let profile = try await APIClient.shared.fetchProfile(clerk: clerk)
                
                session.pendingSync = nil
                session.profile = profile
                session.isLoaded = true
                isLoading = false
                return true
                
            } catch let error as APIError {
                if case .server(_, let message) = error, message.contains("User not found") {
                    errorMessage = "Account not found. Please sign up again."
                } else {
                    errorMessage = error.localizedDescription
                }
                print("signIn failed: \(error)")
                isLoading = false
                return false
            } catch {
                print("signIn failed: \(error)")
                errorMessage = error.localizedDescription
                isLoading = false
                return false
            }
        }
}
