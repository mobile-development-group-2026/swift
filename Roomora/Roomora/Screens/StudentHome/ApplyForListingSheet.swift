import SwiftUI
import ClerkKit

struct ApplyForListingSheet: View {
    let listing: ListingResponse
    var onSubmitted: (() -> Void)? = nil

    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var notes = ""
    @State private var includeVisit = false
    @State private var visitDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var isLoading = false
    @State private var submitted = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {

                    // header
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Apply for")
                            .font(.h2(.bold))
                            .foregroundStyle(Color(.neutral, 900))
                        Text(listing.title)
                            .font(.h2(.bold))
                            .foregroundStyle(Color(.purple, 500))
                            .lineLimit(2)
                    }

                    // visit toggle
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Toggle(isOn: $includeVisit) {
                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text("REQUEST A VISIT")
                                    .font(.body10(.semiBold))
                                    .foregroundStyle(Color(.neutral, 700))
                                Text("Suggest a preferred viewing slot")
                                    .font(.body12())
                                    .foregroundStyle(Color(.neutral, 500))
                            }
                        }
                        .tint(Color(.purple, 500))

                        if includeVisit {
                            DatePicker(
                                "",
                                selection: $visitDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .tint(Color(.purple, 500))
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                    )

                    // notes
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("MESSAGE (OPTIONAL)")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))

                        AppTextField(
                            icon: "",
                            label: "",
                            placeholder: "Tell the landlord a bit about yourself, your schedule, why this place suits you…",
                            text: $notes,
                            isMultiline: true,
                            minHeight: 120
                        )
                    }

                    if let error {
                        ErrorMessage(message: error)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(Color(.neutral, 100))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                    AppButton(
                        title: isLoading ? "Submitting…" : "Submit Application",
                        variant: .primary
                    ) {
                        Task { await submit() }
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.6 : 1)
                    .padding(AppSpacing.lg)
                    .background(.white)
                }
            }
            .navigationTitle("Apply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(.neutral, 600))
                }
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Submit

    private func submit() async {
        isLoading = true
        error = nil

        var fields: [String: Any] = [:]
        if !notes.isEmpty { fields["student_notes"] = notes }
        if includeVisit {
            let formatter = ISO8601DateFormatter()
            fields["preferred_visit_at"] = formatter.string(from: visitDate)
        }

        do {
            try await APIClient.shared.createApplication(clerk: clerk, listingId: listing.id, fields: fields)
            onSubmitted?()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
