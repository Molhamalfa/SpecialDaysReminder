//
//  AddSpecialDayView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct AddSpecialDayView: View {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    @Environment(\.dismiss) var dismiss
    
    // Initial category if adding from a specific category card
    let initialCategory: SpecialDayCategory?
    // NEW: Property to hold the theme color for the background
    let themeColor: Color // This was previously removed, but is needed for the background color consistency.

    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var forWhom: String = ""
    @State private var category: SpecialDayCategory = .other
    @State private var notes: String = ""

    // Custom initializer to accept initialCategory and themeColor
    init(viewModel: SpecialDaysListViewModel, initialCategory: SpecialDayCategory?) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.initialCategory = initialCategory
        // NEW: Initialize themeColor based on initialCategory or default to .other
        self.themeColor = initialCategory?.color ?? SpecialDayCategory.other.color
    }

    // Computed property to check if all required fields are filled
    private var isSaveButtonDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        forWhom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details").foregroundColor(.black)) {
                    TextField("Event Name", text: $name)
                        .foregroundColor(.black)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .foregroundColor(.black)
                    
                    TextField("For Whom", text: $forWhom)
                        .foregroundColor(.black)
                    
                    Picker("Category", selection: $category) {
                        ForEach(SpecialDayCategory.allCases, id: \.self) { cat in
                            // UPDATED: Show icon and display name in the picker
                            HStack {
                                Image(systemName: cat.iconName)
                                    .foregroundColor(.black)
                                Text(cat.displayName)
                                    .foregroundColor(.black)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.black) // Ensures picker itself looks good in light mode
                    
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .foregroundColor(.black)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .background(themeColor.opacity(0.1)) // UPDATED: Use themeColor for background
            .scrollContentBackground(.hidden) // Hide default list background
            .navigationTitle("Add Special Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newDay = SpecialDayModel(name: name, date: date, forWhom: forWhom, category: category, notes: notes.isEmpty ? nil : notes)
                        viewModel.addSpecialDay(newDay)
                        dismiss()
                    }
                    .foregroundColor(.black)
                    .disabled(isSaveButtonDisabled) // NEW: Disable button if required fields are empty
                }
            }
        }
        .onAppear {
            // Pre-select category if provided
            if let initialCat = initialCategory {
                self.category = initialCat
            }
        }
    }
}

struct AddSpecialDayView_Previews: PreviewProvider {
    static var previews: some View {
        // UPDATED: Pass a sample themeColor for the preview
        AddSpecialDayView(viewModel: SpecialDaysListViewModel(), initialCategory: .family)
    }
}
