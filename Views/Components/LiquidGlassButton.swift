import SwiftUI

/// Bouton circulaire en Liquid Glass.
///
/// ⚠️ L'effet de verre est appliqué **au `Button`** (et non à son label) et la
/// zone tactile est explicitement définie avec `.contentShape(Circle())`.
/// Appliquer `.glassEffect` *à l'intérieur* du label peut réduire la zone
/// tactile et provoquer des taps « perdus » (il faut appuyer plusieurs fois).
struct LiquidGlassButton: View {
    var icon: String
    var size: CGFloat = 56
    var glass: Glass = .clear
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .contentShape(Circle())
        }
        .buttonStyle(GlassPressButtonStyle())
        .glassEffect(glass.interactive(), in: Circle())
        .accessibilityAddTraits(.isButton)
    }
}

/// Style de bouton avec un léger effet d'enfoncement, sans utiliser
/// `onLongPressGesture` (qui entre en conflit avec le tap du `Button`).
struct GlassPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}
