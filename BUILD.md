# NovaNote — Guide de build & récupération de l'IPA

Ce guide explique comment transformer le code source en fichier **`.ipa`** installable
sur iPhone, **sans Mac**, en utilisant **GitHub Actions** (macOS dans le cloud).

---

## 1. Comment ça marche

```
Code source (Windows)  ──►  GitHub  ──►  GitHub Actions (runner macOS)
                                             │
                          XcodeGen génère .xcodeproj
                          xcodebuild compile (Release)
                          Packaging en .ipa
                                             │
                                             ▼
                              Artefact téléchargeable ✅
```

Il existe **2 modes** :

| Mode            | Compte Apple requis | Secrets à configurer | Installation                        |
|-----------------|---------------------|----------------------|-------------------------------------|
| **Non signé** (par défaut) | ❌ Non | ❌ Aucun | AltStore / Sideloadly / TrollStore |
| **Signé**       | ✅ Oui (99 $/an)    | ✅ Oui                | Directe / AD-Hoc                    |

> 💡 **Commence par le mode non signé** : c'est le plus simple et il ne demande
> aucun compte Apple payant. Un outil comme **AltStore** ou **Sideloadly** re-signera
> l'IPA avec ton identifiant Apple gratuit.

---

## 2. Prérequis

- [ ] Un compte **GitHub** (gratuit) — https://github.com
- [ ] **Git** installé sur Windows — https://git-scm.com/download/win
- [ ] Un iPhone (pour l'installation finale)
- [ ] *(Pour installer l'IPA)* : **AltStore / Sideloadly** sur PC, ou **TrollStore** selon iOS

---

## 3. Étape par étape

### Étape 1 — Ouvrir un terminal dans le dossier du projet

```powershell
cd C:\Users\lucas\Documents\OpenCode\application\NovaNote
```

### Étape 2 — Initialiser le dépôt Git

```powershell
git init
git add .
git commit -m "NovaNote : première version"
```

> Le fichier `.gitignore` exclut déjà `build/`, les `.ipa` et le `.xcodeproj` généré.

### Étape 3 — Créer le dépôt sur GitHub

1. Va sur https://github.com/new
2. **Repository name** : `NovaNote`
3. Visibilité : **Private** (recommandé) ou Public
4. **Ne coche rien** (pas de README, pas de .gitignore — on les a déjà)
5. Clique sur **Create repository**

### Étape 4 — Relier et pousser le code

Remplace `TON_PSEUDO` par ton nom d'utilisateur GitHub :

```powershell
git branch -M main
git remote add origin https://github.com/TON_PSEUDO/NovaNote.git
git push -u origin main
```

À la première connexion, Git te demandera de t'authentifier :
- **Navigateur** : une fenêtre s'ouvre → connecte-toi
- ou **token** : crée un *Personal Access Token* sur GitHub et utilise-le comme mot de passe

### Étape 5 — Lancer le build

1. Sur GitHub, ouvre ton dépôt → onglet **Actions**
2. Tu verras le workflow **« Build iOS IPA »** se lancer automatiquement (déclenché par le push)
3. Attends ~5 à 10 min (préparation du runner macOS + compilation)

Pour relancer manuellement :
- **Actions** → **Build iOS IPA** → bouton **Run workflow** → **Run workflow**

### Étape 6 — Récupérer l'IPA

1. Onglet **Actions** → clique sur la dernière exécution ✅ verte
2. Descends jusqu'à la section **Artifacts**
3. Télécharge **`NovaNote-unsigned-ipa`**
4. C'est un **fichier ZIP** → décompresse-le → tu obtiens **`NovaNote-unsigned.ipa`** 🎉

---

## 4. Installer l'IPA sur l'iPhone (mode non signé)

### Option A — Sideloadly (Windows)

1. Télécharge **Sideloadly** : https://sideloadly.io
2. Connecte ton iPhone en USB
3. Glisse **`NovaNote-unsigned.ipa`** dans Sideloadly
4. Renseigne ton **Apple ID** (gratuit)
5. Clique sur **Start** → l'app est re-signée et installée

### Option B — AltStore

1. Installe **AltServer** sur PC : https://altstore.io
2. Installe AltStore sur l'iPhone
3. Dans AltStore → **+** → sélectionne **`NovaNote-unsigned.ipa`**

> ⚠️ Avec un Apple ID gratuit, l'app expire au bout de **7 jours** et doit être
> re-signée. Avec un compte développeur payant, c'est 1 an.

### Option C — TrollStore (iOS compatibles uniquement)

Si ton iOS est compatible TrollStore, ouvre simplement l'IPA avec TrollStore
pour une installation permanente.

---

## 5. Mode signé (optionnel, compte Apple payant)

### 5.1 Configurer les secrets GitHub

**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret                         | Description                                                        |
|--------------------------------|--------------------------------------------------------------------|
| `APPLE_CERTIFICATE`            | Certificat `.p12` exporté depuis Keychain, encodé en **base64**    |
| `APPLE_CERTIFICATE_PASSWORD`   | Mot de passe du `.p12`                                             |
| `PROVISIONING_PROFILE`         | Profil de provisionnement `.mobileprovision`, encodé en **base64** |
| `TEAM_ID`                      | Ton Team ID Apple (10 caractères)                                  |
| `PROFILE_NAME`                 | Nom exact du profil de provisionnement                             |

Encodage base64 sous Windows (PowerShell) :

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificat.p12")) | Set-Clipboard
```

### 5.2 Lancer un build signé

1. **Actions** → **Build iOS IPA** → **Run workflow**
2. Mets **signed** à `true`
3. **Run workflow**
4. Récupère l'artefact **`NovaNote-signed-ipa`**

---

## 6. Dépannage

### ❌ Erreur : « deployment target 27.0 is not supported »

Le SDK iOS du runner n'est pas encore 27. Le workflow **baisse automatiquement** la
cible, mais tu peux la forcer : lance le workflow avec `ios_target = 26.0`.

### ❌ Erreur de compilation sur `.glassEffect` / `GlassEffectContainer`

Ces API nécessitent un **SDK iOS 26+**. Si le runner n'a pas Xcode 26/27 :

- Le workflow utilise `xcode-version: latest-stable`. Vérifie dans les logs
  `xcodebuild -showsdks` quelle version est disponible.
- Si nécessaire, épingler une image plus récente : remplace `runs-on: macos-latest`
  par `runs-on: macos-26` (ou `macos-27` s'il existe) dans
  `.github/workflows/build-ios.yml`.

### ❌ Le fichier `.xcodeproj` n'existe pas

C'est **normal** : il est généré par XcodeGen pendant le build (`xcodegen generate`).
Ne le cherche pas dans le dépôt.

### ❌ « xcodegen: command not found »

Le workflow l'installe via `brew install xcodegen`. En local sur Mac :
`brew install xcodegen`.

### ❌ L'IPA ne s'installe pas

- L'IPA **non signé** ne s'installe pas directement → passe par Sideloadly/AltStore.
- Vérifie que l'appareil est **enregistré** (compte payant, méthode `development`).
- Essaie la méthode `ad-hoc` dans `ExportOptions.plist`.

---

## 7. Structure du projet

```
NovaNote/
├── NovaNoteApp.swift                # Point d'entrée + modelContainer SwiftData
├── project.yml                      # Spécification XcodeGen (source de vérité du projet)
├── ExportOptions.plist              # Config d'export pour les builds signés
├── .github/workflows/build-ios.yml  # CI/CD : build + packaging IPA
├── scripts/build-unsigned-ipa.sh    # Build local (macOS)
├── Models/                          # Note, Folder, Tag (@Model SwiftData)
├── ViewModels/                      # NoteViewModel, FolderViewModel (MVVM)
├── Views/                           # SwiftUI
│   └── Components/                  # LiquidGlassButton, QuickCaptureBar, etc.
├── Extensions/                      # Color+Hex
├── Utilities/                       # Constants (design system)
└── Resources/
    ├── Info.plist
    └── Assets.xcassets/             # AppIcon + AccentColor
```

---

## 8. Commandes utiles (récapitulatif)

```powershell
# Projet
cd C:\Users\lucas\Documents\OpenCode\application\NovaNote

# Premier push
git init
git add .
git commit -m "NovaNote : première version"
git branch -M main
git remote add origin https://github.com/TON_PSEUDO/NovaNote.git
git push -u origin main

# Push suivants (après modifications)
git add .
git commit -m "Description du changement"
git push
```
