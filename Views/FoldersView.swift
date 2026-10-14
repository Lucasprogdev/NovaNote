import SwiftUI
import SwiftData

struct FoldersView: View {
    @ObservedObject var folderViewModel: FolderViewModel
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Note.modifiedAt) private var allNotes: [Note]
    @Environment(\.modelContext) private var modelContext
    @Namespace private var glassNamespace
    
    let availableColors = ["#4A90E2", "#6C5CE7", "#00B894", "#E17055", "#D63031", "#FD79A8", "#FDCB6E", "#00CEC9"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: Constants.Spacing.lg),
                        GridItem(.flexible(), spacing: Constants.Spacing.lg)
                    ], spacing: Constants.Spacing.lg) {
                        ForEach(folders) { folder in
                            FolderCardView(
                                folder: folder,
                                noteCount: notesCount(for: folder)
                            )
                        }
                    }
                    .padding(Constants.Spacing.lg)
                    .padding(.bottom, 100)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        GlassEffectContainer(spacing: Constants.Spacing.md) {
                            LiquidGlassButton(icon: "folder.badge.plus") {
                                folderViewModel.newFolderName = ""
                                folderViewModel.newFolderColor = availableColors.first ?? "#4A90E2"
                                folderViewModel.isCreatingFolder = true
                            }
                            .glassEffectID("folderFab", in: glassNamespace)
                        }
                        .padding(Constants.Spacing.xl)
                    }
                }
            }
            .navigationTitle("Dossiers")
            .sheet(isPresented: $folderViewModel.isCreatingFolder) {
                createFolderSheet
            }
        }
    }
    
    private func notesCount(for folder: Folder) -> Int {
        allNotes.filter { $0.folder?.id == folder.id && !$0.isArchived }.count
    }
    
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
                    
                    VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                        Text("Couleur")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Constants.Colors.textSecondary)
                            .padding(.horizontal, Constants.Spacing.xs)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Spacing.sm) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: {
                                        folderViewModel.newFolderColor = color
                                    }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .stroke(.white, lineWidth: folderViewModel.newFolderColor == color ? 2 : 0)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, Constants.Spacing.xs)
                        }
                    }
                    
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
