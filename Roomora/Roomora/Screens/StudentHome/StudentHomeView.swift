import SwiftUI
import ClerkKit

struct StudentHomeView: View {
    @Environment(UserSession.self) private var session

    @State private var vm = StudentHomeViewModel()
    @State private var roommateVM = RoommateViewModel()
    @State private var selectedTab: HomeTab = .roommate
    @State private var activeNavTab: NavTab = .discover
    @State private var selectedListing: ListingResponse?
    @State private var showRoommateProfile = false

    private var hasPlace: Bool {
        session.profile?.housingSituation == "havePlace"
    }

    enum HomeTab: String, CaseIterable {
        case roommate = "Roommate"
        case housing = "Housing"
    }

    enum NavTab: String, CaseIterable {
        case discover = "Discover"
        case map = "Map"
        case favorites = "Favorites"
        case activity = "Activity"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .discover: "magnifyingglass.circle"
            case .map: "map"
            case .favorites: "star"
            case .activity: "bell"
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
            case .favorites:
                favoritesContent
            case .activity:
                activityContent
            case .profile:
                VStack {
                    Spacer()
                    AppButton(title: "Test Roommate Profile", variant: .primary) {
                        showRoommateProfile = true
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    Spacer()
                }
                .sheet(isPresented: $showRoommateProfile) {
                    RoommateProfileView(userId: "4bdce70a-cf28-4f97-a4ae-861c0954631b")
                        .environment(Clerk.shared)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomNav
        }
        .background(Color(.neutral, 100))
        .task {
            async let listings: () = vm.loadListings()
            async let applications: () = vm.loadMyApplications()
            async let favorites: () = vm.loadFavorites()
            async let roommates: () = roommateVM.loadRoommates()
            async let matches: () = vm.loadMatches()
            _ = await (listings, applications, favorites, roommates, matches)
            vm.syncProximityTrackingState()
        }
        .onChange(of: activeNavTab) { _, newTab in
            vm.syncProximityTrackingState()
            if newTab == .activity {
                Task {
                    async let matches: () = vm.loadMatches()
                    async let applications: () = vm.loadMyApplications()
                    _ = await (matches, applications)
                }
            } else if newTab == .favorites {
                Task { await vm.loadFavorites() }
            }
        }
        .sheet(item: $selectedListing) { listing in
            ListingDetailSheet(
                listing: listing,
                showApplyButton: !vm.applications.contains(where: { $0.listingId == listing.id }),
                initiallyFavorited: vm.isFavorited(listing.id),
                onApplicationSubmitted: { wasOffline in
                    if wasOffline {
                        vm.addLocalPendingApplication(for: listing)
                    } else {
                        Task { await vm.loadMyApplications() }
                    }
                },
                onFavoriteToggled: {
                    await vm.toggleFavorite(listing: listing)
                }
            )
        }
    }

    // MARK: - Discover Content

