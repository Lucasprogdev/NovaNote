import Foundation
import SwiftData
import SwiftUI

@MainActor
final class NoteViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var selectedFolder: Folder?
    @Published var selectedTag: Tag?
    @Published var isCreatingNote: Bool = false
    @Published var editingNote: Note?
    @Published var isQuickCapturing: Bool = false

    /// Indique si un filtre (recherche, dossier, tag) est actif.
    var hasActiveFilters: Bool {
        !searchQuery.isEmpty || selectedFolder != nil || selectedTag != nil
    }

    func filteredNotes(_ notes: [Note]) -> [Note] {
        var result = notes.filter { !$0.isArchived }
        
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter { note in
                note.title.lowercased().contains(query) ||
                note.content.lowercased().contains(query)
            }
        }
        
        if let selectedFolder = selectedFolder {
            result = result.filter { $0.folder?.id == selectedFolder.id }
        }
        
        if let selectedTag = selectedTag {
            result = result.filter { note in
                note.tags?.contains(where: { $0.id == selectedTag.id }) ?? false
            }
        }
        
        return result.sorted(by: {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.modifiedAt > $1.modifiedAt
        })
    }
    
    /// Supprime définitivement une note.
    func delete(_ note: Note, in context: ModelContext) {
        if editingNote?.id == note.id {
            editingNote = nil
        }
        context.delete(note)
        try? context.save()
    }

    func pinnedNotes(_ notes: [Note]) -> [Note] {
        notes.filter { $0.isPinned && !$0.isArchived }
            .sorted(by: { $0.modifiedAt > $1.modifiedAt })
    }
    
    func favoriteNotes(_ notes: [Note]) -> [Note] {
        notes.filter { $0.isFavorite && !$0.isArchived }
            .sorted(by: { $0.modifiedAt > $1.modifiedAt })
    }
    
    func archivedNotes(_ notes: [Note]) -> [Note] {
        notes.filter { $0.isArchived }
            .sorted(by: { $0.modifiedAt > $1.modifiedAt })
    }
    
    func clearFilters() {
        searchQuery = ""
        selectedFolder = nil
        selectedTag = nil
    }
}
