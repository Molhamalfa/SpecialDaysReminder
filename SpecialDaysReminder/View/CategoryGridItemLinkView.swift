//
//  CategoryGridItemLinkView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct CategoryGridItemLinkView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    let category: SpecialDayCategory
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingAddSpecialDaySheet: Bool
    @Binding var navigationPath: NavigationPath // Pass NavigationPath

    var body: some View {
        // The NavigationLink for the card itself remains, pushing CategoryDetailView
        // The onDayTapped now pushes EditSpecialDayView via navigationPath
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
            } // Removed onCardTapped parameter
        )
    }
}

// MARK: - Preview Provider
struct CategoryGridItemLinkView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryGridItemLinkView(
            viewModel: SpecialDaysListViewModel(),
            category: .lovedOnes,
            selectedCategoryForAdd: .constant(nil),
            showingAddSpecialDaySheet: .constant(false),
            navigationPath: .constant(NavigationPath()) // Provide a constant binding for preview
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
