import SwiftUI

struct LandlordHomeView: View {
    @Environment(UserSession.self) private var session

    @State private var selectedTab: LandlordTab = .listings
    @State private var activeNavTab: LandlordNavTab = .dashboard

    enum LandlordTab: String, CaseIterable {
        case listings = "My Listings"
        case applications = "Applications"
    }

    enum LandlordNavTab: String, CaseIterable {
        case dashboard = "Dashboard"
        case listings = "Listings"
        case activity = "Activity"
        case messages = "Messages"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .dashboard: "square.grid.2x2"
            case .listings: "house"
            case .activity: "bell"
            case .messages: "bubble.left.and.bubble.right"
            case .profile: "person"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    topBar
                    statsRow
                    tabPicker

                    if selectedTab == .listings {
                        myListings
                    } else {
                        recentApplications
                    }
                }
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomNav
        }
        .background(Color(.neutral, 100))
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if let name = session.firstName {
                    Text("Hey, \(name) 👋")
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                }
                Text("Manage your properties")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 500))
            }

            Spacer()

            ProfileAvatar()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(MockLandlordData.stats, id: \.label) { stat in
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: stat.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(.purple, 500))
                    Text(stat.value)
                        .font(.body18(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text(stat.label)
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 500))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                )
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(LandlordTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.body14(.semiBold))
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

    // MARK: - My Listings

    private var myListings: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // add listing button
            Button {} label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Add new listing")
                        .font(.body14(.semiBold))
                }
                .foregroundStyle(Color(.purple, 500))
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.purple, 500), style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.lg)

            // listing cards
            ForEach(MockLandlordData.listings) { listing in
                listingCard(listing)
            }
        }
    }

    private func listingCard(_ listing: LandlordListing) -> some View {
        HStack(spacing: AppSpacing.md) {
            // thumbnail
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(.purple, 200), Color(.purple, 100)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: listing.imageSystemName)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(.purple, 400))
                )

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // status badge
                HStack(spacing: AppSpacing.xs) {
                    Text(listing.status.rawValue)
                        .font(.body10(.bold))
                        .foregroundStyle(listing.status == .active ? Color(.green, 700) : Color(.neutral, 600))
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(listing.status == .active ? Color(.green, 100) : Color(.neutral, 200))
                        )
                }

                Text(listing.title)
                    .font(.body14(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                    .lineLimit(1)

                Text(listing.type)
                    .font(.body12())
                    .foregroundStyle(Color(.neutral, 500))

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$\(listing.price)")
                        .font(.body16(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("/ \(listing.period)")
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 500))
                }
            }

            Spacer()

            // stats
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "eye")
                        .font(.system(size: 10))
                    Text("\(listing.views)")
                        .font(.body12())
                }
                .foregroundStyle(Color(.neutral, 500))

                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10))
                    Text("\(listing.applications)")
                        .font(.body12())
                }
                .foregroundStyle(Color(.purple, 500))
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Recent Applications

    private var recentApplications: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(MockLandlordData.recentApplications) { app in
                applicationCard(app)
            }
        }
    }

    private func applicationCard(_ app: TenantApplication) -> some View {
        HStack(spacing: AppSpacing.md) {
            // avatar placeholder
            Circle()
                .fill(Color(.purple, 100))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(app.name.prefix(1)))
                        .font(.body18(.bold))
                        .foregroundStyle(Color(.purple, 500))
                )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(app.name)
                        .font(.body14(.semiBold))
                        .foregroundStyle(Color(.neutral, 900))
                    if app.verified {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.purple, 500))
                    }
                }

                Text(app.university)
                    .font(.body12())
                    .foregroundStyle(Color(.neutral, 500))

                HStack(spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(app.moveIn)
                            .font(.body10())
                    }
                    .foregroundStyle(Color(.neutral, 500))

                    Text("\(app.compatibility)% match")
                        .font(.body10(.bold))
                        .foregroundStyle(Color(.green, 500))
                }
            }

            Spacer()

            // actions
            VStack(spacing: AppSpacing.xs) {
                Button {} label: {
                    Text("Review")
                        .font(.body12(.semiBold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.purple, 500))
                        )
                }

                Button {} label: {
                    Text("Decline")
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Bottom Nav

    private var bottomNav: some View {
        HStack {
            ForEach(LandlordNavTab.allCases, id: \.self) { tab in
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
