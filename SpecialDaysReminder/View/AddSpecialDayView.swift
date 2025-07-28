//
//  AddSpecialDayView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - AddSpecialDayView
// A view for adding a new special day.
// This will be presented as a sheet from SpecialDaysListView.
struct AddSpecialDayView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet.
    @ObservedObject var viewModel: SpecialDaysListViewModel // ViewModel to add the new day.

    // @State properties to hold the input values for the new special day.
    @State private var name: String
    @State private var date: Date
    @State private var forWhom: String
    @State private var category: SpecialDayCategory
    @State private var notes: String

    // Store the initial category to determine if the picker should be hidden
    let initialCategory: SpecialDayCategory?

    // Custom initializer to set an initial category
    init(viewModel: SpecialDaysListViewModel, initialCategory: SpecialDayCategory? = nil) {
        self.viewModel = viewModel
        self.initialCategory = initialCategory // Store the initial category
        // Explicitly initialize all @State properties
        _name = State(initialValue: "")
        _date = State(initialValue: Date())
        _forWhom = State(initialValue: "")
        _category = State(initialValue: initialCategory ?? .lovedOnes) // Default if not provided
        _notes = State(initialValue: "")
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
        // Use the selected category's color, or a default if no category is explicitly chosen (e.g., from general '+' button)
        color(for: category)
    }

    var body: some View {
        // Apply background to the entire NavigationView and ignore safe areas
        NavigationView {
            Form { // Provides a grouped, structured layout for input fields.
                Section {
                    TextField("Event Name (e.g., Birthday)", text: $name)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
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

                    // Conditionally display the Picker if initialCategory is nil
                    if initialCategory == nil {
                        Picker("Category", selection: $category) {
                            ForEach(SpecialDayCategory.allCases, id: \.self) { cat in
                                Text(cat.displayName)
                                    .tag(cat)
                                    .foregroundColor(.white) // Picker row text color
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                        .pickerStyle(.menu) // Ensure it's a compact menu style
                        .foregroundColor(.white) // Picker label color
                        .tint(.white) // Apply tint for interactive elements (e.g., disclosure indicator)
                    } else {
                        // Display fixed category if pre-selected
                        HStack {
                            Text("Category")
                                .foregroundColor(.white)
                            Spacer()
                            Text(category.displayName)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }

                    // Ensure TextEditor's own background is clear, rely on listRowBackground for the row
                    TextEditor(text: $notes)
                        .frame(minHeight: 100, maxHeight: 150) // Set a reasonable height range
                        .background(Color.clear) // Ensure TextEditor's own background is clear
                        .foregroundColor(.white) // Text color inside editor
                        .tint(.white) // Cursor color
                        .cornerRadius(10) // Match form row styling
                        .scrollContentBackground(.hidden) // Hide default TextEditor background
                        .listRowBackground(Color.white.opacity(0.1)) // Apply row background to the TextEditor itself
                } header: {
                    Text("Event Details")
                        .font(.headline)
                        .textCase(nil) // Prevent uppercase
                        .foregroundColor(.white.opacity(0.8)) // Header text color
                }
            }
            .background(backgroundColor) // Apply category color to the form background
            .scrollContentBackground(.hidden) // Hide default form background to show custom color
            .navigationTitle("Add Special Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Dismiss the sheet without saving.
                    }
                    .foregroundColor(.white) // Make cancel button stand out on colored background
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newDay = SpecialDayModel(name: name, date: date, forWhom: forWhom, category: category, notes: notes.isEmpty ? nil : notes)
                        viewModel.addSpecialDay(newDay) // Add the new day via the ViewModel.
                        dismiss() // Dismiss the sheet after saving.
                    }
                    .disabled(name.isEmpty || forWhom.isEmpty) // Disable Save button if required fields are empty.
                    .font(.headline) // Make save button slightly bolder
                    .foregroundColor(.white) // Use white for save button
                }
            }
        }
        .background(backgroundColor) // Apply background to the entire NavigationView and ignore safe areas
        .ignoresSafeArea()
        .accentColor(.white) // Ensures toolbar button icons are white
    }
}

// MARK: - Preview Provider
struct AddSpecialDayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddSpecialDayView(viewModel: SpecialDaysListViewModel(), initialCategory: .lovedOnes)
                .previewDisplayName("Add Loved Ones Event")

            AddSpecialDayView(viewModel: SpecialDaysListViewModel(), initialCategory: nil)
                .previewDisplayName("Add General Event")
        }
    }
}
