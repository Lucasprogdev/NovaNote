#!/usr/bin/env bash
#
# Génère un IPA NON SIGNÉ de NovaNote depuis un Mac.
#
# Prérequis : Xcode, XcodeGen (brew install xcodegen)
# Usage : ./scripts/build-unsigned-ipa.sh [cible_iOS]
#
set -euo pipefail

cd "$(dirname "$0")/.."

IOS_TARGET="${1:-27.0}"
APP_NAME="NovaNote"
SCHEME="NovaNote"
PROJECT="NovaNote.xcodeproj"

echo "==> Génération du projet Xcode (XcodeGen)"
xcodegen generate

echo "==> Build (Release, non signé, cible iOS ${IOS_TARGET})"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build \
  IPHONEOS_DEPLOYMENT_TARGET="$IOS_TARGET" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

APP="build/Build/Products/Release-iphoneos/${APP_NAME}.app"
if [ ! -d "$APP" ]; then
  echo "ERREUR : application introuvable à l'emplacement $APP" >&2
  exit 1
fi

echo "==> Empaquetage de l'IPA"
rm -rf Payload "${APP_NAME}-unsigned.ipa"
mkdir -p Payload
cp -R "$APP" Payload/
zip -qry "${APP_NAME}-unsigned.ipa" Payload -x '.*'

echo "==> Terminé : ${APP_NAME}-unsigned.ipa"
ls -lh "${APP_NAME}-unsigned.ipa"
