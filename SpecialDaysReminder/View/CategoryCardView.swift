//
//  CategoryCardView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct CategoryCardView: View {
    let category: SpecialDayCategory
    let specialDays: [SpecialDayModel]
    let onAddTapped: (SpecialDayCategory) -> Void
    let onDayTapped: (SpecialDayModel) -> Void

    // Custom properties for "All Special Days" card
    var customTitle: String?
    var customIcon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: customIcon ?? category.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(customTitle ?? category.displayName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    onAddTapped(category)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 5)

            if specialDays.isEmpty {
                Spacer() // Pushes content to top
                Text("No special days yet.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 10)
                Spacer() // Pushes content to bottom
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(specialDays.prefix(2)) { day in
                        HStack {
                            Text(day.name)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.white)
                            Spacer()
                            Text(day.daysUntilDescription)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onDayTapped(day)
                        }
                    }
                    if specialDays.count > 2 {
                        Text("+\(specialDays.count - 2) more...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 5)
                    }
                }
                Spacer() // Ensures content is pushed to the top within the fixed frame
            }
        }
        .padding()
        .background(category.color)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .frame(minHeight: 170, maxHeight: 170) // CHANGED: Increased fixed height for better consistency
    }
}

// MARK: - SpecialDayCategory Extension
// This provides a color and icon for each category.
extension SpecialDayCategory {


    var iconName: String {
        switch self {
        case .lovedOnes: return "heart.fill"
        case .friends: return "person.2.fill"
        case .family: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "star.fill"
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
                    SpecialDayModel(name: "Anniversary", date: Date().addingTimeInterval(86400 * 30), forWhom: "Partner", category: .lovedOnes),
                    SpecialDayModel(name: "Event 3", date: Date().addingTimeInterval(86400 * 60), forWhom: "Another", category: .lovedOnes)
                ],
                onAddTapped: { _ in },
                onDayTapped: { _ in }
            )
            .previewDisplayName("Loved Ones Card (Full)")

            CategoryCardView(
                category: .other,
                specialDays: [],
                onAddTapped: { _ in },
                onDayTapped: { _ in },
                customTitle: "All Special Days",
                customIcon: "calendar"
            )
            .previewDisplayName("All Days Empty Card")

            CategoryCardView(
                category: .work,
                specialDays: [
                    SpecialDayModel(name: "Work Party", date: Date().addingTimeInterval(86400 * 10), forWhom: "Team", category: .work),
                    SpecialDayModel(name: "Project Deadline", date: Date().addingTimeInterval(86400 * 20), forWhom: "Client", category: .work),
                    SpecialDayModel(name: "Review", date: Date().addingTimeInterval(86400 * 40), forWhom: "Boss", category: .work),
                    SpecialDayModel(name: "Team Lunch", date: Date().addingTimeInterval(86400 * 50), forWhom: "Colleagues", category: .work)
                ],
                onAddTapped: { _ in },
                onDayTapped: { _ in },
                customTitle: "Work Events",
                customIcon: "briefcase.fill"
            )
            .previewDisplayName("Work Card (More than 2)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
