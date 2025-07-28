//
//  SpecialDaysWidget.swift
//  SpecialDaysWidget
//
//  Created by YourName on Date.
//

import WidgetKit
import SwiftUI
import Foundation // For Date and UUID

// MARK: - Widget Entry
// Defines the data structure for a single entry in the widget's timeline.
// It holds the SpecialDayModel that the widget will display.
struct SpecialDaysWidgetEntry: TimelineEntry {
    let date: Date // The date for which this entry is valid
    let specialDay: SpecialDayModel? // The next upcoming special day, or nil if none

    // A URL to open the app to a specific event when the widget is tapped.
    // This will be used for deep linking.
    var deepLinkURL: URL? {
        if let day = specialDay {
            // Construct a URL that includes the event's UUID
            return URL(string: "specialdaysreminder://event?id=\(day.id.uuidString)")
        }
        return nil
    }
}

// MARK: - Timeline Provider
// Responsible for providing the widget's timeline entries.
// It determines when and with what data the widget should update.
struct SpecialDaysTimelineProvider: TimelineProvider {
    // IMPORTANT: Ensure this matches the App Group ID in your SpecialDaysListViewModel
    private let appGroupIdentifier = "group.com.molham.SpecialDaysReminder"

    // Helper to get shared UserDefaults
    private var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    // Placeholder content for the widget gallery.
    func placeholder(in context: Context) -> SpecialDaysWidgetEntry {
        // Provide a sample special day for the placeholder
        let sampleDay = SpecialDayModel(name: "Sample Event", date: Date().addingTimeInterval(86400 * 5), forWhom: "Preview", category: .other, notes: "This is a sample event for the widget preview.")
        return SpecialDaysWidgetEntry(date: Date(), specialDay: sampleDay)
    }

    // Provides a single, current entry for quick previews.
    func getSnapshot(in context: Context, completion: @escaping (SpecialDaysWidgetEntry) -> Void) {
        let entry: SpecialDaysWidgetEntry
        if context.isPreview {
            // Use a placeholder for quick previews
            let sampleDay = SpecialDayModel(name: "Sample Event", date: Date().addingTimeInterval(86400 * 5), forWhom: "Preview", category: .other, notes: "This is a sample event for the widget preview.")
            entry = SpecialDaysWidgetEntry(date: Date(), specialDay: sampleDay)
        } else {
            // Fetch the actual next upcoming day
            entry = fetchNextUpcomingDayEntry()
        }
        completion(entry)
    }

    // Provides a timeline of entries for the widget to display over time.
    func getTimeline(in context: Context, completion: @escaping (Timeline<SpecialDaysWidgetEntry>) -> Void) {
        var entries: [SpecialDaysWidgetEntry] = []

        // Get the current entry
        let currentEntry = fetchNextUpcomingDayEntry()
        entries.append(currentEntry)

        // Schedule the next update.
        // If there's an upcoming day, refresh at its occurrence.
        // Otherwise, refresh daily to check for new events.
        let nextUpdateDate: Date
        if let nextDay = currentEntry.specialDay {
            // Schedule update for the day of the event, or tomorrow if it's today
            let calendar = Calendar.current
            let startOfNextDay = calendar.startOfDay(for: nextDay.nextOccurrenceDate).addingTimeInterval(86400) // Start of the day after the event
            nextUpdateDate = startOfNextDay
        } else {
            // No events, refresh daily to check for new ones
            nextUpdateDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }

        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }

    // MARK: - Data Fetching Logic (Business Logic for Widget)
    // This function encapsulates the logic to load special days and find the next upcoming one.
    private func fetchNextUpcomingDayEntry() -> SpecialDaysWidgetEntry {
        guard let sharedUserDefaults = sharedUserDefaults else {
            print("Widget: Shared UserDefaults not available.")
            return SpecialDaysWidgetEntry(date: Date(), specialDay: nil)
        }

        if let savedData = sharedUserDefaults.data(forKey: "specialDays") {
            do {
                let decoder = JSONDecoder()
                let loadedDays = try decoder.decode([SpecialDayModel].self, from: savedData)
                let nextUpcomingDay = loadedDays.sorted { $0.daysUntil < $1.daysUntil }.first(where: { $0.daysUntil >= 0 })
                return SpecialDaysWidgetEntry(date: Date(), specialDay: nextUpcomingDay)
            } catch {
                print("Widget: Failed to decode special days: \(error)")
                return SpecialDaysWidgetEntry(date: Date(), specialDay: nil)
            }
        }
        return SpecialDaysWidgetEntry(date: Date(), specialDay: nil)
    }
}

// MARK: - Widget View
// The SwiftUI view that defines the appearance of the widget.
struct SpecialDaysWidgetView: View {
    let entry: SpecialDaysWidgetEntry
    @Environment(\.widgetFamily) var family // To adapt UI for different widget sizes

    var body: some View {
        ZStack {
            // Background based on widget family or a default
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all) // Ensure gradient fills the entire widget area

            VStack(alignment: .leading, spacing: 4) {
                if let day = entry.specialDay {
                    // Event Name
                    Text(day.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    // For Whom
                    Text("For: \(day.forWhom)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer()

                    // Days Until / Date
                    HStack {
                        Text(day.daysUntilDescription)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(5)

                        Spacer()

                        Text(day.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 4)

                    // Show notes indicator for medium/large widgets
                    if family != .systemSmall && (day.notes != nil && !day.notes!.isEmpty) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("Has Notes")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(.top, 2)
                    }

                } else {
                    // No upcoming events message
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "calendar.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 5)
                        Text("No Upcoming Special Days")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Add new events in the app!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding() // Add padding around the content
        }
        // Make the entire widget tappable for deep linking
        .widgetURL(entry.deepLinkURL)
    }
}

// MARK: - Widget Bundle
// The main entry point for the widget extension.
// This is the essential declaration for your widget extension to function.
@main
struct SpecialDaysWidgetBundle: WidgetBundle {
    var body: some Widget {
        SpecialDaysWidget() // Register the widget
    }
}

// MARK: - SpecialDaysWidget
// Defines the widget's configuration (kind, display name, description).
struct SpecialDaysWidget: Widget {
    let kind: String = "SpecialDaysWidget" // Unique identifier for the widget

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpecialDaysTimelineProvider()) { entry in
            SpecialDaysWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Event") // Name shown in widget gallery
        .description("View your next upcoming special day.") // Description in widget gallery
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge]) // Supported widget sizes
    }
}
