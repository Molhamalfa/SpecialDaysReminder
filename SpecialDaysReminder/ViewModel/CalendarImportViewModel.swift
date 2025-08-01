//
//  CalendarImportViewModel.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation
import EventKit
import Combine
import SwiftUI // For Date type

// MARK: - ImportableCalendarEvent
// A helper struct to wrap an EKEvent and add a selection state for the UI.
struct ImportableCalendarEvent: Identifiable {
    let id = UUID() // Unique ID for SwiftUI ForEach
    let ekEvent: EKEvent
    var isSelected: Bool = false

    // Computed property to easily access the start date for sorting/display
    var startDate: Date {
        ekEvent.startDate ?? Date()
    }
}

// MARK: - CalendarImportViewModel
// This ViewModel handles the logic for importing events from the iOS Calendar.
class CalendarImportViewModel: ObservableObject {

    // MARK: - Published Properties

    // The list of calendar events fetched from EventKit, with selection state.
    @Published var importableEvents: [ImportableCalendarEvent] = []
    // Tracks if calendar authorization has been granted.
    @Published var calendarAuthorized: Bool = false
    // Message to display to the user regarding authorization or import status.
    @Published var statusMessage: String?
    // Indicates if events are currently being loaded.
    @Published var isLoading: Bool = false

    // MARK: - Private Properties

