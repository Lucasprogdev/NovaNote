import SwiftUI
import SwiftData

struct NoteEditorView: View {
    let note: Note?
    let onSave: (String, String, Folder?, [Tag]?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedFolder: Folder?
    @State private var selectedTags: Set<Tag> = []
    @State private var showFolderPicker = false
    @State private var showTagPicker = false
    @State private var isPinned = false
    @State private var isFavorite = false
    @State private var isArchived = false

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        titleField
                        contentField
                    }
                    .padding(Constants.Spacing.lg)
                    .padding(.bottom, 140)
                }

                VStack {
                    Spacer()
                    editorToolbar
                }
            }
            .navigationTitle(note == nil ? "Nouvelle note" : "Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundStyle(Constants.Colors.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Constants.Colors.accent)
                }
            }
            .onAppear(perform: loadNote)
            .sheet(isPresented: $showFolderPicker) {
                folderPickerSheet
            }
            .sheet(isPresented: $showTagPicker) {
                tagPickerSheet
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Champs

    private var titleField: some View {
        TextField("Titre", text: $title)
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Constants.Colors.textPrimary)
            .padding(Constants.Spacing.lg)
            .background(Constants.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg, style: .continuous))
            .focused($isTitleFocused)
    }

    private var contentField: some View {
        ZStack(alignment: .topLeading) {
            if content.isEmpty {
                Text("Commencez à écrire… (Markdown pris en charge : **gras**, - listes, - [ ] tâches)")
                    .font(.system(size: 16))
                    .foregroundStyle(Constants.Colors.textSecondary.opacity(0.6))
                    .padding(.horizontal, Constants.Spacing.lg + 5)
                    .padding(.vertical, Constants.Spacing.lg + 8)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $content)
                .font(.system(size: 16))
                .foregroundStyle(Constants.Colors.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 300)
                .padding(Constants.Spacing.lg)
                .focused($isContentFocused)
        }
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg, style: .continuous))
    }

    // MARK: - Barre d'outils contextuelle (verre)

    private var editorToolbar: some View {
        GlassEffectContainer(spacing: Constants.Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.sm) {
                    stateButton(
                        icon: "pin.fill",
                        isActive: isPinned,
                        label: "Épingler"
                    ) { isPinned.toggle() }

                    stateButton(
                        icon: "star.fill",
                        isActive: isFavorite,
                        label: "Favori"
                    ) { isFavorite.toggle() }

                    stateButton(
                        icon: "archivebox.fill",
                        isActive: isArchived,
                        label: "Archiver"
                    ) { isArchived.toggle() }

                    toolbarDivider

                    stateButton(
                        icon: "folder.fill",
                        isActive: selectedFolder != nil,
                        label: selectedFolder?.name ?? "Dossier"
                    ) { showFolderPicker = true }

                    stateButton(
                        icon: "tag.fill",
                        isActive: !selectedTags.isEmpty,
                        label: selectedTags.isEmpty ? "Tags" : "\(selectedTags.count)"
                    ) { showTagPicker = true }

                    Divider()
                        .frame(height: 24)
                        .overlay(Color.white.opacity(0.2))

                    formatButton(icon: "bold") { formatText(.bold) }
                    formatButton(icon: "list.bullet") { formatText(.bulletList) }
                    formatButton(icon: "checklist") { formatText(.checklist) }
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
            }
            .glassEffect(.clear.interactive(), in: Capsule())
        }
        .padding(.horizontal, Constants.Spacing.lg)
        .padding(.bottom, Constants.Spacing.xl)
    }

    private func stateButton(
        icon: String,
        isActive: Bool,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                if label.count <= 12 {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundStyle(isActive ? .black : .white)
            .padding(.horizontal, Constants.Spacing.sm)
            .padding(.vertical, Constants.Spacing.sm)
            .background(isActive ? Constants.Colors.accent : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var toolbarDivider: some View {
        Divider()
            .frame(height: 24)
            .overlay(Color.white.opacity(0.2))
    }

    private func formatButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(Constants.Spacing.sm)
                .frame(width: 36, height: 34)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sélecteurs

    private func pickerRow(
        title: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .foregroundStyle(Constants.Colors.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Constants.Colors.accent)
                }
            }
            .padding(Constants.Spacing.lg)
            .background(Constants.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var folderPickerSheet: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.sm) {
                        pickerRow(title: "Aucun dossier", color: Constants.Colors.textSecondary, isSelected: selectedFolder == nil) {
                            selectedFolder = nil
                            showFolderPicker = false
                        }

                        ForEach(folders) { folder in
                            Button {
                                selectedFolder = folder
                                showFolderPicker = false
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(Color(hex: folder.colorHex))
                                        .frame(width: 10, height: 10)
                                    Text(folder.name)
                                        .foregroundStyle(Constants.Colors.textPrimary)
                                    Spacer()
                                    if selectedFolder?.id == folder.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Constants.Colors.accent)
                                    }
                                }
                                .padding(Constants.Spacing.lg)
                                .background(Constants.Colors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.md, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Constants.Spacing.lg)
                }
            }
            .navigationTitle("Dossier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { showFolderPicker = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var tagPickerSheet: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.sm) {
                        if tags.isEmpty {
                            EmptyStateView(
                                icon: "tag.slash",
                                title: "Aucun tag",
                                subtitle: "Créez des tags depuis l'écran Dossiers."
                            )
                            .frame(minHeight: 300)
                        } else {
                            ForEach(tags) { tag in
                                Button {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(Color(hex: tag.colorHex))
                                            .frame(width: 10, height: 10)
                                        Text(tag.name)
                                            .foregroundStyle(Constants.Colors.textPrimary)
                                        Spacer()
                                        if selectedTags.contains(tag) {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(Constants.Colors.accent)
                                        }
                                    }
                                    .padding(Constants.Spacing.lg)
                                    .background(Constants.Colors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.md, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Constants.Spacing.lg)
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Effacer") { selectedTags.removeAll() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Terminé") { showTagPicker = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Actions

    private func loadNote() {
        guard let note else {
            isTitleFocused = true
            return
        }
        title = note.title
        content = note.content
        selectedFolder = note.folder
        selectedTags = Set(note.tags ?? [])
        isPinned = note.isPinned
        isFavorite = note.isFavorite
        isArchived = note.isArchived
    }

    private enum FormatAction {
        case bold, bulletList, checklist
    }

    private func formatText(_ action: FormatAction) {
        switch action {
        case .bold:
            content += content.isEmpty ? "**texte en gras**" : "\n**texte en gras**"
        case .bulletList:
            content += content.isEmpty ? "- Élément" : "\n- Élément"
        case .checklist:
            content += content.isEmpty ? "- [ ] Tâche" : "\n- [ ] Tâche"
        }
    }

    private func saveNote() {
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !finalTitle.isEmpty || !finalContent.isEmpty else {
            dismiss()
            return
        }

        onSave(finalTitle, finalContent, selectedFolder, Array(selectedTags))
        dismiss()
    }
}
