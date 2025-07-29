//
//  SettingsView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - Extracted Reminder Settings Section
// This new private view encapsulates the "Event Reminders" section,
// reducing complexity in the parent SettingsView.
private struct ReminderSettingsSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text("Event Reminders").foregroundColor(.black)) {
            Toggle(isOn: $viewModel.isGlobalReminderEnabled) {
                Text("Enable Daily Reminders")
                    .foregroundColor(.black)
            }
            .tint(.blue) // A neutral tint for the toggle

            if viewModel.isGlobalReminderEnabled {
                // Check for notification authorization status
                if viewModel.notificationsAuthorized {
                    Picker("Reminders per Day", selection: $viewModel.globalReminderFrequency) {
                        ForEach(1...3, id: \.self) { frequency in // Options for 1, 2, or 3 times a day
                            Text("\(frequency) time\(frequency == 1 ? "" : "s")")
                                .tag(frequency)
                                .foregroundColor(.black)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(.black)

                    // Time Pickers for Reminders
                    ForEach(0..<viewModel.globalReminderFrequency, id: \.self) { index in
                        DatePicker("Reminder \(index + 1) Time", selection: $viewModel.reminderTimes[index], displayedComponents: .hourAndMinute)
                            .foregroundColor(.black)
                    }
                } else {
                    // Message and button to request/manage permissions
                    VStack(alignment: .leading) {
                        Text("Notifications are not authorized.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Grant Notification Access") {
                            viewModel.openAppSettings() // Direct user to app settings
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var specialDaysListViewModel: SpecialDaysListViewModel // Passed from parent
    @StateObject private var viewModel: SettingsViewModel // New ViewModel for settings

    init(specialDaysListViewModel: SpecialDaysListViewModel) {
        _specialDaysListViewModel = ObservedObject(wrappedValue: specialDaysListViewModel)
        _viewModel = StateObject(wrappedValue: SettingsViewModel(specialDaysListViewModel: specialDaysListViewModel))
    }

    var body: some View {
        Form {
            Section(header: Text("General Settings").foregroundColor(.black)) {
                // Placeholder for future settings like notifications, theme, etc.
                Text("App version: 1.0.0")
                    .foregroundColor(.black)
            }

            // NEW: Use the extracted ReminderSettingsSection
            ReminderSettingsSection(viewModel: viewModel)
        }
        .background(Color.gray.opacity(0.1)) // Subtle gray background
        .scrollContentBackground(.hidden) // Hide default list background
        .navigationTitle("Settings") // Set navigation title
        .navigationBarTitleDisplayMode(.inline) // Keep bar compact
        .navigationBarBackButtonHidden(true) // Hide the system-provided back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { // Placed in leading for consistency
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.black) // Fixed button color
            }
        }
        .onAppear {
            // Request notification authorization when the settings view appears
            viewModel.requestNotificationAuthorization()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass a dummy SpecialDaysListViewModel for the preview
        SettingsView(specialDaysListViewModel: SpecialDaysListViewModel())
    }
}

