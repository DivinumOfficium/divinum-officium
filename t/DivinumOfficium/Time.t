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


# Make sure that the date_to_days wrapper around the DivinumOfficium::Time
# functions behaves in the same way as the old implementation.

print "# date_to_days. Months are zero-based here.\n";

require 'horas/horascommon.pl';

# Original implementation of date_to_days().
sub old_date_to_days {
  my ($d, $m, $y) = @_;

  my $yc = floor($y / 100);
  my $c =20;
  my $ret = 10957;
  my $add;
  if ($y < 2000) {
    while ($c > $yc) {$c--; $add = (($c % 4) == 0) ? 36525 : 36524; $ret -= $add;}
 } else {
   while ($c < $yc) {$add = (($c % 4) == 0) ? 36525 : 36524; $ret += $add; $c++;}
 }
 $add = 4 * 365;
 if (($yc % 4) == 0) {$add += 1;}
 $yc *= 100;

 while ($yc < ($y - ($y % 4))) {$ret += $add; $add = 4 * 365 + 1; $yc += 4;}
 $add = 366;
 if (($yc % 100) == 0 && ($yc % 400) > 0) {$add = 365;}
 while ($yc < $y) {$ret += $add; $add = 365; $yc++;}

 my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
 if (($y % 4) == 0) {$months[1] = 29;} else {$months[1] = 28;}
 if (($y % 100) == 0 && ($y % 400) > 0) {$months[1] = 28;}
 $c = 0;
 while ($c < $m) {$ret += $months[$c]; $c++;}
 $ret += ($d -1);
 if ($ret < -141427) { error("Date before the Gregorian Calendar!");}
 return $ret
}


# Check some dates. The old implementation doesn't support Julian dates.
foreach my $date_ref (
  # [$day, $month - 1, $year]
  [15, 10 - 1, 1582],
  [29, 2 - 1, 1600],
  [1, 3 - 1, 1600],
  [1, 3 - 1, 1700],
  [31, 12 - 1, 2000],
)
{
  is(date_to_days(@$date_ref), old_date_to_days(@$date_ref), "dtd(@$date_ref)");
}

done_testing();


