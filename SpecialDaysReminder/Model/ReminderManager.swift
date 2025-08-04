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
    // UPDATED: Added a completion handler to report authorization status back to the caller.
    func requestNotificationAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted.")
                completion(true, nil) // Report success
            } else if let error = error {
                print("Notification authorization denied: \(error.localizedDescription)")
                completion(false, error) // Report failure with error
            } else {
                print("Notification authorization denied (unknown reason).")
                completion(false, nil) // Report denial without specific error
            }
        }
    }

    // Checks the current notification authorization status.
    func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    // MARK: - Scheduling Reminders

    // Schedules notifications for upcoming special days.
    // It filters for events that are within `reminderStartDaysBefore` days.
    func scheduleReminders(for specialDays: [SpecialDayModel], frequencyPerDay: Int, atTimes reminderTimes: [Date]) {
        // First, cancel all existing reminders to avoid duplicates and outdated notifications.
        cancelAllReminders()

        let calendar = Calendar.current
        let now = Date()

        // Filter for relevant upcoming days (within the reminder window)
        let relevantDays = specialDays.filter { day in
            let daysUntil = day.daysUntil
            return daysUntil >= 0 && daysUntil <= ReminderManager.reminderStartDaysBefore
        }

        print("Scheduling reminders for \(relevantDays.count) relevant events...")

        for day in relevantDays {
            // Schedule multiple notifications per day based on frequency and times
            for (index, time) in reminderTimes.enumerated() {
                // Calculate the exact trigger date for this reminder
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: day.nextOccurrenceDate)
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                dateComponents.second = timeComponents.second

                if let triggerDate = calendar.date(from: dateComponents) {
                    // Ensure the trigger date is in the future
                    guard triggerDate > now else { continue }

                    let content = UNMutableNotificationContent()
                    content.title = "Special Day Reminder: \(day.name)"
                    content.body = "\(String(describing: day.forWhom))'s \(day.name) is \(day.daysUntilDescription)!"
                    content.sound = .default // Default notification sound

                    // Create a unique identifier for each notification
                    // Format: com.specialdaysreminder.eventReminder.<UUID>.<index>
                    let notificationIdentifier = "\(ReminderManager.notificationBaseIdentifier)\(day.id.uuidString).\(index)"

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false) // No repeat for individual notifications

                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

                    // Add the notification request to the UNUserNotificationCenter
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling notification for \(day.name): \(error.localizedDescription)")
                        } else {
                            print("Scheduled notification for \(day.name) on \(triggerDate.formatted()) with ID: \(notificationIdentifier)")
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
