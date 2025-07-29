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
            // Adjust reminderTimes array size if frequency changes
            adjustReminderTimesArray()
            // When frequency changes, re-evaluate all reminders.
            updateAllReminders()
        }
    }

    // NEW: The specific times of day for reminders (now an array of Dates).
    @Published var reminderTimes: [Date] = {
        if let savedTimes = UserDefaults.standard.array(forKey: Constants.UserDefaultKeys.reminderTimes) as? [Date] {
            return savedTimes
        } else {
            // When generating default times here, we must get the initial frequency directly from UserDefaults
            let initialFrequency = UserDefaults.standard.integer(forKey: Constants.UserDefaultKeys.globalReminderFrequency)
            let frequency = initialFrequency == 0 ? 1 : initialFrequency
            return SettingsViewModel.generateDefaultReminderTimes(frequency: frequency)
        }
    }() {
        didSet {
            // Persist the array of times whenever it changes.
            UserDefaults.standard.set(reminderTimes, forKey: Constants.UserDefaultKeys.reminderTimes)
            // When times change, re-evaluate all reminders.
            updateAllReminders()
        }
    }

    // Indicates if notification permissions have been granted.
    @Published var notificationsAuthorized: Bool = false

    // MARK: - Private Properties

    private let reminderManager = ReminderManager() // Instance of our reminder manager
    private var specialDaysListViewModel: SpecialDaysListViewModel // Reference to the main data source
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(specialDaysListViewModel: SpecialDaysListViewModel) {
        self.specialDaysListViewModel = specialDaysListViewModel

        // Removed all explicit UserDefaults loading here, as it's now handled in property declarations.
        // Removed: if self.globalReminderFrequency == 0 { ... }
        // Removed: if let savedTimes = ... else { ... }
        // Removed: adjustReminderTimesArray() // This is now called from didSet of globalReminderFrequency

        // Request notification authorization on init (or when settings view appears)
        requestNotificationAuthorization()

        // Observe changes in the main list of special days.
        // If events are added/removed/updated, we need to re-schedule reminders.
        specialDaysListViewModel.$specialDays
            .sink { [weak self] _ in
                self?.updateAllReminders()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    // Requests notification authorization and updates the `notificationsAuthorized` status.
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationsAuthorized = granted
                if !granted {
                    print("Notification authorization denied: \(error?.localizedDescription ?? "Unknown error")")
                    // If denied, ensure reminders are off and cancel any existing.
                    self?.isGlobalReminderEnabled = false
                    self?.reminderManager.cancelAllReminders()
                } else {
                    // If granted, update reminders based on current settings.
                    self?.updateAllReminders()
                }
            }
        }
    }

    // Opens app settings so the user can manually change notification permissions.
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    // MARK: - Private Helpers

    // Generates a default array of reminder times based on frequency.
    private static func generateDefaultReminderTimes(frequency: Int) -> [Date] {
        var times: [Date] = []
        let calendar = Calendar.current
        let now = Date()

        switch frequency {
        case 1:
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!) // 9 AM
        case 2:
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!) // 9 AM
            times.append(calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now)!) // 3 PM
        case 3:
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!) // 9 AM
            times.append(calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!) // 1 PM
            times.append(calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now)!) // 5 PM
        default:
            times.append(calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!) // Fallback to 9 AM
        }
        return times
    }

    // Adjusts the `reminderTimes` array size and content when `globalReminderFrequency` changes.
    private func adjustReminderTimesArray() {
        if reminderTimes.count != globalReminderFrequency {
            // If frequency increases, add default times.
            // If frequency decreases, truncate the array.
            reminderTimes = SettingsViewModel.generateDefaultReminderTimes(frequency: globalReminderFrequency)
        }
    }

    // Re-evaluates and schedules/cancels all reminders based on current global settings.
    private func updateAllReminders() {
        if isGlobalReminderEnabled && notificationsAuthorized {
            // Schedule reminders for all events that are close, passing the selected times.
            reminderManager.scheduleReminders(
                for: specialDaysListViewModel.specialDays,
                frequencyPerDay: globalReminderFrequency,
                atTimes: reminderTimes
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
