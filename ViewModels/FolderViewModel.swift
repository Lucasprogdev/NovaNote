import Foundation
import SwiftData
import SwiftUI

@MainActor
final class FolderViewModel: ObservableObject {
    @Published var isCreatingFolder: Bool = false
    @Published var newFolderName: String = ""
    @Published var newFolderColor: String = "#4A90E2"
    @Published var isManagingTags: Bool = false
    @Published var newTagName: String = ""
    @Published var newTagColor: String = "#6C5CE7"

    /// Supprime un dossier. Les notes qu'il contenait sont conservées
    /// (elles redeviennent « sans dossier »).
    func delete(_ folder: Folder, in context: ModelContext) {
        for note in folder.notes ?? [] {
            note.folder = nil
        }
        context.delete(folder)
        try? context.save()
    }

    /// Crée un tag à partir des champs de saisie.
    @discardableResult
    func createTag(in context: ModelContext) -> Tag? {
        let name = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        let tag = Tag(name: name, colorHex: newTagColor)
        context.insert(tag)
        try? context.save()
        newTagName = ""
        newTagColor = "#6C5CE7"
        return tag
    }

    /// Supprime un tag.
    func delete(_ tag: Tag, in context: ModelContext) {
        for note in tag.notes ?? [] {
            note.tags?.removeAll { $0.id == tag.id }
        }
        context.delete(tag)
        try? context.save()
    }
}
