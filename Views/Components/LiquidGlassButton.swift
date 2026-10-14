import SwiftUI

/// Bouton flottant réutilisable basé sur le langage visuel Liquid Glass d'Apple.
///
/// Le verre est réservé à la couche de navigation / aux actions flottantes.
/// Le contenu (listes, éditeurs) ne doit jamais recevoir d'effet de verre.
struct LiquidGlassButton: View {
    let icon: String
    var size: CGFloat = 56
    var glass: Glass = .clear
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .glassEffect(glass.interactive(), in: Circle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}
