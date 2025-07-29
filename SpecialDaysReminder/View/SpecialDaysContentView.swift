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

    // Bindings for sheets and navigation (passed from parent)
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingAddSpecialDaySheet: Bool
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                SpecialDaysHeaderView()
                    .opacity(headerOpacity)
                    .offset(y: headerOffset)
                    .padding(.top, 20)

                // NEW: Use the extracted AllSpecialDaysCardView
                AllSpecialDaysCardView(
                    viewModel: viewModel,
                    allDaysCardOpacity: allDaysCardOpacity,
                    allDaysCardOffset: allDaysCardOffset,
                    navigationPath: $navigationPath,
                    selectedCategoryForAdd: $selectedCategoryForAdd,
                    showingAddSpecialDaySheet: $showingAddSpecialDaySheet
                )

                // NEW: Use the extracted CategoryGridSectionView
                CategoryGridSectionView(
                    viewModel: viewModel,
                    categoryGridOpacity: categoryGridOpacity,
                    categoryGridOffset: categoryGridOffset,
                    selectedCategoryForAdd: $selectedCategoryForAdd,
                    showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
                    navigationPath: $navigationPath
                )
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
            selectedCategoryForAdd: .constant(nil),
            showingAddSpecialDaySheet: .constant(false),
            navigationPath: .constant(NavigationPath())
        )
    }
}
