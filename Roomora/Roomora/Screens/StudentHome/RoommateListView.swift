import SwiftUI
import Lottie

struct RoommateListView: View {
    var vm: RoommateViewModel
    var filteredRoommates: [RoommateStudent]

    @State private var matchedName: String? = nil
    @State private var showMatchScreen = false

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xxl)
            } else if filteredRoommates.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "person.2")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(.neutral, 300))
                    Text("No roommates match your filters")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("Try adjusting your filters.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 400))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxl)
                .padding(.horizontal, AppSpacing.lg)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(filteredRoommates) { roommate in
                        RoommateCard(roommate: roommate) {
                            let matched = await vm.like(roommate: roommate)
                            if matched {
                                matchedName = roommate.firstName
                                showMatchScreen = true
                            }
                            return matched
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showMatchScreen) {
            MatchAnimationScreen(name: matchedName ?? "") {
                showMatchScreen = false
            }
        }
    }
}

struct MatchAnimationScreen: View {
    let name: String
    let onDismiss: () -> Void

    @State private var showText = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.purple, 500), Color(.purple, 900)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LottieView(animation: .named("match"))
                    .playing(loopMode: .playOnce)
                    .frame(width: 280, height: 280)

                VStack(spacing: AppSpacing.sm) {
                    Text("It's a match!")
                        .font(.h1(.bold))
                        .foregroundStyle(.white)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)

                    Text("You and \(name) liked each other.")
                        .font(.body16())
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)

                    Text("Check Activity to message them.")
                        .font(.body14())
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                }
                .padding(.horizontal, AppSpacing.xl)
                .animation(.spring(duration: 0.6).delay(0.4), value: showText)

                Spacer()

                Button(action: onDismiss) {
                    Text("Keep browsing")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.purple, 600))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(RoundedRectangle(cornerRadius: 14).fill(.white))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxl)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
                .animation(.spring(duration: 0.5).delay(0.8), value: showButton)
            }
        }
        .onAppear { showText = true; showButton = true }
    }
}
