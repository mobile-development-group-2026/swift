import SwiftUI
import SwiftData
import ClerkKit

struct ApplyForListingSheet: View {
    let listing: ListingResponse
    var onSubmitted: ((_ wasOffline: Bool) -> Void)? = nil

    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var notes = ""
    @State private var includeVisit = false
    @State private var visitDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var isLoading = false
    @State private var submitted = false
    @State private var queuedOffline = false
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
                    if queuedOffline {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "clock.arrow.2.circlepath")
                                .foregroundStyle(Color(.purple, 500))
                            Text("Saved — will submit when back online")
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.neutral, 700))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.lg)
                        .background(.white)
                    } else {
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

        let visitStr: String? = includeVisit ? ISO8601DateFormatter().string(from: visitDate) : nil
        var fields: [String: Any] = [:]
        if let n = visitStr { fields["preferred_visit_at"] = n }
        if !notes.isEmpty   { fields["student_notes"] = notes }

        do {
            try await APIClient.shared.createApplication(clerk: clerk, listingId: listing.id, fields: fields)
            onSubmitted?(false)
            dismiss()
        } catch let apiErr as APIError {
            // 4xx = server rejected the request — don't queue, show the message.
            if case .server(let status, let message) = apiErr, (400...499).contains(status) {
                self.error = message
            } else {
                // Network/5xx — queue offline and sync later.
                modelContext.insert(PendingApplicationOp(
                    listingId: listing.id,
                    studentNotes: notes.isEmpty ? nil : notes,
                    preferredVisitAt: visitStr
                ))
                try? modelContext.save()
                queuedOffline = true
                onSubmitted?(true)
                try? await Task.sleep(for: .seconds(2))
                dismiss()
            }
        } catch {
            // Unknown network error — queue offline.
            modelContext.insert(PendingApplicationOp(
                listingId: listing.id,
                studentNotes: notes.isEmpty ? nil : notes,
                preferredVisitAt: visitStr
            ))
            try? modelContext.save()
            queuedOffline = true
            onSubmitted?(true)
            try? await Task.sleep(for: .seconds(2))
            dismiss()
        }
        isLoading = false
    }
}
