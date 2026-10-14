import Foundation

/// Liens profonds (`URL scheme`) de l'application.
///
/// Exemple de raccourci dans l'app **Raccourcis** :
/// action « Ouvrir des URL » → `novanote://capture`
/// → NovaNote s'ouvre directement sur la saisie d'une note rapide.
enum NovaNoteLink {
    static let scheme = "novanote"

    /// `novanote://capture` — ouvre la capture rapide.
    static let quickCapture = URL(string: "novanote://capture")!

    /// Exemple de raccourci dans l'app **Raccourcis** :
    static let quickNote = URL(string: "novanote://new")!

    private static let pendingKey = "novanote.pendingQuickCapture"

    /// Enregistre une demande de capture rapide, consommée à l'ouverture de l'app.
    static func requestQuickCapture() {
        UserDefaults.standard.set(true, forKey: pendingKey)
    }

    /// Renvoie `true` une seule fois si une capture rapide a été demandée.
    static func consumeQuickCaptureRequest() -> Bool {
        guard UserDefaults.standard.bool(forKey: pendingKey) else { return false }
        UserDefaults.standard.set(false, forKey: pendingKey)
        return true
    }

    /// Indique si l'URL reçue correspond à une demande de capture rapide.
    static func isQuickCapture(_ url: URL) -> Bool {
        guard url.scheme == scheme else { return false }
        return url.host == "capture" || url.host == "quick-note"
    }
}
