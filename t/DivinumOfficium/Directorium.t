use strict;
use warnings;

BEGIN {
  # Point Directorium.pm at a small, purpose-built fixture data set instead
  # of the real web/www/Tabulae data, so these tests don't depend on (and
  # can't be broken by) ongoing edits to the actual liturgical calendar data.
  # This must be set before 'use DivinumOfficium::Directorium', since
  # $datafolder is resolved once when the module is loaded.
  $ENV{DIRECTORIUM_DATA_PATH} = 't/fixtures/directorium';
}

use lib 'web/cgi-bin';
use DivinumOfficium::Directorium qw(get_from_directorium transfered check_coronatio dirge hymnmerge hymnshift);
use Test2::V0;

# TODO: Not covered here (documented gap, no fixture data set up for these):
#   - get_from_directorium() for the 'tempora'/'stransfer' subjects directly
#     (only 'kalendar' and 'transfer' are exercised below).
#   - hymnshiftmerge().
#   - The leap-year-specific file-loading logic in load_transfers() (the
#     extra letter/easter-code/'bis' files loaded for leap years), deferred
#     as a separate, more involved follow-up.

### check_coronatio - pure function, no I/O.

is(check_coronatio(18, 5), 'Commune/Coronatio', '18 May is Coronatio');
is(check_coronatio(19, 5), '', 'Other dates are not Coronatio');

### get_from_directorium('kalendar', ...)
# t/fixtures/directorium/data.txt defines three fictional versions: 'Fixture
# Base' and 'Fixture Derived' (whose base is 'Fixture Base'), plus 'Fixture
# TBase' (used further down for the transfer-table base-chain, i.e.
# 'tbase', fallback).

# Kalendaria/derived.txt directly overrides 02-02.
is(get_from_directorium('kalendar', 'Fixture Derived', '02-02'), '02-02-derived', 'Direct override in derived.txt');

# 01-01 isn't in derived.txt; it's inherited from the base version's
# Kalendaria/base.txt via the 'base' column in data.txt.
is(
  get_from_directorium('kalendar', 'Fixture Derived', '01-01'),
  '01-01-base', "Falls back to the base version's kalendar",
);

is(get_from_directorium('kalendar', 'Fixture Derived', '99-99'), '', 'Unknown key returns an empty string');

### transfered
# Transfer/409.txt contains '09-09=01-15;;derived', tagged for the
# 'Fixture Derived' version (whose transfer filter is 'derived'). The file is
# named 409 because 2023 (a plain non-leap year, chosen to avoid the extra
# leap-year file-splitting logic in Directorium::load_transfers) has Easter
# on 9 April.

is(transfered('Sancti/01-15', 2023, 'Fixture Derived'), '09-09',
  '15 Jan is transferred to 09-09 per the fixture data',);
is(transfered('Sancti/01-16', 2023, 'Fixture Derived'), '', 'Untransferred dates return an empty string');

# The 'Sancti(M|Cist|OP)?/' prefix is stripped regardless of which variant is
# used, and a bare/unprefixed date string works the same way.
is(transfered('SanctiM/01-15', 2023, 'Fixture Derived'), '09-09', 'SanctiM/ prefix is stripped like Sancti/');
is(transfered('SanctiCist/01-15', 2023, 'Fixture Derived'), '09-09', 'SanctiCist/ prefix is stripped like Sancti/');
is(transfered('SanctiOP/01-15', 2023, 'Fixture Derived'), '09-09', 'SanctiOP/ prefix is stripped like Sancti/');
is(transfered('01-15', 2023, 'Fixture Derived'), '09-09', 'A bare, unprefixed date string works the same way');
is(transfered('Sancti/', 2023, 'Fixture Derived'), '', 'A string that strips down to empty returns empty');

# '01-30=01-30;;derived': the value starts with its own key, so the
# self-referential guard ($val !~ /^$key/) must prevent this from ever being
# reported as a transfer, even though the value otherwise matches.
is(transfered('Sancti/01-30', 2023, 'Fixture Derived'), '',
  'Self-referential entries are never reported as transfers',);

# '05-06=01-21v;;derived': the trailing 'v' marks this as a votive entry,
# which the ($transfer{$key} !~ /v\s*$/i) guard must exclude.
is(transfered('Sancti/01-21', 2023, 'Fixture Derived'), '', 'Votive-suffixed entries are excluded');

