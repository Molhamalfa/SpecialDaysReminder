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
    @Binding var navigationPath: NavigationPath // NEW: Added navigationPath binding

    var body: some View {
        List {
            ForEach(days, id: \.id) { day in // Iterate over the passed 'days'
                NavigationLink(value: NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id))) {
                    SpecialDayRowView(day: day, themeColor: themeColor)
                }
                .listRowBackground(Color.clear) // Ensure NavigationLink's row background is clear
                // NEW: Add swipe actions for Edit and Delete
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        if let index = days.firstIndex(where: { $0.id == day.id }) {
                            deleteAction(IndexSet(integer: index))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(.red)

                    Button {
                        // Navigate to EditSpecialDayView
                        navigationPath.append(NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id)))
                    } label: {
                        Label("Edit", systemImage: "pencil.circle.fill")
                    }
                    .tint(.blue) // A distinct color for edit
                }
            }
            // Removed .onDelete(perform: deleteAction) from ForEach, as swipeActions handles it per row
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
                            .foregroundColor(.black) // Fixed to black for consistency
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
                            .foregroundColor(.black) // Fixed to black for consistency
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
    let category: SpecialDayCategory? // Still needed to determine initial category for AddSpecialDayView

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingAddSpecialDaySheet) {
                AddSpecialDayView(viewModel: viewModel, initialCategory: selectedCategoryForAdd)
            }
    }
}


struct CategoryDetailView: View {
    // Now holds the main SpecialDaysListViewModel (passed from parent)
    @ObservedObject var specialDaysListViewModel: SpecialDaysListViewModel
    let category: SpecialDayCategory? // Nil means "All Special Days"
    @Environment(\.dismiss) var dismiss // For custom back button

    // NEW: StateObject for the CategoryDetail-specific ViewModel
    @StateObject private var categoryDetailViewModel: CategoryDetailViewModel

    // State for presenting the AddSpecialDayView sheet
    @State private var showingAddSpecialDaySheet = false
    @State private var selectedCategoryForAdd: SpecialDayCategory?
    
    @Binding var navigationPath: NavigationPath // NEW: Added navigationPath binding

    // MARK: - Initialization
    // Custom initializer to set up the CategoryDetailViewModel.
    init(viewModel: SpecialDaysListViewModel, category: SpecialDayCategory?, navigationPath: Binding<NavigationPath>) { // UPDATED: Added navigationPath
        _specialDaysListViewModel = ObservedObject(wrappedValue: viewModel)
        self.category = category
        // Initialize the StateObject for CategoryDetailViewModel
        _categoryDetailViewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category, specialDaysListViewModel: viewModel))
        _navigationPath = navigationPath // Initialize navigationPath
    }

    var body: some View {
        VStack {
            CategoryDetailListContent(
                days: categoryDetailViewModel.specialDaysForCategory, // Use data from new ViewModel
                themeColor: category?.color ?? SpecialDayCategory.other.color, // Pass Color
                deleteAction: categoryDetailViewModel.deleteDay, // Use delete action from new ViewModel
                navigationPath: $navigationPath // NEW: Pass navigationPath
            )

            Spacer()
        }
        // REVERTED: Use the Color with original opacity as background
        .background(
            (category?.color ?? SpecialDayCategory.other.color)
                .opacity(0.1) // Apply opacity to the Color view
                .edgesIgnoringSafeArea(.all)
        )
        
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
            viewModel: specialDaysListViewModel, // Pass the main ViewModel to the sheet presenter
            showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
            selectedCategoryForAdd: $selectedCategoryForAdd,
            category: category
        ))
    }
    // Removed: filteredAndSortedDays computed property
    // Removed: deleteDay function
}

// MARK: - Preview Provider
struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryDetailView(viewModel: SpecialDaysListViewModel(), category: .family, navigationPath: .constant(NavigationPath())) // UPDATED: Pass navigationPath
            .previewDisplayName("Family Category Detail")

        CategoryDetailView(viewModel: SpecialDaysListViewModel(), category: nil, navigationPath: .constant(NavigationPath())) // UPDATED: Pass navigationPath
            .previewDisplayName("All Special Days Detail")
    }
}
