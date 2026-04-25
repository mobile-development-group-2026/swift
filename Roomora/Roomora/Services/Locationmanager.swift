//
//  Locationmanager.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation
import CoreLocation
import Combine
import Network
import ClerkKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var currentLocation: CLLocation?
    @Published var accuracyAuthorization: CLAccuracyAuthorization?
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 15
        manager.pausesLocationUpdatesAutomatically = true
    }

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}

// MARK: - Connectivity monitoring

final class ConnectivityMonitor {
    static let shared = ConnectivityMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "roomora.connectivity.monitor")

    @Published private(set) var isConnected = true
    @Published private(set) var isExpensive = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
            }
        }
        monitor.start(queue: queue)
    }
}

// MARK: - Proximity tracking domain

struct ProximityVisitEvent: Codable, Identifiable, Hashable {
    let id: String
    let listingId: String
    let listingTitle: String
    let sector: String
    let city: String
    let enteredRadiusAt: Date
    let eventDay: String
    let radiusMeters: Double
    let latitude: Double
    let longitude: Double
    var syncedAt: Date?
    var attempts: Int
}

struct SectorInterestAnalytics: Codable, Hashable, Identifiable {
    let id: String
    let sector: String
    let interestLevel: String
    let uniqueVisitors: Int
    let visitCount: Int
    let averageDailyTraffic: Double
}

struct HourlyTrafficAnalytics: Codable, Hashable, Identifiable {
    var id: Int { hour }
    let hour: Int
    let visits: Int
}

struct DailyTrafficAnalytics: Codable, Hashable, Identifiable {
    let id: String
    let day: String
    let visits: Int
}

struct ProximityAnalyticsResponse: Codable {
    let sectorAnalytics: [SectorInterestAnalytics]
    let hourlyPeaks: [HourlyTrafficAnalytics]
    let dailyPeaks: [DailyTrafficAnalytics]
    let totalVisits: Int
    let uniqueSectors: Int
    let lastSyncedAt: String?
}

private struct ProximityListingTarget: Hashable {
    let id: String
    let title: String
    let sector: String
    let city: String
    let coordinate: CLLocationCoordinate2D

