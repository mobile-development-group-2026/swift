import SwiftUI

struct StudentHomeView: View {
    @Environment(UserSession.self) private var session

    @State private var selectedTab: HomeTab = .roommate
    @State private var activeNavTab: NavTab = .discover

    enum HomeTab: String, CaseIterable {
        case roommate = "Roommate"
        case housing = "Housing"
    }

    enum NavTab: String, CaseIterable {
        case discover = "Discover"
        case map = "Map"
        case activity = "Activity"
        case messages = "Messages"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .discover: "sparkle.magnifyingglass"
            case .map: "map"
            case .activity: "bell"
            case .messages: "bubble.left.and.bubble.right"
            case .profile: "person"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            switch activeNavTab {
            case .discover:
                discoverContent
            case .map:
                ListingsMapView()
            default:
                Spacer()
                Text(activeNavTab.rawValue)
                    .font(.body16(.semiBold))
                    .foregroundStyle(Color(.neutral, 400))
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomNav
        }
        .background(Color(.neutral, 100))
    }

    // MARK: - Discover Content

    private var discoverContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                topBar
                tabPicker
                listingsHeader
                featuredCard
                moreNearYou
            }
            .padding(.bottom, AppSpacing.lg)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if let name = session.firstName {
                    Text("Hey, \(name) 👋")
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                } else {
                    Text("Hey there 👋")
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                }
            }

            Spacer()

            ProfileAvatar()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.body16(.semiBold))
                        .foregroundStyle(selectedTab == tab ? .white : Color(.neutral, 600))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? Color(.purple, 500) : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Listings Header

    private var listingsHeader: some View {
        HStack {
            Text("Listings near campus")
                .font(.body16(.semiBold))
                .foregroundStyle(Color(.neutral, 900))

            // count badge
            Text("\(MockListings.availableCount)")
                .font(.body12(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxs)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.purple, 500))
                )

            Text("available")
                .font(.body12())
                .foregroundStyle(Color(.neutral, 500))

            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Featured Card

    private var featuredCard: some View {
        let listing = MockListings.featured

        return VStack(alignment: .leading, spacing: 0) {
            // image area
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(.purple, 200), Color(.purple, 100)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: listing.imageSystemName)
                            .font(.system(size: 48))
                            .foregroundStyle(Color(.purple, 400))
                    )

                // badges
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    if listing.isVerifiedLandlord {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 10))
                            Text("Verified landlord")
                                .font(.body10(.semiBold))
                        }
                        .foregroundStyle(Color(.purple, 700))
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(
                            Capsule().fill(Color(.purple, 100))
                        )
                    }

                    // price
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$\(listing.price)")
                            .font(.h3(.bold))
                            .foregroundStyle(Color(.neutral, 900))
                        Text("/ \(listing.period)")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 500))
                    }
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.9))
                    )
                }
                .padding(AppSpacing.md)

                // flash sale
                if let sale = listing.flashSale {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(sale)
                                .font(.body10(.semiBold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, AppSpacing.xs)
                                .background(
                                    Capsule().fill(Color(.purple, 600))
                                )
                                .padding(AppSpacing.md)
                        }
                    }
                    .frame(height: 200)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // details
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(listing.title)
                    .font(.body16(.bold))
                    .foregroundStyle(Color(.neutral, 900))

                HStack(spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(listing.location)
                            .font(.body12())
                    }
                    .foregroundStyle(Color(.neutral, 600))

                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 10))
                        Text(listing.distance)
                            .font(.body12())
                    }
                    .foregroundStyle(Color(.neutral, 600))
                }

                // type & size
                if let size = listing.size {
                    Text("\(listing.type) · \(size)")
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                }

                // amenities
                HStack(spacing: AppSpacing.xs) {
                    ForEach(listing.amenities, id: \.self) { amenity in
                        Text(amenity)
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 700))
                            .padding(.horizontal, AppSpacing.xs)
                            .padding(.vertical, AppSpacing.xxs)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.neutral, 100))
                            )
                    }
                }

                // compatibility + actions
                HStack {
                    if let compat = listing.compatibility {
                        HStack(spacing: AppSpacing.xs) {
                            Text("Compatibility")
                                .font(.body12())
                                .foregroundStyle(Color(.neutral, 600))
                            Text("\(compat)%")
                                .font(.body16(.bold))
                                .foregroundStyle(Color(.green, 500))
                        }
                    }

                    Spacer()

                    HStack(spacing: AppSpacing.sm) {
                        Button {} label: {
                            Text("Schedule visit")
                                .font(.body12(.semiBold))
                                .foregroundStyle(Color(.purple, 500))
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.purple, 500), lineWidth: 1)
                                )
                        }

                        Button {} label: {
                            Text("Apply now")
                                .font(.body12(.semiBold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.purple, 500))
                                )
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - More Near You

    private var moreNearYou: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("More near you")
                    .font(.body16(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                Spacer()
                Button {
                } label: {
                    Text("See all")
                        .font(.body14(.semiBold))
                        .foregroundStyle(Color(.purple, 500))
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(MockListings.nearby) { listing in
                        nearbyCard(listing)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }

    private func nearbyCard(_ listing: MockListing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // image
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(.purple, 100), Color(.neutral, 200)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: listing.imageSystemName)
                            .font(.system(size: 28))
                            .foregroundStyle(Color(.purple, 300))
                    )

                // tag
                if let tag = listing.tags.first {
                    Text(tag.label)
                        .font(.body10(.bold))
                        .foregroundStyle(tag == .hot ? .white : Color(.purple, 700))
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxxs)
                        .background(
                            Capsule()
                                .fill(tag == .hot ? Color(.red, 500) : Color(.purple, 100))
                        )
                        .padding(AppSpacing.xs)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // price
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$\(listing.price)")
                        .font(.body16(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("/ \(listing.period)")
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 500))
                }

                Text(listing.title)
                    .font(.body12(.semiBold))
                    .foregroundStyle(Color(.neutral, 800))
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 8))
                    Text(listing.distance)
                        .font(.body10())
                }
                .foregroundStyle(Color(.neutral, 500))

                Text(listing.moveIn)
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 500))

                Text(listing.leaseTerm)
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 500))

                // amenities
                FlowLayout(spacing: 4) {
                    ForEach(listing.amenities, id: \.self) { amenity in
                        Text(amenity)
                            .font(.body10())
                            .foregroundStyle(Color(.neutral, 600))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.neutral, 100))
                            )
                    }
                }
            }
            .padding(AppSpacing.sm)
        }
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Bottom Nav

    private var bottomNav: some View {
        HStack {
            ForEach(NavTab.allCases, id: \.self) { tab in
                Button {
                    activeNavTab = tab
                } label: {
                    VStack(spacing: AppSpacing.xxs) {
                        Image(systemName: activeNavTab == tab ? tab.icon + ".fill" : tab.icon)
                            .font(.system(size: 20))
                        Text(tab.rawValue)
                            .font(.body10())
                    }
                    .foregroundStyle(activeNavTab == tab ? Color(.purple, 500) : Color(.neutral, 500))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, AppSpacing.sm)
        .background(.white)
        .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
    }
}
