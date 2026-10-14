# NovaNote

Une application iOS moderne de prise de notes développée avec **SwiftUI**, **SwiftData** et le design **Liquid Glass** pour iOS 27+.

## Fonctionnalités

- **Design Dark Mode first** avec effets Liquid Glass
- **Prise de notes** avec éditeur Markdown basique (gras, listes, cases à cocher)
- **Organisation** par dossiers et tags
- **Épinglage** et mise en favoris
- **Archivage** des notes
- **Recherche** instantanée
- **Animations fluides** avec GlassEffectContainer et morphing
- **Persistance locale** avec SwiftData

## Architecture

L'application suit une architecture **MVVM** modulaire :

```
NovaNote/
├── Models/           # Modèles SwiftData (Note, Folder, Tag)
├── ViewModels/       # ViewModels observables (@MainActor)
├── Views/            # Vues SwiftUI
│   └── Components/   # Composants réutilisables
├── Extensions/       # Extensions SwiftUI
├── Utilities/        # Constantes et helpers
└── Resources/        # Info.plist
```

## Stack technique

- **Swift 6+**
- **SwiftUI** (nouvelles API iOS 27+)
- **SwiftData** pour la persistance
- **Liquid Glass** avec `.glassEffect()`, `GlassEffectContainer`, `.interactive()`

## Éléments Liquid Glass

- **TabView** : barre d'onglets avec effet verre
- **Floating Action Buttons** : boutons flottants avec morphing
- **Barre de recherche** : effet verre dynamique
- **Barre d'outils** : contexte édition avec conteneur verre
- **Éléments interactifs** : tous les composants flottants sont marqués `.interactive()`

## Build & IPA

Le projet Xcode (`NovaNote.xcodeproj`) est **généré** à partir de `project.yml` via **XcodeGen**.
Il n'est pas versionné. Un workflow **GitHub Actions** compile l'app sur un runner macOS et
produit un `.ipa` téléchargeable (signé ou non signé).

👉 **Guide complet : [`BUILD.md`](BUILD.md)**

```bash
# générer le projet Xcode (macOS)
xcodegen generate

# build local d'un IPA non signé (macOS)
./scripts/build-unsigned-ipa.sh 27.0
```

## Aperçu rapide

- **Notes** : liste avec notes épinglées, recherche, filtres
- **Dossiers** : organisation par catégories
- **Favoris & Archives** : accès rapide
- **Éditeur** : édition fluide avec outils contextuels
