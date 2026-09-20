# Cookie consent and analytics

How the yeste.studio sites ask for consent before Google Analytics, what the pieces are, and how
to check that the whole thing still complies. Applies to the three product sites (through this
theme) and to yeste-studio-website (through copies kept in sync by `scripts/sync-consent.sh`).

## The pieces

| Piece | Where | What it does |
|---|---|---|
| Cookie register | `_data/cookies.yml` | Every cookie and storage the site uses, with a `version`. Feeds the policy table and the banner |
| Policy table | `_includes/cookies-table.html` | Renders the register inside `politica-de-cookies.md` (`{% include cookies-table.html %}`) |
| Banner | `_includes/cookie-consent.html`, `_sass/3-modules/_cookie-consent.scss` | Non-blocking bar with *Reject* and *Accept* as equals and a link to the policy |
| Logic | `assets/js/consent.js` | Reads the choice, shows the banner when there is none, loads Google Analytics only after *Accept*, undoes it on revoke |
| Switch | `_data/settings.yml` → `google-analytics` | The GA4 measurement ID. Without it the site has no banner, no analytics and no footer link: nothing to consent to |
| Revoke link | `_includes/footer.html` → *configurar cookies* | Reopens the banner |

All four sites report to the same GA4 property (one measurement ID); GA tells them apart by
`hostname`.

## The consent cookie

One contract, implemented identically in the theme and in yeste-studio-website, because the
cookie is shared across the four hosts:

| | |
|---|---|
| Name | `ys_consent` |
| Value | `<version>:<decision>` — `version` is `_data/cookies.yml`'s, `decision` is `granted` or `denied`, e.g. `1:denied` |
| Domain | `.yeste.studio` when the page is served from that domain or a subdomain, so one choice covers the four sites; host-only elsewhere (local previews) |
| Path, flags | `/`, `SameSite=Lax`, `Secure` on https |
| Lifetime | 24 months (`Max-Age=63072000`), the maximum the AEPD guide allows before asking again |

A value whose version differs from the current register counts as no choice: the banner shows
again. That is how a future non-exempt cookie gets consent instead of riding on an old one.

## What happens when

- **No valid choice**: nothing non-exempt is loaded or written; the banner shows. Browsing,
  scrolling or ignoring it changes nothing.
- **Accept**: the cookie is written, then `gtag.js` is inserted with Consent Mode defaults set
  to denied and `analytics_storage` updated to granted, then `config` runs. Only now does the
  browser contact Google.
- **Reject**: the cookie is written; nothing else happens, on this and every later page, until
  the cookie expires or the register version changes.
- **Revoke** (footer link → *Reject* after an earlier *Accept*): `ga-disable-<ID>` is set,
  `analytics_storage` is updated to denied, and `_ga` and `_ga_<container>` are deleted on
  `.yeste.studio` and on the host.

## Requirements and how each is checked

From the AEPD *Guía sobre el uso de las cookies* (May 2024 edition; criteria in force since
January 2024) and the EDPB guidelines it applies. Only what concerns these sites: one third-party
analytics cookie set, no advertising, no walls, no forms, no minors.

| # | Requirement | How to check |
|---|---|---|
| 1 | Two layers of information: a short banner and a full policy it links to | Banner text names Google Analytics and the purpose; its link opens `/politica-de-cookies` |
| 2 | Reject as easy as Accept: same screen, same size and style, one click each | Look at the banner; both buttons share `.cookie-consent__button` with no modifier |
| 3 | Nothing non-exempt before the click: no analytics script, no `_ga*` cookie | DevTools, fresh profile, before deciding: no request to `googletagmanager.com` or `google-analytics.com`; no cookies |
| 4 | Continuing to browse, scrolling or closing is not consent | The banner has no close control; navigating keeps it and still loads nothing |
| 5 | A rejection is remembered and not asked again on every page | Reject, browse three pages: no banner, no requests |
| 6 | Withdrawing consent is as easy as giving it and always reachable | Footer link on every page reopens the banner; *Reject* there removes the `_ga*` cookies and stops further hits |
| 7 | Consent expires: at most 24 months | `Max-Age` on `ys_consent` |
| 8 | The policy lists each cookie with purpose, who sets it, duration and how to withdraw | The table comes from the register; the policy has a section on changing the choice |
| 9 | No deceptive design: no pre-ticked options, colours or wording that push to accept | Compare the two buttons; read the copy |
| 10 | Exempt storage is disclosed but not asked for | `theme` (and `classView` on yeste.studio) and `ys_consent` are in the table under the exempt heading and not in the banner |

Privacy policy side (`politica-de-privacidad.md`): the data category (usage data tied to a random
identifier, only with consent), the legal basis (consent, revocable), the processor (Google
Ireland Limited) and the transfer to Google LLC under the EU-US Data Privacy Framework, the
retention (cookie 2 years; GA event data at most 14 months), and the hosting provider (GitHub).

## Verification, every time this changes

With a fresh browser profile (or after deleting the site's cookies), on a local build or on the
published site:

1. Before deciding: banner visible, no request to Google, no cookies.
2. Reject: banner gone; open three more pages: no banner, no request, only `ys_consent=<v>:denied`.
3. Delete `ys_consent`, reload, Accept: `_ga` and `_ga_<container>` appear on `.yeste.studio`;
   the GA4 realtime report shows the visit.
4. Footer *configurar cookies* → Reject: the `_ga*` cookies are gone and the next page makes no
   request to Google.
5. A product site without `google-analytics` in `_data/settings.yml`: no banner, no footer link,
   no request.

## Maintenance

- Adding or changing a non-exempt cookie: edit `_data/cookies.yml`, bump `version`, update the
  policies if the purpose or the recipient changed, run the verification.
- Adding an exempt storage (a new preference in `localStorage`): add it to the register; no
  version bump.
- Once a year, check whether the AEPD guide has a newer edition than the one above and reread
  the requirements table against it.
- yeste-studio-website: after touching the banner, the table include, the script or the styles,
  run `scripts/sync-consent.sh` and commit both repos. Its register is its own
  (`yeste-studio-website/_data/cookies.yml`, one extra entry) and is edited by hand.
