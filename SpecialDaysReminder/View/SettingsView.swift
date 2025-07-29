//
//  SettingsView.swift
//  SpecialDaysReminder
//
//  Created by YourName on Date.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // Removed NavigationView wrapper. This view will now rely on the
        // NavigationStack from SpecialDaysListView for its navigation context.
        Form {
            Section(header: Text("General Settings").foregroundColor(.black)) {
                // Placeholder for future settings like notifications, theme, etc.
                Text("Settings options will go here.")
                    .foregroundColor(.black)
            }
        }
        .background(Color.white) // Fixed background to white
        .scrollContentBackground(.hidden) // Hide default list background
        .navigationTitle("Settings") // Set navigation title
        .navigationBarTitleDisplayMode(.inline) // Keep bar compact
        .navigationBarBackButtonHidden(true) // NEW: Hide the system-provided back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { // Placed in leading for consistency
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.black) // Fixed button color
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
