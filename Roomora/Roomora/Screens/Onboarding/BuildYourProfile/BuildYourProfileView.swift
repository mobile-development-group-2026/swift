import SwiftUI
import PhotosUI

struct BuildYourProfileView: View {
    @Bindable var vm: BuildYourProfileViewModel
    var role: String = "student"

    private var isStudent: Bool { role == "student" }

    private var bioHint: AttributedString {
        try! AttributedString(markdown: "Add at least **5 characters** to continue.")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Build your")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("profile")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                    Text(isStudent
                         ? "A great profile gets you 3× more matches."
                         : "Help tenants know who they're renting from.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 800))
                        .padding(.top, AppSpacing.xxs)
                }

                // profile photo
                HStack(spacing: AppSpacing.md) {
                    PhotosPicker(selection: $vm.photoPickerItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let photo = vm.profilePhoto {
                                photo
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color(.purple, 500), lineWidth: 2)
                                    )
                            } else {
                                Circle()
                                    .fill(Color(.neutral, 200))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 32))
                                            .foregroundStyle(Color(.neutral, 400))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color(.purple, 500), lineWidth: 2)
                                    )
                            }

                            Circle()
                                .fill(Color(.purple, 500))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                        }
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Profile photo")
                            .font(.body16(.semiBold))
                            .foregroundStyle(Color(.neutral, 900))
                        Text(isStudent
                             ? "A clear photo helps landlords and roommates feel confident about you."
                             : "A clear photo helps tenants feel confident about renting from you.")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 800))
                    }
                }
                .onChange(of: vm.photoPickerItem) {
                    Task {
                        if let data = try? await vm.photoPickerItem?.loadTransferable(type: Data.self) {
                            vm.savePhoto(data: data)
                        }
                    }
                }

                if isStudent {
                    // university
                    AppTextField(
                        icon: "building.columns",
                        label: "UNIVERSITY",
                        placeholder: "e.g. Tec de Monterrey",
                        text: $vm.university
                    )

                    // major
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("MAJOR")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))

                        Menu {
                            ForEach(BuildYourProfileViewModel.majors, id: \.self) { major in
                                Button(major) { vm.major = major }
                            }
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "book")
                                    .foregroundStyle(Color(.neutral, 500))
                                    .font(.body16())
                                Text(vm.major ?? "Select your major")
                                    .font(.body16())
                                    .foregroundStyle(vm.major == nil ? Color(.neutral, 500) : Color(.neutral, 900))
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
                }

                // birth year (+ graduation year for students only)
                HStack(spacing: AppSpacing.md) {
                    yearPicker(
                        icon: "calendar",
                        label: "BIRTH YEAR",
                        placeholder: "Select",
                        years: BuildYourProfileViewModel.birthYears,
                        selection: $vm.birthYear
                    )

                    if isStudent {
                        yearPicker(
                            icon: "graduationcap",
                            label: "GRAD YEAR",
                            placeholder: "Select",
                            years: BuildYourProfileViewModel.gradYears,
                            selection: $vm.graduationYear
                        )
                    }
                }

                // bio
                AppTextField(
                    icon: "",
                    label: "BIO",
                    placeholder: "Tell us about yourself, your interests, what you're studying...",
                    text: $vm.bio,
                    isMultiline: true
                )

                if vm.bio.count < 5 && !vm.bio.isEmpty {
                    HintBanner(message: bioHint)
                }

                // hobbies
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("HOBBIES")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))
                        Spacer()
                        Text("\(vm.selectedHobbies.count) / \(vm.maxHobbies)")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                    }

                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(BuildYourProfileViewModel.hobbies, id: \.self) { hobby in
                            let selected = vm.selectedHobbies.contains(hobby)
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                vm.toggleHobby(hobby)
                            } label: {
                                Text(hobby)
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
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private func yearPicker(
        icon: String,
        label: String,
        placeholder: String,
        years: [Int],
        selection: Binding<Int?>
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 700))

            Menu {
                ForEach(years.reversed(), id: \.self) { year in
                    Button(String(year)) { selection.wrappedValue = year }
                }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: icon)
                        .foregroundStyle(Color(.neutral, 500))
                        .font(.body16())
                    Text(selection.wrappedValue.map(String.init) ?? placeholder)
                        .font(.body16())
                        .foregroundStyle(selection.wrappedValue == nil ? Color(.neutral, 500) : Color(.neutral, 900))
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
    }
}
