//
//  AllSpecialDaysCardView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct AllSpecialDaysCardView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    let allDaysCardOpacity: Double
    let allDaysCardOffset: CGFloat
    @Binding var navigationPath: NavigationPath
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingAddSpecialDaySheet: Bool

    var body: some View {
        NavigationLink(value: NavigationDestinationType.categoryDetail(nil)) { // Pass nil for 'All Special Days'
            CategoryCardView(
                category: .other, // Use 'other' for color, but customize title/icon
                specialDays: viewModel.specialDays, // Pass all special days
                onAddTapped: { _ in // Implement add action for "All Special Days"
                    selectedCategoryForAdd = .other // Pre-select 'Other' for All Special Days add
                    showingAddSpecialDaySheet = true
                },
                onDayTapped: { day in
                    // Push EditSpecialDayView onto the navigation stack
                    navigationPath.append(NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id)))
                },
                customTitle: "All Special Days",
                customIcon: "calendar"
            )
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling for NavigationLink
        .opacity(allDaysCardOpacity) // Apply animation state
        .offset(y: allDaysCardOffset) // Apply animation state
        .padding(.horizontal) // Apply horizontal padding to the card
    }
}

// MARK: - Preview Provider
struct AllSpecialDaysCardView_Previews: PreviewProvider {
    static var previews: some View {
        AllSpecialDaysCardView(
            viewModel: SpecialDaysListViewModel(),
            allDaysCardOpacity: 1.0,
            allDaysCardOffset: 0,
            navigationPath: .constant(NavigationPath()),
            selectedCategoryForAdd: .constant(nil),
            showingAddSpecialDaySheet: .constant(false)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
