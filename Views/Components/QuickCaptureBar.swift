import SwiftUI

/// Capture rapide avec effet de morphing Liquid Glass.
///
/// Au tap, le bouton circulaire se transforme en barre de saisie grâce à
/// `GlassEffectContainer` + `glassEffectID` partagé au sein d'un même `@Namespace`.
///
/// Points d'attention (fiabilité du tap) :
/// - le verre est appliqué au `Button` (et non au contenu du label) ;
/// - `.contentShape(...)` définit explicitement la zone tactile ;
/// - la mise au point du champ est différée d'une frame, car demander le focus
///   pendant l'animation d'apparition échoue parfois silencieusement.
struct QuickCaptureBar: View {
    /// Ouvre l'éditeur complet (note longue / Markdown).
    var onOpenEditor: () -> Void
    /// Enregistre une note rapide à partir du texte saisi.
    var onCreate: (String) -> Void

    @Namespace private var namespace
    @State private var isExpanded = false
    @State private var text = ""
    @FocusState private var isFocused: Bool

    private var animation: Animation { .spring(response: 0.4, dampingFraction: 0.8) }

    var body: some View {
        GlassEffectContainer(spacing: Constants.Spacing.md) {
            if isExpanded {
                expandedBar
                    .glassEffectID("quickCapture", in: namespace)
            } else {
                collapsedButton
                    .glassEffectID("quickCapture", in: namespace)
            }
        }
        .animation(animation, value: isExpanded)
    }

    // MARK: - Bouton replié

    private var collapsedButton: some View {
        Button {
            withAnimation(animation) { isExpanded = true }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .contentShape(Circle())
        }
        .buttonStyle(GlassPressButtonStyle())
        .glassEffect(.clear.interactive(), in: Circle())
        .accessibilityLabel("Créer une note rapide")
    }

    // MARK: - Barre dépliée

    private var expandedBar: some View {
        HStack(spacing: Constants.Spacing.sm) {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 14))
                    .foregroundStyle(Constants.Colors.textSecondary)

                TextField("Note rapide…", text: $text, axis: .vertical)
                    .lineLimit(1...3)
                    .textFieldStyle(.plain)
                    .foregroundStyle(Constants.Colors.textPrimary)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit(save)
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .padding(.vertical, Constants.Spacing.md)

            Button {
                onOpenEditor()
                collapse()
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
            }
            .buttonStyle(GlassPressButtonStyle())
            .glassEffect(.clear.interactive(), in: Circle())
            .accessibilityLabel("Ouvrir l'éditeur complet")

            Button(action: save) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
            }
            .buttonStyle(GlassPressButtonStyle())
            .glassEffect(.clear.interactive(), in: Circle())
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            .accessibilityLabel("Enregistrer la note rapide")
        }
        .padding(Constants.Spacing.sm)
        .glassEffect(.clear.interactive(), in: Capsule())
        .task {
            // Laisse le temps à la barre d'apparaître avant de demander le focus.
            try? await Task.sleep(nanoseconds: 60_000_000)
            isFocused = true
        }
    }

    // MARK: - Actions

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onCreate(trimmed)
        }
        collapse()
    }

    private func collapse() {
        text = ""
        isFocused = false
        withAnimation(animation) { isExpanded = false }
    }
}
