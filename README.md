# yeste-studio-theme

Shared Jekyll theme for the [yeste.studio](https://yeste.studio) family of websites: `yeste.studio`, `musadsl.yeste.studio`, `musalce.yeste.studio`, `nota.yeste.studio`, and any future product sites.

This repository holds the **presentation layer only** — layouts, partials, SCSS, JavaScript — that all sub-sites import via Jekyll's [remote_theme](https://github.com/benbalter/jekyll-remote-theme) plugin. Content (text, data, images specific to a product) lives in each consumer's own repo.

## Using this theme

In a consumer site's `_config.yml`:

```yaml
remote_theme: javier-sy/yeste-studio-theme

plugins:
  - jekyll-remote-theme
```

That is the entire integration. The consumer site can:

- Use the theme's `default` and `page` layouts out of the box (declare `layout: default` or `layout: page` in front matter).
- Override any theme layout, include, sass file or JS by providing the same file at the same path locally — Jekyll's lookup prefers the local file over the theme.
- Add its own navigation by providing `_data/settings.yml` with `menu__settings.menu__items` (the theme's `_includes/header.html` reads from this).

## What's in the theme

| Path | Purpose |
|---|---|
| `_layouts/default.html` | Top-level page wrapper (head + header + content + footer) |
| `_layouts/page.html` | Standard content page layout |
| `_includes/head.html` | `<head>` element with meta tags + favicon + CSS link |
| `_includes/header.html` | Site header with logo + nav (reads `site.data.settings.menu__settings.menu__items`) |
| `_includes/footer.html` | Site footer with social links + legal links |
| `_includes/main.scss` | SCSS entry point — imports the four `_sass` categories |
| `_sass/0-settings/` | Variables, helpers, color scheme, mixins |
| `_sass/1-tools/` | Reset, normalize, grid, syntax highlighting |
| `_sass/2-base/` | Base element styling |
| `_sass/3-modules/` | Section, footer, header, scroll-button-top modules |
| `js/common.js`, `js/scripts.js` | Shared client-side JavaScript |

## What's NOT in the theme (each site provides)

- `_config.yml` with the site-specific config and the `remote_theme:` declaration above.
- `index.html` (or `index.md`) with the site's actual content.
- `_data/settings.yml` with the per-site navigation menu and contact info.
- `CNAME` with the subdomain.
- Site-specific images (logos, product screenshots).
- Product-specific layouts when needed (e.g. yeste-studio-website ships `_layouts/works.html` and `_layouts/music.html` locally).

## Consumers (as of 2026-05-18)

- [yeste-studio-website](https://github.com/javier-sy/yeste-studio-website) → `yeste.studio` (artist umbrella)
- [musadsl-website](https://github.com/javier-sy/musadsl-website) → `musadsl.yeste.studio` (the MusaDSL framework)
- [musalce-website](https://github.com/javier-sy/musalce-website) → `musalce.yeste.studio` (MusaLCE live coding suite)
- [nota-website](https://github.com/javier-sy/nota-website) → `nota.yeste.studio` (Nota plugin for Claude Code)

Future: `pulso-website`, etc.

## Development

There is no `Gemfile` here because consumers don't need to install the theme — GitHub Pages resolves `remote_theme:` directly. To test theme changes locally, point a consumer site at this folder via `theme: yeste-studio-theme` and a `Gemfile` line like `gem 'yeste-studio-theme', path: '../yeste-studio-theme'`.