    init?(listing: ListingResponse) {
        guard let latitude = listing.latitude, let longitude = listing.longitude else { return nil }
        self.id = listing.id
        self.title = listing.title
        self.city = listing.city ?? "Unknown city"
        self.sector = ProximitySectorResolver.resolve(address: listing.address, city: listing.city)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ProximityTrackingStatus: Equatable {
    case idle
    case disabled
    case tracking
    case syncPending(Int)
    case syncing(Int)
    case failed(String)

    var label: String {
        switch self {
        case .idle: return "Idle"
        case .disabled: return "Location permission required"
        case .tracking: return "Tracking visits"
        case .syncPending(let count): return "Pending sync: \(count)"
        case .syncing(let count): return "Syncing \(count) event(s)"
        case .failed(let message): return message
        }
    }
}

enum ProximitySectorResolver {
    static func resolve(address: String?, city: String?) -> String {
        let trimmed = (address ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if trimmed.count >= 2, !trimmed[1].isEmpty { return trimmed[1] }
        if let first = trimmed.first, !first.isEmpty { return String(first) }
        if let city, !city.isEmpty { return city }
        return "Unknown sector"
    }
}

final class ProximityEventStore {
    static let shared = ProximityEventStore()

    private let defaults = UserDefaults.standard
    private let queueKey = "roomora.proximity.queue"
    private let lastEntryKey = "roomora.proximity.lastEntryByListing"

    private init() {}

    func allEvents() -> [ProximityVisitEvent] {
        guard let data = defaults.data(forKey: queueKey),
              let events = try? JSONDecoder().decode([ProximityVisitEvent].self, from: data) else {
            return []
        }
        return events.sorted { $0.enteredRadiusAt < $1.enteredRadiusAt }
    }

    func pendingEvents() -> [ProximityVisitEvent] {
        allEvents().filter { $0.syncedAt == nil }
    }

    func save(_ events: [ProximityVisitEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            defaults.set(data, forKey: queueKey)
        }
    }

    func append(_ event: ProximityVisitEvent) {
        var events = allEvents()
        events.append(event)
        save(events)
    }

    func markSynced(ids: [String], at date: Date = Date()) {
        var events = allEvents()
        events = events.map { event in
            guard ids.contains(event.id) else { return event }
            var updated = event
            updated.syncedAt = date
            return updated
        }
        save(events)
    }

    func incrementAttempts(ids: [String]) {
        var events = allEvents()
        events = events.map { event in
            guard ids.contains(event.id) else { return event }
            var updated = event
            updated.attempts += 1
            return updated
        }
        save(events)
    }

    func lastEntryMap() -> [String: Date] {
        guard let data = defaults.data(forKey: lastEntryKey),
              let raw = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return raw
    }

    func setLastEntry(_ date: Date, for listingId: String) {
        var map = lastEntryMap()
        map[listingId] = date
        if let data = try? JSONEncoder().encode(map) {
            defaults.set(data, forKey: lastEntryKey)
        }
    }
}

@MainActor
final class StudentProximityTracker: ObservableObject {
    static let shared = StudentProximityTracker()

    @Published private(set) var status: ProximityTrackingStatus = .idle
    @Published private(set) var pendingEventsCount: Int = 0

    private let radiusMeters: CLLocationDistance = 250000000
    private let cooldownSeconds: TimeInterval = 30
    private var targets: [ProximityListingTarget] = []
    private var insideRadius: Set<String> = []
    private var cancellables = Set<AnyCancellable>()
    private var hasStarted = false

    private init() {
        LocationManager.shared.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                Task { @MainActor in
                    await self?.processLocationUpdate(location)
                }
            }
            .store(in: &cancellables)

        ConnectivityMonitor.shared.$isConnected
            .removeDuplicates()
            .sink { [weak self] connected in
                guard connected else { return }
                Task { @MainActor in
                    await self?.flushPendingEventsIfPossible(clerk: Clerk.shared)
                }
            }
            .store(in: &cancellables)

        refreshPendingCount()
    }

    func configure(with listings: [ListingResponse]) {
        targets = listings.compactMap(ProximityListingTarget.init)
        refreshPendingCount()
    }

    func start(clerk: Clerk) {
        hasStarted = true
        let status = LocationManager.shared.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            LocationManager.shared.startUpdatingLocation()
            self.status = pendingEventsCount > 0 ? .syncPending(pendingEventsCount) : .tracking
            Task { await flushPendingEventsIfPossible(clerk: clerk) }
        } else {
            LocationManager.shared.requestPermissions()
            self.status = .disabled
        }
    }

    private func refreshPendingCount() {
        pendingEventsCount = ProximityEventStore.shared.pendingEvents().count
    }

    private func processLocationUpdate(_ location: CLLocation) async {
        guard hasStarted, !targets.isEmpty else { return }

        var nowInside = Set<String>()
        let now = Date()
        let lastEntryMap = ProximityEventStore.shared.lastEntryMap()

        for target in targets {
            let targetLocation = CLLocation(latitude: target.coordinate.latitude, longitude: target.coordinate.longitude)
            let distance = location.distance(from: targetLocation)
            let isInside = distance <= radiusMeters
            if isInside { nowInside.insert(target.id) }

            let justEntered = isInside && !insideRadius.contains(target.id)
            guard justEntered else { continue }

            let lastEntry = lastEntryMap[target.id]
            let isCoolingDown = lastEntry.map { now.timeIntervalSince($0) < cooldownSeconds } ?? false
            guard !isCoolingDown else { continue }

            let event = ProximityVisitEvent(
                id: UUID().uuidString,
                listingId: target.id,
                listingTitle: target.title,
                sector: target.sector,
                city: target.city,
                enteredRadiusAt: now,
                eventDay: Self.eventDayFormatter.string(from: now),
                radiusMeters: radiusMeters,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                syncedAt: nil,
                attempts: 0
            )

            ProximityEventStore.shared.append(event)
            ProximityEventStore.shared.setLastEntry(now, for: target.id)
        }

        insideRadius = nowInside
        refreshPendingCount()
        status = pendingEventsCount > 0 ? .syncPending(pendingEventsCount) : .tracking
        await flushPendingEventsIfPossible(clerk: Clerk.shared)
    }

    func flushPendingEventsIfPossible(clerk: Clerk) async {
        let pending = ProximityEventStore.shared.pendingEvents()
        refreshPendingCount()

        guard !pending.isEmpty else {
            status = hasStarted ? .tracking : .idle
            return
        }

        guard ConnectivityMonitor.shared.isConnected else {
            status = .syncPending(pending.count)
            return
        }

        status = .syncing(pending.count)

        do {
            try await APIClient.shared.trackProximityEvents(clerk: clerk, events: pending)
            ProximityEventStore.shared.markSynced(ids: pending.map(\.id))
            refreshPendingCount()
            status = .tracking
        } catch {
            ProximityEventStore.shared.incrementAttempts(ids: pending.map(\.id))
            refreshPendingCount()
            status = .syncPending(pendingEventsCount)
        }
    }

    private static let eventDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
