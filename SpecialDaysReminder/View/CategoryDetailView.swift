//
//  CategoryDetailView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI
import UIKit

// MARK: - Helper to enable swipe back gesture
// This UIViewControllerRepresentable allows us to access the underlying
// UINavigationController and enable its interactivePopGestureRecognizer.
struct EnableInteractivePopGesture: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Find the nearest UINavigationController and enable its interactive pop gesture
        uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

// MARK: - Extracted List Content for CategoryDetailView
// This new private view encapsulates the List of special days,
// reducing complexity in the parent CategoryDetailView.
private struct CategoryDetailListContent: View {
    let days: [SpecialDayModel] // Receive the filtered list directly
    let themeColor: Color
    let deleteAction: (IndexSet) -> Void // Closure for onDelete

    var body: some View {
        List {
            ForEach(days, id: \.id) { day in // Iterate over the passed 'days'
                NavigationLink(value: NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id))) {
                    SpecialDayRowView(day: day, themeColor: themeColor)
                }
                .listRowBackground(Color.clear) // Ensure NavigationLink's row background is clear
            }
            .onDelete(perform: deleteAction) // Use the passed delete action
        }
        .listStyle(.plain)
        .background(Color.clear)
    }
}

// MARK: - Helper ViewModifier for CategoryDetailView Toolbar
private struct CategoryDetailToolbarModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss
    let category: SpecialDayCategory?
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingAddSpecialDaySheet: Bool

    func body(content: Content) -> some View {
        content
            .navigationTitle(category?.displayName ?? "All Special Days")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // Keep this to hide the system's default back button
            .toolbar {
                // Custom Back Button (Leading)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss() // Dismisses the current view from the navigation stack
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(category?.color ?? SpecialDayCategory.other.color) // CHANGED: Default to .other.color
                    }
                }

                // Toolbar for adding new days (Trailing)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedCategoryForAdd = category
                        showingAddSpecialDaySheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(category?.color ?? SpecialDayCategory.other.color) // CHANGED: Default to .other.color
                    }
                }
            }
    }
}

// MARK: - Helper ViewModifier for CategoryDetailView Sheets
private struct CategoryDetailSheetPresenters: ViewModifier {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    @Binding var showingAddSpecialDaySheet: Bool
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    let category: SpecialDayCategory? // Needed for AddSpecialDayView themeColor

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingAddSpecialDaySheet) {
                // FIXED: Removed themeColor argument from AddSpecialDayView
                AddSpecialDayView(viewModel: viewModel, initialCategory: selectedCategoryForAdd)
            }
    }
}


struct CategoryDetailView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    let category: SpecialDayCategory? // Nil means "All Special Days"
    @Environment(\.dismiss) var dismiss // For custom back button

    // State for presenting the AddSpecialDayView sheet
    @State private var showingAddSpecialDaySheet = false
    @State private var selectedCategoryForAdd: SpecialDayCategory?

    // MARK: - Helper Computed Property
    private var filteredAndSortedDays: [SpecialDayModel] {
        let days = category == nil ? viewModel.specialDays : viewModel.specialDays(for: category!)
        return days.sorted { $0.nextOccurrenceDate < $1.nextOccurrenceDate }
    }

    var body: some View {
        VStack {
            CategoryDetailListContent(
                days: filteredAndSortedDays,
                themeColor: category?.color ?? SpecialDayCategory.other.color, // CHANGED: Default to .other.color
                deleteAction: deleteDay
            )

            Spacer()
        }
        // CHANGED: Background defaults to .other.color when category is nil
        .background((category?.color ?? SpecialDayCategory.other.color).opacity(0.1).edgesIgnoringSafeArea(.all))
        
        // Apply the extracted toolbar modifier
        .modifier(CategoryDetailToolbarModifier(
            category: category,
            selectedCategoryForAdd: $selectedCategoryForAdd,
            showingAddSpecialDaySheet: $showingAddSpecialDaySheet
        ))
        
        // Add the helper to enable the interactive pop gesture
        .background(EnableInteractivePopGesture())
        
        // Apply the extracted sheet presenters modifier (now only for AddSpecialDayView)
        .modifier(CategoryDetailSheetPresenters(
            viewModel: viewModel,
            showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
            selectedCategoryForAdd: $selectedCategoryForAdd,
            category: category
        ))
    }

    // MARK: - Helper Functions

    private func deleteDay(at offsets: IndexSet) {
        let daysToDelete = offsets.map { filteredAndSortedDays[$0] }
        for day in daysToDelete {
            viewModel.deleteSpecialDay(id: day.id)
        }
    }
}

// MARK: - Preview Provider
struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryDetailView(viewModel: SpecialDaysListViewModel(), category: .family)
            .previewDisplayName("Family Category Detail")

        CategoryDetailView(viewModel: SpecialDaysListViewModel(), category: nil)
            .previewDisplayName("All Special Days Detail")
    }
}
