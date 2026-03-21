import SwiftUI

struct DesignSystemTestView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
                Section("Typography") {
                    Text("Heading 1").font(.h1())
                    Text("Heading 2").font(.h2())
                    Text("Heading 3").font(.h3())
                    Text("Heading 4").font(.h4())
                    Text("Body 18").font(.body18())
                    Text("Body 16").font(.body16())
                    Text("Body 14").font(.body14())
                    Text("Body 12").font(.body12())
                    Text("Body 10").font(.body10())
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Section("Colors") {
                        colorRow("Purple", colors: [
                            Color(.purple, 100),
                            Color(.purple, 300),
                            Color(.purple, 500),
                            Color(.purple, 700),
                            Color(.purple, 900)
                        ])
                        colorRow("Green", colors: [
                            Color(.green, 100),
                            Color(.green, 300),
                            Color(.green, 500),
                            Color(.green, 700),
                            Color(.green, 900)
                        ])
                        colorRow("Yellow", colors: [
                            Color(.yellow, 100),
                            Color(.yellow, 300),
                            Color(.yellow, 500),
                            Color(.yellow, 700),
                            Color(.yellow, 900)
                        ])
                        colorRow("Red", colors: [
                            Color(.red, 100),
                            Color(.red, 300),
                            Color(.red, 500),
                            Color(.red, 700),
                            Color(.red, 900)
                        ])
                        colorRow("Neutral", colors: [
                            Color(.neutral, 100),
                            Color(.neutral, 300),
                            Color(.neutral, 500),
                            Color(.neutral, 700),
                            Color(.neutral, 900)
                        ])
                    }
                }

                Section("Buttons") {
                    AppButton(title: "Primary Button", variant: .primary) { }
                    AppButton(title: "Secondary Button", variant: .secondary) { }
                }

                Section("Pills") {
                    HStack(spacing: 8) {
                        PillBadge(label: "Verified landlords", dotColor: Color(.green, 500))
                        PillBadge(label: "Roommate matching", dotColor: Color(.yellow, 500))
                    }
                    PillBadge(label: "Map search", dotColor: Color(.purple, 500))
                }
            }
            .padding(24)
        }
    }

    private func colorRow(_ name: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name).font(.body14())
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

