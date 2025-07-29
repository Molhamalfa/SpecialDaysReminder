//
//  SpecialDayRowView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct SpecialDayRowView: View {
    let day: SpecialDayModel
    let themeColor: Color
    // Removed: let onTapAction: (SpecialDayModel) -> Void // No longer needed

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(day.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(themeColor.opacity(0.9))
                Text(day.forWhom)
                    .font(.subheadline)
                    .foregroundColor(themeColor.opacity(0.7))
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(day.daysUntilDescription)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(themeColor.opacity(0.9))
                Text(day.formattedDate)
                    .font(.caption)
                    .foregroundColor(themeColor.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(themeColor.opacity(0.15))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .contentShape(Rectangle()) // Makes the entire row tappable
        // Removed: .onTapGesture { onTapAction(day) } // No longer needed, NavigationLink handles tap
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.vertical, 4)
    }
}

struct SpecialDayRowView_Previews: PreviewProvider {
    static var previews: some View {
        SpecialDayRowView(
            day: SpecialDayModel(name: "Sample Event", date: Date(), forWhom: "Test Person", category: .other),
            themeColor: .purple // Provide a sample theme color for preview
            // Removed: onTapAction: { day in print("Tapped on: \(day.name)") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
