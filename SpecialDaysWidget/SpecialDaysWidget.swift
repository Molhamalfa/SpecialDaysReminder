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

    // A URL for a new add event
    var addDayDeepLinkURL: URL? {
        return URL(string: "specialdaysreminder://add")
    }
}

// MARK: - Timeline Provider
// Responsible for providing the widget's timeline entries.
// It determines when and with what data the widget should update.
struct SpecialDaysTimelineProvider: TimelineProvider {
    // IMPORTANT: Ensure this matches the App Group ID in your SpecialDaysListViewModel
    private let appGroupIdentifier = "group.com.molham.SpecialDaysReminder" // Make sure this matches your unique App Group ID

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
        if let day = entry.specialDay {
            switch family {
            case .systemSmall:
                // Small widget layout
                VStack(alignment: .leading) {
                    Text(day.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                    Spacer()

                    VStack(alignment: .center, spacing: -5) {
                        Text(day.daysUntilDescription.replacingOccurrences(of: " days", with: "").replacingOccurrences(of: "Today!", with: "0").replacingOccurrences(of: "Tomorrow!", with: "1"))
                            .font(.system(size: 56))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)

                        Text("Days")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()

                    Text(day.formattedDate)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .widgetURL(entry.deepLinkURL)
                .containerBackground(for: .widget) {
                    day.category.color
                }

            case .systemMedium:
                // Medium widget layout with notes on the right side
                HStack(alignment: .top, spacing: 15) {
                    // Left side: Event details
                    VStack(alignment: .leading, spacing: 5) {
                        Text(day.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        Text("For: \(day.forWhom)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        Spacer()
                        
                        Text(day.daysUntilDescription)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right side: Notes
                    VStack(alignment: .trailing) {
                        Spacer()
                        
                        if let notes = day.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .italic()
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(nil)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .widgetURL(entry.deepLinkURL)
                .containerBackground(for: .widget) {
                    day.category.color
                }

            case .systemLarge:
                // Large widget layout
                VStack(alignment: .leading, spacing: 4) {
                    // Top row: Event details and buttons
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(day.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            Text("For: \(day.forWhom)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        
                        Spacer()
                        
                        // Buttons on the top right
                        HStack(spacing: 8) {
                            // "Add" button to create a new event
                            if let addURL = entry.addDayDeepLinkURL {
                                Link(destination: addURL) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            // "Edit" button to edit the current event
                            if let editURL = entry.deepLinkURL {
                                Link(destination: editURL) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    
                    // Spacer to push the notes to the middle
                    Spacer()
                    
                    // Display notes if they exist and are not empty
                    if let notes = day.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.white)
                            .lineLimit(nil) // Allow multiple lines
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal) // Add horizontal padding for readability
                    }

                    // Spacer to push the days until / date to the bottom
                    Spacer()
                    
                    // Days Until / Date at the bottom
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
                }
                .padding()
                .widgetURL(entry.deepLinkURL)
                .containerBackground(for: .widget) {
                    day.category.color
                }
            
            default:
                EmptyView()
            }
        } else {
            // No upcoming events message (common for all sizes)
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
            .padding()
            .containerBackground(for: .widget) {
                Color.gray.opacity(0.4)
            }
        }
    }
}

// MARK: - Widget Bundle
// The main entry point for the widget extension.
@main
struct SpecialDaysWidgetBundle: WidgetBundle {
    var body: some Widget {
        SpecialDaysWidget()
    }
}

// MARK: - Widget
// Defines the widget's configuration (kind, display name, description).
struct SpecialDaysWidget: Widget {
    let kind: String = "SpecialDaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpecialDaysTimelineProvider()) { entry in
            SpecialDaysWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Event")
        .description("View your next upcoming special day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
