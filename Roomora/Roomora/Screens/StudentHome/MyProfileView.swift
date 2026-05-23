//
//  MyProfileView.swift
//  Roomora
//
//  Created by Andy on 23/05/26.
//


import SwiftUI
import ClerkKit
import PhotosUI

struct MyProfileView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = MyProfileViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero / avatar
                heroSection

                VStack(alignment: .leading, spacing: 0) {
                    buildProfileSection
                    lifestyleSection
                    situationSection
                }
                .background(.white)

                // Save button
                AppButton(
                    title: vm.isSaving ? "Saving..." : "Save Changes",
                    variant: .primary
                ) {
                    Task { await vm.save(clerk: clerk, session: session) }
                }
                .disabled(vm.isSaving)
                .opacity(vm.isSaving ? 0.6 : 1)
                .padding(AppSpacing.lg)

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.body12())
                        .foregroundStyle(.red)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.md)
                }

                if vm.saveSuccess {
                    Text("✓ Profile updated")
                        .font(.body12(.semiBold))
                        .foregroundStyle(Color(.green, 600))
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.md)
                }
            }
        }
        .background(Color(.neutral, 100))
        .onAppear { vm.populate(from: session.profile) }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: [Color(.purple, 800), Color(.purple, 500)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)

            // Avatar picker
            PhotosPicker(selection: $vm.photoPickerItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let photo = vm.profilePhoto {
                            photo.resizable().scaledToFill()
                        } else if let urlString = session.profile?.avatarUrl,
                                  let url = URL(string: urlString) {
                            CachedAsyncImage(url: url) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                initialsCircle
                            }
                        } else {
                            initialsCircle
                        }
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 3))

                    Circle()
                        .fill(Color(.purple, 500))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                        )
                }
            }
            .offset(y: 45)
        }
        .padding(.bottom, 45)
        .onChange(of: vm.photoPickerItem) {
            Task {
                if let data = try? await vm.photoPickerItem?.loadTransferable(type: Data.self) {
                    vm.savePhoto(data: data)
                }
            }
        }
    }

    private var initialsCircle: some View {
        Circle()
            .fill(Color(.purple, 300))
            .overlay(
                Text(session.profile.map { "\($0.firstName.prefix(1))\($0.lastName.prefix(1))" } ?? "?")
                    .font(.h2(.bold))
                    .foregroundStyle(.white)
            )
    }

    // MARK: - Build Profile Section

    private var buildProfileSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(icon: "person.fill", title: "Profile")

            VStack(spacing: AppSpacing.md) {
                // University
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("UNIVERSITY")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    Menu {
                        ForEach(BuildYourProfileViewModel.universities, id: \.self) { uni in
                            Button(uni) { vm.university = uni }
                        }
                    } label: {
                        menuRow(icon: "building.columns", value: vm.university, placeholder: "Select university")
                    }
                    .buttonStyle(.plain)
                }

                // Major
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("MAJOR")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    Menu {
                        ForEach(BuildYourProfileViewModel.majors, id: \.self) { major in
                            Button(major) { vm.major = major }
                        }
                    } label: {
                        menuRow(icon: "book", value: vm.major, placeholder: "Select major")
                    }
                    .buttonStyle(.plain)
                }

                // Bio
                AppTextField(
                    icon: "",
                    label: "BIO",
                    placeholder: "Tell us about yourself...",
                    text: $vm.bio,
                    isMultiline: true,
                    minHeight: 80
                )

                // Hobbies
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text("HOBBIES")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        Spacer()
                        Text("\(vm.selectedHobbies.count)/5")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 500))
                    }
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(BuildYourProfileViewModel.hobbies, id: \.self) { hobby in
                            let selected = vm.selectedHobbies.contains(hobby)
                            Button {
                                vm.toggleHobby(hobby)
                            } label: {
                                Text(hobby)
                                    .font(.body12(.medium))
                                    .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                                    .padding(.horizontal, AppSpacing.sm)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selected ? Color(.purple, 100) : Color(.neutral, 100))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(selected ? Color(.purple, 400) : Color(.neutral, 300), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(.white)
    }

    // MARK: - Lifestyle Section

    private var lifestyleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            sectionHeader(icon: "heart.fill", title: "Lifestyle")

            VStack(spacing: AppSpacing.lg) {
                // Sleep schedule
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("SLEEP SCHEDULE")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    HStack(spacing: AppSpacing.sm) {
                        ForEach([
                            (0, "🌅", "Early bird"),
                            (1, "🦉", "Night owl"),
                            (2, "😴", "Flexible")
                        ], id: \.0) { val, emoji, label in
                            optionCard(emoji: emoji, label: label, selected: vm.sleepSchedule == val) {
                                vm.sleepSchedule = val
                            }
                        }
                    }
                }

                // Cleanliness
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("CLEANLINESS")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    HStack(spacing: AppSpacing.sm) {
                        ForEach([
                            (0, "✨", "Tidy"),
                            (1, "🧼", "Moderate"),
                            (2, "😌", "Relaxed")
                        ], id: \.0) { val, emoji, label in
                            optionCard(emoji: emoji, label: label, selected: vm.cleanliness == val) {
                                vm.cleanliness = val
                            }
                        }
                    }
                }

                // Gender preference
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("GENDER PREFERENCE")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach([
                            (0, "No preference"),
                            (1, "Same as me"),
                            (2, "Women only"),
                            (3, "Men only")
                        ], id: \.0) { val, label in
                            selectableChip(label, selected: vm.genderPreference == val) {
                                vm.genderPreference = val
                            }
                        }
                    }
                }

                // Lifestyle tags
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("YOUR LIFESTYLE")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach([
                            ("🚭", "Non-smoker"),
                            ("🐾", "Pet-friendly"),
                            ("💃", "No parties"),
                            ("📚", "Study buddy"),
                            ("🍳", "Cooks often"),
                            ("🫂", "Limited guests")
                        ], id: \.1) { emoji, label in
                            let tag = "\(emoji) \(label)"
                            selectableChip(tag, selected: vm.lifestyleTags.contains(label)) {
                                vm.toggleLifestyleTag(label)
                            }
                        }
                    }
                }

                // Requirements
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("REQUIREMENTS")
                        .font(.body10(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(["✅ Verified students", "🎓 Same university", "📅 Flexible move-in"], id: \.self) { req in
                            selectableChip(req, selected: vm.requirements.contains(req)) {
                                vm.toggleRequirement(req)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(.white)
    }

    // MARK: - Situation Section

    private var situationSection: some View {
        let hasPlace = session.profile?.housingSituation == "havePlace"

        return VStack(alignment: .leading, spacing: 0) {
            Divider()
            sectionHeader(icon: hasPlace ? "house.fill" : "mappin.and.ellipse", title: hasPlace ? "Your Place" : "Housing Preferences")

            VStack(spacing: AppSpacing.lg) {
                if hasPlace {
                    // Spots available
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("SPOTS AVAILABLE")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        HStack(spacing: AppSpacing.md) {
                            ForEach(1...4, id: \.self) { n in
                                Button {
                                    vm.spotsAvailable = n
                                } label: {
                                    Text("\(n)")
                                        .font(.body14(.semiBold))
                                        .foregroundStyle(vm.spotsAvailable == n ? Color(.purple, 700) : Color(.neutral, 700))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(vm.spotsAvailable == n ? Color(.purple, 100) : Color(.neutral, 100)))
                                        .overlay(Circle().stroke(vm.spotsAvailable == n ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Move-in month
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("AVAILABLE FROM")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(months, id: \.self) { month in
                                selectableChip(month, selected: vm.moveInMonth == month) {
                                    vm.moveInMonth = vm.moveInMonth == month ? nil : month
                                }
                            }
                        }
                    }
                } else {
                    // Budget
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("MONTHLY BUDGET")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        HStack(spacing: AppSpacing.sm) {
                            ForEach([300, 600, 900, 1200], id: \.self) { amount in
                                Button {
                                    vm.maxBudget = amount
                                } label: {
                                    Text("$\(amount)")
                                        .font(.body12(.semiBold))
                                        .foregroundStyle(vm.maxBudget == amount ? Color(.purple, 700) : Color(.neutral, 700))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppSpacing.sm)
                                        .background(RoundedRectangle(cornerRadius: 10).fill(vm.maxBudget == amount ? Color(.purple, 100) : Color(.neutral, 100)))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(vm.maxBudget == amount ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Property type
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("PROPERTY TYPE")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(["Studio", "1 Bedroom", "Shared room", "Any"], id: \.self) { type in
                                selectableChip(type, selected: vm.propertyType == type) {
                                    vm.propertyType = vm.propertyType == type ? nil : type
                                }
                            }
                        }
                    }

                    // Move-in date
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("MOVE-IN DATE")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        DatePicker("", selection: $vm.moveInDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color(.purple, 500))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(.white)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color(.purple, 500))
            Text(title.uppercased())
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 900))  
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.sm)
    }

    private func menuRow(icon: String, value: String?, placeholder: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color(.neutral, 500))
                .font(.body16())
            Text(value ?? placeholder)
                .font(.body16())
                .foregroundStyle(value == nil ? Color(.neutral, 500) : Color(.neutral, 900))
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 12))
                .foregroundStyle(Color(.neutral, 500))
        }
        .padding(AppSpacing.md)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.neutral, 300), lineWidth: 1))
    }

    private func optionCard(emoji: String, label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 22))
                Text(label).font(.body12(.semiBold)).foregroundStyle(Color(.neutral, 800))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .background(RoundedRectangle(cornerRadius: 12).fill(selected ? Color(.purple, 100) : Color(.neutral, 100)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }

    private func selectableChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.body12(.semiBold))
                .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(RoundedRectangle(cornerRadius: 20).fill(selected ? Color(.purple, 100) : Color(.neutral, 100)))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
