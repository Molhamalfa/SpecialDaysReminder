//
//  EditSpecialDayView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - EditSpecialDayView
// A view for editing an existing special day.
// This will be presented as a sheet from SpecialDaysListView.
struct EditSpecialDayView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet.
    @ObservedObject var viewModel: SpecialDaysListViewModel // ViewModel to update the day.

    // @State properties to hold the input values for the special day being edited.
    // Initialize them with the values from the passed-in specialDay.
    @State private var name: String
    @State private var date: Date
    @State private var forWhom: String
    @State private var category: SpecialDayCategory
    @State private var notes: String

    // The original special day model passed from the list view.
    let originalSpecialDay: SpecialDayModel

    // Custom initializer to set initial @State values from the SpecialDayModel.
    init(viewModel: SpecialDaysListViewModel, specialDay: SpecialDayModel) {
        self.viewModel = viewModel
        self.originalSpecialDay = specialDay
        _name = State(initialValue: specialDay.name)
        _date = State(initialValue: specialDay.date)
        _forWhom = State(initialValue: specialDay.forWhom)
        _category = State(initialValue: specialDay.category) // Category is fixed for edit view
        _notes = State(initialValue: specialDay.notes ?? "")
    }

    // Helper function to get a color based on category
    private func color(for category: SpecialDayCategory) -> Color {
        switch category {
        case .lovedOnes: return .pink
        case .friends: return .blue
        case .family: return .green
        case .work: return .orange
        case .other: return .purple
        }
    }

    // Computed property for the background color of the view
    private var backgroundColor: Color {
        // Always return the category's color, regardless of system dark/light mode
        color(for: category)
    }

    var body: some View {
        // Apply background to the entire NavigationView and ignore safe areas
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Name (e.g., Birthday)", text: $name)
                        .listRowBackground(Color.white.opacity(0.1)) // Subtle background for form rows
                        .foregroundColor(.white) // White text for input
                    TextField("For Whom (e.g., Mom)", text: $forWhom)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .listRowBackground(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .listRowBackground(Color.white.opacity(0.1))
                        .datePickerStyle(.graphical) // Modern date picker style
                        .foregroundColor(.white) // Date picker label color
                        .colorMultiply(.white) // To ensure date components are visible
                        .tint(.white) // Apply tint for interactive elements (e.g., selected date circle)

                    // Display fixed category, not a picker
                    HStack {
                        Text("Category")
                            .foregroundColor(.white)
                        Spacer()
                        Text(category.displayName)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .listRowBackground(Color.white.opacity(0.1))

                    // Ensure TextEditor's own background is clear, rely on listRowBackground for the row
                    TextEditor(text: $notes)
                        .frame(minHeight: 100, maxHeight: 150) // Set a reasonable height range
                        .background(Color.clear) // Ensure TextEditor's own background is clear
                        .foregroundColor(.white) // Text color inside editor
                        .tint(.white) // Cursor color
                        .cornerRadius(10) // Match form row styling
                        .scrollContentBackground(.hidden) // Hide default TextEditor background
                        .listRowBackground(Color.white.opacity(0.1)) // Apply row background to the TextEditor itself
                }
            }
            .background(backgroundColor) // Apply category color to the form background
            .scrollContentBackground(.hidden) // Hide default form background to show custom color
            .navigationTitle("Edit Special Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white) // White color for cancel button
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Create an updated SpecialDayModel with the same ID as the original.
                        let updatedDay = SpecialDayModel(
                            id: originalSpecialDay.id, // Keep the original ID
                            name: name,
                            date: date,
                            forWhom: forWhom,
                            category: category, // Category is fixed based on original event
                            notes: notes.isEmpty ? nil : notes
                        )
                        viewModel.updateSpecialDay(updatedDay) // Update via the ViewModel.
                        dismiss()
                    }
                    .disabled(name.isEmpty || forWhom.isEmpty)
                    .font(.headline) // Make save button slightly bolder
                    .foregroundColor(.white) // White color for save button
                }
            }
        }
        .background(backgroundColor) // Apply background to the entire NavigationView and ignore safe areas
        .ignoresSafeArea()
        .accentColor(.white) // Ensures toolbar button icons are white
    }
}

// MARK: - Preview Provider
struct EditSpecialDayView_Previews: PreviewProvider {
    static var previews: some View {
        EditSpecialDayView(viewModel: SpecialDaysListViewModel(), specialDay: SpecialDayModel(name: "Sample Birthday", date: Date(), forWhom: "Someone", category: .lovedOnes, notes: "Test notes for preview"))
    }
}
