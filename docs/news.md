# News and the newsletter

yeste.studio publishes its news and those of its tools once, and every site shows them:

- **yeste.studio** holds the news (`_news/`), their pages under `/news/`, one page and one RSS feed
  per topic (`/news/<topic>/`, `/news/<topic>/feed.xml`), the general feed (`/feed.xml`) and
  `news.json`.
- **A product site** has its own news page (`/news/`, the menu's News: every item of its topic
  in full) and feed (`/feed.xml`), so a visitor stays on the product, and the signup form in its
  hero. The news are copies: the news page's canonical link points to the topic's page on
  yeste.studio.
- **yeste.studio news**, the newsletter, sends occasional letters (`_letters/` in yeste.studio):
  a text by Javier and a selection of news. Letters are written, not generated, and are published
  on the web once sent.

## What lives where

| Piece | Where | Notes |
|---|---|---|
| Topics | `_data/topics.yml` | Closed list. A news item with any other topic fails the yeste.studio build |
| Newsletter settings | `_data/newsletter.yml` | Name, form endpoint, texts, and the service's data for the privacy policies |
| Headline list | `_includes/news-list.html` | yeste.studio's news lists |
| News page and feed | `_layouts/product-news.html`, `_layouts/product-feed.xml` | Product sites only: `news.md` (`layout: product-news`, `permalink: /news/`) and `feed.xml` (`layout: product-feed`) at the site's root; `news_topic` in `_data/settings.yml` picks the topic |
| Signup form | `_includes/newsletter-form.html` | A plain `POST` to the service, opening in a new tab: no script, nothing loaded from a third party. Every page has one in its footer; a product's hero (`compact`), the news pages and yeste.studio's home add one near the top |
| Privacy section | `_includes/newsletter-privacy.md` | Included in every site's `politica-de-privacidad.md` |
| Styles | `_sass/3-modules/_news.scss` | |

`scripts/sync-news.sh` copies all of these except the product layouts to yeste-studio-website.

## Turning the newsletter on

While `endpoint` in `_data/newsletter.yml` is empty, no site shows the form or the privacy section;
news, feeds and the product news pages work without it. To turn it on: set `endpoint`; check in the service's settings that double opt-in is on (the privacy
section says so) and that `tracking` and `processor` match its settings and legal pages; run
`scripts/sync-news.sh`, and publish the theme and yeste-studio-website. Moving the list to another
service changes the same three keys.

## news.json

`https://yeste.studio/news.json` is an array, newest first, of every news item:

```json
{"title": "MusaDSL 1.0", "date": "2026-09-20", "url": "https://yeste.studio/news/2026/musadsl-1-0/",
 "topics": ["musadsl", "musalce"], "summary": "…", "lang": "es", "slug": "musadsl-1-0",
 "content": "<p>… <a href=\"https://yeste.studio/contact\">…</a></p>"}
```

`content` is the item's HTML with its links made absolute, because the product sites show it on
another domain; `slug` is its anchor in their news pages. The published letters follow, as
`{"letter": true, "title", "date", "url"}` with no topics: the news lists leave them out, and the
signup form links to the latest.

Each signup carries where it came from: `utm_source` (the site), `utm_medium` (the form's place:
`hero`, `top` or `footer`) and `utm_campaign` (the page). The newsletter service keeps them with
the subscriber.

A product site's Pages workflow fetches it into `_data/news.json` before building (the file is in
its `.gitignore`). If the fetch fails the site builds with an empty news page.

A new item reaches the product sites in three ways:

- **On publishing it.** Once yeste.studio is deployed, its workflow rebuilds the three product
  sites when the push touched `_news/` (or the topics, the plugin or `news.json`). It needs the
  `PRODUCT_SITES_TOKEN` secret in yeste-studio-website: a fine-grained personal access token with
  access to musadsl-website, musalce-website and nota-website and the *Actions: read and write*
  permission. Without the secret the step says so and does nothing.
- **Daily.** Each product site also rebuilds every day. GitHub disables a public repository's
  scheduled workflows after 60 days without commits; the Actions tab offers to re-enable them.
- **By hand.** `gh workflow run jekyll.yml --repo javier-sy/<site>`.

To preview a product site with headlines, copy `news.json` from a local build of yeste-studio-website
into the preview's `_data/`.

## Writing news and letters

In yeste-studio-website:

- `_news/YYYY-MM-DD-slug.md` with `title`, `date` (stated in the front matter), `topics`, a one-line
  `summary` for the lists, and `lang` only when the item is not in Spanish.
- `_letters/YYYY-MM-DD-slug.md` with `title`, `date` and `news`: the items it brings, each as
  `item: <slug>` (the file name without the date) and optionally `text`, the letter's own lines for
  it. The build writes `/news/letters/<slug>/email.txt`, the letter in Markdown with absolute links,
  to paste into the newsletter service. `_letters/2026-10-01-ejemplo.md` shows the format.
