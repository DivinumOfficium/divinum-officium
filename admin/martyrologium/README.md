# Martyrologium

Each elogium is stored once, under a key. The Latin file for a day lists
which entries the day has and in what order, and every language uses the
same keys, so the columns line up entry for entry and a version can say
"1960 drops this one" once instead of once per language.

Files are read by `setupstring`, so an entry a language has not translated
is filled from the reader's fallback language. It stops there: an entry no
language in the chain has is left out rather than shown in Latin.

## Adding a translation

Write plain files the way the martyrology has always been written — a
heading line, `_`, then one elogium per line — name them `MM-DD.txt`, and:

```
perl import_translation.pl --lang Deutsch --src ~/deutsch
perl verify.pl
```

Any subset of the year is fine; import a month, look at it, come back to
the rest. If what you have is twelve monthly files (`01.txt` .. `12.txt`),
run `split_months.pl` in that folder first to cut them into days.

The import keeps a copy of your files under
`obsolete/martyrologium-source`, matches each line against the Latin,
learns the language's name list into `namelex/`, then matches again now
that it knows the names. Lines naming the same saints as a Latin elogium
take that Latin key; the rest keep a key of their own. The percentage is
reported and never enforced.

Nothing needs to be said about versions. The order and the version rules
come from the Latin.

To redo a language already in the tree, point `--src` at its files under
`obsolete/martyrologium-source` and pass `--replace`.

## Keys come from the Latin

They cannot come from the translation: there is no way to turn *Grégoire
Barbarigo* into `Gregorii-Barbadici`. The matcher can only be shown two
names and asked whether they look like the same one, so a translated line
earns a Latin key by being compared against that day's Latin entries.

A key is made from the elogium's own words: the word introducing the name
(`sancti`, `beátæ`, `sanctórum`) and the next capitalised word or two. It
is always Latin, whichever book the entry came from: an entry only the
Czech has is `Alberici-Cisterciensis`, not `V-Citeaux`.

Plenty of entries name nobody, being a number of people put to death
together, and then the key says how many and of whom:
`Militum-Triginta`, `Quadraginta-Trium-Monachorum`,
`Decem-Millium-Martyrum`. Latin compounds its numbers, so the whole run of
them is kept: forty-two martyrs and forty-seven martyrs must not come out
alike. Where the entry names neither a person nor a number, the place is
what is left.

An elogium a translation has and the Latin has not still gets a Latin key,
so that it lines up and renders; the Latin section under it is left empty
until the Latin value is added. There are hundreds of these, and
`latin-todo.txt` is the list, with the text of each so it can be read:

```
 07-04 Procopii-Abbatis   # Bohemice: Svatého Prokopa, opata...
-01-01 Fiesta-Santisimo   # Espanol: Fiesta del Santísimo Nombre... 2ª cl. Blanco
```

The ones marked `-` are not elogia. The printed books put their own
furniture between the entries: the Spanish edition prints the day's
calendar with its rank and color and a page of devotional comment, the
Polish one a date heading and a leader-dot where it omits an entry - and
that belongs to the language printing it. A line marked `<` is the rest of
the entry above it, wrapped, and is joined back on. `latin_todo.pl --apply`
reads the file rather than its own opinion, so a wrong call is fixed by
moving one character.

Filling one in is the whole job: write the Latin into its empty section.
Nothing else has to change, because every language already names it.

## The files

One folder per language, one file per day:

```
web/www/horas/<Lang>/Martyrologium/MM-DD.txt

[Titulus]           the date line, may run to several lines
[Separatio]         only when the separator is not a plain '_'
[Martyrologium]     the day in order — Latin only
[Nazianzi]          one section per elogium
[Hermae]
```

Values are the lines verbatim. A leading `=` escapes a line that would
otherwise read as section grammar (`=_` is a literal `_`, `=` alone a blank
line, and a line opening with `(` needs it too).

A translation carries only `[Titulus]` and its entries. It inherits the
Latin's index, which is what keeps the columns together.

### Wording an entry by version

A book that says an elogium differently gets a section of its own, after
the plain one:

```
[Bernardi]
the ordinary wording

[Bernardi] (rubrica Cisterciensis)
what the Cistercian book says instead
```

One key, one saint, one wording per book that words it differently. This
works in any language file, not only the Latin: the Czech martyrology is
the Cistercian one throughout and every entry in it is marked that way.

## Names

Names are matched by folding the spellings that vary predictably between
Latin and its vernaculars — ae/e, ph/f, th/t, j/i, doubled letters, dropped
h, Latin case endings, and `-ti-`/`-ci-`/`-zi-` for the Romance languages.
Entries are scored on how well their two name sets agree, both ways, so a
long notice sharing only a city cannot beat a short entry whose names match
exactly.

Names differing by history rather than spelling (Michaélis/Miguel,
Gállia/Francia) are learned from the corpus into `namelex/<Lang>.txt`. That
file is data: the block above the marker is kept by hand, where
`stem stem` adds a pair and `-stem stem` drops a wrong one. A new language
starts without one and runs on the rules alone.

## Tools

```
split_months.pl         monthly files -> day files
import_translation.pl   day files -> the language's Martyrologium folder
verify.pl               nothing renders differently than it should
latin_todo.pl           what the Latin owes; also joins wrapped entries
latin-todo.txt          which entries are elogia and which are not
namelex/                learned name lists, one per language
internal/               the libraries, and selftest.pl
```

`verify.pl` exits non-zero on divergence, so it is worth running on any
change to the martyrology: it checks the Latin line for line against the
files under `obsolete/martyrologium-source` and checks that no translated
entry has become unreachable. `internal/selftest.pl` covers the rendering
rules on a made-up language.
