import SwiftUI

struct ListingDetailSheet: View {
    let listing: ListingResponse
    @Environment(\.dismiss) private var dismiss

    private var rentValue: Int { Int(Double(listing.rent) ?? 0) }
    private var depositValue: Int? {
        guard let d = listing.securityDeposit else { return nil }
        return Int(Double(d) ?? 0)
    }
    private var isActive: Bool { listing.status == "active" }

    /// Builds a display string from whichever location fields are present.
    private var locationDisplay: String? {
        let parts = [listing.address, listing.city, listing.state]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                statusAndTitle
                priceSection
                if listing.propertyType != nil || listing.leaseTermMonths != nil || listing.availableDate != nil {
                    detailsGrid
                }
                if let amenities = listing.amenities, !amenities.isEmpty {
                    tagSection(title: "Amenities", items: amenities, hue: .purple)
                }
                if let rules = listing.rules, !rules.isEmpty {
                    tagSection(title: "House Rules", items: rules, hue: .red)
                }
                if let desc = listing.description, !desc.isEmpty {
                    descriptionSection(desc)
                }
                if let location = locationDisplay {
                    locationSection(location)
                }
            }
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color(.neutral, 100))
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(.neutral, 600))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    )
            }
            .padding(.trailing, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(.purple, 500), Color(.purple, 300), Color(.purple, 100)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .overlay(
                Image(systemName: iconForPropertyType(listing.propertyType))
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(.white.opacity(0.25))
            )
        }
    }

    // MARK: - Status & Title

    private var statusAndTitle: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                // status pill
                HStack(spacing: AppSpacing.xxs) {
                    Circle()
                        .fill(isActive ? Color(.green, 500) : Color(.neutral, 400))
                        .frame(width: 6, height: 6)
                    Text(listing.status.capitalized)
                        .font(.body12(.bold))
                        .foregroundStyle(isActive ? Color(.green, 700) : Color(.neutral, 600))
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .background(
                    Capsule()
                        .fill(isActive ? Color(.green, 100) : Color(.neutral, 200))
                )

                if let type = listing.propertyType {
                    Text(type)
                        .font(.body12(.medium))
                        .foregroundStyle(Color(.purple, 700))
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(Color(.purple, 100))
                        )
                }
            }

            Text(listing.title)
                .font(.h2(.bold))
                .foregroundStyle(Color(.neutral, 900))
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Price

    private var priceSection: some View {
        HStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("MONTHLY RENT")
                    .font(.body10(.semiBold))
                    .foregroundStyle(Color(.neutral, 500))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$\(rentValue)")
                        .font(.h2(.bold))
                        .foregroundStyle(Color(.purple, 500))
                    Text("/ mo")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 500))
                }
            }

            if let deposit = depositValue, deposit > 0 {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("DEPOSIT")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("$\(deposit)")
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }

    // MARK: - Details Grid

    private var detailsGrid: some View {
        let items: [(icon: String, label: String, value: String)] = {
            var arr: [(String, String, String)] = []
            if let type = listing.propertyType {
                arr.append(("building.2", "Property", type))
            }
            if let months = listing.leaseTermMonths {
                arr.append(("clock", "Lease", "\(months) months"))
            }
            if let dateStr = listing.availableDate {
                let formatted = formatDate(dateStr)
                arr.append(("calendar", "Available", formatted))
            }
            return arr
        }()

        return VStack(spacing: 0) {
            Divider()
                .padding(.vertical, AppSpacing.lg)

            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Rectangle()
                            .fill(Color(.neutral, 200))
                            .frame(width: 1, height: 40)
                    }

                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(.purple, 500))
                        Text(item.label)
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 500))
                        Text(item.value)
                            .font(.body14(.semiBold))
                            .foregroundStyle(Color(.neutral, 900))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Tag Sections

    private func tagSection(title: String, items: [String], hue: AppHue) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Divider()
                .padding(.top, AppSpacing.lg)

            Text(title.uppercased())
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 500))

            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(items, id: \.self) { item in
                    Text(item)
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
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Description

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Divider()
                .padding(.top, AppSpacing.lg)

            Text("DESCRIPTION")
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 500))

            Text(text)
                .font(.body14())
                .foregroundStyle(Color(.neutral, 700))
                .lineSpacing(4)
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Location

    private func locationSection(_ address: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Divider()
                .padding(.top, AppSpacing.lg)

            Text("LOCATION")
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 500))

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(.purple, 500))
                Text(address)
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 700))
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Helpers

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

    private func formatDate(_ iso: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        guard let date = isoFormatter.date(from: iso) else { return iso }
        let display = DateFormatter()
        display.dateFormat = "MMM d, yyyy"
        return display.string(from: date)
    }
}
