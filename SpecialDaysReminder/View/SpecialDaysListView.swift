//
//  SpecialDaysListView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - Helper struct to make UUID Identifiable for .sheet(item:)
struct IdentifiableUUID: Identifiable, Equatable { // ADDED EQUATABLE CONFORMANCE
    let id: UUID
}

// MARK: - SpecialDaysListView
// This is the main view that displays a list of special days.
// It observes the SpecialDaysListViewModel to react to data changes.
struct SpecialDaysListView: View {

    // MARK: - Properties

    // @StateObject creates and manages the lifecycle of the ViewModel.
    // It ensures the ViewModel persists across view updates.
    @StateObject var viewModel: SpecialDaysListViewModel

    // Environment variable to detect current color scheme (light/dark mode)
    @Environment(\.colorScheme) var colorScheme

    // @State property to control the presentation of the AddSpecialDayView.
    @State private var showingAddSpecialDaySheet: Bool
    // @State property to control the presentation of the EditSpecialDayView.
    @State private var showingEditSpecialDaySheet: Bool
    // @State property to control the presentation of the CategoryDetailView.
    @State private var showingCategoryDetailSheet: Bool

    // @State property to hold the SpecialDayModel being edited.
    @State private var selectedDayToEdit: SpecialDayModel?

    // @State property to hold the category for which a new day is being added.
    @State private var selectedCategoryForAdd: SpecialDayCategory?
    // @State property to hold the category whose details are being viewed.
    @State private var selectedCategoryForDetail: SpecialDayCategory?

    // Binding to receive deep link category
    @Binding var deepLinkCategory: SpecialDayCategory?
    // New binding to receive deep link event ID, now wrapped in IdentifiableUUID
    @Binding var deepLinkIdentifiableEventID: IdentifiableUUID? // CHANGED TYPE

    // Animation states for initial load
    @State private var headerOpacity: Double = 0
    @State private var headerOffset: CGFloat = -20
    @State private var allDaysCardOpacity: Double = 0
    @State private var allDaysCardOffset: CGFloat = -20
    @State private var categoryGridOpacity: Double = 0
    @State private var categoryGridOffset: CGFloat = -20


    // MARK: - Initialization
    // Custom initializer to set initial values for @State properties.
    init(deepLinkCategory: Binding<SpecialDayCategory?>, deepLinkEventID: Binding<UUID?>) { // KEPT UUID? for external call
        _viewModel = StateObject(wrappedValue: SpecialDaysListViewModel())
        _showingAddSpecialDaySheet = State(initialValue: false)
        _showingEditSpecialDaySheet = State(initialValue: false)
        _showingCategoryDetailSheet = State(initialValue: false)
        _selectedDayToEdit = State(initialValue: nil)
        _selectedCategoryForAdd = State(initialValue: nil)
        _selectedCategoryForDetail = State(initialValue: nil)
        _deepLinkCategory = deepLinkCategory
        // Initialize deepLinkIdentifiableEventID from deepLinkEventID
        _deepLinkIdentifiableEventID = Binding(
            get: { deepLinkEventID.wrappedValue.map(IdentifiableUUID.init) },
            set: { identifiableUUID in deepLinkEventID.wrappedValue = identifiableUUID?.id }
        )
    }


    // MARK: - Body

    var body: some View {
        // Use a ZStack to ensure the background covers the entire screen
        // while the NavigationView content respects safe areas.
        ZStack {
            // Background color that fills the entire screen
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            NavigationView { // Main navigation container
                SpecialDaysContentView( // Using the new extracted view
                    viewModel: viewModel,
                    headerOpacity: headerOpacity,
                    headerOffset: headerOffset,
                    allDaysCardOpacity: allDaysCardOpacity,
                    allDaysCardOffset: allDaysCardOffset,
                    categoryGridOpacity: categoryGridOpacity,
                    categoryGridOffset: categoryGridOffset,
                    selectedDayToEdit: $selectedDayToEdit,
                    showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
                    selectedCategoryForAdd: $selectedCategoryForAdd,
                    showingEditSpecialDaySheet: $showingEditSpecialDaySheet
                )
                .navigationTitle("") // Hide default navigation title, but keep navigation bar present
                .navigationBarTitleDisplayMode(.inline) // Ensure title area is compact
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Changed from Button to NavigationLink for normal view presentation
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill") // Settings symbol
                                .font(.title2)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
                // Sheet for adding a new special day
                .sheet(isPresented: $showingAddSpecialDaySheet) {
                    AddSpecialDayView(viewModel: viewModel, initialCategory: selectedCategoryForAdd)
                }
                // Sheet for editing an existing special day (from tapping a row in 'All Days' or category cards)
                .sheet(isPresented: $showingEditSpecialDaySheet) {
                    if let dayToEdit = selectedDayToEdit {
                        EditSpecialDayView(viewModel: viewModel, specialDay: dayToEdit)
                    }
                }
                // Sheet for displaying category details
                .sheet(isPresented: $showingCategoryDetailSheet) {
                    if let category = selectedCategoryForDetail {
                        CategoryDetailView(viewModel: viewModel, category: category)
                    } else {
                        // This handles the "All Special Days" detail view
                        CategoryDetailView(viewModel: viewModel, category: nil)
                    }
                }
                // New sheet for deep-linked event details, now using IdentifiableUUID
                .sheet(item: $deepLinkIdentifiableEventID) { identifiableEventID in // CHANGED ITEM TYPE
                    if let dayToEdit = viewModel.specialDays.first(where: { $0.id == identifiableEventID.id }) { // ACCESS .id
                        EditSpecialDayView(viewModel: viewModel, specialDay: dayToEdit)
                    }
                }
            }
        }
        .onAppear {
            // Staggered initial appearance animation
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                headerOpacity = 1
                headerOffset = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                allDaysCardOpacity = 1
                allDaysCardOffset = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                categoryGridOpacity = 1
                categoryGridOffset = 0
            }
        }
        // Updated onChange syntax for iOS 17+
        .onChange(of: deepLinkCategory) { oldValue, newCategory in
            if let category = newCategory {
                // If a deep link category is received, trigger the detail sheet
                selectedCategoryForDetail = category
                // FIX: Defer sheet presentation slightly
                DispatchQueue.main.async {
                    showingCategoryDetailSheet = true
                    deepLinkCategory = nil // Consume the deep link
                }
            }
        }
        // New onChange for deepLinkIdentifiableEventID
        .onChange(of: deepLinkIdentifiableEventID) { oldValue, newEventID in
            if newEventID != nil {
                // The sheet will be presented automatically by .sheet(item: $deepLinkIdentifiableEventID)
                // We just need to ensure the ID is consumed after presentation if needed,
                // or let the sheet dismissal handle resetting deepLinkIdentifiableEventID.
                // For simplicity, we'll let the sheet's lifecycle manage it.
            }
        }
    }
}

// MARK: - Preview Provider
// Provides a preview of the SpecialDaysListView in Xcode's canvas.
struct SpecialDaysListView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a constant binding for preview
        SpecialDaysListView(deepLinkCategory: .constant(nil), deepLinkEventID: .constant(nil))
    }
}
