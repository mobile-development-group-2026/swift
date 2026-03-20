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

struct OnboardingStep2View: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // header
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("What's your")
                    .font(.h1(.bold))
                    .foregroundStyle(Color(.neutral, 900))
                Text("situation?")
                    .font(.h1(.bold))
                    .foregroundStyle(Color(.purple, 500))
                Text("Pick the one that matches where you are right now.")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 600))
                    .padding(.top, AppSpacing.xxs)
            }

            // cards
            VStack(spacing: AppSpacing.md) {
                ForEach(HousingSituation.allCases, id: \.self) { option in
                    let selected = vm.situation == option
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.situation = option
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            HStack(spacing: AppSpacing.sm) {
                                // radio
                                Circle()
                                    .fill(selected ? Color(.purple, 500) : .clear)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(selected ? Color(.purple, 500) : Color(.neutral, 400), lineWidth: 2)
                                    )

                                // icon
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(option.iconBackground)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: option.icon)
                                            .font(.system(size: 16))
                                            .foregroundStyle(option.iconColor)
                                    )

                                // title + subtitle
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.title)
                                        .font(.body16(.bold))
                                        .foregroundStyle(Color(.neutral, 900))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(option.subtitle)
                                        .font(.body12())
                                        .foregroundStyle(Color(.neutral, 600))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            Text(option.description)
                                .font(.body14())
                                .foregroundStyle(Color(.neutral, 600))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(AppSpacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selected ? Color(.purple, 400) : Color(.neutral, 500), lineWidth: selected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            // hint
            HStack(alignment: .top, spacing: AppSpacing.xs) {
                Image(systemName: "info.circle")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 500))
                Text("Switch or add modes anytime from your profile")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 500))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        Spacer()
    
    }
}
