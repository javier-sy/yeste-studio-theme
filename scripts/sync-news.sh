#!/usr/bin/env bash
# Copies the news and newsletter pieces this theme owns into ../yeste-studio-website, which does
# not consume the theme but publishes the news and must show the same list, form and privacy
# section (docs/news.md). Run after editing any of them here; commit both repos.
set -euo pipefail

THEME="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$THEME/../yeste-studio-website"
[ -d "$SITE/_includes" ] || { echo "yeste-studio-website not found at $SITE" >&2; exit 1; }

cp "$THEME/_data/topics.yml"                "$SITE/_data/topics.yml"
cp "$THEME/_data/newsletter.yml"            "$SITE/_data/newsletter.yml"
cp "$THEME/_includes/news-list.html"        "$SITE/_includes/news-list.html"
cp "$THEME/_includes/newsletter-form.html"  "$SITE/_includes/newsletter-form.html"
cp "$THEME/_includes/newsletter-privacy.md" "$SITE/_includes/newsletter-privacy.md"
cp "$THEME/_sass/3-modules/_news.scss"      "$SITE/_sass/3-modules/_news.scss"

echo "news pieces copied into yeste-studio-website"
