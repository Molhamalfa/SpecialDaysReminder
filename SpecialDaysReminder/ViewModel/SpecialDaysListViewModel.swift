//
//  SpecialDaysListViewModel.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation
import Combine
import WidgetKit // Needed for WidgetCenter

// MARK: - SpecialDaysListViewModel
// This ViewModel manages the collection of SpecialDayModel objects.
// It handles data loading, saving, and provides methods for adding,
// editing, and deleting special days.
// It conforms to `ObservableObject` to allow SwiftUI views to react to its changes.
class SpecialDaysListViewModel: ObservableObject {

    // MARK: - Properties

    @Published var specialDays: [SpecialDayModel] = [] {
        // Property observer: whenever `specialDays` changes, save the data.
        didSet {
            saveSpecialDays()
        }
    }

    // Key for UserDefaults to store and retrieve our special days.
    private let userDefaultsKey = "specialDays"
    // App Group Identifier for shared UserDefaults
    private let appGroupIdentifier = "group.com.molham.SpecialDaysReminder" // IMPORTANT: Replace with your actual App Group ID
    private var sharedUserDefaults: UserDefaults?

    // MARK: - Initialization

    init() {
        // Initialize sharedUserDefaults with the App Group suite name
        sharedUserDefaults = UserDefaults(suiteName: appGroupIdentifier)
        loadSpecialDays() // Load existing data when the ViewModel is created.
    }

    // MARK: - Data Persistence (Using UserDefaults)

    // Saves the current list of special days to UserDefaults.
    // Error handling is included to catch potential encoding issues.
    private func saveSpecialDays() {
        guard let sharedUserDefaults = sharedUserDefaults else {
            print("Shared UserDefaults not initialized.")
            return
        }
        if let encoded = try? JSONEncoder().encode(specialDays) {
            sharedUserDefaults.set(encoded, forKey: userDefaultsKey)
            print("Special days saved successfully to App Group.")
            // Notify WidgetKit that its timeline needs to be reloaded
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            print("Failed to encode special days for saving.")
        }
    }

    // Loads special days from UserDefaults.
    // Error handling is included to catch potential decoding issues.
    private func loadSpecialDays() {
        guard let sharedUserDefaults = sharedUserDefaults else {
            print("Shared UserDefaults not initialized. Initializing with sample data.")
            // Initialize with sample data if sharedUserDefaults isn't available
            self.specialDays = [
                SpecialDayModel(name: "Birthday", date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, forWhom: "Mom", category: .lovedOnes),
                SpecialDayModel(name: "Anniversary", date: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, forWhom: "Sarah & Mark", category: .friends),
                SpecialDayModel(name: "Graduation", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, forWhom: "Brother", category: .family),
                SpecialDayModel(name: "Project Deadline", date: Calendar.current.date(byAdding: .day, value: 20, to: Date())!, forWhom: "Work Team", category: .work),
                SpecialDayModel(name: "Pet's Birthday", date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, forWhom: "Fluffy", category: .other)
            ]
            return
        }

        if let savedSpecialDays = sharedUserDefaults.data(forKey: userDefaultsKey) {
            if let decodedDays = try? JSONDecoder().decode([SpecialDayModel].self, from: savedSpecialDays) {
                self.specialDays = decodedDays
                print("Special days loaded successfully from App Group.")
                return
            } else {
                print("Failed to decode special days from saved data.")
            }
        }
        // If no data or decoding fails, initialize with some sample data for demonstration.
        self.specialDays = [
            SpecialDayModel(name: "Birthday", date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, forWhom: "Mom", category: .lovedOnes),
            SpecialDayModel(name: "Anniversary", date: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, forWhom: "Sarah & Mark", category: .friends),
            SpecialDayModel(name: "Graduation", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, forWhom: "Brother", category: .family),
            SpecialDayModel(name: "Project Deadline", date: Calendar.current.date(byAdding: .day, value: 20, to: Date())!, forWhom: "Work Team", category: .work),
            SpecialDayModel(name: "Pet's Birthday", date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, forWhom: "Fluffy", category: .other)
        ]
        saveSpecialDays() // Save sample data immediately after creation
    }

    // MARK: - Public Methods for Managing Special Days

    // Adds a new special day to the collection.
    func addSpecialDay(_ day: SpecialDayModel) {
        specialDays.append(day)
        // `didSet` on `specialDays` will automatically call `saveSpecialDays()`
    }

    // Updates an existing special day.
    func updateSpecialDay(_ day: SpecialDayModel) {
        if let index = specialDays.firstIndex(where: { $0.id == day.id }) {
            specialDays[index] = day
            // `didSet` on `specialDays` will automatically call `saveSpecialDays()`
        }
    }

    // Deletes a special day by its ID.
    func deleteSpecialDay(id: UUID) {
        specialDays.removeAll { $0.id == id }
        // `didSet` on `specialDays` will automatically call `saveSpecialDays()`
    }

    // Deletes special days at specified offsets (useful for SwiftUI's onDelete modifier).
    func deleteSpecialDays(at offsets: IndexSet) {
        specialDays.remove(atOffsets: offsets)
        // `didSet` on `specialDays` will automatically call `saveSpecialDays()`
    }

    // MARK: - Filtering and Sorting (Business Logic)

    // Returns special days sorted by the closest upcoming date.
    var upcomingSpecialDays: [SpecialDayModel] {
        return specialDays.sorted { $0.daysUntil < $1.daysUntil }
    }

    // Returns special days filtered by a specific category.
    func specialDays(for category: SpecialDayCategory) -> [SpecialDayModel] {
        return specialDays.filter { $0.category == category }
            .sorted { $0.daysUntil < $1.daysUntil } // Also sort within categories
    }

    // Returns the next upcoming special day across all categories.
    var nextUpcomingDay: SpecialDayModel? {
        return upcomingSpecialDays.first
    }
}
