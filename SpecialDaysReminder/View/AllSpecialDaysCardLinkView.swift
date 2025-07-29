//
//  AllSpecialDaysCardLinkView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct AllSpecialDaysCardLinkView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    let allDaysCardOpacity: Double
    let allDaysCardOffset: CGFloat
    @Binding var navigationPath: NavigationPath
    @Binding var selectedCategoryForAdd: SpecialDayCategory? // NEW: Accept binding
    @Binding var showingAddSpecialDaySheet: Bool // NEW: Accept binding

    var body: some View {
        CategoryCardView(
            category: .other, // Use 'other' for color, but customize title/icon
            specialDays: viewModel.specialDays, // Pass all special days
            onAddTapped: { _ in // UPDATED: Implement add action
                selectedCategoryForAdd = .other // Pre-select 'Other' for All Special Days add
                showingAddSpecialDaySheet = true
            },
            onDayTapped: { day in
                navigationPath.append(NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id)))
            },
            customTitle: "All Special Days",
            customIcon: "calendar"
        )
    }
}

// MARK: - Preview Provider
struct AllSpecialDaysCardLinkView_Previews: PreviewProvider {
    static var previews: some View {
        AllSpecialDaysCardLinkView(
            viewModel: SpecialDaysListViewModel(),
            allDaysCardOpacity: 1.0,
            allDaysCardOffset: 0,
            navigationPath: .constant(NavigationPath()), // Provide a constant binding for preview
            selectedCategoryForAdd: .constant(nil), // Provide constant binding for preview
            showingAddSpecialDaySheet: .constant(false) // Provide constant binding for preview
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
