//
//  SettingsViewModel.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import Foundation
import Combine
import UserNotifications // For checking notification authorization status
import SwiftUI // For Date type for reminderTime
import EventKit // For EKAuthorizationStatus

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    // Global toggle for enabling/disabling reminders for all events.
    @Published var isGlobalReminderEnabled: Bool = UserDefaults.standard.bool(forKey: Constants.UserDefaultKeys.isGlobalReminderEnabled) {
        didSet {
            // Persist the setting whenever it changes.
            UserDefaults.standard.set(isGlobalReminderEnabled, forKey: Constants.UserDefaultKeys.isGlobalReminderEnabled)
            // When the global reminder state changes, re-evaluate all reminders.
            updateAllReminders()
        }
    }

    // How many times a day the user wants to be reminded.
    @Published var globalReminderFrequency: Int = {
        let savedFrequency = UserDefaults.standard.integer(forKey: Constants.UserDefaultKeys.globalReminderFrequency)
        return savedFrequency == 0 ? 1 : savedFrequency // Default to 1 if not set
    }() {
        didSet {
            // Ensure frequency is at least 1 if enabled.
            if globalReminderFrequency < 1 { globalReminderFrequency = 1 }
            // Persist the setting whenever it changes.
            UserDefaults.standard.set(globalReminderFrequency, forKey: Constants.UserDefaultKeys.globalReminderFrequency)
            // Adjust the reminder times array size if frequency changes.
            adjustReminderTimesArray()
            // Re-evaluate all reminders when frequency changes.
            updateAllReminders()
        }
    }

    // Array of specific times for daily reminders.
    @Published var globalReminderTimes: [Date] = {
        if let savedTimesData = UserDefaults.standard.data(forKey: Constants.UserDefaultKeys.reminderTimes),
           let decodedTimes = try? JSONDecoder().decode([Date].self, from: savedTimesData) {
            return decodedTimes
        }
        // Default to a single 9 AM reminder if nothing is saved.
        return SettingsViewModel.generateDefaultReminderTimes(frequency: 1)
    }() {
        didSet {
            // Persist the setting whenever it changes.
            if let encoded = try? JSONEncoder().encode(globalReminderTimes) {
                UserDefaults.standard.set(encoded, forKey: Constants.UserDefaultKeys.reminderTimes)
            }
            // Re-evaluate all reminders when times change.
            updateAllReminders()
        }
    }

    // Tracks if notification authorization has been granted.
    @Published var notificationsAuthorized: Bool = false

    // REMOVED: Calendar authorization status and message
    // @Published var calendarAuthorized: Bool = false
    // @Published var calendarImportMessage: String?

    // MARK: - Private Properties

    // Reference to the main SpecialDaysListViewModel to access and modify the global list of special days.
    private var specialDaysListViewModel: SpecialDaysListViewModel

    // Manages scheduling and canceling of local notifications.
    private let reminderManager = ReminderManager()

    // REMOVED: CalendarManager instance
    // private let calendarManager = CalendarManager()

    // Set to hold Combine cancellables to prevent memory leaks.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(specialDaysListViewModel: SpecialDaysListViewModel) {
        self.specialDaysListViewModel = specialDaysListViewModel

        // Adjust reminder times array initially based on loaded frequency
        adjustReminderTimesArray()

        // Observe changes in the main specialDays list to re-schedule reminders.
        specialDaysListViewModel.$specialDays
            .sink { [weak self] _ in
                self?.updateAllReminders()
            }
            .store(in: &cancellables)

        // Check initial notification authorization status
        checkNotificationAuthorizationStatus()
        // REMOVED: Initial calendar authorization status check
        // checkCalendarAuthorizationStatus()
    }

    // MARK: - Notification Management

    // Requests notification authorization from the user.
    func requestNotificationAuthorization() {
        // FIX: Call reminderManager.requestNotificationAuthorization with the completion handler.
        reminderManager.requestNotificationAuthorization { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationsAuthorized = granted
                if !granted {
                    // Optionally, guide user to settings if denied
                    // UPDATED: Removed direct calendarImportMessage as it's no longer in this ViewModel
                    // self?.calendarImportMessage = "Notifications denied. Please enable in Settings."
                } else {
                    self?.updateAllReminders() // Schedule if granted
                }
            }
        }
    }

    // Checks the current notification authorization status.
    func checkNotificationAuthorizationStatus() {
        // UPDATED: Use the new getNotificationAuthorizationStatus from ReminderManager
        reminderManager.getNotificationAuthorizationStatus { [weak self] status in
            DispatchQueue.main.async {
                // Address deprecation warning by checking for more specific statuses.
                // If status is not denied or not determined, we consider it authorized for general purposes.
                self?.notificationsAuthorized = (status != .denied && status != .notDetermined)
                
                // If authorization is denied, disable global reminders
                if status == .denied {
                    self?.isGlobalReminderEnabled = false
                }
                self?.updateAllReminders() // Update reminders based on current status
            }
        }
    }

    // MARK: - Calendar Import Management (REMOVED from this ViewModel)

    // REMOVED: requestCalendarAuthorization()
    // REMOVED: checkCalendarAuthorizationStatus()
    // REMOVED: importCalendarEvents()

    // MARK: - Helper Methods

    // Generates default reminder times based on frequency.
    static func generateDefaultReminderTimes(frequency: Int) -> [Date] {
        var times: [Date] = []
        let calendar = Calendar.current
        let now = Date()

        switch frequency {
        case 1:
            // Default 9 AM
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now)
        case 2:
            // Default 9 AM, 3 PM
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now)
            times.append(calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now) ?? now)
        case 3:
            // Default 9 AM, 1 PM, 5 PM
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now)
            times.append(calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now) ?? now)
            times.append(calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now)
        default:
            // Fallback to 9 AM
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now)
        }
        return times
    }

    // Adjusts the `globalReminderTimes` array size and content when `globalReminderFrequency` changes.
    private func adjustReminderTimesArray() {
        if globalReminderTimes.count != globalReminderFrequency {
            // If frequency increases, add default times.
            // If frequency decreases, truncate the array.
            globalReminderTimes = SettingsViewModel.generateDefaultReminderTimes(frequency: globalReminderFrequency)
        }
    }

    // Re-evaluates and schedules/cancels all reminders based on current global settings.
    private func updateAllReminders() {
        if isGlobalReminderEnabled && notificationsAuthorized {
            // Schedule reminders for all events that are close, passing the selected times.
            reminderManager.scheduleReminders(
                for: specialDaysListViewModel.specialDays,
                frequencyPerDay: globalReminderFrequency,
                atTimes: globalReminderTimes
            )
        } else {
            // If global reminders are disabled or not authorized, cancel all.
            reminderManager.cancelAllReminders()
        }
    }
}

// MARK: - Constants for UserDefaults Keys
private struct Constants {
    struct UserDefaultKeys {
        static let isGlobalReminderEnabled = "isGlobalReminderEnabled"
        static let globalReminderFrequency = "globalReminderFrequency"
        static let reminderTimes = "reminderTimes" // Key for array of times
    }
}
