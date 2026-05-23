//
//  RoommateFilterSheet.swift
//  Roomora
//
//  Created by Andy on 23/05/26.
//


import SwiftUI

struct RoommateFilterSheet: View {
    @Binding var filter: RoommateFilter
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    // Sleep schedule
                    filterSection(icon: "moon.stars.fill", title: "SLEEP SCHEDULE") {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach([
                                (0, "🌅", "Early bird"),
                                (1, "🦉", "Night owl"),
                                (2, "😴", "Flexible")
                            ], id: \.0) { val, emoji, label in
                                filterCard(
                                    emoji: emoji,
                                    label: label,
                                    selected: filter.sleepSchedule == val
                                ) {
                                    filter.sleepSchedule = filter.sleepSchedule == val ? nil : val
                                }
                            }
                        }
                    }

                    // Cleanliness
                    filterSection(icon: "sparkles", title: "CLEANLINESS") {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach([
                                (0, "✨", "Tidy"),
                                (1, "🧼", "Moderate"),
                                (2, "😌", "Relaxed")
                            ], id: \.0) { val, emoji, label in
                                filterCard(
                                    emoji: emoji,
                                    label: label,
                                    selected: filter.cleanlinessLevel == val
                                ) {
                                    filter.cleanlinessLevel = filter.cleanlinessLevel == val ? nil : val
                                }
                            }
                        }
                    }

                    // Move-in month
                    filterSection(icon: "calendar.circle.fill", title: "MOVE-IN MONTH") {
                        let months = ["Jan","Feb","Mar","Apr","May","Jun",
                                      "Jul","Aug","Sep","Oct","Nov","Dec"]
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(months, id: \.self) { month in
                                filterChip(month, selected: filter.moveInMonth == month) {
                                    filter.moveInMonth = filter.moveInMonth == month ? nil : month
                                }
                            }
                        }
                    }

                    // University
                    filterSection(icon: "building.columns.fill", title: "UNIVERSITY") {
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(BuildYourProfileViewModel.universities.filter { $0 != "Other" }, id: \.self) { uni in
                                filterChip(uni, selected: filter.university == uni) {
                                    filter.university = filter.university == uni ? nil : uni
                                }
                            }
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("Filter Roommates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filter = RoommateFilter()
                    }
                    .foregroundStyle(Color(.neutral, 600))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .font(.body16(.semiBold))
                    .foregroundStyle(Color(.purple, 500))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.light)
    }

    private func filterSection<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.purple, 500))
                Text(title)
                    .font(.body10(.semiBold))
                    .foregroundStyle(Color(.neutral, 600))
            }
            content()
        }
    }

    private func filterCard(emoji: String, label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 22))
                Text(label).font(.body12(.semiBold)).foregroundStyle(Color(.neutral, 800))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .background(RoundedRectangle(cornerRadius: 12).fill(selected ? Color(.purple, 100) : .white))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }

    private func filterChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.body12(.semiBold))
                .foregroundStyle(selected ? Color(.purple, 700) : Color(.neutral, 700))
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(RoundedRectangle(cornerRadius: 20).fill(selected ? Color(.purple, 100) : .white))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? Color(.purple, 500) : Color(.neutral, 300), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}