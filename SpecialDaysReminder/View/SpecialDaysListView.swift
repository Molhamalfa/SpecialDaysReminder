//
//  SpecialDaysListView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - Helper struct to make UUID Identifiable for .sheet(item:)
struct IdentifiableUUID: Identifiable, Equatable, Hashable {
    let id: UUID
}

// MARK: - Navigation Destination Types
// Define types that can be pushed onto the NavigationStack
enum NavigationDestinationType: Hashable {
    case categoryDetail(SpecialDayCategory?) // For CategoryDetailView (nil for All Special Days)
    case editSpecialDay(IdentifiableUUID) // For EditSpecialDayView
}

// MARK: - Helper ViewModifier for NavigationStack Content
// This new modifier encapsulates all content and modifiers within the NavigationStack,
// significantly simplifying SpecialDaysListView's body.
private struct SpecialDaysListNavigationContent: ViewModifier {
    @ObservedObject var viewModel: SpecialDaysListViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var selectedCategoryForAdd: SpecialDayCategory?
    @Binding var showingAddSpecialDaySheet: Bool

    // Animation states are passed directly to SpecialDaysContentView
    let headerOpacity: Double
    let headerOffset: CGFloat
    let allDaysCardOpacity: Double
    let allDaysCardOffset: CGFloat
    let categoryGridOpacity: Double
    let categoryGridOffset: CGFloat

