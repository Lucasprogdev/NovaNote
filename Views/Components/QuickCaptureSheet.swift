import SwiftUI

/// Feuille de **capture rapide** : un seul champ, une mise au point automatique,
/// un bouton « Enregistrer ». Conçue pour être ouverte instantanément depuis un
/// raccourci (`novanote://capture`).
struct QuickCaptureSheet: View {
    /// Reçoit le texte saisi ; c'est l'appelant qui crée la note.
    var onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                TextEditor(text: $text)
                    .focused($isFocused)
                    .font(.system(size: 17))
                    .foregroundStyle(Constants.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(Constants.Spacing.lg)
                    .background(Constants.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("Note rapide…")
                                .font(.system(size: 17))
                                .foregroundStyle(Constants.Colors.textSecondary)
                                .padding(.horizontal, Constants.Spacing.lg + 5)
                                .padding(.vertical, Constants.Spacing.xl)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(Constants.Spacing.lg)
            }
            .navigationTitle("Note rapide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(Constants.Colors.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Constants.Colors.accent)
                    .disabled(trimmed.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            isFocused = true
        }
    }

    private func save() {
        guard !trimmed.isEmpty else {
            dismiss()
            return
        }
        onSave(trimmed)
        dismiss()
    }
}
