import SwiftUI

struct StudentHomeView: View {
    @Environment(UserSession.self) private var session

    @State private var vm = StudentHomeViewModel()
    @State private var selectedTab: HomeTab = .housing
    @State private var activeNavTab: NavTab = .discover
    @State private var selectedListing: ListingResponse?

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
                myApplicationsContent
            case .profile:
                Spacer()
                Text("Profile")
                    .font(.body16(.semiBold))
                    .foregroundStyle(Color(.neutral, 400))
                Spacer()
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
            _ = await (listings, applications, favorites)
            vm.syncProximityTrackingState()
        }
        .onChange(of: activeNavTab) { _, newTab in
            vm.syncProximityTrackingState()
            if newTab == .activity {
                Task { await vm.loadMyApplications() }
            } else if newTab == .favorites {
                Task { await vm.loadFavorites() }
            }
        }
        .sheet(item: $selectedListing) { listing in
            ListingDetailSheet(
                listing: listing,
                showApplyButton: !vm.applications.contains(where: { $0.listingId == listing.id }),
                initiallyFavorited: vm.isFavorited(listing.id),
                onApplicationSubmitted: {
                    Task { await vm.loadMyApplications() }
                },
                onFavoriteToggled: {
                    await vm.toggleFavorite(listing: listing)
                }
            )
        }
    }

    // MARK: - Discover Content

    private var discoverContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                topBar
                proximityTrackingBanner
                tabPicker

                if selectedTab == .roommate {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "person.2")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(.neutral, 300))
                        Text("No roommates available right now")
                            .font(.body16(.semiBold))
                            .foregroundStyle(Color(.neutral, 500))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxl)
                    .padding(.horizontal, AppSpacing.lg)
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
            .padding(.bottom, AppSpacing.lg)
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
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
        .padding(.horizontal, AppSpacing.lg)
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

    // MARK: - My Applications (Activity tab)

    private var myApplicationsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("My")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("Applications")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)

                if vm.isLoadingApplications {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppSpacing.xxl)
                } else if vm.applications.isEmpty {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 44))
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
                    .padding(.vertical, AppSpacing.xxl)
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
            .padding(.bottom, AppSpacing.lg)
        }
        .refreshable {
            await vm.loadMyApplications()
        }
    }

    private func applicationCard(_ app: ApplicationResponse) -> some View {
        HStack(spacing: AppSpacing.md) {
            // status indicator stripe
            RoundedRectangle(cornerRadius: 3)
                .fill(statusColor(app.status))
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // listing title
                Text(app.listing?.title ?? "Listing")
                    .font(.body14(.semiBold))
                    .foregroundStyle(Color(.neutral, 900))
                    .lineLimit(1)

                // status pill
                statusPill(app.status)

                // preferred / confirmed visit datetime
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

                // landlord notes (shown after review)
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

                // date applied
                Text("Applied \(formatDate(app.createdAt))")
                    .font(.body10())
                    .foregroundStyle(Color(.neutral, 400))
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
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
            .background(
                Capsule().fill(Color(config.hue, config.bg))
            )
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
        // fallback: try without fractional seconds (e.g. "2026-04-24T16:17:00Z")
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
            // cover image
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

            // fixed-height content area — top-aligned so cards are uniform
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
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
