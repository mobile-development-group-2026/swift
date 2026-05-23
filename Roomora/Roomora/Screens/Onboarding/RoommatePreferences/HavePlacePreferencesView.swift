//
//  HavePlacePreferencesView.swift
//  Roomora
//
//  Created by Andy on 22/05/26.
//


import SwiftUI

struct HavePlacePreferencesView: View {
    @Bindable var vm: RoommatePreferencesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // header
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Your")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.neutral, 900))
                    Text("place")
                        .font(.h1(.bold))
                        .foregroundStyle(Color(.purple, 500))
                    Text("Tell us about your place so we can find the right match.")
                        .font(.body14())
                        .foregroundStyle(Color(.neutral, 600))
                        .padding(.top, AppSpacing.xxs)
                }

                // spots available
                PreferenceSection(icon: "person.2.fill", title: "SPOTS AVAILABLE") {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("How many roommates are you looking for?")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 600))
                        HStack(spacing: AppSpacing.md) {
                            ForEach(1...4, id: \.self) { n in
                                Button {
                                    vm.spotsAvailable = n
                                } label: {
                                    Text("\(n)")
                                        .font(.body14(.semiBold))
                                        .foregroundStyle(vm.spotsAvailable == n ? Color(.purple, 700) : Color(.neutral, 700))
                                        .frame(width: 40, height: 40)
                                        .background(Circle().fill(vm.spotsAvailable == n ? Color(.purple, 100) : .clear))
                                        .overlay(Circle().stroke(vm.spotsAvailable == n ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // move-in month
                PreferenceSection(icon: "calendar.circle.fill", title: "AVAILABLE FROM") {
                    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(months, id: \.self) { month in
                            Button {
                                vm.moveInMonth = vm.moveInMonth == month ? nil : month
                            } label: {
                                Text(month)
                                    .font(.body14(.medium))
                                    .foregroundStyle(vm.moveInMonth == month ? Color(.purple, 700) : Color(.neutral, 700))
                                    .frame(minWidth: 52)
                                    .padding(.horizontal, AppSpacing.md)
                                    .padding(.vertical, AppSpacing.sm)
                                    .background(RoundedRectangle(cornerRadius: 20).fill(vm.moveInMonth == month ? Color(.purple, 100) : .clear))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(vm.moveInMonth == month ? Color(.purple, 500) : Color(.neutral, 500), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
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
