use strict;
use warnings;

use DivinumOfficium::Main qw(vernaculars liturgical_color);

use Test::Simple tests => 31;

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
ok(scalar(@vernaculars) == scalar(keys(%vernaculars)), 'No dups');
ok(exists($vernaculars{'English'}), 'Has English');
ok(exists($vernaculars{'Italiano'}), 'Has Italian');
ok(!exists($vernaculars{'Latin'}), 'No Latin');

# Make sure failing to load the file is fatal.
{

  package DivinumOfficium::Main;
  use Test::Carp;
  does_croak(\&::vernaculars, 'non/est/hic');
}

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

ok(liturgical_color('In Nativitate Domini') eq 'black', 'No keywords matched falls through to the default black');

ok(liturgical_color("Beatae Mariae") eq 'blue', 'Blue: "Beatae Mariae"');
ok(liturgical_color("Sanct\x{e6} Mari\x{e6}") eq 'blue', 'Blue: the ae-ligature spelling is also recognized');

ok(liturgical_color('Officium Defunctorum') eq 'grey', 'Grey: "Defunctorum"');

ok(liturgical_color('In Vigilia Ascensionis Domini') eq 'black', 'Black (anchored): "^In Vigilia Ascensionis"');

ok(liturgical_color('Dominica Septuagesima') eq 'purple', 'Purple: "gesim" (Septuagesima/Sexagesima/Quinquagesima)');

ok(liturgical_color('In Dedicatione Ecclesiae') eq 'black', 'Black: "Dedicatione"');

ok(liturgical_color('In Festo Pentecosten') eq 'green', 'Green: bare "Pentecosten"');

# Isolated from every earlier branch (no Mari/Vigilia/Martyr/etc.), so this
# can only be reached via the final red branch's "Innocentium" alternative.
ok(liturgical_color('In Festo Sanctorum Innocentium') eq 'red', 'Red: "Innocentium", reached only via the last branch');

## Group B: guards/exceptions on individual branches.

# Blue's Marian pattern is explicitly suppressed for a Vigil; this falls all
# the way through to purple's (case-insensitive, unguarded) "Vigilia".
ok(
  liturgical_color('In Vigilia Assumptionis Beatae Mariae Virginis') eq 'purple',
  'Blue\'s Vigil exception sends a Marian vigil to purple instead',
);

# Purple's Advent keyword is suppressed by the "commemoratione" exception.
ok(
  liturgical_color('In Commemoratione Adventus Domini') eq 'black',
  'Purple\'s commemoratione exception excludes "Adventus" here',
);

# Purple's Rogation keyword is suppressed by the "votivum" exception.
ok(liturgical_color('In festo Rogationis votivum') eq 'black', 'Purple\'s votivum exception excludes "Rogatio" here');

# Green's negative lookahead only looks *forward* from the match position:
# "Pentecosten" followed later by "infra octavam" is excluded from green...
ok(
  liturgical_color('In Pentecosten infra octavam') eq 'black',
  'Green\'s lookahead excludes "Pentecosten" when "infra octavam" follows it',
);

# ...but if "infra octavam" precedes "Pentecosten" instead, the lookahead
# (which only checks what comes after) does not exclude it.
ok(
  liturgical_color('Dominica infra octavam Pentecosten') eq 'green',
  'Green\'s lookahead does not look backwards, so preceding text does not exclude it',
);

## Group C: case-sensitivity and orthography quirks worth pinning down.

# Blue's pattern has no /i flag, so it is case-sensitive.
ok(liturgical_color('beatae mariae') eq 'black',
  'Blue\'s pattern is case-sensitive; an all-lowercase match falls through');

# Black's anchored Vigil pattern has no /i flag either; a lowercase variant
# instead falls through to purple's case-insensitive "Vigilia".
ok(
  liturgical_color('in vigilia ascensionis') eq 'purple',
  'The anchored black Vigil pattern is case-sensitive; lowercase falls through to purple',
);

# Purple's Holy Week pattern only recognizes the ae-ligature
# spelling ("Hebdomadae Sanctae" with ae-ligature characters), unlike blue's
# Marian pattern which accepts both the ligature and the plain "ae" digraph.
ok(
  liturgical_color("Feria II Hebdomad\x{e6} Sanct\x{e6}") eq 'purple',
  'Purple: the ae-ligature spelling of "Hebdomadae Sanctae" is recognized',
);
ok(
  liturgical_color('Feria II Hebdomadae Sanctae') eq 'black',
  'Purple\'s Holy Week pattern does not recognize the plain "ae" digraph spelling',
);

## Group D: priority between branches that could both match the same input.

# A Marian feast that is also a martyr is blue, not red: blue is checked
# first.
ok(liturgical_color('In Festo Sanctae Mariae Martyris') eq 'blue', 'Blue takes priority over red\'s "Martyr"');

# Our Lady of Sorrows ("Dolorum") is a purple keyword, but a Marian feast
# titled with it is still blue: blue is checked before purple.
ok(liturgical_color('Septem Dolorum Beatae Mariae Virginis') eq 'blue', 'Blue takes priority over purple\'s "Dolorum"');

# Red's specific compound "Quattuor Temporum Pentecostes" is checked before
# purple's bare "Quattuor", so the more specific Pentecost Ember Days phrase
# wins; a bare "Quattuor" with no "Pentecostes" correctly falls through to
# purple instead.
ok(
  liturgical_color('Feria IV Quattuor Temporum Pentecostes') eq 'red',
  'Red\'s specific "Quattuor Temporum Pentecostes" takes priority over purple\'s bare "Quattuor"',
);
ok(
  liturgical_color('Quattuor Temporum Septembris') eq 'purple',
  'A bare "Quattuor" (no "Pentecostes") falls through to purple as expected',
);

# Red's "Decollatione" is checked before black's "oann", even though a
# beheading-of-St-John feast name would match both.
ok(
  liturgical_color('In Decollatione S. Ioannis Baptistae') eq 'red',
  'Red\'s "Decollatione" takes priority over black\'s "oann"'
);

# Grey's "Parasceve" is checked before purple's "Passion".
ok(
  liturgical_color('Passionis tempore in Parasceve') eq 'grey',
  'Grey\'s "Parasceve" takes priority over purple\'s "Passion"'
);

# Black's "Cathedra"/"Conversione" are checked before red's "Apostol", even
# though feasts of an Apostle's Chair/Conversion would match both.
ok(
  liturgical_color('In Cathedra S. Petri Apostoli') eq 'black',
  'Black\'s "Cathedra" takes priority over red\'s "Apostol"'
);

# Green's "Pentecosten" (accusative, n-ending) and red's "Pentecostes"
# (s-ending) are distinct substrings that never overlap.
ok(
  liturgical_color('Dominica infra octavam Pentecostes') eq 'red',
  'Red\'s "Pentecostes" (s-ending) is a distinct match from green\'s "Pentecosten" (n-ending)',
);

