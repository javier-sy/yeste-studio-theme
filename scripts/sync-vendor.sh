#!/usr/bin/env bash
# Copies the self-hosted fonts and icons this theme owns into ../yeste-studio-website, which does
# not consume the theme but serves the same faces and icons from the same paths (assets/fonts,
# assets/vendor) so that no page contacts Google Fonts or a CDN. Run after changing any of them
# here; commit both repos.
set -euo pipefail

THEME="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$THEME/../yeste-studio-website"
[ -d "$SITE/_includes" ] || { echo "yeste-studio-website not found at $SITE" >&2; exit 1; }

mkdir -p "$SITE/assets/fonts" "$SITE/assets/vendor"
rsync -a --delete "$THEME/assets/fonts/"           "$SITE/assets/fonts/"
rsync -a --delete "$THEME/assets/vendor/ionicons/" "$SITE/assets/vendor/ionicons/"
cp "$THEME/_sass/0-settings/_fonts.scss"           "$SITE/_sass/0-settings/_fonts.scss"

echo "fonts and icons copied into yeste-studio-website"
