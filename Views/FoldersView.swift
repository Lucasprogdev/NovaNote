import SwiftUI
import SwiftData

struct FoldersView: View {
    @ObservedObject var folderViewModel: FolderViewModel
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Query(sort: \Note.modifiedAt) private var allNotes: [Note]
    @Environment(\.modelContext) private var modelContext
    @Namespace private var glassNamespace

    @State private var folderToDelete: Folder?
    @State private var tagToDelete: Tag?
    @State private var folderToRename: Folder?
    @State private var renameText: String = ""

    let availableColors = ["#4A90E2", "#6C5CE7", "#00B894", "#E17055", "#D63031", "#FD79A8", "#FDCB6E", "#00CEC9"]

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Constants.Spacing.xl) {
                        foldersSection
                        tagsSection
                    }
                    .padding(Constants.Spacing.lg)
                    .padding(.bottom, 100)
                }

                floatingAddButton
            }
            .navigationTitle("Dossiers")
        }
        .sheet(isPresented: $folderViewModel.isCreatingFolder) {
            createFolderSheet
        }
        .sheet(isPresented: $folderViewModel.isManagingTags) {
            createTagSheet
        }
        .alert("Renommer le dossier", isPresented: renameBinding) {
            TextField("Nom", text: $renameText)
            Button("Annuler", role: .cancel) { folderToRename = nil }
            Button("Renommer") { renameFolder() }
        }
        .confirmationDialog(
            "Supprimer ce dossier ?",
            isPresented: Binding(
                get: { folderToDelete != nil },
                set: { if !$0 { folderToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                if let folder = folderToDelete {
                    folderViewModel.delete(folder, in: modelContext)
                }
                folderToDelete = nil
            }
            Button("Annuler", role: .cancel) { folderToDelete = nil }
        } message: {
            Text("Les notes du dossier seront conservées, mais ne seront plus classées.")
        }
        .confirmationDialog(
            "Supprimer ce tag ?",
            isPresented: Binding(
                get: { tagToDelete != nil },
                set: { if !$0 { tagToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                if let tag = tagToDelete {
                    folderViewModel.delete(tag, in: modelContext)
                }
                tagToDelete = nil
            }
            Button("Annuler", role: .cancel) { tagToDelete = nil }
        } message: {
            Text("Le tag sera retiré de toutes les notes.")
        }
    }

    // MARK: - Sections

    private var foldersSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            sectionHeader(icon: "folder.fill", title: "Dossiers")

            if folders.isEmpty {
                EmptyStateView(
                    icon: "folder.badge.plus",
                    title: "Aucun dossier",
                    subtitle: "Appuyez sur + pour créer votre premier dossier."
                )
                .frame(minHeight: 180)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Constants.Spacing.lg),
                    GridItem(.flexible(), spacing: Constants.Spacing.lg)
                ], spacing: Constants.Spacing.lg) {
                    ForEach(folders) { folder in
                        FolderCardView(
                            folder: folder,
                            noteCount: notesCount(for: folder)
                        )
                        .contextMenu {
                            Button {
                                renameText = folder.name
                                folderToRename = folder
                            } label: {
                                Label("Renommer", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                folderToDelete = folder
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                sectionHeader(icon: "tag.fill", title: "Tags")
                Spacer()
                Button {
                    folderViewModel.newTagName = ""
                    folderViewModel.newTagColor = "#6C5CE7"
                    folderViewModel.isManagingTags = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Constants.Colors.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Nouveau tag")
            }

            if tags.isEmpty {
                Text("Aucun tag. Créez-en un pour classer vos notes.")
                    .font(.system(size: 13))
                    .foregroundStyle(Constants.Colors.textSecondary)
                    .padding(.horizontal, Constants.Spacing.xs)
            } else {
                VStack(spacing: Constants.Spacing.sm) {
                    ForEach(tags) { tag in
                        HStack(spacing: Constants.Spacing.md) {
                            Circle()
                                .fill(Color(hex: tag.colorHex))
                                .frame(width: 10, height: 10)
                            Text(tag.name)
                                .font(.system(size: 15))
                                .foregroundStyle(Constants.Colors.textPrimary)
                            Spacer()
                            Text("\(tagsCount(for: tag))")
                                .font(.system(size: 12))
                                .foregroundStyle(Constants.Colors.textSecondary)
                        }
                        .padding(Constants.Spacing.lg)
                        .background(Constants.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.md, style: .continuous))
                        .contextMenu {
                            Button(role: .destructive) {
                                tagToDelete = tag
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                LiquidGlassButton(icon: "folder.badge.plus") {
                    folderViewModel.newFolderName = ""
                    folderViewModel.newFolderColor = availableColors.first ?? "#4A90E2"
                    folderViewModel.isCreatingFolder = true
                }
                .padding(Constants.Spacing.xl)
            }
        }
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: Constants.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Constants.Colors.textSecondary)
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Constants.Colors.textPrimary)
        }
        .padding(.horizontal, Constants.Spacing.xs)
    }

    // MARK: - Aides

    private var renameBinding: Binding<Bool> {
        Binding(
            get: { folderToRename != nil },
            set: { if !$0 { folderToRename = nil } }
        )
    }

    private func renameFolder() {
        guard let folder = folderToRename else { return }
        let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty {
            folder.name = name
            try? modelContext.save()
        }
        folderToRename = nil
    }

    private func notesCount(for folder: Folder) -> Int {
        allNotes.filter { $0.folder?.id == folder.id && !$0.isArchived }.count
    }

    private func tagsCount(for tag: Tag) -> Int {
        allNotes.filter { note in
            note.tags?.contains(where: { $0.id == tag.id }) ?? false
        }.count
    }

    // MARK: - Feuille « Nouveau dossier »

    private var createFolderSheet: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: Constants.Spacing.xl) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                        Text("Nom du dossier")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Constants.Colors.textSecondary)
                            .padding(.horizontal, Constants.Spacing.xs)

                        TextField("Ex: Travail, Personnel...", text: $folderViewModel.newFolderName)
                            .font(.system(size: 16))
                            .foregroundStyle(Constants.Colors.textPrimary)
                            .padding(Constants.Spacing.lg)
                            .background(Constants.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg))
                    }

                    colorPicker(selection: $folderViewModel.newFolderColor)

                    Spacer()
                }
                .padding(Constants.Spacing.lg)
            }
            .navigationTitle("Nouveau dossier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        folderViewModel.isCreatingFolder = false
                    }
                    .foregroundStyle(Constants.Colors.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Créer") {
                        createFolder()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Constants.Colors.accent)
                    .disabled(folderViewModel.newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Feuille « Nouveau tag »

    private var createTagSheet: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: Constants.Spacing.xl) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                        Text("Nom du tag")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Constants.Colors.textSecondary)
                            .padding(.horizontal, Constants.Spacing.xs)

                        TextField("Ex: Urgent, Idée...", text: $folderViewModel.newTagName)
                            .font(.system(size: 16))
                            .foregroundStyle(Constants.Colors.textPrimary)
                            .padding(Constants.Spacing.lg)
                            .background(Constants.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg))
                    }

                    colorPicker(selection: $folderViewModel.newTagColor)

                    Spacer()
                }
                .padding(Constants.Spacing.lg)
            }
            .navigationTitle("Nouveau tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        folderViewModel.isManagingTags = false
                    }
                    .foregroundStyle(Constants.Colors.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Créer") {
                        folderViewModel.createTag(in: modelContext)
                        folderViewModel.isManagingTags = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Constants.Colors.accent)
                    .disabled(folderViewModel.newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Composants partagés

    private func colorPicker(selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Couleur")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Constants.Colors.textSecondary)
                .padding(.horizontal, Constants.Spacing.xs)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.sm) {
                    ForEach(availableColors, id: \.self) { color in
                        Button {
                            selection.wrappedValue = color
                        } label: {
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: selection.wrappedValue == color ? 2 : 0)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Constants.Spacing.xs)
            }
        }
    }

    // MARK: - Actions

    private func createFolder() {
        let name = folderViewModel.newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty {
            let newFolder = Folder(name: name, colorHex: folderViewModel.newFolderColor)
            modelContext.insert(newFolder)
            try? modelContext.save()
            folderViewModel.isCreatingFolder = false
        }
    }
}