# 'dirge1=03-03;;derived' would otherwise match a query for 03-03, but keys
# matching /(dirge|Hy)/i must be skipped entirely when scanning for
# transfers.
is(transfered('Sancti/03-03', 2023, 'Fixture Derived'), '', 'dirge/Hy-named keys are excluded from transfer matching',);

# '05-07=Tempora/Epi3;;derived' points at a Tempora season without the
# 'Epi1-0' exception, so it must be skipped; '05-08=Tempora/Epi1-0;;derived'
# has the exception and so must NOT be skipped.
is(
  transfered('Epi3', 2023, 'Fixture Derived'),
  '', 'Entries pointing at Tempora (without the Epi1-0 exception) are skipped',
);
is(
  transfered('Epi1-0', 2023, 'Fixture Derived'),
  '05-08', 'Entries pointing at Tempora with the Epi1-0 exception are not skipped',
);

# '10-10=02-25;;tbaseversion' only exists tagged for 'Fixture TBase', which is
# only reachable via the recursive 'tbase' (transferbase) fallback once
# 'Fixture Derived' itself has no matching entry.
is(
  transfered('Sancti/02-25', 2023, 'Fixture Derived'),
  '10-10', 'Falls back through the transferbase chain to Fixture TBase',
);

### dirge
# Transfer/409.txt also contains 'dirge1=03-03;;derived'.

ok(dirge('Fixture Derived', 'Laudes', 3, 3, 2023), 'Dirge applies on the recorded date');
ok(!dirge('Fixture Derived', 'Laudes', 4, 3, 2023), 'Dirge does not apply on the day after');

# $hora values other than Vespera/Laudes short-circuit to false regardless of
# any dirge data.
ok(!dirge('Fixture Derived', 'Matutinum', 3, 3, 2023), 'Dirge never applies outside Vespera/Laudes');

# The Vespera branch uses nextday() rather than get_sday(), so Vespera on 2
# March (the day before) is what actually matches dirge1=03-03.
ok(dirge('Fixture Derived', 'Vespera', 2, 3, 2023), 'Dirge at Vespera checks the next day');
ok(!dirge('Fixture Derived', 'Vespera', 1, 3, 2023), 'Dirge at Vespera does not apply on other days');

# Transfer/TestDioc/409.txt has its own 'dirge1=04-04;;derived', distinct
# from Generale's 'dirge1=03-03;;derived'. A diocese-specific dirge1
# *replaces* (rather than merges with) Generale's for that lookup.
ok(dirge('Fixture Derived', 'Laudes', 4, 4, 2023, 'TestDioc'), "Diocese's own dirge date applies");
ok(
  !dirge('Fixture Derived', 'Laudes', 3, 3, 2023, 'TestDioc'),
  "Generale's dirge date does not apply once a diocese override exists",
);
ok(dirge('Fixture Derived', 'Laudes', 3, 3, 2023), "Generale's own dirge date is unaffected when no diocese is given");

### get_from_directorium('transfer', ...) with a $dioecesis
# Transfer/TestDioc/409.txt also has '11-11=05-20;;derived'.

is(
  get_from_directorium('transfer', 'Fixture Derived', '11-11', 2023, 'TestDioc'),
  '05-20;;TestDioc', 'Diocese-specific transfer entries are found, tagged with the diocese name',
);

# NB: the equivalent diocese-override lookup for the 'kalendar' subject does
# not work the same way - see the comment on load_kalendar() in
# Directorium.pm for why.

### hymnmerge / hymnshift
# Transfer/409.txt also contains 'Hy05-05=1;;derived' and 'Hy05-09=2;;derived'.
# A value of 1 means hymns merge (Rule XX.3); a value of 2 means they shift
# instead. $dioecesis is passed as '' explicitly to avoid interpolating undef
# into a regexp inside Directorium.pm.

ok(hymnmerge('Fixture Derived', 5, 5, 2023, ''), 'Hymnmerge applies on the recorded date');
ok(!hymnmerge('Fixture Derived', 6, 5, 2023, ''), 'Hymnmerge does not apply on other dates');
ok(!hymnshift('Fixture Derived', 5, 5, 2023, ''), 'Hymnshift does not apply when hymnmerge does instead');

ok(hymnshift('Fixture Derived', 9, 5, 2023, ''), 'Hymnshift applies on its own recorded date');
ok(!hymnmerge('Fixture Derived', 9, 5, 2023, ''), 'Hymnmerge does not apply when hymnshift does instead');

done_testing;
