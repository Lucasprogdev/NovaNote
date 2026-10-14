import SwiftUI
import SwiftData

struct FavoritesArchiveView: View {
    @ObservedObject var noteViewModel: NoteViewModel
    @Query(sort: \Note.modifiedAt, order: .reverse) private var allNotes: [Note]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: Constants.Spacing.xl) {
                        if !noteViewModel.favoriteNotes(allNotes).isEmpty {
                            favoritesSection
                        }
                        
                        if !noteViewModel.archivedNotes(allNotes).isEmpty {
                            archivesSection
                        }
                        
                        if noteViewModel.favoriteNotes(allNotes).isEmpty && noteViewModel.archivedNotes(allNotes).isEmpty {
                            EmptyStateView(
                                icon: "star.slash",
                                title: "Rien ici",
                                subtitle: "Vos notes favorites et archivées apparaîtront ici"
                            )
                            .padding(.top, 120)
                        }
                    }
                    .padding(Constants.Spacing.lg)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Favoris & Archives")
        }
    }
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                Text("Favoris")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Constants.Colors.textPrimary)
            }
            .padding(.horizontal, Constants.Spacing.xs)
            
            ForEach(noteViewModel.favoriteNotes(allNotes)) { note in
                NavigationLink(destination: NoteEditorView(
                    note: note,
                    onSave: { title, content, folder, tags in
                        note.title = title
                        note.content = content
                        note.folder = folder
                        note.tags = tags
                        note.modifiedAt = Date()
                        try? modelContext.save()
                    }
                )) {
                    NoteRowView(note: note)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var archivesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                Text("Archives")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Constants.Colors.textPrimary)
            }
            .padding(.horizontal, Constants.Spacing.xs)
            
            ForEach(noteViewModel.archivedNotes(allNotes)) { note in
                NavigationLink(destination: NoteEditorView(
                    note: note,
                    onSave: { title, content, folder, tags in
                        note.title = title
                        note.content = content
                        note.folder = folder
                        note.tags = tags
                        note.modifiedAt = Date()
                        try? modelContext.save()
                    }
                )) {
                    NoteRowView(note: note)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
