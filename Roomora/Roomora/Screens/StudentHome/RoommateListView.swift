import SwiftUI

struct RoommateListView: View {
    var vm: RoommateViewModel

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xxl)
            } else if let error = vm.errorMessage {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(.neutral, 300))
                    Text(error)
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 500))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxl)
                .padding(.horizontal, AppSpacing.lg)
            } else if vm.roommates.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "person.2")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(.neutral, 300))
                    Text("No roommates available right now")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 500))
                    Text("Check back soon — more students join every day.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 400))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxl)
                .padding(.horizontal, AppSpacing.lg)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(vm.roommates) { roommate in
                        RoommateCard(roommate: roommate)
                            .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
        }
    }
}
