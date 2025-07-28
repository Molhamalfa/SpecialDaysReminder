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
    @Binding var selectedDayToEdit: SpecialDayModel?
    @Binding var showingEditSpecialDaySheet: Bool // ENSURE THIS IS THE CORRECT BINDING

    var body: some View {
        NavigationLink(destination: CategoryDetailView(viewModel: viewModel, category: category)) {
            CategoryCardView(
                category: category,
                specialDays: viewModel.specialDays(for: category),
                onAddTapped: { selectedCategory in
                    selectedCategoryForAdd = selectedCategory
                    showingAddSpecialDaySheet = true
                },
                onDayTapped: { day in
                    selectedDayToEdit = day
                    showingEditSpecialDaySheet = true // CORRECTED USAGE
                },
                onCardTapped: { selectedCategory in
                    // This will be handled by NavigationLink now
                }
            )
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
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
            selectedDayToEdit: .constant(nil),
            showingEditSpecialDaySheet: .constant(false) // CORRECTED PREVIEW BINDING
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
