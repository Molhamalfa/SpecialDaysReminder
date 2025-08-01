//
//  CalendarImportView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - CalendarImportView
// This view allows users to import events from their iOS Calendar.
struct CalendarImportView: View {
    @Environment(\.dismiss) var dismiss // To dismiss the sheet/navigation view
    
    // ViewModel for handling calendar import logic
    @StateObject private var viewModel: CalendarImportViewModel

    // Custom initializer to pass the main SpecialDaysListViewModel
    init(specialDaysListViewModel: SpecialDaysListViewModel) {
        _viewModel = StateObject(wrappedValue: CalendarImportViewModel(specialDaysListViewModel: specialDaysListViewModel))
    }

    var body: some View {
        NavigationView {
            VStack {
                // Display status messages
                if let message = viewModel.statusMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(message.contains("denied") || message.contains("No events") ? .red : .blue)
                        .padding()
                        .multilineTextAlignment(.center)
                }

                if viewModel.isLoading {
                    ProgressView("Loading events...")
                        .padding()
                } else if !viewModel.calendarAuthorized {
                    // Show button to request access if not authorized
                    Button("Grant Calendar Access") {
                        viewModel.requestCalendarAuthorization()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding()
                } else if viewModel.importableEvents.isEmpty && viewModel.statusMessage?.contains("No new events") == false {
                    // Show message if authorized but no events found yet (e.g., still loading or none in range)
                    Text("No events found. Ensure you have events in your calendar for the next year.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .multilineTextAlignment(.center)
                } else {
                    // List of importable events
                    List {
                        ForEach($viewModel.importableEvents) { $event in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(event.ekEvent.title ?? "Unknown Event")
                                        .font(.headline)
                                    Text(event.startDate, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Toggle("", isOn: $event.isSelected)
                                    .labelsHidden() // Hide default toggle label
                                    .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)

                    // "Add Selected Events" button
                    Button("Add Selected Events") {
                        viewModel.importSelectedEvents()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.bottom)
                    .disabled(viewModel.importableEvents.filter({ $0.isSelected }).isEmpty) // Disable if no events selected
                }
            }
            .navigationTitle("Import Calendar Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .onAppear {
                // Re-check status on appear in case user changed permissions in Settings
                viewModel.checkCalendarAuthorizationStatus()
            }
        }
    }
}

// MARK: - Preview Provider
struct CalendarImportView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarImportView(specialDaysListViewModel: SpecialDaysListViewModel())
    }
}
