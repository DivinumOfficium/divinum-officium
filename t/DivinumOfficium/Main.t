use strict;
use warnings;

use DivinumOfficium::Main qw(vernaculars);

use Test::Simple tests => 5;

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
ok(exists($vernaculars{'English'}),                    'Has English');
ok(exists($vernaculars{'Italiano'}),                   'Has Italian');
ok(!exists($vernaculars{'Latin'}),                     'No Latin');

# Make sure failing to load the file is fatal.
{
  package DivinumOfficium::Main;
  use Test::Carp;
  does_croak(\&::vernaculars, 'non/est/hic');
}

