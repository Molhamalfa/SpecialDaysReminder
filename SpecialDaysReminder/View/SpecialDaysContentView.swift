//
//  SpecialDaysContentView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct SpecialDaysContentView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel

    // Animation states for initial load (passed from parent)
    let headerOpacity: Double
    let headerOffset: CGFloat
    let allDaysCardOpacity: Double
    let allDaysCardOffset: CGFloat
    let categoryGridOpacity: Double
    let categoryGridOffset: CGFloat

    // Bindings for sheets (passed from parent)
    @Binding var selectedDayToEdit: SpecialDayModel?
    @Binding var showingAddSpecialDaySheet: Bool
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingEditSpecialDaySheet: Bool // ADD THIS LINE

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                SpecialDaysHeaderView()
                    .opacity(headerOpacity)
                    .offset(y: headerOffset)
                    .padding(.top, 20)

                AllSpecialDaysCardLinkView(
                    viewModel: viewModel,
                    allDaysCardOpacity: allDaysCardOpacity,
                    allDaysCardOffset: allDaysCardOffset,
                    selectedDayToEdit: $selectedDayToEdit,
                    showingEditSpecialDaySheet: $showingEditSpecialDaySheet // CORRECTED BINDING
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(SpecialDayCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                        CategoryGridItemLinkView(
                            viewModel: viewModel,
                            category: category,
                            selectedCategoryForAdd: $selectedCategoryForAdd,
                            showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
                            selectedDayToEdit: $selectedDayToEdit,
                            showingEditSpecialDaySheet: $showingEditSpecialDaySheet // CORRECTED BINDING
                        )
                    }
                }
                .opacity(categoryGridOpacity)
                .offset(y: categoryGridOffset)
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Preview Provider
struct SpecialDaysContentView_Previews: PreviewProvider {
    static var previews: some View {
        SpecialDaysContentView(
            viewModel: SpecialDaysListViewModel(),
            headerOpacity: 1.0,
            headerOffset: 0,
            allDaysCardOpacity: 1.0,
            allDaysCardOffset: 0,
            categoryGridOpacity: 1.0,
            categoryGridOffset: 0,
            selectedDayToEdit: .constant(nil),
            showingAddSpecialDaySheet: .constant(false),
            selectedCategoryForAdd: .constant(nil),
            showingEditSpecialDaySheet: .constant(false) // ADD TO PREVIEW
        )
    }
}
