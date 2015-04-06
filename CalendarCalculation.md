# Introduction #

Calculating the ordo for a given day involves two mostly independent steps:
firstly, determining which office should be said (including things like
commemorations and translations), and then actually compiling the content of the
hours. The first of these stages is our current concern.

At present, translations of entire offices and of occurring Scripture are
pre-calculated (up to 2015, currently) and stored in look-up tables that are
consulted at run-time by the scripts that actually produce the offices. The
algorithm for generating these tables has some bugs, and ad-hoc patches have
been applied to the tables manually.

In order to resolve occurrence and concurrence, the program reads and parses all
of the files for the candidate offices and assesses their ranks and other
salient properties. Some special cases require separate handling.

It is proposed to do two things: Firstly, to store in one place all the
information necessary for determining the office of the day (see [issue 129](https://code.google.com/p/divinum-officium/issues/detail?id=129) and
[issue 149](https://code.google.com/p/divinum-officium/issues/detail?id=149)).  This has benefits of its own, but is mostly directed towards the
second proposed change, namely the calculation of the translation of offices on
the fly. This is a more tentative prospect; I hope to examine its (de)merits in
more detail in due course.

This article sketches a possible solution.


# Requirements #

Here are some required, or at least desired, properties of the new system:

  * The basics: title and ranking info. See [Calendar data](CalendarCalculation#Calendar_data.md), below.
  * Speed. This is a major motivation. The calendar data would be stored in setupstring-parseable format, but could be preprocessed and stored again, perhaps as a serialised hash. These would probably best be recalculated each time the site is updated, rather than cached on the fly at runtime. Testing for speed (not to mention correctness) would be essential, naturally!
  * Separation of different offices occurring on the same day. For practical purposes, commemorations are occurring offices of simple rite. When the office of the day is translated, the commemorations are (usually) not. Those which _are_ to be translated are intrinsic to the office and should _not_ be treated separately.
  * Some sort of hierarchy for local calendars, e.g. Westminster -> England and Wales -> universal calendar. Calendars higher in the hierarchy would need to be able to modify those lower down, rather than simply layer on top of them.  Support for this isn't necessary to begin with, but it should be borne in mind so that it can be added easily in the future.


# Calendar data #

Candidate data for each liturgical day in the central calendar database:
  * Title (allow for autogeneration for ferias, and maybe Sundays, days in octaves...).
  * Rank and rite, in some sense. More below.
  * Type of day (feast, vigil...).
  * Duration of day in exceptional cases.
  * Filename of office, and commemoration index in file, when appropriate.

We note at this point that the entire calendar needn't be stored in a single
_file_, necessarily -- one file for each month might be appropriate for the
sanctoral cycle, for example -- but the important thing is that we separate the
ranking data from the offices themselves.


## Some details ##

The entry for a day would take the following form:

```
[day-id]
<title>
<rank_line>
...more fields...
```

Each line would be of the form `key=value`, except that in the first two
fields the keys would implicitly be "title" and "rank", respectively.  Null
values would be legal, in which case the "=" would be omitted. Multiple offices
occurring on the same day would be separated by at least one blank line.

A fragmentary example:

```
[Pasc0-0]
Dominica Resurrectionis
Dominica Maior Duplex Primaria I. classis

[06-17] (rubrica 1960)
S. Gregorii Barbadici, Episcopi et Confessoris
Festum Duplex
filename=Sancti/06-17r

[09-14]
In Exaltatione Sanctae Crucis
Festum Domini Duplex Maius
(sed rubrica 1960) Festum Domini Duplex II. classis

[10-07]
Sacratissimi Rosarii Beatae Mariae Virginis
(sed rubrica 1960) Beatae Mariae Virginis a Rosario
Festum Duplex Secundaria II. classis

S. Marci, Papae et Confessoris
Festum Simplex
```

Here are the supported fields:

| **Field** | **Significance** |
|:----------|:-----------------|
| title | Title of office. |
| rank  | Specification of the office's rank, rite etc. See below. |
| filename | Relative path to office file, without `.txt`. If omitted, this is inferred. |
| id    | ID string for subsequent references to the office. Specifying an existing ID causes any previous office of that ID to be deleted. This field can be omitted unless this behaviour is needed. See the _Implementation_ section for more. |

There are several other fields which for the moment should be considered as undocumented and for internal use only. However, the null-valued fields `De tempore` and `Proprio Sanctorum` have special significance and set an internal field to values to indicate that the office is temporal or sancotral, respecitvely. Most of the time this is inferred from the calpoint and so specifying these is not necessary (e.g. `Pasc7-6` defaults to being temporal and `05-25` to being sanctoral).

## Rank, rite etc. ##

```
<rank_line>	::= <category> <rite> <nobility> <rank>
<category>	::= "Festum" <person> | "Dominica" <sun_type> | "Feria" <fer_type> | "Vigilia" | "Dies infra octavam" <oct_type> | "Dies octava" <oct_type>
<person>	::= "Domini" |
<sun_type>	::= "Maior" |
<fer_type>	::= "Maior privilegiata" | "Maior" |
<oct_type>	::= <oct_order> "ordinis" | "communis" | "communem" | "simplex"
<oct_order>	::= "I." | "II." | "III."
<rite>		::= "Duplex maius" | "Duplex" | "Semiduplex" | "Simplex"
<nobility>	::= "Primaria" | "Secundaria" |
<rank>		::= <rank_order> "classis" |
<rank_order>	::= "I." | "II." | "III." | "IV."
```

This is designed to generalise as far as possible the rankings across all of
the supported sets of rubrics. It's modelled mostly on the Divino
classifications (which are refinements of the Tridentine ones), with some extra
things to support 1960 changes. Conditionals would be used in cases where a
single classification can't capture everything necessary for all rubrics.

The following is a (partial?) list of the interpretation of various things
under the 1960 rubrics:

| **Classification**		| **1960**			|
|:--------------------|:-----------|
| Dominica maior		| I. cl.		|
| Feria maior privilegiata	| I. cl.		|
| Feria maior			| III. cl.		|
| III. ordinis (of an octave)  | II. cl. octave	|
| Duplex maius			| III. cl.		|
| Duplex			| III. cl.		|
| Semiduplex			| III. cl.		|
| Simplex			| Commemoration	|

The correspondence isn't perfect (e.g. in the last days of Advent), but this
can be worked around with explicit exceptions.

Omitting fields, when this is allowed, will result in sensible defaults, which
will differ according to the active rubrics.


## Temporal Cycle ##

Much of the temporal cycle is formulaic, and this fact could be used to our
advantage. Having to specify all of the ferias _per annum_ explicity (for
example) would not be ideal, so a set of implicit defaults could be specified.
Thus a feria after Pentecost has name _Feria m infra hebdomadam n post Octavam
Pentecostes_ and is of simple rite, a feria in Lent is a greater feria of
simple rite and is _Feria m infra hebdomadam n Quadragesimae_, and so on. If a
particular day deviates from the general pattern, it would be enough to create
an entry for it in the calendar file, and the defaults would be overriden: for
instance, for the Ember days.

# Implementation #

As of Easter 2013, work has begun on this project on the `calcalc` branch. This section contains sundry implementation notes.

## Source files ##
  * **`admin/gen-cal.pl`** generates a calendar file in the format described above by extracting the appropriate data from the existing office files. It doesn't handle commemorations or the distinction between primary and secondary feasts, but these would maybe be better done manually. It also misses a few cases, such as feasts calculated relative to a certain week of a month.

  * **`web/cgi-bin/horas/caldata.pm`** parses calendar files.

  * **`web/cgi-bin/horas/calendar.pm`** is intended to house calendar logic. It currently has occurrence and concurrence comparators; its other main task will be to resolve the office (including any commemorated offices) for a given hour on a given day.


## Calendar file directory structure ##

Storing the calendar file(s) in (the new directory) `web/www/horas/Kalendaria` would seem to be appropriate. The main file would be `generalis.txt`, and supposing we eventually support local calendars, these could be arrange into subdirectories.

## Data structures representing parsed calendar files ##

We have two distinct sorts of query that we perform on the calendar database. The conceptually straightforward one is to retrieve the offices to be said on a given liturgical day (e.g. the Third Sunday After Easter, 23rd April, Last Sunday in October... these are called _calendar points_, or _calpoints_, in the source, and I'll adopt that convention here).

The other sort of query is to retrieve the details of a specific office (say, St George's day). In fact we don't need this in an essential way at the moment, but implementing it in full generality will make support for particular calendars easier. This requires some way of referring to an office; we use an ID system, described later.

The parsed data is stored in two hashes: one has office IDs as keys and the office data itself as values (this is itself a hash, described earlier), and the other has calpoints as keys and arrays of office IDs as values. These arrays are sorted in occurrence-precedence order, with higher-ranking offices first. The two hashes are stored in one hash for convenience; if this is `%calendar`, the first hash is `$calendar{offices`} and the second is `$calendar{calpoints`}.

### Caching parsed data ###

## Resolving the office ##

Given a calendar day, we wish to find the offices to be said. An algorithm would look something like this:

Firstly, to resolve occurrence:

  1. Find all the calpoints falling on that day, taking into account transferral.
  1. Get the list of offices for each of the calpoints.
  1. Interleave the lists according to occurrence precedence. This is reasonably straightforward, as each list is already sorted.

And concurrence:

  1. Resolve occurrence for both days.
  1. Interleave preceding and following. The first item in the list is determined by the concurrence comparator in the natural way; this determines whether the office is to be of the preceding or of the following (or from the chapter of the following). But thereafter the ordering of offices depends on the active rubrics: some require that preceding offices be commemorated before all following ones; others just sort by rank, in some sense (concurrence rank? occurrence rank?).

**Remark:** Functions for comparing the ranks of any two offices in occurrence and concurrence have been implemented: see `calendar.pm`.

### Transferral of offices ###

For the time being we can use the existing precalculated tables, but in the long run we will need some replacement for these. Precalculation is a good solution _except_ that it would be problematic for particular calendars. Finding a sufficiently fast (and correct!) algorithm for on-the-fly calculation is an intriguing problem. If the calculation did prove too expensive, some sort of per-particular-calendar caching might be practicable, in the same spirit as for the calendar files themselves. As some first thoughts in this direction, [here is an article by Paul Cavendish which mentions, in passing, how St Mark ended up in June](http://www.ingentaconnect.com/content/maney/usu/2011/00000002/00000002/art00002), and, secondly, it is probably reasonable to assume that a feast is never translated by more than a year (!).