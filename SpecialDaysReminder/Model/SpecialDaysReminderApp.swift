//
//  SpecialDaysReminderApp.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

@main
struct SpecialDaysReminderApp: App {
    // State to hold the category from a deep link (e.g., from a widget)
    @State private var deepLinkCategory: SpecialDayCategory? = nil
    // New state to hold the event ID from a deep link (e.g., from a widget)
    @State private var deepLinkEventID: UUID? = nil
    // State to trigger showing the AddSpecialDaySheet from a deep link
    @State private var deepLinkAddEvent: Bool = false

    // NEW: Instance of CalendarManager to request authorization at app launch
    @StateObject private var calendarManager = CalendarManager()

    var body: some Scene {
        WindowGroup {
            // Pass the deepLinkCategory, deepLinkEventID, and deepLinkAddEvent as bindings to SpecialDaysListView
            SpecialDaysListView(deepLinkCategory: $deepLinkCategory, deepLinkEventID: $deepLinkEventID, deepLinkAddEvent: $deepLinkAddEvent)
                .preferredColorScheme(.light) // NEW: Force light mode for the entire app
                // Handle incoming URLs from widgets or other sources
                .onOpenURL { url in
                    // Example URL for category: specialdaysreminder://category?id=Loved%20Ones
                    // Example URL for event: specialdaysreminder://event?id=<UUID_STRING>
                    // NEW: Example URL for add: specialdaysreminder://add

                    guard url.scheme == "specialdaysreminder" else {
                        return // Not our app's scheme
                    }

                    // Reset all deep link states before processing new one
                    self.deepLinkCategory = nil
                    self.deepLinkEventID = nil
                    self.deepLinkAddEvent = false

                    if url.host == "category",
                       let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let queryItems = components.queryItems,
                       let categoryID = queryItems.first(where: { $0.name == "id" })?.value {

                        if let category = SpecialDayCategory(rawValue: categoryID) {
                            self.deepLinkCategory = category
                        } else {
                            self.deepLinkCategory = nil // Fallback to showing all days or default
                        }
                    } else if url.host == "event",
                              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                              let queryItems = components.queryItems,
                              let eventIDString = queryItems.first(where: { $0.name == "id" })?.value,
                              let eventID = UUID(uuidString: eventIDString) {
                        self.deepLinkEventID = eventID
                    } else if url.host == "add" {
                        self.deepLinkAddEvent = true
                    } else {
                        // Handle unknown or malformed deep links
                        // (States already reset above)
                    }
                }
                // NEW: Request calendar authorization when the app first appears
                .onAppear {
                    calendarManager.requestCalendarAuthorization { granted, error in
                        // This completion block is primarily for logging/debugging the initial request.
                        // The SettingsViewModel will check the status independently.
                        if granted {
                            print("Initial calendar authorization request granted.")
                        } else {
                            print("Initial calendar authorization request denied or failed: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
        }
    }
}
