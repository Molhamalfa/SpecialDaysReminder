//
//  CategoryCardView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

// MARK: - CategoryCardView
// A custom view that displays a category of special days as a colorful card.
struct CategoryCardView: View {
    let category: SpecialDayCategory
    let specialDays: [SpecialDayModel]
    let onAddTapped: (SpecialDayCategory) -> Void // Closure to handle adding a new day for this category
    let onDayTapped: (SpecialDayModel) -> Void // Closure to handle tapping on an existing day
    let onCardTapped: (SpecialDayCategory) -> Void // New closure to handle tapping the card itself

    // Optional properties for custom title and icon
    var customTitle: String?
    var customIcon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Card Title and Icon - now uses customTitle/customIcon if provided
            HStack {
                Image(systemName: customIcon ?? icon(for: category))
                    .font(.title2)
                    .foregroundColor(.white)
                // Removed Text(customTitle ?? category.displayName)
                Spacer()
                // Display count of special days in this category
                Text("\(specialDays.count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
            }
            .padding(.bottom, 5)

            // List of Special Days (limited to a few for glanceability)
            if specialDays.isEmpty {
                Spacer()
                Text("No special days yet. Tap '+' to add one!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(specialDays.prefix(3)) { day in // Show top 3 upcoming days
                    HStack {
                        Text(day.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                        Text(day.daysUntilDescription)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(day.daysUntil == 0 ? .red : .white.opacity(0.9))
                    }
                    .padding(.vertical, 2)
                    .onTapGesture {
                        onDayTapped(day) // Call the closure when a day is tapped
                    }
                }
                if specialDays.count > 3 {
                    Text("+\(specialDays.count - 3) more...")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                }
            }

            Spacer() // Pushes content up

            // Plus Button at the bottom center
            HStack {
                Spacer()
                Button {
                    onAddTapped(category) // Call the closure to add a new day
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [color(for: category).opacity(0.9), color(for: category)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .contentShape(Rectangle()) // Make the entire card tappable
        .onTapGesture {
            // Only trigger onCardTapped if the tap wasn't consumed by the button
            // SwiftUI's tap gesture precedence usually handles this, but explicit
            // action ensures the button's action takes priority.
            onCardTapped(category)
        }
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
}

// MARK: - Preview Provider
struct CategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryCardView(
                category: .lovedOnes,
                specialDays: [
                    SpecialDayModel(name: "Mom's Birthday", date: Date(), forWhom: "Mom", category: .lovedOnes),
                    SpecialDayModel(name: "Anniversary", date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, forWhom: "Spouse", category: .lovedOnes)
                ],
                onAddTapped: { _ in },
                onDayTapped: { _ in },
                onCardTapped: { _ in } // Added for preview
            )
            .previewLayout(.sizeThatFits)
            .padding()

            CategoryCardView(
                category: .friends,
                specialDays: [],
                onAddTapped: { _ in },
                onDayTapped: { _ in },
                onCardTapped: { _ in } // Added for preview
            )
            .previewLayout(.sizeThatFits)
            .padding()

            // Preview for the new "All Special Days" card
            CategoryCardView(
                category: .other, // Base category for color
                specialDays: [
                    SpecialDayModel(name: "Mom's Bday", date: Date(), forWhom: "Mom", category: .lovedOnes),
                    SpecialDayModel(name: "Project Due", date: Date(), forWhom: "Work", category: .work),
                    SpecialDayModel(name: "Friend's Meet", date: Date(), forWhom: "John", category: .friends)
                ],
                onAddTapped: { _ in },
                onDayTapped: { _ in },
                onCardTapped: { _ in },
                customTitle: "All Special Days",
                customIcon: "calendar"
            )
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
