import SwiftUI
import SwiftData

/// Racine de l'application.
///
/// La `TabView` fait partie de la couche de navigation : elle bénéficie
/// nativement du Liquid Glass sur iOS 27+. On ne superpose pas de conteneur
/// de verre au-dessus d'elle pour ne pas perturber la mise en page du contenu.
struct ContentView: View {
    @StateObject private var noteViewModel = NoteViewModel()
    @StateObject private var folderViewModel = FolderViewModel()

    var body: some View {
        TabView {
            NotesListView(
                noteViewModel: noteViewModel,
                folderViewModel: folderViewModel
            )
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }

            FoldersView(folderViewModel: folderViewModel)
                .tabItem {
                    Label("Dossiers", systemImage: "folder.fill")
                }

            FavoritesArchiveView(noteViewModel: noteViewModel)
                .tabItem {
                    Label("Favoris & Archives", systemImage: "star.fill")
                }
        }
        .tint(Constants.Colors.accent)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Note.self, Folder.self, Tag.self], inMemory: true)
}
