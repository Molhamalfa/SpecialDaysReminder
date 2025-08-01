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
                        DatePicker("Reminder \(index + 1) Time", selection: Binding(
                            get: { viewModel.globalReminderTimes.indices.contains(index) ? viewModel.globalReminderTimes[index] : Date() },
                            set: { newValue in viewModel.globalReminderTimes[index] = newValue }
                        ), displayedComponents: .hourAndMinute)
                        .foregroundColor(.black)
                    }
                } else {
                    // Message if notifications are not authorized
                    Text("Notifications are not authorized. Please enable them in iOS Settings to receive reminders.")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                }
            }
        }
    }
}

// MARK: - SettingsView
// This view allows users to configure various app settings.
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // Use StateObject to manage the lifecycle of SettingsViewModel
    @StateObject var viewModel: SettingsViewModel

    // Custom initializer to pass the main ViewModel
    init(specialDaysListViewModel: SpecialDaysListViewModel) {
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

            // REMOVED: Calendar Import Section
            /*
            Section(header: Text("Calendar Import").foregroundColor(.black)) {
                if viewModel.calendarAuthorized {
                    Button("Import Events from Calendar") {
                        viewModel.importCalendarEvents()
                    }
                    .foregroundColor(.blue) // Standard button color
                } else {
                    Button("Request Calendar Access") {
                        viewModel.requestCalendarAuthorization()
                    }
                    .foregroundColor(.orange) // Highlight for action needed
                }

                if let message = viewModel.calendarImportMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(message.contains("Success") ? .green : .red)
                        .padding(.vertical, 5)
                }
            }
            */
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
            // REMOVED: Check calendar authorization status when the settings view appears
            // viewModel.checkCalendarAuthorizationStatus()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass a dummy SpecialDaysListViewModel for the preview
        SettingsView(specialDaysListViewModel: SpecialDaysListViewModel())
    }
}
