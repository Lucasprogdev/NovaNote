import Foundation
import SwiftData

/// Conteneur SwiftData unique, partagé par l'application **et** les App Intents.
///
/// Les App Intents s'exécutent dans le processus de l'application. En utilisant
/// le même `ModelContainer` des deux côtés, une note créée depuis un raccourci
/// est immédiatement visible dans l'application (et inversement).
enum NovaNoteData {
    /// `nonisolated(unsafe)` : SwiftData gère lui-même la synchronisation de son
    /// conteneur ; il est conçu pour être partagé (le projet compile en Swift 6).
    nonisolated(unsafe) static let shared: ModelContainer = {
        let schema = Schema([Note.self, Folder.self, Tag.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Impossible de créer le conteneur SwiftData : \(error)")
        }
    }()
}
