import SwiftUI

struct CountryCode: Identifiable, Hashable {
    let id: String       // ISO code
    let flag: String
    let name: String
    let dialCode: String

    static let all: [CountryCode] = [
        .init(id: "US", flag: "🇺🇸", name: "United States", dialCode: "+1"),
        .init(id: "MX", flag: "🇲🇽", name: "Mexico", dialCode: "+52"),
        .init(id: "CA", flag: "🇨🇦", name: "Canada", dialCode: "+1"),
        .init(id: "GB", flag: "🇬🇧", name: "United Kingdom", dialCode: "+44"),
        .init(id: "ES", flag: "🇪🇸", name: "Spain", dialCode: "+34"),
        .init(id: "FR", flag: "🇫🇷", name: "France", dialCode: "+33"),
        .init(id: "DE", flag: "🇩🇪", name: "Germany", dialCode: "+49"),
        .init(id: "BR", flag: "🇧🇷", name: "Brazil", dialCode: "+55"),
        .init(id: "AR", flag: "🇦🇷", name: "Argentina", dialCode: "+54"),
        .init(id: "CO", flag: "🇨🇴", name: "Colombia", dialCode: "+57"),
        .init(id: "CL", flag: "🇨🇱", name: "Chile", dialCode: "+56"),
        .init(id: "PE", flag: "🇵🇪", name: "Peru", dialCode: "+51"),
        .init(id: "IN", flag: "🇮🇳", name: "India", dialCode: "+91"),
        .init(id: "CN", flag: "🇨🇳", name: "China", dialCode: "+86"),
        .init(id: "JP", flag: "🇯🇵", name: "Japan", dialCode: "+81"),
        .init(id: "KR", flag: "🇰🇷", name: "South Korea", dialCode: "+82"),
        .init(id: "AU", flag: "🇦🇺", name: "Australia", dialCode: "+61"),
        .init(id: "IT", flag: "🇮🇹", name: "Italy", dialCode: "+39"),
        .init(id: "PT", flag: "🇵🇹", name: "Portugal", dialCode: "+351"),
        .init(id: "NL", flag: "🇳🇱", name: "Netherlands", dialCode: "+31"),
    ]
}

struct PhoneField: View {
    let label: String
    @Binding var phone: String
    @State private var selectedCountry = CountryCode.all[0]
    @State private var localNumber = ""
    @State private var showPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 700))

            HStack(spacing: 0) {
                // country selector
                Button {
                    showPicker = true
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Text(selectedCountry.flag)
                            .font(.system(size: 20))
                        Text(selectedCountry.dialCode)
                            .font(.body16())
                            .foregroundStyle(Color(.neutral, 900))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(.neutral, 500))
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                }
                .buttonStyle(.plain)

                // divider
                Rectangle()
                    .fill(Color(.neutral, 500))
                    .frame(width: 1, height: 24)

                // number input
                TextField("", text: $localNumber, prompt: Text("(555) 000-0000").foregroundColor(Color(.neutral, 500)))
                    .font(.body16())
                    .foregroundStyle(Color(.neutral, 900))
                    .keyboardType(.phonePad)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                    .onChange(of: localNumber) {
                        phone = selectedCountry.dialCode + localNumber
                    }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.neutral, 500), lineWidth: 1)
            )
        }
        .onChange(of: selectedCountry.id) {
            phone = selectedCountry.dialCode + localNumber
        }
        .sheet(isPresented: $showPicker) {
            CountryPickerSheet(selected: $selectedCountry, isPresented: $showPicker)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(24)
        }
    }
}

private struct CountryPickerSheet: View {
    @Binding var selected: CountryCode
    @Binding var isPresented: Bool
    @State private var search = ""

    private var filtered: [CountryCode] {
        if search.isEmpty { return CountryCode.all }
        return CountryCode.all.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.dialCode.contains(search) ||
            $0.id.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { country in
                Button {
                    selected = country
                    isPresented = false
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        Text(country.flag)
                            .font(.system(size: 24))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .font(.body16())
                                .foregroundStyle(.primary)
                            Text(country.dialCode)
                                .font(.body14())
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if country.id == selected.id {
                            Image(systemName: "checkmark")
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.purple, 500))
                        }
                    }
                }
                .listRowBackground(country.id == selected.id ? Color(.purple, 50) : .clear)
            }
            .listStyle(.plain)
            .searchable(text: $search, prompt: "Search country")
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.purple, 500))
                }
            }
        }
    }
}
