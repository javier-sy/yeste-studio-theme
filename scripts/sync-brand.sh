#!/usr/bin/env bash
# Refreshes the brand assets every yeste.studio site serves, from the brand masters in
# ../../../Resources (the single source of truth; see its CLAUDE.md):
#   - this theme (assets/brand/ + _includes/brand/), which the product sites consume
#   - ../yeste-studio-website, which has its own layouts and keeps an identical copy
# Run after the masters change; commit both repos. Never edit the outputs by hand.
set -euo pipefail

THEME="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$THEME/../yeste-studio-website"
SRC="${BRAND_SRC:-$THEME/../../../Resources/logo}"
[ -d "$SRC/svg" ] || { echo "brand masters not found at $SRC" >&2; exit 1; }

# Inline SVGs taking the page's text colour (ink -> currentColor), announced as images.
inline_svg() {  # <master.svg> <out.svg> <class> <label>
  python3 - "$@" <<'PY'
import sys
src, out, cls, label = sys.argv[1:5]
svg = open(src).read().strip()
svg = svg.replace("#17140f", "currentColor")
svg = svg.replace("<svg ", f'<svg class="{cls}" role="img" aria-label="{label}" focusable="false" ', 1)
open(out, "w").write(svg + "\n")
PY
}

# favicon.svg: the mark, ink on light tabs and light on dark ones.
favicon_svg() {  # <out.svg>
  python3 - "$SRC/svg/yeste-mark--dark-on-transparent.svg" "$1" <<'PY'
import sys
svg = open(sys.argv[1]).read().strip()
style = "<style>@media (prefers-color-scheme: dark){path,circle{fill:#edeff2}}</style>"
svg = svg.replace('viewBox="0 0 100 100">', 'viewBox="0 0 100 100">' + style, 1)
open(sys.argv[2], "w").write(svg + "\n")
PY
}

# favicon.ico packing the 16 and 32 px PNGs.
favicon_ico() {  # <16.png> <32.png> <out.ico>
  python3 - "$@" <<'PY'
import struct, sys
pngs = [open(p, "rb").read() for p in sys.argv[1:3]]
header = struct.pack("<HHH", 0, 1, len(pngs))
offset = 6 + 16 * len(pngs)
entries, data = b"", b""
for size, png in zip((16, 32), pngs):
    entries += struct.pack("<BBBBHHII", size, size, 0, 0, 1, 32, len(png), offset + len(data))
    data += png
open(sys.argv[3], "wb").write(header + entries + data)
PY
}

# Raster icon set into a directory: favicons, iOS home icon (opaque paper), Android (alpha).
icon_set() {  # <dir>
  local d="$1"
  cp "$SRC/png/yeste-mark--dark-on-transparent--16.png" "$d/favicon-16x16.png"
  cp "$SRC/png/yeste-mark--dark-on-transparent--32.png" "$d/favicon-32x32.png"
  favicon_ico "$d/favicon-16x16.png" "$d/favicon-32x32.png" "$d/favicon.ico"
  favicon_svg "$d/favicon.svg"
  sips -s format png -z 180 180 "$SRC/png/yeste-mark--on-paper--512.png" --out "$d/apple-touch-icon.png" >/dev/null
  sips -s format png -z 192 192 "$SRC/png/yeste-mark--dark-on-transparent--512.png" --out "$d/android-chrome-192x192.png" >/dev/null
  cp "$SRC/png/yeste-mark--dark-on-transparent--512.png" "$d/android-chrome-512x512.png"
}

# --- theme: header mark, author lockup, icons under assets/brand/
mkdir -p "$THEME/_includes/brand" "$THEME/assets/brand"
inline_svg "$SRC/svg/yeste-mark--dark-on-transparent.svg"   "$THEME/_includes/brand/mark.svg"   brand-mark   "yeste.studio"
inline_svg "$SRC/svg/yeste-lockup--dark-on-transparent.svg" "$THEME/_includes/brand/lockup.svg" brand-lockup "yeste.studio"
icon_set "$THEME/assets/brand"

# --- yeste-studio-website: header lockup, icons at the site root
mkdir -p "$SITE/_includes/brand"
inline_svg "$SRC/svg/yeste-lockup--dark-on-transparent.svg" "$SITE/_includes/brand/lockup.svg" brand-lockup "yeste.studio"
icon_set "$SITE"

echo "brand assets refreshed from $SRC into the theme and yeste-studio-website"
