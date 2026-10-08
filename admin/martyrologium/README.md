# Martyrologium

Each elogium is stored once, under a key. The Latin file for a day lists
which entries the day has and in what order; every language uses the same
keys, so the columns line up entry for entry and a version rule like
"1960 drops this one" is written once instead of once per language.

An entry a language has not translated is filled from the reader's
fallback language. If nobody in that chain has it, it is left out rather
than shown in Latin.

**If you are adding or fixing a translation, you only ever supply words.**
Order, and which versions have what, come from the Latin.

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
`obsolete/martyrologium-source`, matches each line against the Latin, and
gives it that Latin key. Lines it cannot match keep a key of their own.
To redo a language already in the tree, point `--src` at its files under
`obsolete/martyrologium-source` and pass `--replace`.

Run `verify.pl` after any change. It exits non-zero if something no longer
renders that should.

## The files

One folder per language, one file per day:

```
web/www/horas/<Lang>/Martyrologium/MM-DD.txt

[Titulus]           the day's heading
[Separatio]         only when the separator is not a plain '_'
[Martyrologium]     the day in order — Latin only
[Nazianzi]          one section per elogium
[Hermae]
```

A translation carries only `[Titulus]` and its entries. It inherits the
Latin's index, which is what keeps the columns together.

Values are the lines verbatim. A leading `=` escapes a line that would
otherwise read as section grammar (`=_` is a literal `_`, `=` alone is a
blank line, and a line opening with `(` needs it too).

## The five things you can write

Everything below works in any language file, not only the Latin.

**1. An entry.** One section per elogium, named by its key.

```
[Bernardi]
At Clairvaux, holy Bernard, Abbot...
```

**2. A version's own wording.** Same key, a rubric after the bracket. The
plain section is the ordinary wording; the qualified one replaces it for
that version only.

```
[Bernardi] (rubrica Cisterciensis)
what the Cistercian book says instead
```

**3. A heading that announces the day's feast.** Some books announce the
feast above the rule and then say "upon the same day, were born into the
better life" below it, where the Latin prints the same elogium as the
first one under the rule. Don't copy the words into the heading — ask for
the entry by key:

```
[Titulus]
@:Joannis
Upon the same 6th day of May, were born into the better life:
```

The call is answered only while the Latin keeps that entry at the head of
the day. A version that drops the entry outright (example: 1960 dropped the
Octave of St Stephen on 2 January) simply has no feast to announce, and
the rest of the heading stands without it. But a version that keeps the
entry and moves it down — 1960 did that on 6 May, when the feast of St
John before the Latin Gate went — takes the heading with it: the entry
falls in among the elogia where the Latin now puts it, and "upon the same
day" has nothing left to be about.

Write the call only where the Latin agrees the entry comes first. Where
your book announces above the rule something the Latin keeps far down the
list, leave it alone: the Latin decides the order, here as everywhere.

An empty `[Titulus]` is not the same as no `[Titulus]`: a language
without one takes the fallback's, a language with a blank one shows a
blank. So if your book announces nothing and opens straight on the
elogia — as the Italian and the Polish do — write the blank one, or the
column will announce the day in English.

```
[Titulus]

```

**4. An entry your book says inside another one.** The books do not always
divide a day the same way. On 20 December the Latin has *Liberáti et
Bájuli* and then a notice of Ammon, Zeno and the rest; the French says all
of them in one line. That line takes one key, and without something in
the other the reader gets Bajulus twice — once in the list he is already
in, once from the fallback on his own.

So instead of a translation, write where it was already said:

```
[Liberati-Bajuli]
@:Alexandriae-Ammonis
```

That entry then prints nothing and nothing is filled in for it.

**5. Nothing.** Leaving a key out is fine and normal — the column falls
back. Only write a note (4) when your book has already said it elsewhere.

## Keys

Keys are always Latin, whichever book the entry came from: an entry only
the Czech has is `Alberici-Cisterciensis`, not `V-Citeaux`. A key is made
from the elogium's own words — the word introducing the name (`sancti`,
`beátæ`, `sanctórum`) and the next capitalised word or two.

Entries naming nobody are keyed by number and kind
(`Quadraginta-Trium-Monachorum`), or failing that by place.

**One saint, one key.** If you find the same saint under two keys on a
day, that is a bug: the two should be one, or one should be a note (4).

## latin-todo.txt

An elogium a translation has and the Latin has not still gets a Latin key
so that it lines up and renders; its Latin section is left empty until
someone writes the Latin. `latin-todo.txt` is the list of those, with the
text of each so it can be read:

```
 07-04 Procopii-Abbatis   # Bohemice: Svatého Prokopa, opata...
-01-01 Fiesta-Santisimo   # Espanol: Fiesta del Santísimo Nombre... 2ª cl. Blanco
```

The first character is the decision. A space means the Latin ought to
carry it. A `-` means it is not an elogium at all — a calendar line, a
date heading, the leader-dot the Polish book prints where it omits an
entry — and it stays where it is without rendering. A `<` means the line
is not an entry but the rest of the one above it, and is joined back on.

`latin_todo.pl --apply` reads this file rather than its own opinion, so a
wrong call is fixed by changing one character.

**Filling one in is the whole job:** write the Latin into its empty
section. Nothing else has to change, because every language already names
it.

## Names

Names are matched by folding the spellings that vary predictably between
Latin and its vernaculars — ae/e, ph/f, th/t, j/i, doubled letters,
dropped h, Latin case endings, and `-ti-`/`-ci-`/`-zi-` for the Romance
languages.

Names differing by history rather than spelling (Michaélis/Miguel,
Gállia/Francia) live in `namelex/<Lang>.txt`. The block above the marker
is yours: `stem stem` adds a pair, `-stem stem` drops a wrong one. Add a
pair there when the import keeps missing a saint you know is the same.

## Tools

```
split_months.pl         monthly files -> day files
import_translation.pl   day files -> the language's Martyrologium folder
verify.pl               nothing renders differently than it should
latin_todo.pl           what the Latin owes; also joins wrapped entries
latin-todo.txt          which entries are elogia and which are not
namelex/                name lists, one per language
internal/selftest.pl    the rendering rules, on a made-up language
```
