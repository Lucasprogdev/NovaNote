import SwiftUI
import SwiftData

@main
struct NovaNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Note.self, Folder.self, Tag.self])
    }
}
