import SwiftUI
import ClerkKit

struct LandlordHomeView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = LandlordHomeViewModel()
    @State private var selectedTab: LandlordTab = .listings
    @State private var activeNavTab: LandlordNavTab = .dashboard
    @State private var selectedListing: ListingResponse?

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
        .task {
            await vm.loadListings(clerk: clerk)
        }
        .sheet(item: $selectedListing) { listing in
            ListingDetailSheet(listing: listing)
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
            statCard(icon: "eye.fill", value: "—", label: "Views")
            statCard(icon: "doc.text.fill", value: "—", label: "Applications")
            statCard(icon: "house.fill", value: "\(vm.listings.count)", label: "Listings")
            statCard(icon: "star.fill", value: "—", label: "Rating")
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(.purple, 500))
            Text(value)
                .font(.body18(.bold))
                .foregroundStyle(Color(.neutral, 900))
            Text(label)
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

            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xl)
            } else if vm.listings.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "house")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(.neutral, 300))
                    Text("No listings yet")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("Create your first listing to start receiving applications.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 400))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
                .padding(.horizontal, AppSpacing.lg)
            } else {
                ForEach(vm.listings, id: \.id) { listing in
                    Button {
                        selectedListing = listing
                    } label: {
                        listingCard(listing)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func listingCard(_ listing: ListingResponse) -> some View {
        let rentValue = Int(Double(listing.rent) ?? 0)
        let isActive = listing.status == "active"
        let icon = iconForPropertyType(listing.propertyType)

        return HStack(spacing: AppSpacing.md) {
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
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(.purple, 400))
                )

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // status badge
                Text(listing.status.capitalized)
                    .font(.body10(.bold))
                    .foregroundStyle(isActive ? Color(.green, 700) : Color(.neutral, 600))
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isActive ? Color(.green, 100) : Color(.neutral, 200))
                    )

                Text(listing.title)
                    .font(.body14(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                    .lineLimit(1)

                if let type = listing.propertyType {
                    Text(type)
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$\(rentValue)")
                        .font(.body16(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("/ mo")
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 500))
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, AppSpacing.lg)
    }

    private func iconForPropertyType(_ type: String?) -> String {
        switch type {
        case "Studio", "studio": return "building.2.fill"
        case "1 bedroom", "apartment": return "building.fill"
        case "2 bedrooms": return "building.fill"
        case "3+ bedrooms", "house": return "house.lodge.fill"
        case "Shared room", "room": return "person.2.fill"
        default: return "house.fill"
        }
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
