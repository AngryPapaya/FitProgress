//
//  FitProgressApp.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI

@main
struct FitProgressApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // No fuerces un esquema de color específico
                //.preferredColorScheme(.light)
        }
    }
}