    private var discoverContent: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                topBar
                proximityTrackingBanner
                if !hasPlace {
                    tabPicker
                }
            }
            .background(Color(.neutral, 100))

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    if hasPlace || selectedTab == .roommate {
                        RoommateListView(vm: roommateVM)
                    } else if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppSpacing.xxl)
                    } else if vm.listings.isEmpty {
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "house")
                                .font(.system(size: 40))
                                .foregroundStyle(Color(.neutral, 300))
                            Text("No listings available")
                                .font(.body16(.semiBold))
                                .foregroundStyle(Color(.neutral, 500))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xxl)
                    } else {
                        listingsGrid
                    }
                }
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
            .refreshable {
                if hasPlace || selectedTab == .roommate {
                    await roommateVM.refresh()
                } else {
                    async let listings: () = vm.loadListings()
                    async let applications: () = vm.loadMyApplications()
                    _ = await (listings, applications)
                }
            }
        }
    }

    private var listingsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)],
            spacing: AppSpacing.md
        ) {
            ForEach(vm.listings) { listing in
                Button { selectedListing = listing } label: {
                    gridCard(listing)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
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

    private var proximityTrackingBanner: some View {
        HStack(alignment: .center, spacing: AppSpacing.sm) {
            Image(systemName: vm.pendingProximityEvents > 0 ? "antenna.radiowaves.left.and.right.slash" : "location.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(vm.pendingProximityEvents > 0 ? Color(.yellow, 700) : Color(.purple, 500))

            VStack(alignment: .leading, spacing: 2) {
                Text("Nearby-home detection")
                    .font(.body12(.semiBold))
                    .foregroundStyle(Color(.neutral, 800))
                Text(vm.pendingProximityEvents > 0 ? "\(vm.proximityStatusText). Events are stored locally until connection is back." : vm.proximityStatusText)
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 500))
            }

            Spacer()

            if vm.pendingProximityEvents > 0 {
                Text("\(vm.pendingProximityEvents)")
                    .font(.body10(.bold))
                    .foregroundStyle(Color(.yellow, 800))
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(.yellow, 100)))
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white))
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedTab == tab ? Color(.purple, 500) : Color.clear)
                    Text(tab.rawValue)
                        .font(.body16(.semiBold))
                        .foregroundStyle(selectedTab == tab ? .white : Color(.neutral, 600))
                        .padding(.vertical, 8)
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedTab = tab }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 44)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Activity

    private var activityContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("My")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("Activity")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)

                matchesSection

                if !hasPlace {
                    applicationsSection
                }
            }
            .padding(.bottom, AppSpacing.lg)
        }
        .refreshable {
            async let matches: () = vm.loadMatches()
            async let applications: () = vm.loadMyApplications()
            _ = await (matches, applications)
        }
    }

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("MATCHES")
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 500))
                .padding(.horizontal, AppSpacing.lg)

            if vm.isLoadingMatches {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else if vm.matches.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "heart")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(.neutral, 300))
                    Text("No matches yet")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("Like someone and wait for them to like you back.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 400))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
                .padding(.horizontal, AppSpacing.lg)
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(vm.matches) { match in
                        MatchCard(match: match)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }

    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("APPLICATIONS")
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 500))
                .padding(.horizontal, AppSpacing.lg)

            if vm.isLoadingApplications {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else if vm.applications.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(.neutral, 300))
                    Text("No applications yet")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("Browse listings and hit Apply Now to get started.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 400))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
                .padding(.horizontal, AppSpacing.lg)
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(vm.applications) { app in
                        Button {
                            if let listing = vm.listing(for: app) {
                                selectedListing = listing
                            }
                        } label: {
                            applicationCard(app)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }

    private func applicationCard(_ app: ApplicationResponse) -> some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: 3)
                .fill(statusColor(app.status))
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(app.listing?.title ?? "Listing")
                    .font(.body14(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                    .lineLimit(1)

                statusPill(app.status)

                if let visit = app.preferredVisitAt {
                    let isConfirmed = app.status == "approved"
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: isConfirmed ? "calendar.badge.checkmark" : "calendar")
                            .font(.system(size: 11))
                            .foregroundStyle(isConfirmed ? Color(.green, 500) : Color(.neutral, 400))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(isConfirmed ? "Visit confirmed" : "Requested visit")
                                .font(.body10(.semiBold))
                                .foregroundStyle(isConfirmed ? Color(.green, 600) : Color(.neutral, 500))
                            Text(formatDateTime(visit))
                                .font(.body12(.semiBold))
                                .foregroundStyle(isConfirmed ? Color(.green, 700) : Color(.neutral, 700))
                        }
                    }
                }

                if let notes = app.landlordNotes, !notes.isEmpty {
                    HStack(alignment: .top, spacing: AppSpacing.xxs) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(.neutral, 400))
                        Text(notes)
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 600))
                    }
                }

                Text("Applied \(formatDate(app.createdAt))")
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 400))
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private func statusPill(_ status: String) -> some View {
        let config: (label: String, fg: Int, bg: Int, hue: AppHue) = switch status {
        case "approved": ("Approved ✓", 700, 100, .green)
        case "denied":   ("Denied",     700, 100, .red)
        default:         ("Pending",    600, 200, .neutral)
        }

        return Text(config.label)
            .font(.body12(.semiBold))
            .foregroundStyle(Color(config.hue, config.fg))
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(Capsule().fill(Color(config.hue, config.bg)))
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "approved": Color(.green, 500)
        case "denied":   Color(.red, 500)
        default:         Color(.neutral, 300)
        }
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateFormat = "MMM d"
            return display.string(from: date)
        }
        return String(iso.prefix(10))
    }

    private func formatDateTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateFormat = "MMM d 'at' h:mm a"
            return display.string(from: date)
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateFormat = "MMM d 'at' h:mm a"
            return display.string(from: date)
        }
        return iso
    }

    // MARK: - Favorites

    private var favoritesContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("My")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("Favorites")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)

                if vm.isLoadingFavorites {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppSpacing.xxl)
                } else if vm.favoriteListings.isEmpty {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "star")
                            .font(.system(size: 44))
                            .foregroundStyle(Color(.neutral, 300))
                        Text("No favorites yet")
                            .font(.body16(.semiBold))
                            .foregroundStyle(Color(.neutral, 500))
                        Text("Tap the star on any listing to save it here.")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 400))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxl)
                    .padding(.horizontal, AppSpacing.lg)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)],
                        spacing: AppSpacing.md
                    ) {
                        ForEach(vm.favoriteListings) { listing in
                            Button { selectedListing = listing } label: {
                                gridCard(listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .padding(.bottom, AppSpacing.lg)
        }
        .refreshable {
            await vm.loadFavorites()
        }
    }

    // MARK: - Grid Card

    private func gridCard(_ listing: ListingResponse) -> some View {
        let rentValue = Int(Double(listing.rent) ?? 0)
        let favorited = vm.isFavorited(listing.id)

        return VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let urlString = listing.coverPhotoUrl, let url = URL(string: urlString) {
                    CachedAsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        gradientCardPlaceholder(listing.propertyType)
                    }
                    .frame(height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    gradientCardPlaceholder(listing.propertyType)
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if favorited {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.yellow, 500))
                        .padding(6)
                        .background(Circle().fill(.white.opacity(0.9)))
                        .padding(6)
                }
            }
            .padding(AppSpacing.sm)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$\(rentValue)")
                        .font(.body14(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("/ mo")
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 500))
                }

                Text(listing.title)
                    .font(.body12(.semiBold))
                    .foregroundStyle(Color(.neutral, 800))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let status = vm.applicationStatus(for: listing.id) {
                    statusPill(status)
                }

                Spacer(minLength: 0)

                if let city = listing.city {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "mappin")
                            .font(.system(size: 8))
                        Text(city)
                            .font(.body10())
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color(.neutral, 500))
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.bottom, AppSpacing.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(height: 270)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
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

    // MARK: - Helpers

    @ViewBuilder
    private func gradientCardPlaceholder(_ propertyType: String?) -> some View {
        LinearGradient(
            colors: [Color(.purple, 100), Color(.neutral, 200)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: iconForPropertyType(propertyType))
                .font(.system(size: 26))
                .foregroundStyle(Color(.purple, 300))
        )
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
}
