import SwiftUI

struct ListingPreferencesView: View {
    @Bindable var vm: ListingPreferencesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Find your")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("next home")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                }

                budgetSection
                propertyTypeSection
                moveInLeaseSection
                distanceSection
                amenitiesSection
                preferencesSection

                // hint
                Text("You can change these filters anytime")
                    .font(.body12())
                    .foregroundStyle(Color(.neutral, 500))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    // MARK: - Budget

    private var budgetSection: some View {
        PreferenceSection(icon: "dollarsign.circle.fill", title: "MONTHLY BUDGET") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // display
                HStack {
                    Text("$\(vm.maxBudget ?? 0)")
                        .font(.h3(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Spacer()
                    Text("Up to $\(vm.maxBudget ?? 0) max per month")
                        .font(.body12())
                        .foregroundStyle(Color(.neutral, 500))
                }

                // chips
                HStack(spacing: AppSpacing.sm) {
                    ForEach(ListingPreferencesViewModel.budgetOptions, id: \.self) { amount in
                        let label = amount >= 1200 ? "$\(amount / 100 * 100)+" : "$\(amount)"
                        Button {
                            vm.maxBudget = amount
                        } label: {
                            Text(label)
                                .font(.body14(.medium))
                                .foregroundStyle(vm.maxBudget == amount ? Color(.purple, 700) : Color(.neutral, 700))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(vm.maxBudget == amount ? Color(.purple, 100) : .clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(vm.maxBudget == amount ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Property Type

    private var propertyTypeSection: some View {
        PreferenceSection(icon: "building.2.fill", title: "PROPERTY TYPE") {
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(ListingPreferencesViewModel.propertyTypes, id: \.label) { opt in
                    let selected = vm.propertyType == opt.label
                    Button {
                        vm.propertyType = vm.propertyType == opt.label ? nil : opt.label
                    } label: {
                        VStack(spacing: AppSpacing.xs) {
                            Text(opt.emoji)
                                .font(.system(size: 28))
                            Text(opt.label)
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.neutral, 900))
                            Text(opt.sub)
                                .font(.body10())
                                .foregroundStyle(Color(.neutral, 600))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected ? Color(.purple, 100) : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: selected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Move-in & Lease

    private var moveInLeaseSection: some View {
        PreferenceSection(icon: "calendar.circle.fill", title: "MOVE-IN & LEASE") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // move-in date
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Move-in date")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    DatePicker(
                        "",
                        selection: $vm.moveInDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .tint(Color(.purple, 500))
                }

                // lease length
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Lease length")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(ListingPreferencesViewModel.leaseOptions, id: \.self) { months in
                            Button {
                                vm.leaseLength = months
                            } label: {
                                Text("\(months) months")
                                    .font(.body14(.medium))
                                    .foregroundStyle(vm.leaseLength == months ? Color(.purple, 700) : Color(.neutral, 700))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(vm.leaseLength == months ? Color(.purple, 100) : .clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(vm.leaseLength == months ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Distance

    private var distanceSection: some View {
        PreferenceSection(icon: "location.circle.fill", title: "MAX DISTANCE TO CAMPUS") {
            HStack(spacing: AppSpacing.sm) {
                ForEach(ListingPreferencesViewModel.distanceOptions, id: \.value) { opt in
                    let selected = vm.maxDistance == opt.value
                    Button {
                        vm.maxDistance = vm.maxDistance == opt.value ? nil : opt.value
                    } label: {
                        Text(opt.label)
                            .font(.body14(.medium))
                            .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selected ? Color(.purple, 100) : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        PreferenceSection(icon: "star.fill", title: "MUST-HAVE AMENITIES") {
            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(ListingPreferencesViewModel.amenities, id: \.label) { opt in
                    let selected = vm.selectedAmenities.contains(opt.label)
                    Button {
                        vm.toggleAmenity(opt.label)
                    } label: {
                        VStack(spacing: AppSpacing.xs) {
                            Text(opt.emoji)
                                .font(.system(size: 22))
                            Text(opt.label)
                                .font(.body12(.medium))
                                .foregroundStyle(Color(.neutral, 900))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected ? Color(.purple, 100) : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: selected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        PreferenceSection(icon: "slider.horizontal.3", title: "YOUR PREFERENCES") {
            VStack(spacing: AppSpacing.sm) {
                ForEach(ListingPreferencesViewModel.preferences, id: \.label) { opt in
                    let selected = vm.selectedPreferences.contains(opt.label)
                    Button {
                        vm.togglePreference(opt.label)
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            Text(opt.emoji)
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(opt.label)
                                    .font(.body14(.semiBold))
                                    .foregroundStyle(Color(.neutral, 900))
                                Text(opt.sub)
                                    .font(.body12())
                                    .foregroundStyle(Color(.neutral, 600))
                            }
                            Spacer()
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(selected ? Color(.purple, 500) : Color(.neutral, 400))
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected ? Color(.purple, 50) : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: selected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
