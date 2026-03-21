import SwiftUI
import PhotosUI

struct NewListingView: View {
    @Bindable var vm: NewListingViewModel

    @State private var coverPhoto: Image?
    @State private var photoPickerItem: PhotosPickerItem?

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

            HStack(spacing: AppSpacing.md) {
                // cover photo
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    ZStack {
                        if let photo = coverPhoto {
                            photo
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

                // add more button
                Button {} label: {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundStyle(Color(.neutral, 400))
                        .frame(width: 80, height: 140)
                        .overlay(
                            VStack(spacing: AppSpacing.xs) {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(Color(.neutral, 500))
                            }
                        )
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text("First photo is the cover")
                .font(.body10())
                .foregroundStyle(Color(.neutral, 500))
        }
        .onChange(of: photoPickerItem) {
            Task {
                if let data = try? await photoPickerItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    coverPhoto = Image(uiImage: uiImage)
                }
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
            sectionLabel("AMENITIES")

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
            sectionLabel("NON-NEGOTIABLE RULES")

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
