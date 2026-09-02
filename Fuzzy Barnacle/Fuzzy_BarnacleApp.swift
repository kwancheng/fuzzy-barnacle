import SwiftUI
import SwiftData

@main
struct Fuzzy_BarnacleApp: App {
    init() {
        // the piece's own clock: shifted by a launch argument when
        // it is shifted, the way the water is shifted by nothing
        ContentView.timeOffset = ContentView.virtualTimeOffset(
            from: ProcessInfo.processInfo.arguments
        )
        // the water's voice: kept when the piece is asked to be
        // silent — the piece's motion is the piece's motion,
        // whether it is heard or not
        ContentView.voiceEnabled = ContentView.voiceEnabled(
            from: ProcessInfo.processInfo.arguments
        )
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Barnacle.self,
            Ghost.self,
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
