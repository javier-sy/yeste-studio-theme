#!/usr/bin/env bash
# Builds a product site with this theme as it is on disk, not the published one that
# remote_theme fetches, so theme changes can be seen before they are pushed.
#
#   scripts/preview.sh <site> [--news FILE] [--newsletter URL] [--serve PORT]
#
# <site> is the folder name without "-website" (musadsl, musalce, nota). The copy and its
# _site go to $PREVIEW_DIR/<site> (default: $TMPDIR/yeste-preview). The site's own files win
# over the theme's, as with remote_theme. --news gives the headlines of the News section (a
# news.json, e.g. from a local build of yeste-studio-website); without it the section has none.
# --newsletter sets the signup form's endpoint in the copy, so the form and its privacy section
# show while newsletter.yml has none (any URL will do to see them; signing up goes there).
set -euo pipefail

THEME="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: preview.sh <site> [--news FILE] [--newsletter URL] [--serve PORT]}"; shift
SITE="$THEME/../$NAME-website"
[ -f "$SITE/_config.yml" ] || { echo "no site at $SITE" >&2; exit 1; }
NEWS=""; PORT=""; ENDPOINT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --news)  NEWS="$2"; shift 2 ;;
    --newsletter) ENDPOINT="$2"; shift 2 ;;
    --serve) PORT="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 1 ;;
  esac
done

OUT="${PREVIEW_DIR:-${TMPDIR:-/tmp}/yeste-preview}/$NAME"
mkdir -p "$OUT/src"
rsync -a --delete --exclude _site --exclude .git --exclude vendor "$SITE/" "$OUT/src/"
for dir in _includes _layouts _sass assets _data; do
  rsync -a --ignore-existing "$THEME/$dir/" "$OUT/src/$dir/"
done
sed -i.bak '/remote_theme/d; /jekyll-remote-theme/d' "$OUT/src/_config.yml" && rm "$OUT/src/_config.yml.bak"
if [ -n "$NEWS" ]; then cp "$NEWS" "$OUT/src/_data/news.json"; fi
if [ -n "$ENDPOINT" ]; then
  sed -i.bak "s|^endpoint:.*|endpoint: $ENDPOINT|" "$OUT/src/_data/newsletter.yml" && rm "$OUT/src/_data/newsletter.yml.bak"
fi

cd "$SITE"
BUNDLE_GEMFILE="$SITE/Gemfile" bundle exec jekyll build --source "$OUT/src" --destination "$OUT/_site" 2>&1 \
  | grep -v -e 'DEPRECATION WARNING' -e 'repetitive deprecation' -e 'Run in verbose mode' -e '^ *[│╷╵]' -e '^ *[0-9]* │' -e 'root stylesheet' -e '@import$' || true
[ -f "$OUT/_site/index.html" ] || { echo "build failed" >&2; exit 1; }
echo "built: $OUT/_site"
if [ -n "$PORT" ]; then
  BUNDLE_GEMFILE="$SITE/Gemfile" exec bundle exec jekyll serve --source "$OUT/src" --destination "$OUT/_site" \
    --port "$PORT" --host 127.0.0.1 --skip-initial-build --no-watch
fi
