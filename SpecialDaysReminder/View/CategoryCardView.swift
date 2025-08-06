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
                Text("No special days yet.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 10)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(specialDays.prefix(2), id: \.id) { day in
                        VStack(alignment: .leading) {
                            Text(day.daysUntilDescription)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            HStack {
                                Text(day.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(day.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    if specialDays.count > 2 {
                        Text("(\(specialDays.count - 2) more...)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(height: 200) // UPDATED: Increased height to accommodate "X more..." text
        .frame(maxWidth: .infinity)
        .background(category.color.gradient)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 25))
    }
}

// MARK: - Preview Provider
struct CategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryCardView(
                category: .lovedOnes,
                specialDays: [
                    SpecialDayModel(name: "Birthday", date: Date().addingTimeInterval(86400), forWhom: "John", category: .lovedOnes),
                    SpecialDayModel(name: "Anniversary", date: Date().addingTimeInterval(86400 * 5), forWhom: "Jane", category: .lovedOnes)
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