    func body(content: Content) -> some View {
        content // This represents the NavigationStack
            .navigationTitle("") // Hide default navigation title, but keep navigation bar present
            .navigationBarTitleDisplayMode(.inline) // Ensure title area is compact
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Pass viewModel to SettingsView
                    NavigationLink(destination: SettingsView(specialDaysListViewModel: viewModel)) {
                        Image(systemName: "gearshape.fill") // Settings symbol
                            .font(.title2)
                            .foregroundColor(.black) // Fixed to black for light mode look
                    }
                }
            }
            // Sheet for adding a new special day
            .sheet(isPresented: $showingAddSpecialDaySheet) {
                AddSpecialDayView(viewModel: viewModel, initialCategory: selectedCategoryForAdd)
            }
            // Navigation Destinations for the NavigationStack
            .navigationDestination(for: NavigationDestinationType.self) { destination in
                switch destination {
                case .categoryDetail(let category):
                    CategoryDetailView(viewModel: viewModel, category: category)
                case .editSpecialDay(let identifiableUUID):
                    if let dayToEdit = viewModel.specialDays.first(where: { $0.id == identifiableUUID.id }) {
                        // FIXED: Pass themeGradient to EditSpecialDayView
                        EditSpecialDayView(viewModel: viewModel, specialDay: dayToEdit, themeColor: dayToEdit.category.color)
                    } else {
                        // Handle case where day is not found (e.g., show an alert or go back)
                        Text("Event not found.") // Placeholder for error handling
                    }
                }
            }
    }
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

    // NavigationStack path for programmatic navigation (iOS 16+)
    @State private var navigationPath = NavigationPath() // NEW: For programmatic navigation

    // @State properties related to sheets (only AddSpecialDaySheet remains)
    @State private var selectedCategoryForAdd: SpecialDayCategory?

    // Binding to receive deep link category
    @Binding var deepLinkCategory: SpecialDayCategory?
    // Binding to receive deep link event ID
    @Binding var deepLinkEventID: UUID? // Kept as UUID? for external deep link handling
    // NEW: Binding to trigger showing the AddSpecialDaySheet from a deep link
    @Binding var deepLinkAddEvent: Bool // ADD THIS LINE

    // Animation states for initial load
    @State private var headerOpacity: Double = 0
    @State private var headerOffset: CGFloat = -20
    @State private var allDaysCardOpacity: Double = 0
    @State private var allDaysCardOffset: CGFloat = -20
    @State private var categoryGridOpacity: Double = 0
    @State private var categoryGridOffset: CGFloat = -20


    // MARK: - Initialization
    // Custom initializer to set initial values for @State properties.
    init(deepLinkCategory: Binding<SpecialDayCategory?>, deepLinkEventID: Binding<UUID?>, deepLinkAddEvent: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: SpecialDaysListViewModel())
        _showingAddSpecialDaySheet = State(initialValue: false)
        _navigationPath = State(initialValue: NavigationPath()) // Initialize NavigationPath
        _selectedCategoryForAdd = State(initialValue: nil)
        _deepLinkCategory = deepLinkCategory
        _deepLinkEventID = deepLinkEventID
        _deepLinkAddEvent = deepLinkAddEvent // INITIALIZE NEW BINDING
    }


    // MARK: - Body

    var body: some View {
        // Use a ZStack to ensure the background covers the entire screen
        // while the NavigationStack content respects safe areas.
        ZStack {
            // Background color that fills the entire screen
            Color.white // Always use white background for light mode look
                .edgesIgnoringSafeArea(.all)

            NavigationStack(path: $navigationPath) {
                SpecialDaysContentView( // Using the new extracted view
                    viewModel: viewModel,
                    headerOpacity: headerOpacity,
                    headerOffset: headerOffset,
                    allDaysCardOpacity: allDaysCardOpacity,
                    allDaysCardOffset: allDaysCardOffset,
                    categoryGridOpacity: categoryGridOpacity,
                    categoryGridOffset: categoryGridOffset,
                    selectedCategoryForAdd: $selectedCategoryForAdd,
                    showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
                    navigationPath: $navigationPath // Pass navigationPath
                )
                // NEW: Apply the extracted NavigationStack content modifier
                .modifier(SpecialDaysListNavigationContent(
                    viewModel: viewModel,
                    navigationPath: $navigationPath,
                    selectedCategoryForAdd: $selectedCategoryForAdd,
                    showingAddSpecialDaySheet: $showingAddSpecialDaySheet,
                    headerOpacity: headerOpacity, // Pass animation states
                    headerOffset: headerOffset,
                    allDaysCardOpacity: allDaysCardOpacity,
                    allDaysCardOffset: allDaysCardOffset,
                    categoryGridOpacity: categoryGridOpacity,
                    categoryGridOffset: categoryGridOffset
                ))
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
        // Updated onChange syntax for iOS 17+ for deepLinkCategory
        .onChange(of: deepLinkCategory) { oldValue, newCategory in
            if let category = newCategory {
                // Clear existing path and push the category detail
                navigationPath = NavigationPath() // Clear path to ensure it's the root
                navigationPath.append(NavigationDestinationType.categoryDetail(category))
                deepLinkCategory = nil // Consume the deep link
            }
        }
        // NEW: onChange for deepLinkEventID to navigate to category detail AND then edit view
        .onChange(of: deepLinkEventID) { oldValue, newEventID in
            if let eventID = newEventID {
                if let day = viewModel.specialDays.first(where: { $0.id == eventID }) {
                    navigationPath = NavigationPath() // Clear path
                    navigationPath.append(NavigationDestinationType.categoryDetail(day.category)) // Push category detail
                    navigationPath.append(NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id))) // Then push edit view
                }
                deepLinkEventID = nil // Consume the deep link
            }
        }
        // NEW: onChange for deepLinkAddEvent to show the AddSpecialDaySheet
        .onChange(of: deepLinkAddEvent) { oldValue, newAddEvent in
            if newAddEvent {
                showingAddSpecialDaySheet = true
                deepLinkAddEvent = false // Consume the deep link
            }
        }
    }
}

// MARK: - Preview Provider
// Provides a preview of the SpecialDaysListView in Xcode's canvas.
struct SpecialDaysListView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide constant bindings for preview
        SpecialDaysListView(deepLinkCategory: .constant(nil), deepLinkEventID: .constant(nil), deepLinkAddEvent: .constant(false))
    }
}
