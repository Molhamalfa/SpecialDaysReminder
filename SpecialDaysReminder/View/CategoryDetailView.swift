//
//  CategoryDetailView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - CategoryDetailView
// A view that displays a detailed list of special days for a specific category or all days.
struct CategoryDetailView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet.
    @ObservedObject var viewModel: SpecialDaysListViewModel // ViewModel to access and modify data.

    let category: SpecialDayCategory? // Make category optional. If nil, show all days.

    // State to manage showing the edit sheet from this detail view
    @State private var showingEditSpecialDaySheet: Bool = false
    @State private var selectedDayToEdit: SpecialDayModel?

    // Computed property to get the correct list of days based on the category
    private var displayedDays: [SpecialDayModel] {
        if let category = category {
            return viewModel.specialDays(for: category)
        } else {
            return viewModel.specialDays.sorted { $0.daysUntil < $1.daysUntil } // Show all days, sorted
        }
    }

    // Helper to get SF Symbol name based on category
    private func icon(for category: SpecialDayCategory) -> String {
        switch category {
        case .lovedOnes: return "heart.fill"
        case .friends: return "person.2.fill"
        case .family: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "star.fill"
        }
    }

    // Helper to get a Color based on category
    private func color(for category: SpecialDayCategory) -> Color {
        switch category {
        case .lovedOnes: return .pink
        case .friends: return .blue
        case .family: return .green
        case .work: return .orange
        case .other: return .purple
        }
    }

    // Computed property for the background color of the detail view
    private var backgroundColor: Color {
        // Always return the category's color, regardless of system color scheme
        if let category = category {
            return color(for: category)
        } else {
            return color(for: .other) // Default for "All Special Days"
        }
    }

    // Computed property for the display name
    private var headerDisplayName: String {
        category?.displayName ?? "Special Days" // Changed from "All Special Days"
    }

    // Computed property for the header icon
    private var headerIconName: String {
        if let category = category {
            return icon(for: category)
        } else {
            return "calendar" // General icon for "All Special Days"
        }
    }

    var body: some View {
        NavigationView { // This NavigationView is needed for sheet presentation
            GeometryReader { geometry in // Use GeometryReader for safe area
                VStack(spacing: 0) {
                    // Custom Header (resembling widget header)
                    HStack {
                        // Custom back button with modern symbol and white color
                        Button {
                            dismiss() // Dismiss the detail view
                        } label: {
                            Image(systemName: "chevron.backward.circle.fill") // Modern back symbol
                                .font(.title)
                                .foregroundColor(.white) // White color
                        }
                        .padding(.trailing, 8) // Padding for the back button

                        Image(systemName: headerIconName)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.trailing, 8)

                        Text(headerDisplayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, geometry.safeAreaInsets.top + 20) // Adjust for safe area
                    .padding(.bottom, 15)

                    // Scrollable List of Events
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) { // Spacing between rows
                            if displayedDays.isEmpty {
                                Text("No special days in this category yet.")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7)) // Adjusted color for dark background
                                    .padding()
                            } else {
                                ForEach(displayedDays) { day in
                                    SpecialDayRowView(day: day) {
                                        selectedDayToEdit = day
                                        DispatchQueue.main.async {
                                            showingEditSpecialDaySheet = true
                                        }
                                    }
                                    .background(Color.white.opacity(0.1)) // Slightly transparent background for each row
                                    .cornerRadius(10)
                                    .padding(.horizontal, 5) // Add horizontal padding to rows
                                }
                                // Add a section for deletion (if EditButton is active)
                                .onDelete { offsets in
                                    let daysToDelete = offsets.map { displayedDays[$0] }
                                    for day in daysToDelete {
                                        viewModel.deleteSpecialDay(id: day.id)
                                    }
                                }
                            }
                        }
                        .padding(.vertical) // Padding for the scrollable content
                    }
                    .ignoresSafeArea(.all, edges: .bottom) // Let the scroll view ignore bottom safe area
                }
                .background(backgroundColor) // Apply background to the entire VStack
                .ignoresSafeArea(.all, edges: .all) // Make the background ignore all safe areas
            } // End GeometryReader
            .navigationTitle("") // Hide default navigation title, custom header is used
            .navigationBarHidden(true) // Hide default navigation bar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton() // Allow editing within the detail list
                        .foregroundColor(.white) // Ensure EditButton is white
                }
            }
            // Sheet for editing an existing special day from this detail view
            .sheet(isPresented: $showingEditSpecialDaySheet) {
                if let dayToEdit = selectedDayToEdit {
                    EditSpecialDayView(viewModel: viewModel, specialDay: dayToEdit)
                }
            }
        }
    }
}

// MARK: - Preview Provider
struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryDetailView(
                viewModel: SpecialDaysListViewModel(),
                category: .lovedOnes
            )
            .previewDisplayName("Loved Ones Detail")

            CategoryDetailView(
                viewModel: SpecialDaysListViewModel(),
                category: nil // Preview for "All Special Days"
            )
            .previewDisplayName("All Special Days Detail")
        }
    }
}
