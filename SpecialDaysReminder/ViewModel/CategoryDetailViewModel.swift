//
//  CategoryDetailViewModel.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation
import Combine // For Combine framework (for observing changes)

// MARK: - CategoryDetailViewModel
// This ViewModel handles the business logic for the CategoryDetailView.
// It manages filtering, sorting, and deletion of special days specific to a category.
class CategoryDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    // The list of special days filtered and sorted for the current category.
    @Published var specialDaysForCategory: [SpecialDayModel] = []

    // MARK: - Private Properties

    // The category this detail view is focused on (nil for "All Special Days").
    private let category: SpecialDayCategory?

    // Reference to the main SpecialDaysListViewModel to access and modify the global list of special days.
    private var specialDaysListViewModel: SpecialDaysListViewModel

    // Set to hold Combine cancellables to prevent memory leaks.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    // Initializes the ViewModel with a specific category and a reference to the main data ViewModel.
    init(category: SpecialDayCategory?, specialDaysListViewModel: SpecialDaysListViewModel) {
        self.category = category
        self.specialDaysListViewModel = specialDaysListViewModel

        // Immediately update the filtered days when initialized.
        updateFilteredDays()

        // Set up a subscriber to react to changes in the main list of special days.
        // Whenever specialDays in SpecialDaysListViewModel changes, re-filter and re-sort.
        specialDaysListViewModel.$specialDays
            .sink { [weak self] _ in
                self?.updateFilteredDays()
            }
            .store(in: &cancellables)
    }

    // MARK: - Business Logic Methods

    // Filters and sorts the special days based on the current category.
    // This method is called whenever the source data changes.
    private func updateFilteredDays() {
        let days: [SpecialDayModel]
        if let category = category {
            // Filter by category if a specific category is provided.
            days = specialDaysListViewModel.specialDays.filter { $0.category == category }
        } else {
            // If category is nil, show all special days.
            days = specialDaysListViewModel.specialDays
        }
        // Sort the filtered days by their next occurrence date.
        self.specialDaysForCategory = days.sorted { $0.nextOccurrenceDate < $1.nextOccurrenceDate }
    }

    // Handles the deletion of special days.
    // This method is exposed to the View for .onDelete modifier.
    func deleteDay(at offsets: IndexSet) {
        // Map the offsets from the filtered list to the actual SpecialDayModel instances.
        let daysToDelete = offsets.map { specialDaysForCategory[$0] }
        // Iterate and call the deletion method on the main ViewModel for each day.
        for day in daysToDelete {
            specialDaysListViewModel.deleteSpecialDay(id: day.id)
        }
    }
}
