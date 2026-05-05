# How the Divinum Officium Calendar Works

This document explains how the liturgical calendar is generated and served,
including the full-year (Totus) ordo cache introduced in May 2026.

---

## The Regular Calendar (Single Month)

**Step 1 — You open the calendar page**

Your browser requests `kalendar.pl`. Starman (the persistent web server)
receives it and hands it to the CGI handler defined in `app.psgi`.

**Step 2 — The script loads its helpers**

`kalendar.pl` loads a set of shared libraries needed to calculate liturgical
days, including:

- `web/cgi-bin/horas/horascommon.pl` — shared Office utilities
- `web/cgi-bin/DivinumOfficium/setup.pl` — configuration and ini loading
- `web/cgi-bin/DivinumOfficium/RunTimeOptions.pm` — user preference handling

**Step 3 — Your rubrical version is read from your cookie**

`RunTimeOptions.pm` checks your browser cookie (set the last time you used
the site) for your preferred rubrical version — for example
`Rubrics 1960 - 1960` or `Tridentine - 1570`. If no cookie exists, it
defaults to `Rubrics 1960 - 1960`.

The full list of supported versions is defined in
`web/www/Tabulae/data.txt`.

**Step 4 — The calendar table is drawn**

For a single month (clicking "Jan", "Feb", etc.), `kalendar.pl` loops over
each day of that month and calls the liturgical calculation engine. This is
fast — 28 to 31 iterations.

**Step 5 — Each day is looked up in the Tabulae**

For each day, the engine consults the data files in
`web/www/Tabulae/Kalendaria/` — for example `1960.txt` or `1570.txt` —
which define the liturgical calendar rules for that rubrical version. It
determines what feast or season falls on that day, its rank, and what text
to display.

**Step 6 — The HTML is printed to the browser**

`kalendar.pl` builds an HTML table row by row and sends it to the browser.
For a single month this completes in under a second.

---

## The Full-Year Calendar (Totus)

**Step 7 — Clicking Totus submits kmonth=14**

The JavaScript on the page sets `kmonth=14` in the HTML form and POSTs it
to `kalendar.pl`. The value `14` is a special sentinel meaning "whole year"
— defined in the source as:

```perl
# entries 13 (placeholder) and 14 (actually) are added for the Whole Year (Totus) Option
use constant MONTHLENGTH => ('', 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, '', 365);
```

**Step 8 — WITHOUT the cache (the old broken way)**

`kalendar.pl` loops over all 365 days (366 in a leap year), runs the full
liturgical calculation for each one, builds one giant HTML table, and tries
to print it all back to the browser. This takes 60–100+ seconds, which
exceeds Cloudflare's gateway timeout — resulting in a **504 error**.

**Step 9 — WITH the cache (the current solution)**

`app.psgi` intercepts the request *before* it ever reaches `kalendar.pl`.
It reads `kmonth` from the POST body, sees the value `14`, reads the
`version` parameter (e.g. `Rubrics 1960 - 1960`), converts it to a
filename-safe key (`rubrics-1960-1960`), and looks for:

```
/var/www/web/ordo-cache/2026-rubrics-1960-1960.html
```

If the file exists, `app.psgi` reads it and returns it directly to the
browser in milliseconds with the response header `X-Ordo-Cache: HIT`.
`kalendar.pl` is never called at all.

If the file does *not* exist (cache miss), the request falls through to the
live CGI — which will be slow or may timeout, but degrades gracefully.

---

## The Cache Warmer

**Step 10 — Where the cache files come from**

`warm-ordo-cache.sh` is a shell script that pre-generates the full-year
ordo for all supported rubrical versions. It runs in two situations:

1. **At container startup** — runs in the background so Starman starts
   immediately without waiting. Cache is ready within ~60 seconds.
2. **Nightly at 2:00 AM UTC** — triggered by a cron job inside the
   container, ensuring the cache stays fresh as liturgical corrections are
   pushed to the codebase.

The script loops through all 11 rubrical versions:

| Version | Cache filename |
|---|---|
| Tridentine - 1570 | `2026-tridentine-1570.html` |
| Tridentine - 1888 | `2026-tridentine-1888.html` |
| Divino Afflatu - 1939 | `2026-divino-afflatu-1939.html` |
| Divino Afflatu - 1954 | `2026-divino-afflatu-1954.html` |
| Reduced - 1955 | `2026-reduced-1955.html` |
| Rubrics 1960 - 1960 | `2026-rubrics-1960-1960.html` |
| Rubrics 1960 - 2020 USA | `2026-rubrics-1960-2020-usa.html` |
| Monastic Tridentinum 1617 | `2026-monastic-tridentinum-1617.html` |
| Monastic Divino 1930 | `2026-monastic-divino-1930.html` |
| Monastic - 1963 | `2026-monastic-1963.html` |
| Ordo Praedicatorum - 1962 | `2026-ordo-praedicatorum-1962.html` |

For each version, it hits `kalendar.pl` locally via `wget`, waits ~5
seconds for the 365-day computation to complete, and saves the HTML to
`/var/www/web/ordo-cache/`. The full run takes approximately 54 seconds
and logs to `/var/log/ordo-cache-warm.log`.

---

## Key Files

| File | Purpose |
|---|---|
| `web/cgi-bin/horas/kalendar.pl` | Main calendar CGI script |
| `web/cgi-bin/DivinumOfficium/RunTimeOptions.pm` | Reads user rubrical version preference from cookie |
| `web/www/Tabulae/data.txt` | Defines all supported rubrical versions |
| `web/www/Tabulae/Kalendaria/1960.txt` | Liturgical rules for Rubrics 1960 |
| `web/www/Tabulae/Kalendaria/1570.txt` | Liturgical rules for Tridentine 1570 |
| `app.psgi` | PSGI app — routes requests, serves ordo cache |
| `warm-ordo-cache.sh` | Nightly cache warmer script |
| `/var/www/web/ordo-cache/` | Cache directory (ephemeral, rebuilt on startup) |

---

## Why Not Just Make kalendar.pl Faster?

The 365-day computation involves a complex chain of liturgical precedence
rules, feast rankings, commemorations, and rubrical exceptions — all
evaluated independently for each day. It is inherently sequential and
cannot easily be parallelized. The caching approach sidesteps the problem
entirely: the expensive work happens once per night on a warm server with
no timeout pressure, rather than on every user click.
