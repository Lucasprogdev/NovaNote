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

    @State private var selectedTab: Int = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $selectedTab) {
            NotesListView(
                noteViewModel: noteViewModel,
                folderViewModel: folderViewModel
            )
            .tag(0)
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }

            FoldersView(folderViewModel: folderViewModel)
                .tag(1)
                .tabItem {
                    Label("Dossiers", systemImage: "folder.fill")
                }

            FavoritesArchiveView(noteViewModel: noteViewModel)
                .tag(2)
                .tabItem {
                    Label("Favoris & Archives", systemImage: "star.fill")
                }
        }
        .tint(Constants.Colors.accent)
        .preferredColorScheme(.dark)
        .onOpenURL { url in
            if NovaNoteLink.isQuickCapture(url) {
                openQuickCapture()
            }
        }
        .onAppear {
            // Cas où l'App Intent a été exécutée au lancement de l'application.
            if NovaNoteLink.consumeQuickCaptureRequest() {
                openQuickCapture()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // Cas où l'application était déjà ouverte en arrière-plan.
            if phase == .active, NovaNoteLink.consumeQuickCaptureRequest() {
                openQuickCapture()
            }
        }
    }

    /// Ouvre la capture rapide depuis l'onglet Notes.
    private func openQuickCapture() {
        selectedTab = 0
        noteViewModel.isQuickCapturing = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Note.self, Folder.self, Tag.self], inMemory: true)
}
