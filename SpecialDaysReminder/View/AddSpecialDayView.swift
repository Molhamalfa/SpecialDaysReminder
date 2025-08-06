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
    let themeColor: Color

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
                            Text(cat.displayName).tag(cat)
                                .foregroundColor(.black) // Text inside picker rows
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.black) // Ensures picker itself looks good in light mode
                    
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .foregroundColor(.black)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            // UPDATED: Use the themeColor with opacity for the background
            .background(themeColor.opacity(0.1))
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
