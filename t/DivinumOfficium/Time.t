use strict;
use warnings;

use DivinumOfficium::Time qw(julian_ordinal_date gregorian_ordinal_date);

use Test::More;

print "# Ordinal dates\n";

is(julian_ordinal_date(1, 1, 1),    1, '1-1-1 maps to 1');
is(gregorian_ordinal_date(1, 1, 1), 1, 'Gregorian request for 1-1-1');

is(julian_ordinal_date(1, 1, 2), 366, '1-1-2');

is(julian_ordinal_date(3, 1, 100), gregorian_ordinal_date(3, 1, 100),
  '3-1-100: Julian and Gregorian dates equal');

is(julian_ordinal_date(10, 4, 1582), gregorian_ordinal_date(10, 4, 1582),
  'Julian 10-4-1582 == Gregorian 10-4-1582');

is(julian_ordinal_date(10, 5, 1582), gregorian_ordinal_date(10, 15, 1582),
  'Julian 10-5-1582 == Gregorian 10-15-1582');

sub is_leap_year
{
  my ($func, $year) = @_;
  return $func->(3, 1, $year) - $func->(2, 28, $year) == 2;
}

ok(is_leap_year(\&julian_ordinal_date, 1600),    '1600 is Julian leap year');
ok(is_leap_year(\&gregorian_ordinal_date, 1600), '1600 is Gregorian leap year');
ok(is_leap_year(\&julian_ordinal_date, 1700),    '1700 is Julian leap year');
ok(!is_leap_year(\&gregorian_ordinal_date, 1700),
  '1700 is not Gregorian leap year');

is(julian_ordinal_date(12, 31, 2000), 365 * 1500 + 366 * 500,
  'Julian day-count at the end of 2000');
# 13 is the effective number of non-leap-year-centuries: there were 15 which
# were not 0 mod 400, minus two extra corrective leap days.
is(gregorian_ordinal_date(12, 31, 2000), 365 * (1500 + 13) + 366 * (500 - 13),
  'Gregorian day-count at the end of 2000');

done_testing();


