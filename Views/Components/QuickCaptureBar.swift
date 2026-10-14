import SwiftUI

/// Capture rapide avec effet de morphing Liquid Glass.
///
/// Au tap, le bouton circulaire se transforme en barre de saisie grâce à
/// `GlassEffectContainer` + `glassEffectID` partageant le même `@Namespace`.
struct QuickCaptureBar: View {
    /// Ouvre l'éditeur complet (note longue / Markdown).
    var onOpenEditor: () -> Void
    /// Enregistre une note rapide à partir du texte saisi.
    var onCreate: (String) -> Void

    @Namespace private var namespace
    @State private var isExpanded = false
    @State private var text = ""
    @FocusState private var isFocused: Bool

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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }

    private var collapsedButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .glassEffect(.clear.interactive(), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Création rapide")

    }

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
                    .frame(width: 34, height: 34)
                    .glassEffect(.clear.interactive(), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ouvrir l'éditeur complet")

            Button {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    onCreate(trimmed)
                }
                collapse()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .glassEffect(.regular.interactive(), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            .accessibilityLabel("Enregistrer la note rapide")
        }
        .padding(Constants.Spacing.sm)
        .glassEffect(.clear.interactive(), in: Capsule())
        .onAppear {
            isFocused = true
        }
    }

    private func collapse() {
        text = ""
        isFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isExpanded = false
        }
    }
}
