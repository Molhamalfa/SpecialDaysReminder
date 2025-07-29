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

// MARK: - Helper ViewModifier for Navigation Destinations
// This modifier encapsulates the logic for navigation destinations,
// reducing complexity in the main view's body.
private struct AppNavigationDestinations: ViewModifier {
    @ObservedObject var viewModel: SpecialDaysListViewModel

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationDestinationType.self) { destination in
                switch destination {
                case .categoryDetail(let category):
                    CategoryDetailView(viewModel: viewModel, category: category)
                case .editSpecialDay(let identifiableUUID):
                    if let dayToEdit = viewModel.specialDays.first(where: { $0.id == identifiableUUID.id }) {
                        EditSpecialDayView(viewModel: viewModel, specialDay: dayToEdit, themeColor: dayToEdit.category.color)
                    } else {
                        // Handle case where day is not found (e.g., show an alert or go back)
                        Text("Event not found.") // Placeholder for error handling
                    }
                }
            }
    }
}

// MARK: - Helper ViewModifier for Deep Link Handling
// This modifier encapsulates onChange logic for deep links.
private struct SpecialDaysListDeepLinkHandling: ViewModifier { // RENAMED AND SIMPLIFIED
    @ObservedObject var viewModel: SpecialDaysListViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var deepLinkCategory: SpecialDayCategory?
    @Binding var deepLinkEventID: UUID?
    @Binding var deepLinkAddEvent: Bool
    @Binding var showingAddSpecialDaySheet: Bool // Pass this binding to allow direct modification

    func body(content: Content) -> some View {
        content
            .onChange(of: deepLinkCategory) { oldValue, newCategory in
                if let category = newCategory {
                    navigationPath = NavigationPath()
                    navigationPath.append(NavigationDestinationType.categoryDetail(category))
                    deepLinkCategory = nil
                }
            }
            .onChange(of: deepLinkEventID) { oldValue, newEventID in
                if let eventID = newEventID {
                    if let day = viewModel.specialDays.first(where: { $0.id == eventID }) {
                        navigationPath = NavigationPath()
                        navigationPath.append(NavigationDestinationType.categoryDetail(day.category))
                        navigationPath.append(NavigationDestinationType.editSpecialDay(IdentifiableUUID(id: day.id)))
                    }
                    deepLinkEventID = nil
                }
            }
            .onChange(of: deepLinkAddEvent) { oldValue, newAddEvent in
                if newAddEvent {
                    showingAddSpecialDaySheet = true
                    deepLinkAddEvent = false
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
    // Keep this for other potential uses, but not for background here.
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


    // Animation states for initial load - Kept as @State in the main view
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
        _deepLinkAddEvent = deepLinkAddEvent
    }


    // MARK: - Body

    var body: some View {
        // Use a ZStack to ensure the background covers the entire screen
        // while the NavigationStack content respects safe areas.
        ZStack {
            // Background color that fills the entire screen
            Color(white: 0.9) // Fixed to a clearer light gray background
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
                .navigationTitle("") // Hide default navigation title, but keep navigation bar present
                .navigationBarTitleDisplayMode(.inline) // Ensure title area is compact
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Changed from Button to NavigationLink for normal view presentation
                        NavigationLink(destination: SettingsView()) {
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
                // Apply the extracted navigation destinations modifier
                .modifier(AppNavigationDestinations(viewModel: viewModel))
            }
        }
        // Moved onAppear animation logic back to the main view
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
        // Apply the simplified deep link handling modifier
        .modifier(SpecialDaysListDeepLinkHandling(
            viewModel: viewModel,
            navigationPath: $navigationPath,
            deepLinkCategory: $deepLinkCategory,
            deepLinkEventID: $deepLinkEventID,
            deepLinkAddEvent: $deepLinkAddEvent,
            showingAddSpecialDaySheet: $showingAddSpecialDaySheet // Pass the binding
        ))
    }
}

// MARK: - Preview Provider
// Provides a preview of the SpecialDaysListView in Xcode's canvas.
struct SpecialDaysListView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a constant binding for preview
        SpecialDaysListView(deepLinkCategory: .constant(nil), deepLinkEventID: .constant(nil), deepLinkAddEvent: .constant(false))
    }
}
