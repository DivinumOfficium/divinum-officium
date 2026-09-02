use strict;
use warnings;

use DivinumOfficium::Main qw(vernaculars liturgical_color);

use Test2::V0;

# We're assuming here that the test is invoked from the parent of the t/
# directory.

# vernaculars() seems to be dead code in application terms (nothing calls it since d08ac5615d)
# the test now passes as I'm pointing to an existing file, but it's testing an orphaned function
# against a file (missa/Linguae.txt) that may itself become stale/unrelated to what vernaculars()
# was originally meant to enumerate (horas language dirs vs. missa language dirs are conceptually different lists).
# TODO: Remove this test and the function, or rework it to enumerate the actual language dirs from the filesystem
# TODO: instead of reading a static file.

my @vernaculars = vernaculars('web/www/missa/');
my %vernaculars;
@vernaculars{@vernaculars} = ();

# Sanity checks on the available languages.
is(scalar(@vernaculars), scalar(keys(%vernaculars)), 'No dups');
ok(exists($vernaculars{'English'}), 'Has English');
ok(exists($vernaculars{'Italiano'}), 'Has Italian');
ok(!exists($vernaculars{'Latin'}), 'No Latin');

# Make sure failing to load the file is fatal.
like(dies { vernaculars('non/est/hic') }, qr/Couldn't load language list/, 'croaks on a bad path');

### liturgical_color
# liturgical_color() sets $_ = shift and then runs a fixed sequence of
# regexes against it, returning on the first match (or 'black' if none
# match). Because it's a plain sequence of if/elsif-style early returns, the
# *order* of the branches matters a lot whenever a feast name could match
# more than one pattern - several of the tests below exist specifically to
# pin down that ordering, not just each pattern in isolation.
#
# NB: the function relies on the caller's $_ being clobbered (no 'local'), so
# each call below effectively resets $_ to its own input; this is a known,
# pre-existing quirk and not something these tests attempt to guard against.

## Group A: one representative match per branch/color, chosen to avoid
## incidentally tripping an earlier branch.

is(liturgical_color('In Nativitate Domini'), 'black', 'No keywords matched falls through to the default black');

is(liturgical_color("Beatae Mariae"), 'blue', 'Blue: "Beatae Mariae"');
is(liturgical_color("Sanct\x{e6} Mari\x{e6}"), 'blue', 'Blue: the ae-ligature spelling is also recognized');

is(liturgical_color('Officium Defunctorum'), 'grey', 'Grey: "Defunctorum"');

is(liturgical_color('In Vigilia Ascensionis Domini'), 'black', 'Black (anchored): "^In Vigilia Ascensionis"');

is(liturgical_color('Dominica Septuagesima'), 'purple', 'Purple: "gesim" (Septuagesima/Sexagesima/Quinquagesima)');

is(liturgical_color('In Dedicatione Ecclesiae'), 'black', 'Black: "Dedicatione"');

is(liturgical_color('In Festo Pentecosten'), 'green', 'Green: bare "Pentecosten"');

# Isolated from every earlier branch (no Mari/Vigilia/Martyr/etc.), so this
# can only be reached via the final red branch's "Innocentium" alternative.
is(liturgical_color('In Festo Sanctorum Innocentium'), 'red', 'Red: "Innocentium", reached only via the last branch');

## Group B: guards/exceptions on individual branches.

# Blue's Marian pattern is explicitly suppressed for a Vigil; this falls all
# the way through to purple's (case-insensitive, unguarded) "Vigilia".
is(
  liturgical_color('In Vigilia Assumptionis Beatae Mariae Virginis'),
  'purple', 'Blue\'s Vigil exception sends a Marian vigil to purple instead',
);

# Purple's Advent keyword is suppressed by the "commemoratione" exception.
is(
  liturgical_color('In Commemoratione Adventus Domini'),
  'black', 'Purple\'s commemoratione exception excludes "Adventus" here',
);

# Purple's Rogation keyword is suppressed by the "votivum" exception.
is(liturgical_color('In festo Rogationis votivum'), 'black', 'Purple\'s votivum exception excludes "Rogatio" here');

# Green's negative lookahead only looks *forward* from the match position:
# "Pentecosten" followed later by "infra octavam" is excluded from green...
is(
  liturgical_color('In Pentecosten infra octavam'),
  'black', 'Green\'s lookahead excludes "Pentecosten" when "infra octavam" follows it',
);

# ...but if "infra octavam" precedes "Pentecosten" instead, the lookahead
# (which only checks what comes after) does not exclude it.
is(
  liturgical_color('Dominica infra octavam Pentecosten'),
  'green', 'Green\'s lookahead does not look backwards, so preceding text does not exclude it',
);

## Group C: case-sensitivity and orthography quirks worth pinning down.

# Blue's pattern has no /i flag, so it is case-sensitive.
is(
  liturgical_color('beatae mariae'),
  'black', 'Blue\'s pattern is case-sensitive; an all-lowercase match falls through',
);

# Black's anchored Vigil pattern has no /i flag either; a lowercase variant
# instead falls through to purple's case-insensitive "Vigilia".
is(
  liturgical_color('in vigilia ascensionis'),
  'purple', 'The anchored black Vigil pattern is case-sensitive; lowercase falls through to purple',
);

# Purple's Holy Week pattern only recognizes the ae-ligature
# spelling ("Hebdomadae Sanctae" with ae-ligature characters), unlike blue's
# Marian pattern which accepts both the ligature and the plain "ae" digraph.
is(
  liturgical_color("Feria II Hebdomad\x{e6} Sanct\x{e6}"),
  'purple', 'Purple: the ae-ligature spelling of "Hebdomadae Sanctae" is recognized',
);
is(
  liturgical_color('Feria II Hebdomadae Sanctae'),
  'black', 'Purple\'s Holy Week pattern does not recognize the plain "ae" digraph spelling',
);

## Group D: priority between branches that could both match the same input.

# A Marian feast that is also a martyr is blue, not red: blue is checked
# first.
is(liturgical_color('In Festo Sanctae Mariae Martyris'), 'blue', 'Blue takes priority over red\'s "Martyr"');

# Our Lady of Sorrows ("Dolorum") is a purple keyword, but a Marian feast
# titled with it is still blue: blue is checked before purple.
is(liturgical_color('Septem Dolorum Beatae Mariae Virginis'), 'blue', 'Blue takes priority over purple\'s "Dolorum"');

# Red's specific compound "Quattuor Temporum Pentecostes" is checked before
# purple's bare "Quattuor", so the more specific Pentecost Ember Days phrase
# wins; a bare "Quattuor" with no "Pentecostes" correctly falls through to
# purple instead.
is(
  liturgical_color('Feria IV Quattuor Temporum Pentecostes'),
  'red', 'Red\'s specific "Quattuor Temporum Pentecostes" takes priority over purple\'s bare "Quattuor"',
);
is(
  liturgical_color('Quattuor Temporum Septembris'),
  'purple', 'A bare "Quattuor" (no "Pentecostes") falls through to purple as expected',
);

# Red's "Decollatione" is checked before black's "oann", even though a
# beheading-of-St-John feast name would match both.
is(
  liturgical_color('In Decollatione S. Ioannis Baptistae'),
  'red', 'Red\'s "Decollatione" takes priority over black\'s "oann"',
);

# Grey's "Parasceve" is checked before purple's "Passion".
is(
  liturgical_color('Passionis tempore in Parasceve'),
  'grey', 'Grey\'s "Parasceve" takes priority over purple\'s "Passion"',
);

# Black's "Cathedra"/"Conversione" are checked before red's "Apostol", even
# though feasts of an Apostle's Chair/Conversion would match both.
is(
  liturgical_color('In Cathedra S. Petri Apostoli'),
  'black', 'Black\'s "Cathedra" takes priority over red\'s "Apostol"',
);

# Green's "Pentecosten" (accusative, n-ending) and red's "Pentecostes"
# (s-ending) are distinct substrings that never overlap.
is(
  liturgical_color('Dominica infra octavam Pentecostes'),
  'red', 'Red\'s "Pentecostes" (s-ending) is a distinct match from green\'s "Pentecosten" (n-ending)',
);

done_testing;
