//
//  SpecialDayModel.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation
import SwiftUI // Import SwiftUI for Color type

// MARK: - SpecialDayCategory Enum
// Defines the categories for special days.
// This helps in organizing events and filtering them for display.
// Conforms to Identifiable for SwiftUI lists, Codable for persistence.
public enum SpecialDayCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case lovedOnes = "Loved Ones"
    case friends = "Friends"
    case family = "Family"
    case work = "Work" // Example additional category
    case other = "Other"

    // Provides a localized display name for each category.
    public var displayName: String {
        return self.rawValue
    }

    // Conformance to Identifiable protocol
    public var id: String { self.rawValue }

    // Computed property to provide a Color for each category
    // REVERTED: Back to original solid Color values
    public var color: Color {
        switch self {
        case .lovedOnes: return .pink
        case .friends: return .blue
        case .family: return .green
        case .work: return .orange
        case .other: return .purple
        }
    }

    // Icon name for each category
    public var iconName: String {
        switch self {
        case .lovedOnes: return "heart.fill"
        case .friends: return "person.2.fill"
        case .family: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "star.fill"
        }
    }
}

// MARK: - SpecialDayModel
// Represents a single special day event.
// Conforms to Identifiable for SwiftUI lists, Codable for persistence,
// and Hashable for unique identification if needed in sets/dictionaries.
public struct SpecialDayModel: Identifiable, Codable, Hashable {
    // Unique identifier for each special day.
    // UUID is used to ensure global uniqueness.
    public let id: UUID

    // The name of the event (e.g., "Birthday", "Anniversary").
    public var name: String

    // The date of the special day.
    public var date: Date

    // The person or entity associated with the event.
    public var forWhom: String

    // The category of the special day (e.g., Loved Ones, Work).
    public var category: SpecialDayCategory

    // Optional notes for the special day.
    public var notes: String?

    // NEW: Reminder properties (These were removed in a later step, but this is the version requested)
    public var isReminderEnabled: Bool // Whether reminders are active for this event
    public var reminderFrequency: Int // How many notifications per day (e.g., 1, 2, 3)

    // MARK: - Initialization

    // Initializes a new SpecialDayModel with a generated UUID.
    public init(id: UUID = UUID(), name: String, date: Date, forWhom: String, category: SpecialDayCategory, notes: String? = nil, isReminderEnabled: Bool = false, reminderFrequency: Int = 1) { // UPDATED: Added new parameters with default values
        self.id = id
        self.name = name
        self.date = date
        self.forWhom = forWhom
        self.category = category
        self.notes = notes
        self.isReminderEnabled = isReminderEnabled // Initialize new property
        self.reminderFrequency = reminderFrequency // Initialize new property
    }

    // MARK: - Computed Properties (Business Logic)

    // Calculates the next upcoming occurrence date of the special day.
    // This handles events that recur yearly (like birthdays, anniversaries).
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

    // Provides a formatted date string for display.
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // e.g., "Jul 29, 2025"
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
