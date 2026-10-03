# Product sites

A product site (musadsl, musalce, nota.yeste.studio) is one page: a hero, sections in order, and a
common tail (News, the related products and the author). The theme assembles it with the
`product` layout; the site writes its prose in Markdown and its lists of components and links as
data.

```
index.md                 layout: product, title, description, hero, author
_sections/10-about.md    one file per section, in `order`
_data/projects.yml       the projects the page links to
_data/tables.yml         link tables
_data/components.yml     card grids (any name: the section passes it to the include)
_data/settings.yml       title, description, news_topic, contact, google-analytics
_config.yml              the sections collection (output: false) and kramdown's settings
news.md, feed.xml        the site's news page and feed (layouts product-news and product-feed;
                         the news come from yeste.studio, see news.md in this folder)
```

## The home page

`index.md` holds only front matter:

```yaml
layout: product
title: …                       # the <title>
description: …
hero:
  title: MusaDSL
  subtitle: …                  # HTML allowed
  meta:                        # icon (Ionicons name), text, optional url
    - {icon: document-text-outline, text: GPL-3.0-or-later, url: "#license"}
  image: /images/musa-dsl.png  # optional, with image_alt
author:                        # the parameters of author.html
  product: MusaDSL
  license: GPL-3.0-or-later
```

## Sections

Each file in `_sections/` is a section, sorted by `order`:

```yaml
anchor: getting-started    # the section's id, the #anchor of the menu
title: Getting Started     # the heading
menu: Getting Started      # the menu label; without it the section is not in the menu
order: 40
class: getting-started     # optional: extra classes of the <section>
content_class: install-steps   # optional: extra classes of the content box
wrap: false                # optional: no 800px content box, for full-width content
```

Jekyll reserves some fields of a document and puts its own values in them: `id` (hence `anchor`),
`url`, `path`, `slug`, `date`, `excerpt`, `content`, `output`, `collection`, `relative_path`,
`ext`, `next`, `previous`, `draft`, `categories`, `tags`.

The body is Markdown. Raw HTML blocks pass through unchanged (the install tabs of Nota are one),
and `<div … markdown="1">` lets Markdown in again. A section made only of includes (a card grid)
is an `.html` file, so that kramdown does not touch the markup.

The menu is built from the sections: Home, every section with a `menu` label, then News and Author
as a group of their own.

## Cards, tables and links

`_data/projects.yml` describes each project once:

```yaml
musalce-server:
  name: musalce-server
  repo: javier-sy/musalce-server       # GitHub links: github, readme
  gem: musalce-server                  # RubyGems docs: api
architecture:
  name: Architecture reference
  readme: {url: "https://…/architecture.md", label: architecture.md}   # a type's own link
```

A link has a type from `_data/link_types.yml` (`github`, `readme`, `api`, `doc`, `reference`,
`marketplace`); with no `url`, it is built from the project.

A card grid is a list of categories, `{% include component-grid.html categories=site.data.components %}`:

```yaml
- title: Editor Clients
  intro: …                   # optional, Markdown
  cards:
    - title: MusaLCE Client for VSCode     # HTML allowed
      project: vscode-client
      description: …                       # Markdown, one or more paragraphs
      links:
        - {type: marketplace, url: "https://…"}
        - {type: github}
      discontinued: true                   # optional: dimmed, with a badge
  table: midi_libraries      # optional: a link table instead of, or after, the cards
```

A link table, `{% include link-table.html table="documentation" %}`, is defined in
`_data/tables.yml`: columns show a project field (`field`, `strong`) or a link (`link`), and rows
are project keys. A row with no link of a column shows a dash.

## Blocks

- **Feature block:** capture the body in Markdown, then
  `{% include feature-block.html icon="build-outline" title="…" body=body %}`; several in a row
  go inside `<div class="feature-blocks">`. The body is converted on its own, so a kramdown
  shorthand defined in the section (`{:ext: …}`) does not reach it: write the attributes out.
- **Video:** `{% include video.html id="<YouTube id>" title="…" %}`.
- **Set-apart paragraph** after a grid or a table: `{: .section__note}`; a line of commands:
  `{: .flow-line}`; a note: `{: .note}`.

## Markdown

Kramdown keeps its defaults: typographic quotes and apostrophes (as in the legal pages) and an
`id` on every heading. Code blocks come out as plain `<pre><code>` because the site turns off
kramdown's highlighter; `{% highlight ruby %}` still colours code. Explicit anchors:
`### Install {#install}`.

## Seeing a change

A site built from its own folder uses the published theme. To see the theme as it is on disk:

```bash
scripts/preview.sh musadsl --serve 8124
scripts/preview.sh nota --news ../yeste-studio-website/_site/news.json \
  --newsletter https://buttondown.com/api/emails/embed-subscribe/PREVIEW --serve 8123
```

To check that a change keeps a page as it was, build before and after and compare:
`scripts/compare-html.py before.html after.html` (markup as tags and text, CSS as rules).
