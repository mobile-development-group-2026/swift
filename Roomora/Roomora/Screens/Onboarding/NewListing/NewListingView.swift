import SwiftUI
import PhotosUI

struct NewListingView: View {
    @Bindable var vm: NewListingViewModel

    @State private var photoImages: [Image] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("New")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("listing")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                    Text("Fill in your property details. You can edit anytime before publishing.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 600))
                        .padding(.top, AppSpacing.xxs)
                }

                photosSection
                detailsSection
                locationSection
                roomsSection
                propertyTypeSection
                leaseSection
                amenitiesSection
                rulesSection
                descriptionSection
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    // MARK: - Photos

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionLabel("PHOTOS")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    // Multi-photo picker — first item = cover
                    PhotosPicker(
                        selection: $vm.selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        ZStack {
                            if let first = photoImages.first {
                                first
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(alignment: .topTrailing) {
                                        Text("Edit")
                                            .font(.body10(.semiBold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, AppSpacing.xs)
                                            .padding(.vertical, AppSpacing.xxxs)
                                            .background(Capsule().fill(Color(.purple, 500)))
                                            .padding(AppSpacing.xs)
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.neutral, 200))
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        VStack(spacing: AppSpacing.xs) {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color(.neutral, 400))
                                            Text("Cover photo")
                                                .font(.body12(.medium))
                                                .foregroundStyle(Color(.neutral, 500))
                                        }
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    // Additional thumbnails (photos 2–5)
                    ForEach(Array(photoImages.dropFirst().enumerated()), id: \.offset) { _, image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            Text("First photo is the cover · up to 5")
                .font(.body10())
                .foregroundStyle(Color(.neutral, 500))
        }
        .onChange(of: vm.selectedPhotos) {
            Task {
                var images: [Image] = []
                for item in vm.selectedPhotos {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        images.append(Image(uiImage: uiImage))
                    }
                }
                photoImages = images
            }
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionLabel("DETAILS")

            AppTextField(
                icon: "textformat",
                label: "PROPERTY TITLE",
                placeholder: "Lovely, quiet studio near cathedral",
                text: $vm.title
            )

            HStack(spacing: AppSpacing.md) {
                AppTextField(
                    icon: "dollarsign",
                    label: "MONTHLY RENT",
                    placeholder: "700",
                    text: $vm.monthlyRent,
                    keyboardType: .numberPad
                )

                AppTextField(
                    icon: "dollarsign",
                    label: "SECURITY DEPOSIT",
                    placeholder: "700",
                    text: $vm.securityDeposit,
                    keyboardType: .numberPad
                )
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionLabel("LOCATION")

            AppTextField(
                icon: "mappin.and.ellipse",
                label: "CITY *",
                placeholder: "Bogotá",
                text: $vm.city
            )

            AppTextField(
                icon: "map",
                label: "ADDRESS",
                placeholder: "Cra 7 #40-62, Apt 301",
                text: $vm.address
            )

            HStack(spacing: AppSpacing.md) {
                AppTextField(
                    icon: "flag",
                    label: "STATE / DEPT",
                    placeholder: "Cundinamarca",
                    text: $vm.state
                )
                AppTextField(
                    icon: "number",
                    label: "ZIP CODE",
                    placeholder: "110111",
                    text: $vm.zipCode,
                    keyboardType: .numberPad
                )
            }
        }
    }

    // MARK: - Rooms

    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionLabel("ROOMS")

            HStack(spacing: AppSpacing.md) {
                roomStepper(label: "BEDROOMS", value: $vm.bedrooms)
                roomStepper(label: "BATHROOMS", value: $vm.bathrooms)
            }
        }
    }

    private func roomStepper(label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 700))

            HStack(spacing: AppSpacing.md) {
                Button {
                    if value.wrappedValue > 1 { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.neutral, 600))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color(.neutral, 100)))
                }
                .buttonStyle(.plain)

                Text("\(value.wrappedValue)")
                    .font(.body16(.bold))
                    .foregroundStyle(Color(.neutral, 900))
                    .frame(minWidth: 24)

                Button {
                    if value.wrappedValue < 10 { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.purple, 500))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color(.purple, 100)))
                }
                .buttonStyle(.plain)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.neutral, 300), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Property Type

    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionLabel("PROPERTY TYPE")

            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(NewListingViewModel.propertyTypes, id: \.self) { type in
                    let selected = vm.propertyType == type
                    Button {
                        vm.propertyType = vm.propertyType == type ? nil : type
                    } label: {
                        Text(type)
                            .font(.body14(.medium))
                            .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected ? Color(.purple, 100) : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Lease & Available From

    private var leaseSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                // lease length
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("LEASE LENGTH")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))

                    Menu {
                        ForEach(NewListingViewModel.leaseOptions, id: \.self) { option in
                            Button(option) { vm.leaseLength = option }
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "clock")
                                .foregroundStyle(Color(.neutral, 500))
                                .font(.body16())
                            Text(vm.leaseLength)
                                .font(.body16())
                                .foregroundStyle(Color(.neutral, 900))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(.neutral, 500))
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.neutral, 500), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                // available from
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("AVAILABLE FROM")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))

                    DatePicker("", selection: $vm.availableFrom, displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color(.purple, 500))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.neutral, 500), lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionLabel("AMENITIES (OPTIONAL)")

            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(NewListingViewModel.amenities, id: \.self) { amenity in
                    let selected = vm.selectedAmenities.contains(amenity)
                    Button {
                        vm.toggleAmenity(amenity)
                    } label: {
                        Text(amenity)
                            .font(.body14(.medium))
                            .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected ? Color(.purple, 100) : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Rules

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionLabel("NON-NEGOTIABLE RULES (OPTIONAL)")

            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(NewListingViewModel.rules, id: \.self) { rule in
                    let selected = vm.selectedRules.contains(rule)
                    Button {
                        vm.toggleRule(rule)
                    } label: {
                        Text(rule)
                            .font(.body14(.medium))
                            .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected ? Color(.purple, 100) : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selected ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                sectionLabel("DESCRIPTION")
                Spacer()
                Text("\(vm.description.count) / \(vm.descriptionMinChars) min")
                    .font(.body10())
                    .foregroundStyle(
                        vm.description.count >= vm.descriptionMinChars
                            ? Color(.green, 500)
                            : Color(.neutral, 500)
                    )
            }

            AppTextField(
                icon: "",
                label: "",
                placeholder: "Describe your property — the neighbourhood, what makes it great, anything students should know…",
                text: $vm.description,
                isMultiline: true,
                minHeight: 100
            )
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.body10(.semiBold))
            .foregroundStyle(Color(.neutral, 700))
    }
}
