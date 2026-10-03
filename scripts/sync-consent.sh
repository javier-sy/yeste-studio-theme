#!/usr/bin/env bash
# Copies the cookie-consent pieces this theme owns into ../yeste-studio-website, which does not
# consume the theme but must share the same banner, script and consent cookie contract
# (docs/cookie-consent.md). Run after editing any of them here; commit both repos.
# The site's cookie register (_data/cookies.yml) is its own and is not copied, except its
# `version`: the consent cookie is shared by every site on .yeste.studio, so the four registers
# must carry the same version or the banner would come back as the visitor moves between sites.
set -euo pipefail

THEME="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$THEME/../yeste-studio-website"
[ -d "$SITE/_includes" ] || { echo "yeste-studio-website not found at $SITE" >&2; exit 1; }

cp "$THEME/_includes/cookie-consent.html"         "$SITE/_includes/cookie-consent.html"
cp "$THEME/_includes/cookies-table.html"          "$SITE/_includes/cookies-table.html"
cp "$THEME/assets/js/consent.js"                  "$SITE/js/consent.js"
cp "$THEME/_sass/3-modules/_cookie-consent.scss"  "$SITE/_sass/3-modules/_cookie-consent.scss"

VERSION="$(sed -n 's/^version: *//p' "$THEME/_data/cookies.yml")"
sed -i.bak "s/^version: .*/version: $VERSION/" "$SITE/_data/cookies.yml" && rm "$SITE/_data/cookies.yml.bak"

echo "cookie-consent pieces and register version $VERSION copied into yeste-studio-website"
