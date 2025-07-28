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
    @Binding var selectedDayToEdit: SpecialDayModel?
    @Binding var showingEditSpecialDaySheet: Bool // ENSURE THIS IS THE CORRECT BINDING

    var body: some View {
        NavigationLink(destination: CategoryDetailView(viewModel: viewModel, category: nil)) {
            CategoryCardView(
                category: .other, // Use 'other' for color, but customize title/icon
                specialDays: viewModel.specialDays, // Pass all special days
                onAddTapped: { _ in }, // Not used for this card
                onDayTapped: { day in
                    selectedDayToEdit = day
                    showingEditSpecialDaySheet = true // CORRECTED USAGE
                },
                onCardTapped: { _ in }, // NavigationLink handles this now
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
struct AllSpecialDaysCardLinkView_Previews: PreviewProvider {
    static var previews: some View {
        AllSpecialDaysCardLinkView(
            viewModel: SpecialDaysListViewModel(),
            allDaysCardOpacity: 1.0,
            allDaysCardOffset: 0,
            selectedDayToEdit: .constant(nil),
            showingEditSpecialDaySheet: .constant(false) // CORRECTED PREVIEW BINDING
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
