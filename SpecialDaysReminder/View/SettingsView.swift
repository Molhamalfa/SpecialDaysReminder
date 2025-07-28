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
        NavigationView {
            Form {
                Section(header: Text("General Settings")) {
                    // Placeholder for future settings like notifications, theme, etc.
                    Text("Settings options will go here.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
