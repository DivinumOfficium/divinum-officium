use strict;
use warnings;

use DivinumOfficium::Main qw(vernaculars);

use Test::Simple tests => 5;

# We're assuming here that the test is invoked from the parent of the t/
# directory.
my @vernaculars = vernaculars('web/www/horas/');
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

