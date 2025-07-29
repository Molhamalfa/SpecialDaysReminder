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
    // Removed: let themeColor: Color // No longer needed here

    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var forWhom: String = ""
    @State private var category: SpecialDayCategory = .other
    @State private var notes: String = ""

    // Custom initializer to accept initialCategory (themeColor removed)
    init(viewModel: SpecialDaysListViewModel, initialCategory: SpecialDayCategory?) { // UPDATED: Removed themeColor
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.initialCategory = initialCategory
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
            .background(Color.gray.opacity(0.3)) // UPDATED: Fixed background to white
            .scrollContentBackground(.hidden) // Hide default list background
            .navigationTitle("Add Special Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black) // UPDATED: Fixed button color to black
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newDay = SpecialDayModel(name: name, date: date, forWhom: forWhom, category: category, notes: notes.isEmpty ? nil : notes)
                        viewModel.addSpecialDay(newDay)
                        dismiss()
                    }
                    .foregroundColor(.black) // UPDATED: Fixed button color to black
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
        AddSpecialDayView(viewModel: SpecialDaysListViewModel(), initialCategory: .family) // UPDATED: Removed themeColor from preview
    }
}
