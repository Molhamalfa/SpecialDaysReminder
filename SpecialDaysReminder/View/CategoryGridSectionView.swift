//
//  CategoryGridSectionView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct CategoryGridSectionView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    let categoryGridOpacity: Double
    let categoryGridOffset: CGFloat
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingAddSpecialDaySheet: Bool
    @Binding var navigationPath: NavigationPath

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(SpecialDayCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                NavigationLink(value: NavigationDestinationType.categoryDetail(category)) {
                    CategoryCardView(
                        category: category,
                        specialDays: viewModel.specialDays(for: category),
                        onAddTapped: { selectedCategory in
                            selectedCategoryForAdd = selectedCategory
                            showingAddSpecialDaySheet = true
                        },
                        onDayTapped: { day in
                            // Push EditSpecialDayView onto the navigation stack
                            navigationPath.append(NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id)))
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styling
            }
        }
        .opacity(categoryGridOpacity)
        .offset(y: categoryGridOffset)
        .padding(.horizontal)
    }
}

// MARK: - Preview Provider
struct CategoryGridSectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryGridSectionView(
            viewModel: SpecialDaysListViewModel(),
            categoryGridOpacity: 1.0,
            categoryGridOffset: 0,
            selectedCategoryForAdd: .constant(nil),
            showingAddSpecialDaySheet: .constant(false),
            navigationPath: .constant(NavigationPath())
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