    // Manager to interact with EventKit.
    private let calendarManager = CalendarManager()
    // Reference to the main ViewModel to add imported special days.
    private var specialDaysListViewModel: SpecialDaysListViewModel
    // Set to hold Combine cancellables.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(specialDaysListViewModel: SpecialDaysListViewModel) {
        self.specialDaysListViewModel = specialDaysListViewModel
        // Check authorization status immediately when the ViewModel is created.
        checkCalendarAuthorizationStatus()
    }

    // MARK: - Authorization and Event Fetching

    // Checks the current calendar authorization status and updates `calendarAuthorized`.
    func checkCalendarAuthorizationStatus() {
        DispatchQueue.main.async {
            let status = self.calendarManager.getAuthorizationStatus()
            if #available(iOS 17.0, *) {
                self.calendarAuthorized = (status == .fullAccess)
            } else {
                self.calendarAuthorized = (status == .authorized)
            }

            if !self.calendarAuthorized && status != .notDetermined {
                self.statusMessage = "Calendar access denied. Please enable in iOS Settings to import events."
            } else if self.calendarAuthorized {
                self.statusMessage = nil // Clear message if authorized
                self.fetchCalendarEvents() // Fetch events if already authorized
            }
        }
    }

    // Requests calendar authorization from the user.
    func requestCalendarAuthorization() {
        isLoading = true
        statusMessage = "Requesting calendar access..."
        calendarManager.requestCalendarAuthorization { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.calendarAuthorized = granted
                if granted {
                    self?.statusMessage = nil
                    self?.fetchCalendarEvents() // Fetch events if access granted
                } else {
                    self?.statusMessage = "Calendar access denied: \(error?.localizedDescription ?? "Unknown error"). Please enable in iOS Settings."
                }
            }
        }
    }

    // Fetches events from the calendar for the next year, filtering out past events.
    func fetchCalendarEvents() {
        guard calendarAuthorized else {
            statusMessage = "Calendar access not authorized. Cannot fetch events."
            return
        }

        isLoading = true
        statusMessage = "Loading events from calendar..."

        // FIX 1: Start date is now the current date to avoid past events
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate

        calendarManager.fetchEvents(startDate: startDate, endDate: endDate) { [weak self] ekEvents in // UPDATED: Receive [EKEvent]
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                // Convert fetched EKEvent to ImportableCalendarEvent
                // Filter out events that are already in the app and events that have already passed
                self.importableEvents = ekEvents.compactMap { ekEvent in
                    // Ensure event has a valid start date and is not in the past
                    guard let eventStartDate = ekEvent.startDate, eventStartDate >= Date() else { // FIX 1: Filter out past events
                        return nil
                    }

                    // Convert EKEvent to a temporary SpecialDayModel for duplicate checking
                    let tempSpecialDay = self.convertEKEventToSpecialDayModel(ekEvent: ekEvent)

                    let isDuplicate = self.specialDaysListViewModel.specialDays.contains { existingDay in
                        existingDay.name == tempSpecialDay.name &&
                        Calendar.current.isDate(existingDay.date, inSameDayAs: tempSpecialDay.date) &&
                        existingDay.forWhom == tempSpecialDay.forWhom
                    }
                    return isDuplicate ? nil : ImportableCalendarEvent(ekEvent: ekEvent) // FIX 2: Directly wrap the EKEvent
                }

                // Sort events by date
                self.importableEvents.sort { $0.startDate < $1.startDate }

                if self.importableEvents.isEmpty {
                    self.statusMessage = "No new upcoming events found in your calendar for import."
                } else {
                    self.statusMessage = "Select events to import."
                }
            }
        }
    }
    
    // Helper to convert EKEvent to SpecialDayModel (used internally for duplicate check and import)
    private func convertEKEventToSpecialDayModel(ekEvent: EKEvent) -> SpecialDayModel {
        let category: SpecialDayCategory
        let lowercasedTitle = ekEvent.title?.lowercased() ?? ""
        let lowercasedCalendarTitle = ekEvent.calendar.title.lowercased()

        if lowercasedTitle.contains("birthday") || lowercasedTitle.contains("anniversary") || lowercasedCalendarTitle.contains("personal") {
            category = .lovedOnes
        } else if lowercasedTitle.contains("meeting") || lowercasedTitle.contains("work") || lowercasedCalendarTitle.contains("work") {
            category = .work
        } else if lowercasedTitle.contains("family") || lowercasedCalendarTitle.contains("family") {
            category = .family
        } else if lowercasedTitle.contains("friend") || lowercasedCalendarTitle.contains("friends") {
            category = .friends
        } else {
            category = .other
        }

        return SpecialDayModel(
            name: ekEvent.title ?? "Unknown Event",
            date: ekEvent.startDate ?? Date(),
            forWhom: ekEvent.notes ?? "N/A", // Use notes for 'forWhom' or default
            category: category,
            notes: ekEvent.notes,
            isReminderEnabled: false,
            reminderFrequency: 1
        )
    }


    // MARK: - Selection Management

    // Toggles the selection state of an event.
    func toggleSelection(for event: ImportableCalendarEvent) {
        if let index = importableEvents.firstIndex(where: { $0.id == event.id }) {
            importableEvents[index].isSelected.toggle()
        }
    }

    // MARK: - Import Action

    // Imports all selected events into the main SpecialDaysListViewModel.
    func importSelectedEvents() {
        let selectedDays = importableEvents.filter { $0.isSelected }.compactMap { importableEvent -> SpecialDayModel? in
            // Convert EKEvent to SpecialDayModel using the helper function
            return self.convertEKEventToSpecialDayModel(ekEvent: importableEvent.ekEvent)
        }

        if selectedDays.isEmpty {
            statusMessage = "No events selected for import."
            return
        }

        for day in selectedDays {
            // Add to the main ViewModel, which handles persistence and duplicate checks
            specialDaysListViewModel.addSpecialDay(day)
        }
        statusMessage = "Successfully imported \(selectedDays.count) event(s)."
        // Clear selected events from the list after import
        importableEvents.removeAll { $0.isSelected }
    }
}

// REMOVED: SpecialDayModel.toEKEvent() extension as it's not needed for this import flow.
/*
extension SpecialDayModel {
    func toEKEvent() -> EKEvent {
        let event = EKEvent(eventStore: EKEventStore())
        event.title = self.name
        event.startDate = self.date
        event.endDate = self.date // Assuming single-day events for simplicity
        event.notes = self.notes
        // No direct mapping for 'forWhom' or 'category' in EKEvent, but we can put it in notes
        return event
    }
}
*/
