import AppIntents
import Foundation
import SwiftData

// MARK: - Créer une note rapide

/// Crée une note rapide dans NovaNote, **sans ouvrir l'application**.
///
/// Utilisable depuis l'app Raccourcis (action « Créer une note rapide ») ou
/// depuis Siri. Le raccourci peut fournir le texte directement, ou le demander
/// à l'utilisateur (« Demander une entrée » + dictée).
struct CreateQuickNoteIntent: AppIntent {
    // Propriétés calculées : aucune donnée globale mutable (compatibilité Swift 6).
    static var title: LocalizedStringResource { "Créer une note rapide" }

    static var description: IntentDescription {
        IntentDescription("Enregistre une note rapide dans NovaNote sans ouvrir l'application.")
    }

    /// Inutile d'ouvrir l'application : l'intention écrit directement en base.
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "Texte de la note")
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Créer une note avec \(\.$text)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = NovaNoteData.shared.mainContext
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .result(dialog: "Note vide : rien n'a été enregistré.")
        }
        let note = Note(title: "", content: trimmed)
        context.insert(note)
        try context.save()
        return .result(dialog: "Note enregistrée dans NovaNote.")
    }
}

// MARK: - Ouvrir la capture rapide

/// Ouvre l'application directement sur la feuille de capture rapide.
///
/// Le raccourci sert de « bouton d'accès » : un tap (ou « Dis Siri ») et le
/// clavier est prêt pour saisir une note, qu'un second tap enregistre.
struct OpenQuickCaptureIntent: AppIntent {
    static var title: LocalizedStringResource { "Ouvrir la capture rapide" }

    static var description: IntentDescription {
        IntentDescription("Ouvre NovaNote prêt à saisir une note rapide.")
    }

    static var openAppWhenRun: Bool { true }

    @MainActor
    func perform() async throws -> some IntentResult {
        NovaNoteLink.requestQuickCapture()
        return .result()
    }
}

// MARK: - Raccourcis proposés automatiquement

/// Raccourcis visibles immédiatement dans l'app Raccourcis (aucune
/// configuration requise) et utilisables à la voix avec Siri.
struct NovaNoteAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateQuickNoteIntent(),
            phrases: [
                "Nouvelle note dans \(.applicationName)",
                "Créer une note dans \(.applicationName)",
                "Note rapide \(.applicationName)"
            ],
            shortTitle: "Note rapide",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenQuickCaptureIntent(),
            phrases: [
                "Capture rapide \(.applicationName)"
            ],
            shortTitle: "Capture rapide",
            systemImageName: "plus.bubble"
        )
    }
}
