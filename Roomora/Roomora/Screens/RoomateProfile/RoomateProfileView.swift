import SwiftUI
import ClerkKit

struct RoommateProfileView: View {
    let userId: String

    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var vm: RoommateProfileViewModel

    init(userId: String) {
        self.userId = userId
        _vm = State(initialValue: RoommateProfileViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            if vm.isLoading && vm.profile == nil {
                loadingView
            } else if let error = vm.errorMessage, vm.profile == nil {
                errorView(error)
            } else if let profile = vm.profile {
                profileContent(profile)
            }
        }
        .ignoresSafeArea()
        .task {
            await vm.load(clerk: clerk)
        }
    }


    private func profileContent(_ profile: RoommateProfileResponse) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection(profile)
                detailsSection(profile)
            }
        }
        .overlay(alignment: .topLeading) {
            closeButton
        }
    }



    private func heroSection(_ profile: RoommateProfileResponse) -> some View {
        ZStack(alignment: .bottomLeading) {
   
            Group {
                if let urlString = profile.avatarUrl, let url = URL(string: urlString) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        avatarPlaceholder(profile)
                    }
                } else {
                    avatarPlaceholder(profile)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 480)
            .clipped()


            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 480)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                    Text(profile.fullName)
                        .font(.h1(.bold))
                        .foregroundStyle(.white)

                    if let age = profile.age {
                        Text("\(age)")
                            .font(.h1())
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    if profile.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(.purple, 400))
                    }
                }

                if let major = profile.studentProfile?.major {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 13))
                        Text(major)
                            .font(.body16(.semiBold))
                    }
                    .foregroundStyle(.white.opacity(0.85))
                }

                if let university = profile.studentProfile?.university {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 13))
                        Text(university)
                            .font(.body14())
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private func avatarPlaceholder(_ profile: RoommateProfileResponse) -> some View {
        LinearGradient(
            colors: [Color(.purple, 800), Color(.purple, 500)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Text(profile.firstName.prefix(1).uppercased() + profile.lastName.prefix(1).uppercased())
                .font(.system(size: 96, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
        )
    }


    private func detailsSection(_ profile: RoommateProfileResponse) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            if let lp = profile.listingProfile {
                lookingForBanner(lp)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)
            }


            if let bio = profile.studentProfile?.bio, !bio.isEmpty {
                sectionBlock(title: "About Me") {
                    Text(bio)
                        .font(.body16())
                        .foregroundStyle(Color(.neutral, 700))
                        .lineSpacing(4)
                }
            }

            if let lp = profile.lifestyleProfile {
                lifestyleSection(lp)
            }

     
            if let hobbies = profile.studentProfile?.hobbies, !hobbies.isEmpty {
                sectionBlock(title: "Hobbies") {
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(hobbies, id: \.self) { hobby in
                            pill(hobby, hue: .purple)
                        }
                    }
                }
            }

            if let lp = profile.listingProfile {
                housingPreferencesSection(lp)
            }

            if let requirements = profile.lifestyleProfile?.requirements, !requirements.isEmpty {
                sectionBlock(title: "Deal-breakers") {
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(requirements, id: \.self) { req in
                            pill(req, hue: .red)
                        }
                    }
                }
            }

        
            contactButton
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxxl)
        }
        .background(.white)
    }



    private func lookingForBanner(_ lp: RoommateListingProfile) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text("🏠")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Looking for")
                    .font(.body12(.semiBold))
                    .foregroundStyle(Color(.purple, 600))
                Text([lp.propertyType, lp.formattedBudget]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " · "))
                    .font(.body14(.bold))
                    .foregroundStyle(Color(.purple, 900))
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.purple, 100))
        )
    }

    

    private func lifestyleSection(_ lp: RoommateLifestyleProfile) -> some View {
        sectionBlock(title: "Lifestyle") {
            VStack(spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.md) {
                    lifestyleCard(icon: "moon.stars.fill", label: lp.sleepScheduleLabel)
                    lifestyleCard(icon: "sparkles", label: lp.cleanlinessLabel)
                }

                if let moveIn = lp.moveInMonth {
                    lifestyleCard(icon: "calendar", label: "Move in: \(moveIn)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let tags = lp.lifestyle, !tags.isEmpty {
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(tags, id: \.self) { tag in
                            pill(tag, hue: .neutral)
                        }
                    }
                }
            }
        }
    }

    private func lifestyleCard(icon: String, label: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(.purple, 500))
            Text(label)
                .font(.body14(.semiBold))
                .foregroundStyle(Color(.neutral, 800))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.neutral, 100))
        )
    }

    
    private func housingPreferencesSection(_ lp: RoommateListingProfile) -> some View {
        sectionBlock(title: "Housing Preferences") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if let budget = lp.maxBudget, budget > 0 {
                    preferenceRow(icon: "dollarsign.circle.fill", label: "Budget up to \(lp.formattedBudget)")
                }
                if let type = lp.propertyType {
                    preferenceRow(icon: "building.2.fill", label: type)
                }
                if let months = lp.leaseLengthMonths {
                    preferenceRow(icon: "clock.fill", label: "\(months) months lease")
                }
                if let amenities = lp.amenities, !amenities.isEmpty {
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(amenities, id: \.self) { a in
                            pill(a, hue: .green)
                        }
                    }
                }
            }
        }
    }

    private func preferenceRow(icon: String, label: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(.purple, 500))
                .frame(width: 24)
            Text(label)
                .font(.body14())
                .foregroundStyle(Color(.neutral, 700))
        }
    }

    

    private var contactButton: some View {
        AppButton(title: "Contact", variant: .primary) {
            
        }
    }

    

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(.neutral, 700))
                .frame(width: 36, height: 36)
                .background(Circle().fill(.white).shadow(color: .black.opacity(0.15), radius: 6, y: 2))
        }
        .padding(.top, 56)
        .padding(.leading, AppSpacing.lg)
    }



    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            PulseLoader()
            Text("Loading profile...")
                .font(.body14())
                .foregroundStyle(Color(.neutral, 500))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(Color(.neutral, 400))
            Text(message)
                .font(.body14())
                .foregroundStyle(Color(.neutral, 500))
                .multilineTextAlignment(.center)
            AppButton(title: "Retry", variant: .primary) {
                Task { await vm.load(clerk: clerk) }
            }
            .frame(width: 160)
        }
        .padding(.horizontal, AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }

 

    private func sectionBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title.uppercased())
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 500))
            content()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
    }

    private func pill(_ label: String, hue: AppHue) -> some View {
        Text(label)
            .font(.body14(.medium))
            .foregroundStyle(Color(hue, 700))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hue, 100))
            )
    }
}

#Preview {
    RoommateProfileView(userId: "fake-user-id-for-preview")
        .environment(Clerk.shared)
}
