//
//  SpecialDayModel.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation

// MARK: - SpecialDayCategory Enum
// Defines the categories for special days.
// This helps in organizing events and filtering them for display.
// Conforms to Identifiable for SwiftUI lists, Codable for persistence.
public enum SpecialDayCategory: String, CaseIterable, Codable, Identifiable { // Made public for potential cross-module access
    case lovedOnes = "Loved Ones"
    case friends = "Friends"
    case family = "Family"
    case work = "Work" // Example additional category
    case other = "Other"

    // Provides a localized display name for each category.
    public var displayName: String { // Made public
        return self.rawValue
    }

    // Conformance to Identifiable protocol
    public var id: String { self.rawValue } // Made public
}

// MARK: - SpecialDayModel
// Represents a single special day event.
// Conforms to Identifiable for SwiftUI lists, Codable for persistence,
// and Hashable for unique identification if needed in sets/dictionaries.
public struct SpecialDayModel: Identifiable, Codable, Hashable { // Made public
    // Unique identifier for each special day.
    // UUID is used to ensure global uniqueness.
    public let id: UUID

    // The name of the event (e.g., "Birthday", "Anniversary").
    public var name: String

    // The date of the special day.
    public var date: Date

    // The person or entity associated with the special day (e.g., "Mom", "John Doe").
    public var forWhom: String

    // The category this special day belongs to.
    public var category: SpecialDayCategory

    // Optional notes for the special day.
    public var notes: String?

    // Initializes a new SpecialDayModel instance.
    // A default UUID is generated if not provided.
    public init(id: UUID = UUID(), name: String, date: Date, forWhom: String, category: SpecialDayCategory, notes: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.forWhom = forWhom
        self.category = category
        self.notes = notes
    }

    // MARK: - Helper Properties (Computed)

    // Formats the date for display.
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // e.g., "July 27, 2025"
        return formatter.string(from: date)
    }

    // Computed property to get the actual Date object for the next upcoming occurrence.
    public var nextOccurrenceDate: Date {
        let calendar = Calendar.current
        let now = Date()

        var components = DateComponents()
        components.year = calendar.component(.year, from: now)
        components.month = calendar.component(.month, from: date)
        components.day = calendar.component(.day, from: date)

        var eventDateThisYear = calendar.date(from: components)!

        // If the event has already passed this year, set it for next year
        if eventDateThisYear < now {
            components.year = calendar.component(.year, from: now) + 1
            eventDateThisYear = calendar.date(from: components)!
        }
        return eventDateThisYear
    }


    // Calculates the number of days until the special day's next upcoming occurrence.
    // This will always return a non-negative value for the next future event.
    public var daysUntil: Int {
        let calendar = Calendar.current
        let now = Date() // Use current date and time for comparison

        // Calculate the difference in days from now to the upcoming event date
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: nextOccurrenceDate)).day ?? 0
        return days
    }

    // Provides a human-readable string for the days until the event.
    public var daysUntilDescription: String {
        let days = daysUntil
        if days == 0 {
            return "Today!"
        } else if days == 1 {
            return "Tomorrow!"
        } else {
            return "\(days) days"
        }
    }
}

