//
//  SpecialDayRowView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct SpecialDayRowView: View {
    let day: SpecialDayModel
    let themeColor: Color // UPDATED: Changed to Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(day.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white) // Fixed to white for contrast
                Text(day.forWhom)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8)) // Fixed to white for contrast
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(day.daysUntilDescription)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Fixed to white for contrast
                Text(day.formattedDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8)) // Fixed to white for contrast
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(themeColor) // UPDATED: Use the Color directly
        // UPDATED: Adjusted corner radius to match the other cards
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .contentShape(Rectangle()) // Makes the entire row tappable
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.vertical, 4)
    }
}

struct SpecialDayRowView_Previews: PreviewProvider {
    static var previews: some View {
        SpecialDayRowView(
            day: SpecialDayModel(name: "Sample Event", date: Date(), forWhom: "Test Person", category: .other),
            themeColor: SpecialDayCategory.other.color // UPDATED: Pass Color
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
