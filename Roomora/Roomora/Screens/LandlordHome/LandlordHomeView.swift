import SwiftUI
import ClerkKit

struct LandlordHomeView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = LandlordHomeViewModel()
    @State private var selectedTab: LandlordTab = .listings
    @State private var activeNavTab: LandlordNavTab = .dashboard
    @State private var selectedListing: ListingResponse?
    @State private var showCreateListing = false

    enum LandlordTab: String, CaseIterable {
        case listings = "My Listings"
        case applications = "Applications"
    }

    enum LandlordNavTab: String, CaseIterable {
        case dashboard = "Dashboard"
        case messages = "Messages"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .dashboard: "square.grid.2x2"
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
            await vm.loadApplications(clerk: clerk)
        }
        .sheet(item: $selectedListing) { listing in
            ListingDetailSheet(listing: listing)
        }
        .fullScreenCover(isPresented: $showCreateListing) {
            CreateListingSheet { newListing in
                vm.listings.insert(newListing, at: 0)
            }
            .environment(Clerk.shared)
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

    private var totalViews: Int {
        vm.listings.reduce(0) { $0 + ($1.viewsCount ?? 0) }
    }

    private var totalStars: Int {
        vm.listings.reduce(0) { $0 + ($1.favoritesCount ?? 0) }
    }

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            statCard(icon: "eye.fill", value: "\(totalViews)", label: "Views")
            statCard(icon: "doc.text.fill", value: "\(vm.applications.count)", label: "Applications")
            statCard(icon: "house.fill", value: "\(vm.listings.count)", label: "Listings")
            statCard(icon: "star.fill", value: "\(totalStars)", label: "Stars")
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
            Button { showCreateListing = true } label: {
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
        let stars = listing.favoritesCount ?? 0

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

            VStack(spacing: AppSpacing.xxs) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.yellow, 400))
                Text("\(stars)")
                    .font(.body12(.bold))
                    .foregroundStyle(Color(.neutral, 700))
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
            if vm.isLoadingApplications {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xl)
            } else if vm.applications.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(.neutral, 300))
                    Text("No applications yet")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("Students will appear here once they apply for your listings.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 400))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
                .padding(.horizontal, AppSpacing.lg)
            } else {
                ForEach(vm.applications) { app in
                    applicationCard(app)
                }
            }
        }
    }

    private func applicationCard(_ app: ApplicationResponse) -> some View {
        let name = app.student?.fullName ?? "Applicant"
        let initial = String(name.prefix(1))
        let isVerified = app.student?.verified ?? false
        let isPending = app.status == "pending"

        return HStack(spacing: AppSpacing.md) {
            // avatar
            Circle()
                .fill(Color(.purple, 100))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(initial)
                        .font(.body18(.bold))
                        .foregroundStyle(Color(.purple, 500))
                )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(name)
                        .font(.body14(.semiBold))
                        .foregroundStyle(Color(.neutral, 900))
                    if isVerified {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.purple, 500))
                    }
                }

                // listing title
                if let title = app.listing?.title {
                    Text(title)
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                        .lineLimit(1)
                }

                // status or visit date
                HStack(spacing: AppSpacing.xs) {
                    statusPill(app.status)

                    if let visit = app.preferredVisitAt {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(formatDate(visit))
                                .font(.body10())
                        }
                        .foregroundStyle(Color(.neutral, 500))
                    }
                }

                if let notes = app.studentNotes, !notes.isEmpty {
                    Text(notes)
                        .font(.body10())
                        .foregroundStyle(Color(.neutral, 500))
                        .lineLimit(1)
                }
            }

            Spacer()

            // approve / deny — only for pending
            if isPending {
                VStack(spacing: AppSpacing.xs) {
                    Button {
                        Task { await vm.updateApplication(clerk: clerk, id: app.id, status: "approved", notes: nil) }
                    } label: {
                        Text("Approve")
                            .font(.body12(.semiBold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.green, 500))
                            )
                    }

                    Button {
                        Task { await vm.updateApplication(clerk: clerk, id: app.id, status: "denied", notes: nil) }
                    } label: {
                        Text("Deny")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 500))
                    }
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

    private func statusPill(_ status: String) -> some View {
        let (label, fg, bg): (String, AppHue, AppHue) = switch status {
        case "approved": ("Approved", .green, .green)
        case "denied":   ("Denied",   .red,   .red)
        default:         ("Pending",  .neutral, .neutral)
        }

        return Text(label)
            .font(.body10(.bold))
            .foregroundStyle(Color(fg, fg == .neutral ? 600 : 700))
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(Color(bg, bg == .neutral ? 200 : 100))
            )
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateFormat = "MMM d, HH:mm"
            return display.string(from: date)
        }
        // fallback: strip to first 10 chars (yyyy-MM-dd)
        return String(iso.prefix(10))
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
