# yeste-studio-theme

Shared Jekyll theme for the [yeste.studio](https://yeste.studio) family of websites: `yeste.studio`, `musadsl.yeste.studio`, `musalce.yeste.studio`, `nota.yeste.studio`, and any future product sites.

This repository holds the **presentation layer only** — layouts, partials, SCSS, JavaScript — that all sub-sites import via Jekyll's [remote_theme](https://github.com/benbalter/jekyll-remote-theme) plugin. Content (text, data, images specific to a product) lives in each consumer's own repo.

## Using this theme

In a consumer site's `_config.yml`:

```yaml
remote_theme: javier-sy/yeste-studio-theme@main

plugins:
  - jekyll-remote-theme
```

That is the entire integration, with one requirement: **Jekyll 4** (`gem 'jekyll', '~> 4.3'`, as in musadsl-website's Gemfile), because the theme ships `_data/` that Jekyll 3 does not read. The `github-pages` gem pins Jekyll 3.10 and must not be used; the sites build with their own GitHub Actions workflow anyway. The consumer site can:

- Build its home page with the `product` layout: a hero from the front matter, the documents of its `_sections` collection and the common tail (News, related products, author). See `docs/product-sites.md`.
- Use the theme's `default` and `page` layouts for any other page (the legal pages use `page`).
- Override any theme layout, include, sass file or JS by providing the same file at the same path locally — Jekyll's lookup prefers the local file over the theme.

## What's in the theme

| Path | Purpose |
|---|---|
| `_layouts/default.html` | Top-level page wrapper (head + header + content + footer) |
| `_layouts/page.html` | Standard content page layout |
| `_layouts/product.html` | A product site's home page: hero, sections, News, related products, author (`docs/product-sites.md`) |
| `_includes/hero.html`, `_includes/section.html` | The opening block (from `hero` in the front matter) and the wrapper of each section |
| `_includes/component-grid.html`, `_includes/link-table.html`, `_includes/link.html`, `_data/link_types.yml` | Component cards and link tables from a site's `_data`; typed links (GitHub, README, API…) built from a project's repository and gem |
| `_includes/feature-block.html`, `_includes/video.html` | A block with icon and title over a Markdown body; a youtube-nocookie player |
| `scripts/preview.sh`, `scripts/compare-html.py` | Build a product site with this theme as it is on disk (with headlines and a newsletter endpoint if wanted), and compare two builds of a page |
| `_includes/head.html` | `<head>` element with meta tags, brand favicons, CSS link; `noindex: true` in a page's front matter adds `<meta name="robots" content="noindex">` |
| `_includes/header.html` | Site header with the product lockup + nav. The lockup is `_includes/brand/lockup-<title>.svg`, picked by the site's `title` in `_data/settings.yml` lowercased (`MusaDSL` → `lockup-musadsl.svg`); the menu is Home, every section with a `menu` label in its order, then News and Author as a group of their own (`_includes/nav-item.html`) |
| `_includes/author.html` | "Author" section with the brand lockup; shows a license badge only when the site passes `license="…"` (no default: a license is never written in the theme) |
| `_includes/license-notice.html` | The license notice of a product site: `product`, `base` (`gpl` or `proprietary`) and optional `faq` URL. The commercial-license sentence is the studio's standard one and is identical for every product |
| `_includes/brand/` | Inline SVGs in `currentColor`: the yeste.studio mark and lockup, and one product lockup per site (name, "by yeste.studio") |
| `assets/brand/` | Favicon set (ico, svg, png) and home-screen icons |
| `scripts/sync-brand.sh` | Regenerates `_includes/brand/`, `assets/brand/` and yeste-studio-website's copies from the brand masters in `../../../Resources` (the single source of truth). Never edit those outputs by hand |
| `_includes/footer.html` | Site footer with social links + legal links; *configurar cookies* reopens the consent bar when the site has analytics |
| `_includes/cookie-consent.html`, `assets/js/consent.js`, `_sass/3-modules/_cookie-consent.scss` | Consent bar for Google Analytics: nothing from Google loads until the visitor accepts. Active only when `_data/settings.yml` has `google-analytics: G-…`. See `docs/cookie-consent.md` |
| `_data/cookies.yml`, `_includes/cookies-table.html` | The cookie register and the table it renders inside each site's `politica-de-cookies.md` |
| `scripts/sync-consent.sh` | Copies the consent pieces to yeste-studio-website, which shares the banner without using the theme |
| `_data/topics.yml`, `_data/newsletter.yml` | The news topics and the settings of *yeste.studio news*, the newsletter. See `docs/news.md` |
| `_includes/news-block.html`, `_includes/news-list.html`, `_layouts/product-news.html`, `_layouts/product-feed.xml` | A product site's News section, news page and feed: the news of its `news_topic`, from yeste.studio's `news.json` fetched at build time |
| `_includes/newsletter-form.html`, `_includes/newsletter-privacy.md`, `_sass/3-modules/_news.scss` | The signup form (a plain `POST`, no script) and the privacy section; both appear only when `newsletter.yml` has an `endpoint` |
| `scripts/sync-news.sh` | Copies the news and newsletter pieces to yeste-studio-website, which publishes the news |
| `assets/fonts/`, `_sass/0-settings/_fonts.scss` | Self-hosted DM Sans and Josefin Sans (OFL), the same subsets Google Fonts served; no page contacts Google for them |
| `assets/vendor/ionicons/` | Ionicons 7.1.0 (MIT), served from the site instead of a CDN. The `<ion-icon>` component fetches `svg/<name>.svg` next to its script, so the whole folder ships |
| `scripts/sync-vendor.sh` | Copies fonts, the fonts partial and Ionicons to yeste-studio-website |
| `_includes/main.scss` | SCSS entry point — imports the four `_sass` categories |
| `_sass/0-settings/` | Variables, helpers, color scheme, mixins |
| `_sass/1-tools/` | Reset, normalize, grid, syntax highlighting |
| `_sass/2-base/` | Base element styling |
| `_sass/3-modules/` | One module per component: header, footer, sections, hero, content sections, components, feature blocks, link tables, getting started, video, author, tabs, notice, cookie consent, news |
| `assets/js/common.js`, `assets/js/scripts.js` | Shared client-side JavaScript |

## What's NOT in the theme (each site provides)

- `_config.yml` with the site-specific config and the `remote_theme:` declaration above.
- `index.md` with `layout: product` and its front matter (`hero`, `author`); `_sections/` with the page's prose; `_data/projects.yml`, `tables.yml` and the card lists its sections use. See `docs/product-sites.md`.
- `_data/settings.yml` with the site's title, description and contact info, and `google-analytics: G-…` once the site's legal pages describe analytics (the banner, the script and the footer link all hang on that key).
- `news_topic: <key>` in `_data/settings.yml`, `news.md` and `feed.xml` at its root, and the workflow step that fetches `_data/news.json` (`docs/news.md`); the product layout shows the News section.
- `CNAME` with the subdomain.
- Site-specific images (product screenshots). The brand itself comes with the theme.
- Product-specific layouts when needed (e.g. yeste-studio-website ships `_layouts/works.html` and `_layouts/music.html` locally).

## Consumers (as of 2026-05-18)

- [musadsl-website](https://github.com/javier-sy/musadsl-website) → `musadsl.yeste.studio` (the MusaDSL framework)
- [musalce-website](https://github.com/javier-sy/musalce-website) → `musalce.yeste.studio` (MusaLCE live coding suite)
- [nota-website](https://github.com/javier-sy/nota-website) → `nota.yeste.studio` (Nota plugin for Claude Code and opencode)

[yeste-studio-website](https://github.com/javier-sy/yeste-studio-website) (`yeste.studio`) does **not** use the theme: it has its own layouts and styles, and shares the brand assets through `scripts/sync-brand.sh`, the cookie-consent pieces through `scripts/sync-consent.sh`, the self-hosted fonts and icons through `scripts/sync-vendor.sh`, and the news and newsletter pieces through `scripts/sync-news.sh`.

Future: `pulso-website`, etc.

## Development

There is no `Gemfile` here because consumers don't need to install the theme — the sites resolve `remote_theme:` when they build. A consumer built from its own folder therefore uses the **published** theme; to see changes before pushing them, `scripts/preview.sh <site> [--serve PORT]` builds the site with this folder on top. Push the theme before a site that needs its new pieces.
