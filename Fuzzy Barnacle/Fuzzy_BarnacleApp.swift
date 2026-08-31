//
//  Fuzzy_BarnacleApp.swift
//  Fuzzy Barnacle
//
//  Created by kc on 8/31/26.
//

import SwiftUI
import SwiftData

@main
struct Fuzzy_BarnacleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Barnacle.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
