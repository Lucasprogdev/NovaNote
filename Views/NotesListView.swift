import SwiftUI
import SwiftData

struct NotesListView: View {
    @ObservedObject var noteViewModel: NoteViewModel
    @ObservedObject var folderViewModel: FolderViewModel

    @Query(sort: \Note.modifiedAt, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Tag.name) private var tags: [Tag]

    @Environment(\.modelContext) private var modelContext

    @State private var noteToDelete: Note?

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: Constants.Spacing.lg) {
                        searchBar

                        if !noteViewModel.pinnedNotes(allNotes).isEmpty {
                            pinnedSection
                        }

                        if !folders.isEmpty || !tags.isEmpty {
                            filterSection
                        }

                        notesList
                    }
                    .padding(.horizontal, Constants.Spacing.lg)
                    .padding(.top, Constants.Spacing.md)
                    .padding(.bottom, 120)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        QuickCaptureBar(
                            onOpenEditor: {
                                noteViewModel.isCreatingNote = true
                            },
                            onCreate: { text in
                                let newNote = Note(title: "", content: text)
                                modelContext.insert(newNote)
                                try? modelContext.save()
                            }
                        )
                        .padding(Constants.Spacing.xl)
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        noteViewModel.isCreatingNote = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .foregroundStyle(Constants.Colors.accent)
                    .accessibilityLabel("Nouvelle note")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if noteViewModel.hasActiveFilters {
                        Button("Effacer") {
                            noteViewModel.clearFilters()
                        }
                        .foregroundStyle(Constants.Colors.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $noteViewModel.isCreatingNote) {
            NoteEditorView(
                note: nil,
                onSave: { title, content, folder, tags in
                    let newNote = Note(
                        title: title,
                        content: content,
                        folder: folder,
                        tags: tags
                    )
                    modelContext.insert(newNote)
                    try? modelContext.save()
                }
            )
        }
        .sheet(item: $noteViewModel.editingNote) { note in
            NoteEditorView(
                note: note,
                onSave: { title, content, folder, tags in
                    note.title = title
                    note.content = content
                    note.folder = folder
                    note.tags = tags
                    note.modifiedAt = Date()
                    try? modelContext.save()
                }
            )
        }
        .confirmationDialog(
            "Supprimer cette note ?",
            isPresented: Binding(
                get: { noteToDelete != nil },
                set: { if !$0 { noteToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                if let note = noteToDelete {
                    noteViewModel.delete(note, in: modelContext)
                }
                noteToDelete = nil
            }
            Button("Annuler", role: .cancel) {
                noteToDelete = nil
            }
        } message: {
            Text("Cette action est définitive.")
        }
        .sheet(isPresented: $noteViewModel.isQuickCapturing) {
            QuickCaptureSheet { text in
                let newNote = Note(title: "", content: text)
                modelContext.insert(newNote)
                try? modelContext.save()
            }
        }
    }

    // MARK: - Recherche

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Constants.Colors.textSecondary)

            TextField("Rechercher dans les notes…", text: $noteViewModel.searchQuery)
                .textFieldStyle(.plain)
                .foregroundStyle(Constants.Colors.textPrimary)
                .autocorrectionDisabled()

            if !noteViewModel.searchQuery.isEmpty {
                Button {
                    noteViewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Constants.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Constants.Spacing.lg)
        .padding(.vertical, Constants.Spacing.md)
        .glassEffect(.clear.interactive(), in: Capsule())
    }

    // MARK: - Notes épinglées

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            sectionHeader(icon: "pin.fill", title: "Épinglées", tint: Constants.Colors.accent)

            ForEach(noteViewModel.pinnedNotes(allNotes)) { note in
                noteButton(note)
            }
        }
    }

    // MARK: - Filtres (dossiers + tags)

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            if !folders.isEmpty {
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    sectionHeader(icon: "folder.fill", title: "Dossiers", tint: Constants.Colors.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.Spacing.sm) {
                            filterChip(
                                title: "Tous",
                                isSelected: noteViewModel.selectedFolder == nil,
                                color: Constants.Colors.accent
                            ) {
                                noteViewModel.selectedFolder = nil
                            }

                            ForEach(folders) { folder in
                                filterChip(
                                    title: folder.name,
                                    isSelected: noteViewModel.selectedFolder?.id == folder.id,
                                    color: Color(hex: folder.colorHex)
                                ) {
                                    noteViewModel.selectedFolder =
                                        (noteViewModel.selectedFolder?.id == folder.id) ? nil : folder
                                }
                            }
                        }
                        .padding(.horizontal, Constants.Spacing.xs)
                        .padding(.vertical, Constants.Spacing.xs)
                    }
                }
            }

            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    sectionHeader(icon: "tag.fill", title: "Tags", tint: Constants.Colors.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.Spacing.sm) {
                            filterChip(
                                title: "Tous",
                                isSelected: noteViewModel.selectedTag == nil,
                                color: Constants.Colors.accent
                            ) {
                                noteViewModel.selectedTag = nil
                            }

                            ForEach(tags) { tag in
                                TagChipView(
                                    tag: tag,
                                    isSelected: noteViewModel.selectedTag?.id == tag.id
                                ) {
                                    noteViewModel.selectedTag =
                                        (noteViewModel.selectedTag?.id == tag.id) ? nil : tag
                                }
                            }
                        }
                        .padding(.horizontal, Constants.Spacing.xs)
                        .padding(.vertical, Constants.Spacing.xs)
                    }
                }
            }
        }
    }

    // MARK: - Liste des notes

    private var notesList: some View {
        let filtered = noteViewModel.filteredNotes(allNotes)

        return VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            if filtered.isEmpty && noteViewModel.pinnedNotes(allNotes).isEmpty {
                EmptyStateView(
                    icon: "note.text",
                    title: "Aucune note",
                    subtitle: "Appuyez sur le bouton + pour créer votre première note."
                )
                .frame(minHeight: 320)
            } else if filtered.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "Aucun résultat",
                    subtitle: "Aucune note ne correspond à votre recherche ou à vos filtres."
                )
                .frame(minHeight: 260)
            } else {
                sectionHeader(icon: "note.text", title: "Toutes les notes", tint: Constants.Colors.textSecondary)

                ForEach(filtered) { note in
                    noteButton(note)
                }
            }
        }
    }

    // MARK: - Composants internes

    private func noteButton(_ note: Note) -> some View {
        Button {
            noteViewModel.editingNote = note
        } label: {
            NoteRowView(note: note)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                noteViewModel.editingNote = note
            } label: {
                Label("Modifier", systemImage: "pencil")
            }

            Button {
                note.isFavorite.toggle()
                try? modelContext.save()
            } label: {
                Label(
                    note.isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                    systemImage: note.isFavorite ? "star.slash" : "star"
                )
            }

            Button {
                note.isArchived.toggle()
                try? modelContext.save()
            } label: {
                Label(
                    note.isArchived ? "Désarchiver" : "Archiver",
                    systemImage: note.isArchived ? "tray.and.arrow.up" : "archivebox"
                )
            }

            Divider()

            Button(role: .destructive) {
                noteToDelete = note
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }

    private func sectionHeader(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: Constants.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Constants.Colors.textPrimary)
        }
        .padding(.horizontal, Constants.Spacing.xs)
    }

    private func filterChip(
        title: String,
        isSelected: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? .black : Constants.Colors.textPrimary)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(isSelected ? color : color.opacity(0.2))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
