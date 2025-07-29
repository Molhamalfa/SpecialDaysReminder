//
//  EditSpecialDayView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - Extracted Form Content for EditSpecialDayView
// This new private view encapsulates the Form's sections.
// Reminder settings have been removed from here.
private struct EditSpecialDayFormContent: View {
    @Binding var specialDay: SpecialDayModel // Receive specialDay as a binding
    let themeColor: Color

    var body: some View {
        Form {
            Section(header: Text("Event Details").foregroundColor(.black)) {
                TextField("Event Name", text: $specialDay.name)
                    .foregroundColor(.black)
                
                DatePicker("Date", selection: $specialDay.date, displayedComponents: .date)
                    .foregroundColor(.black)
                
                TextField("For Whom", text: $specialDay.forWhom)
                    .foregroundColor(.black)
                
                Picker("Category", selection: $specialDay.category) {
                    ForEach(SpecialDayCategory.allCases, id: \.self) { cat in
                        Text(cat.displayName).tag(cat)
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(.menu)
                .foregroundColor(.black)
                
                TextField("Notes (Optional)", text: Binding(get: { specialDay.notes ?? "" }, set: { specialDay.notes = $0.isEmpty ? nil : $0 }), axis: .vertical)
                    .foregroundColor(.black)
                    .lineLimit(3, reservesSpace: true)
            }

            // REMOVED: Reminder Settings Section
            // This section will be moved to SettingsView
            /*
            Section(header: Text("Reminder Settings").foregroundColor(.black)) {
                Toggle(isOn: $specialDay.isReminderEnabled) {
                    Text("Enable Reminder")
                        .foregroundColor(.black)
                }
                .tint(themeColor)

                if specialDay.isReminderEnabled {
                    Picker("Frequency per Day", selection: $specialDay.reminderFrequency) {
                        ForEach(1...3, id: \.self) { frequency in
                            Text("\(frequency) time\(frequency == 1 ? "" : "s")")
                                .tag(frequency)
                                .foregroundColor(.black)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(.black)
                }
            }
            */
        }
        .background(themeColor.opacity(0.1)) // Use themeColor for background
        .scrollContentBackground(.hidden) // Hide default list background
    }
}


struct EditSpecialDayView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    @Environment(\.dismiss) var dismiss
    
    // Special day to be edited
    @State private var specialDay: SpecialDayModel // Use @State for mutable copy
    let themeColor: Color // Property to accept the theme color

    // Initializer to receive the immutable specialDay and create a mutable copy
    init(viewModel: SpecialDaysListViewModel, specialDay: SpecialDayModel, themeColor: Color) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _specialDay = State(initialValue: specialDay) // Initialize @State with the passed model
        self.themeColor = themeColor // Initialize themeColor
    }

    var body: some View {
        NavigationView {
            // Use the extracted EditSpecialDayFormContent
            EditSpecialDayFormContent(specialDay: $specialDay, themeColor: themeColor)
            .navigationTitle("Edit Special Day")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateSpecialDay(specialDay) // Update the original in ViewModel
                        dismiss()
                    }
                    .foregroundColor(themeColor)
                }
            }
        }
    }
}

struct EditSpecialDayView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview updated to reflect removal of reminder properties
        EditSpecialDayView(viewModel: SpecialDaysListViewModel(), specialDay: SpecialDayModel(name: "Sample Edit", date: Date(), forWhom: "Preview", category: .friends), themeColor: .blue)
    }
}
