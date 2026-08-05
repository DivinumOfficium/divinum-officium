# Martyrologium elogia pool

The elogia (saints of any given day) are stored under key-text pairs defining
the ordering and inheritance of each saint as they are shown, replacing
the system of the martyrology being a single flat file that had to exist
in its entirety per day, per version, and per language.

Each elogium is stored once under a key, and a version file holds only
the changes that version makes. Adding one new elogium for a WIP 1960-specific
English translation for example only requires a single text file
(`Martyrologium1960/01-01.txt`) to be written with a single key for just that elogium,
(and as documented below, it's possible to specify order with even one key),
so that a new translation would not have to be written out four times per each version
we support.

## Adding a translation

Write plain files the way the martyrology has always been written — a
heading line, `_`, then one elogium per line — name them `MM-DD.txt`, and:

```
python import_translation.py --lang Deutsch --from 1960 --src ~/deutsch
```

`--from` is the Latin version the translation follows (`base`, `1955R`,
`1960`). Any subset of the year is fine; you can import a month, check it,
and come back to the rest.

If what you have is twelve monthly files (`01.txt` .. `12.txt`), run
`split_months.pl` in that folder first to cut them into days.

Then check nothing else moved:

```
perl verify_perl.pl
```

The import does the whole job: it keeps a copy of your files under
`source/`, matches each line against the Latin, learns the language's name
list into `namelex/`, then matches again now that it knows the names.

Lines that name the same saints as a Latin elogium take that Latin key, so
they line up with the other languages; the rest keep a key of their own.
The percentage is reported and never enforced. A day imports whatever it
came out at, and the text renders exactly as written either way.

Days import so they render as written under every version. Add
`--enable-versions 1960` only if you want those days to follow 1960's
arrangement instead.

To redo a language that is already in the tree, point `--src` at its own
`source/` folder and pass `--replace`.

## The Latin pool is the schema

Every language's keys come from the Latin. They are not derived from the
translation: there is no way to turn *Grégoire Barbarigo* into
`Gregorii-Barbadici`. The name matcher can only be shown two names and
asked whether they look like the same one. So a translated line gets a
Latin key by being compared against the Latin entry for that day, and
a line that matches nothing keeps a key of its own.

That is what makes the columns line up, what lets a version say "1960
deletes this entry" once instead of once per language, and why the Latin
pool has to be built before any translation can be imported. The purpose of
`internal/decompose.py` is to build the Latin elogia from the original
month-day files, and the importer's `convertlib` checks a translation's
month-day against it.

### Deciding what counts as the same entry

The Latin is four editions of the same year, and an elogium is often set a
little differently in each. `decompose.py` has to recognise those as one
entry: that is what lets a version file say "reworded" in a line instead of
carrying a whole second copy of the text, and it is what keeps one saint on
one key across all four.

Where two wordings are word for word the same once accents are folded, it
merges them itself. That covers nearly every 1570 entry, since that edition
is the base text unaccented. Where the wording genuinely differs, it does
not guess. The entry keeps a key of its own and is written to
`reports/unify-pending.txt` with its text and everything already keyed for
that day, and it stays there until `unify.txt` answers. That file is the
record of those answers, and the only thing that can merge two entries:

```
 <day> <version> <key> <same-as>   merge <key> into <same-as>
-<day> <version> <key>             confirmed a separate elogium

 08-19 1570 Ludovici-Tolosani Ludovici
-05-01 1955R Joseph-Opificis         # new feast
```

`<key>` is the key the entry would be given on its own, so it can shift as
earlier merges land. Re-run and check the pending list after editing.

The decisions in `unify.txt` as of now are mostly the 1570 setting spelling
a word differently (`eundem`/`eumdem`, `paenitentiae`/`poenitentiae`) or
misprinting one (`Ægídii`/`Atgidii`, `martyrum`/`marytrum`), or a version
adding a feast the base never had, or running two of the base's entries
onto a single line.

It is done by hand because a wrong merge is invisible to every check here:
the base file would hold one wording and the version file the other, both
would render exactly as their sources, and everything would pass while two
saints quietly shared a key.

This only matters if you're attempting to add a new Latin version.

## Files

```
web/www/horas/<Lang>/
├── Martyrologium/
│   ├── MM-DD.txt              the day, in reading order
│   ├── source/MM-DD.txt       the original flat file, kept as-is
│   └── Mobile.txt             movable commemorations (not converted)
├── Martyrologium1955R/MM-DD.txt   only what that version changes
├── Martyrologium1960/MM-DD.txt
└── Martyrologium1570/MM-DD.txt    (Latin only)
```

A day file is the whole day, and everything in it is shown:

```
[Titulus]        the date line, may run to several lines
[Separatio]      only when the separator is not a plain '_'
[Nazianzi]       one section per elogium, in the order they are read
[Hermae]
```

Values are the lines verbatim. A leading `=` escapes a line that would
otherwise look like section grammar (`=_` is a literal `_`, `=` alone a
blank line). `[MM-DD:Key]` refers to an entry kept in another day's file.

A version file holds only the differences:

| section | meaning |
|---|---|
| `[Key]` empty | deleted for this version |
| `[Key]` value | reworded, stays where it was |
| `[Key post Other]` value | placed after `Other` |
| `[Key ante Other]` empty | moved before `Other`, keeps its value |
| `[Titulus]`, `[Separatio]` | change the day's structure |

1570 is the base text without accents, so its values are derived by
deaccenting and only real rewordings get stored.

## Rendering

* **Latin** renders the merged key order with Latin values.
* **Vernacular** renders its own file order. It only merges with the
  Latin when it has a version file for the active rubrics, or when the
  fallback option is on.
* **A language with no file for that day** renders its parent's, the same
  order `checkfile()` uses: `Latin-Bea` reads Latin, `Polski-Newer` reads
  Polski, anything else the fallback language.
* gabc still reads the flat files under `source/`.

### Option: "Use left column elogia as fallback"

`$martyrfallback`, off by default. An entry the language never mentions is
filled from the other column on the page:

```
<lang> version file -> <lang> root -> <lang1> version file -> <lang1> root
```

Keys are the same in every language, so changing the left column changes
only which wording fills a gap, never the order or which entries appear.
An empty value stops the chain: it means deleted, not untranslated.

## Matching

Names are matched by folding the spellings that vary predictably between
Latin and its vernaculars — ae/e, ph/f, th/t, j/i, doubled letters,
dropped h, Latin case endings, and `-ti-`/`-ci-`/`-zi-` for the Romance
languages. Entries are then scored on how well their two name sets agree,
both ways, so a long notice sharing only a city cannot beat a short entry
whose names match exactly.

Names that differ by history rather than spelling (Michaélis/Miguel,
Gállia/Francia) are learned from the corpus instead, into
`namelex/<Lang>.txt`. That file is data: the block above the marker is
kept by hand, where `stem stem` adds a pair and `-stem stem` drops a wrong
one. A new language starts without one and runs on the rules alone.

## Tools

```
split_months.pl          monthly files -> day files
import_translation.py    day files -> pool files, and everything that goes with it
verify_perl.pl           every language x version still renders as it did
namelex/                 learned name lists, one per language
internal/                the libraries, and the pieces only used to rebuild
```

Inside `internal/`: `martyrlib.py`, `convertlib.py` and `cognates.py` are
the libraries; `learn_names.py` builds a `namelex/` file on its own if you
want to redo one without reimporting; `decompose.py` rebuilds the Latin
pool from the flat Latin files and checks its own output; `selftest.py`
imports a made-up language and checks it renders correctly.

`verify_perl.pl` exits non-zero on
divergence, so it is worth running in CI on any PR that touches
`specprima.pl`.
