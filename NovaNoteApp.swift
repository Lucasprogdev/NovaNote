import SwiftUI
import SwiftData

@main
struct NovaNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(NovaNoteData.shared)
    }
}
