import SwiftUI
import PhotosUI

struct OnboardingStep1View: View {
    @Bindable var vm: OnboardingViewModel

    private var bioHint: AttributedString {
        var str = AttributedString("Add at least ")
        var bold = AttributedString("5 characters")
        bold.font = .body14(.bold)
        var end = AttributedString(" to continue.")
        str += bold
        str += end
        return str
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
                    Text("A great profile gets you 3× more matches.")
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
                        Text("A clear photo helps landlords and roommates feel confident about you.")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 800))
                    }
                }
                .onChange(of: vm.photoPickerItem) {
                    Task {
                        if let data = try? await vm.photoPickerItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            vm.profilePhoto = Image(uiImage: uiImage)
                        }
                    }
                }

                // university
                AppTextField(
                    icon: "building.columns",
                    label: "UNIVERSITY",
                    placeholder: "e.g. Tec de Monterrey",
                    text: $vm.university
                )

                // birth year & graduation year
                HStack(spacing: AppSpacing.md) {
                    AppTextField(
                        icon: "calendar",
                        label: "BIRTH YEAR",
                        placeholder: "e.g. 2003",
                        text: $vm.birthYear,
                        keyboardType: .numberPad
                    )

                    AppTextField(
                        icon: "graduationcap",
                        label: "GRADUATION YEAR",
                        placeholder: "e.g. 2027",
                        text: $vm.graduationYear,
                        keyboardType: .numberPad
                    )
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
                        ForEach(OnboardingViewModel.hobbies, id: \.self) { hobby in
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
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for (i, row) in rows.enumerated() {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight
            if i < rows.count - 1 { height += spacing }
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentWidth: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentWidth = 0
            }
            rows[rows.count - 1].append(view)
            currentWidth += size.width + spacing
        }
        return rows
    }
}
