//
//  SpecialDayRowView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - Custom ButtonStyle for SpecialDayRow
// This style provides the visual feedback for the SpecialDayRow button.
struct SpecialDayRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.1) : Color.white.opacity(0.05)) // Subtle background for rows
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Subtle scale effect on press
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed) // Smooth animation
    }
}

// MARK: - SpecialDayRowView
// A simple view to display a single special day's details in a list row.
// This is now a Button to encapsulate tap logic and visual feedback.
struct SpecialDayRowView: View {
    let day: SpecialDayModel // The special day to display.
    let onTapAction: () -> Void // Closure to be executed when the row is tapped.

    var body: some View {
        Button(action: onTapAction) { // The entire row is now a button
            VStack(alignment: .center, spacing: 8) { // Changed to VStack and centered
                // Category Icon
                Image(systemName: icon(for: day.category))
                    .font(.title2)
                    .foregroundColor(.white) // Changed icon color to white
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15)) // Keep a subtle background for the icon
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel(day.category.displayName)

                VStack(alignment: .center, spacing: 4) { // Centered content vertically
                    Text(day.name) // Display the event name.
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white) // Changed text color to white
                        .multilineTextAlignment(.center)

                    Text(day.forWhom) // Display who the event is for.
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8)) // Changed text color to white.opacity

                    // Display notes if available, before date and daysUntilDescription
                    if let notes = day.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7)) // Changed text color to white.opacity
                            .multilineTextAlignment(.center) // Center notes
                            .lineLimit(2) // Limit notes to 2 lines for brevity in the list
                            .padding(.horizontal, 10) // Add some horizontal padding to notes
                    }

                    Text(day.formattedDate) // Display the formatted date.
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8)) // Changed text color to white.opacity

                    Text(day.daysUntilDescription) // Display days until.
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(day.daysUntil == 0 ? .red : .white) // Highlight "Today!".
                }
            }
            .padding(.vertical, 15) // Increased vertical padding for better spacing.
            .padding(.horizontal, 10) // Add horizontal padding
            .frame(maxWidth: .infinity) // Ensure it takes full width for centering
        }
        .buttonStyle(SpecialDayRowButtonStyle()) // Apply the custom button style
    }

    // Helper function to get SF Symbol name based on category
    private func icon(for category: SpecialDayCategory) -> String {
        switch category {
        case .lovedOnes: return "heart.fill"
        case .friends: return "person.2.fill"
        case .family: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "star.fill"
        }
    }

    // Helper function to get a color based on category (still used for background of icon)
    private func color(for category: SpecialDayCategory) -> Color {
        switch category {
        case .lovedOnes: return .pink
        case .friends: return .blue
        case .family: return .green
        case .work: return .orange
        case .other: return .purple
        }
    }
}

// MARK: - Preview Provider
struct SpecialDayRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpecialDayRowView(day: SpecialDayModel(name: "Mom's Birthday", date: Date(), forWhom: "Mom", category: .lovedOnes, notes: "Don't forget the cake!")) {
                print("Row tapped in preview!")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.pink) // Simulate category background

            SpecialDayRowView(day: SpecialDayModel(name: "Team Meeting", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, forWhom: "Work Team", category: .work, notes: "Discuss Q3 results and next steps for Project X. Bring your reports and coffee.")) {
                print("Row tapped in preview!")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.orange) // Simulate category background
        }
    }
}
