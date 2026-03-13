import SwiftUI

struct DesignSystemTestView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // MARK: - Typography
                Section("Typography") {
                    Text("Heading 1").font(.h1)
                    Text("Heading 2").font(.h2)
                    Text("Heading 3").font(.h3)
                    Text("Heading 4").font(.h4)
                    Text("Body 18").font(.body18)
                    Text("Body 16").font(.body16)
                    Text("Body 14").font(.body14)
                    Text("Body 12").font(.body12)
                    Text("Body 10").font(.body10)
                }

                // MARK: - Colors
                Section("Colors") {
                    colorRow("Purple", colors: [
                        AppColors.purple100, AppColors.purple300,
                        AppColors.purple500, AppColors.purple700, AppColors.purple900
                    ])
                    colorRow("Green", colors: [
                        AppColors.green100, AppColors.green300,
                        AppColors.green500, AppColors.green700, AppColors.green900
                    ])
                    colorRow("Yellow", colors: [
                        AppColors.yellow100, AppColors.yellow300,
                        AppColors.yellow500, AppColors.yellow700, AppColors.yellow900
                    ])
                    colorRow("Red", colors: [
                        AppColors.red100, AppColors.red300,
                        AppColors.red500, AppColors.red700, AppColors.red900
                    ])
                    colorRow("Neutral", colors: [
                        AppColors.neutral100, AppColors.neutral300,
                        AppColors.neutral500, AppColors.neutral700, AppColors.neutral900
                    ])
                }

                // MARK: - Buttons
                Section("Buttons") {
                    AppButton(title: "Primary Button", variant: .primary) { }
                    AppButton(title: "Secondary Button", variant: .secondary) { }
                }

                // MARK: - Pills
                Section("Pills") {
                    HStack(spacing: 8) {
                        PillBadge(label: "Verified landlords", dotColor: AppColors.green500)
                        PillBadge(label: "Roommate matching", dotColor: AppColors.yellow500)
                    }
                    PillBadge(label: "Map search", dotColor: AppColors.purple500)
                }
            }
            .padding(24)
        }
    }

    private func colorRow(_ name: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name).font(.body14)
            HStack(spacing: 4) {
                ForEach(0..<colors.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colors[i])
                        .frame(height: 40)
                }
            }
        }
    }
}

#Preview {
    DesignSystemTestView()
}
