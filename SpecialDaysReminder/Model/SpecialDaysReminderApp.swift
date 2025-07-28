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

    var body: some Scene {
        WindowGroup {
            // Pass the deepLinkCategory and deepLinkEventID as bindings to SpecialDaysListView
            SpecialDaysListView(deepLinkCategory: $deepLinkCategory, deepLinkEventID: $deepLinkEventID)
                // Handle incoming URLs from widgets or other sources
                .onOpenURL { url in
                    // Example URL for category: specialdaysreminder://category?id=Loved%20Ones
                    // Example URL for event: specialdaysreminder://event?id=<UUID_STRING>

                    guard url.scheme == "specialdaysreminder" else {
                        return // Not our app's scheme
                    }

                    if url.host == "category",
                       let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let queryItems = components.queryItems,
                       let categoryID = queryItems.first(where: { $0.name == "id" })?.value {

                        // Attempt to find the SpecialDayCategory matching the ID
                        if let category = SpecialDayCategory(rawValue: categoryID) {
                            self.deepLinkCategory = category
                            self.deepLinkEventID = nil // Reset event ID if category link
                        } else {
                            // Handle cases where the category ID is invalid or "All Special Days" equivalent
                            if categoryID == "All Special Days" || categoryID == "Other" {
                                self.deepLinkCategory = nil // Set to nil to show all days
                                self.deepLinkEventID = nil // Reset event ID
                            } else {
                                self.deepLinkCategory = nil // Fallback to showing all days or default
                                self.deepLinkEventID = nil // Reset event ID
                            }
                        }
                    } else if url.host == "event",
                              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                              let queryItems = components.queryItems,
                              let eventIDString = queryItems.first(where: { $0.name == "id" })?.value,
                              let eventID = UUID(uuidString: eventIDString) {
                        self.deepLinkEventID = eventID
                        self.deepLinkCategory = nil // Reset category if event link
                    } else {
                        // Handle unknown or malformed deep links
                        self.deepLinkCategory = nil
                        self.deepLinkEventID = nil
                    }
                }
        }
    }
}
