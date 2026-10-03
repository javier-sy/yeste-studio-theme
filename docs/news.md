# News and the newsletter

yeste.studio publishes its news and those of its tools once, and every site shows them:

- **yeste.studio** holds the news (`_news/`), their pages under `/news/`, one page and one RSS feed
  per topic (`/news/<topic>/`, `/news/<topic>/feed.xml`), the general feed (`/feed.xml`) and
  `news.json`.
- **A product site** shows, in its News section, the latest headlines of its topic, links to that
  topic's page and feed, and the signup form.
- **yeste.studio news**, the newsletter, sends occasional letters (`_letters/` in yeste.studio):
  a text by Javier and a selection of news. Letters are written, not generated, and are published
  on the web once sent.

## What lives where

| Piece | Where | Notes |
|---|---|---|
| Topics | `_data/topics.yml` | Closed list. A news item with any other topic fails the yeste.studio build |
| Newsletter settings | `_data/newsletter.yml` | Name, form endpoint, texts, and the service's data for the privacy policies |
| Headline list | `_includes/news-list.html` | Used by yeste.studio and by the News section |
| News section | `_includes/news-block.html` | Product sites only: `{% include news-block.html %}` and `news_topic` in `_data/settings.yml` |
| Signup form | `_includes/newsletter-form.html` | A plain `POST` to the service: no script, nothing loaded from a third party |
| Privacy section | `_includes/newsletter-privacy.md` | Included in every site's `politica-de-privacidad.md` |
| Styles | `_sass/3-modules/_news.scss` | |

`scripts/sync-news.sh` copies all of these except `news-block.html` to yeste-studio-website.

## Turning the newsletter on

While `endpoint` in `_data/newsletter.yml` is empty, no site shows the form or the privacy section;
news, feeds and the News sections work without it. To turn it on: set `endpoint`; check in the service's settings that double opt-in is on (the privacy
section says so) and that `tracking` and `processor` match its settings and legal pages; run
`scripts/sync-news.sh`, and publish the theme and yeste-studio-website. Moving the list to another
service changes the same three keys.

## news.json

`https://yeste.studio/news.json` is an array, newest first, of every news item:

```json
{"title": "MusaDSL 1.0", "date": "2026-09-20", "url": "https://yeste.studio/news/2026/musadsl-1-0/",
 "topics": ["musadsl", "musalce"], "summary": "…", "lang": "es"}
```

A product site's Pages workflow fetches it into `_data/news.json` before building (the file is in
its `.gitignore`), and rebuilds daily so new news reach it without a commit; `gh workflow run
jekyll.yml --repo javier-sy/<site>` rebuilds one at once. GitHub disables a public repository's
scheduled workflows after 60 days without commits: the Actions tab offers to re-enable them, and
until then a new item reaches a quiet site only through `gh workflow run`. If the fetch fails the site builds with
an empty list and keeps the section's links and form.

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
