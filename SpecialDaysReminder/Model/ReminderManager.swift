//
//  ReminderManager.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation
import UserNotifications // Required for local notifications
import SwiftUI // For Color type (if needed for notification content, e.g., category color)

// MARK: - ReminderManager
// This class handles the scheduling and management of local notifications for special days.
// It interacts with the UserNotifications framework.
class ReminderManager {

    // MARK: - Constants
    
    // Base identifier for notification requests to easily manage them.
    // Each event's notifications will have a unique identifier based on this.
    private static let notificationBaseIdentifier = "com.specialdaysreminder.eventReminder."

    // The number of days before an event when reminders should start.
    private static let reminderStartDaysBefore: Int = 3

    // MARK: - Notification Permissions

    // Requests notification authorization from the user.
    // This should be called early in the app lifecycle (e.g., on app launch or when user tries to enable reminders).
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization denied: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Scheduling Reminders

    // Schedules reminders for a list of special days based on global settings.
    // Reminders will be scheduled for events that are within the 'reminderStartDaysBefore' window.
    // frequencyPerDay: How many notifications to send per day (e.g., 1 for once a day, 2 for twice a day).
    // atTimes: An array of specific times of day (hour and minute) when notifications should be sent.
    func scheduleReminders(for specialDays: [SpecialDayModel], frequencyPerDay: Int, atTimes: [Date]) { // CHANGED: Parameter name and type to [Date]
        // First, cancel all existing reminders to ensure a clean slate before rescheduling.
        // This prevents duplicate notifications or lingering old reminders.
        cancelAllReminders() // Cancel all before rescheduling specific ones

        guard frequencyPerDay > 0 else {
            print("Reminder frequency is invalid. Not scheduling any reminders.")
            return
        }
        
        // Ensure the number of provided times matches the frequency
        guard atTimes.count == frequencyPerDay else {
            print("Number of provided reminder times (\(atTimes.count)) does not match frequency per day (\(frequencyPerDay)). Not scheduling reminders.")
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        // Filter for events that are within the reminder window (today or in the next 3 days).
        let relevantDays = specialDays.filter { day in
            let eventDate = day.nextOccurrenceDate
            let daysUntilEvent = calendar.dateComponents([.day], from: startOfToday, to: calendar.startOfDay(for: eventDate)).day ?? 0
            return daysUntilEvent <= ReminderManager.reminderStartDaysBefore && daysUntilEvent >= 0
        }

        // Schedule notifications for each relevant day.
        for day in relevantDays {
            let eventDate = day.nextOccurrenceDate
            let daysUntilEvent = calendar.dateComponents([.day], from: startOfToday, to: calendar.startOfDay(for: eventDate)).day ?? 0

            // Schedule notifications for each day from today until the event day.
            for i in 0...daysUntilEvent {
                guard let reminderDate = calendar.date(byAdding: .day, value: i, to: startOfToday) else { continue }

                for timeDate in atTimes { // Iterate through the provided 'atTimes' array
                    let reminderHour = calendar.component(.hour, from: timeDate)
                    let reminderMinute = calendar.component(.minute, from: timeDate)

                    var triggerDateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
                    triggerDateComponents.hour = reminderHour
                    triggerDateComponents.minute = reminderMinute

                    guard let triggerDate = calendar.date(from: triggerDateComponents) else { continue }

                    // Ensure we don't schedule for times already past today
                    if triggerDate > now {
                        let content = UNMutableNotificationContent()
                        content.title = "Special Day Reminder: \(day.name)"
                        content.body = "\(day.daysUntilDescription) until \(day.name) for \(day.forWhom)!"
                        content.sound = .default // Play default notification sound

                        // Add user info for deep linking or context
                        content.userInfo = ["eventID": day.id.uuidString]

                        // Create a unique identifier for each notification request.
                        let notificationIdentifier = "\(ReminderManager.notificationBaseIdentifier)\(day.id.uuidString).\(calendar.component(.year, from: triggerDate))-\(calendar.component(.month, from: triggerDate))-\(calendar.component(.day, from: triggerDate))-\(reminderHour)-\(reminderMinute)"

                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Error scheduling notification for \(day.name) (ID: \(day.id)): \(error.localizedDescription)")
                            } else {
                                print("Scheduled notification for \(day.name) on \(triggerDate.formatted()) with ID: \(notificationIdentifier)")
                            }
                        }
                    }
                }
            }
        }
        print("Completed scheduling reminders for \(relevantDays.count) relevant events.")
    }

    // MARK: - Canceling Reminders

    // Cancels all pending notifications for a specific special day.
    // This is useful if an event is deleted or its reminder status changes.
    func cancelReminders(for day: SpecialDayModel) {
        let identifierPrefix = "\(ReminderManager.notificationBaseIdentifier)\(day.id.uuidString)"
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.filter { $0.identifier.hasPrefix(identifierPrefix) }.map { $0.identifier }
            if !identifiersToCancel.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
                print("Canceled \(identifiersToCancel.count) pending notifications for \(day.name).")
            }
        }
    }

    // Cancels all pending notifications for all special days.
    // Useful for global reminder disable or app uninstall.
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Canceled all pending notifications.")
    }
}
