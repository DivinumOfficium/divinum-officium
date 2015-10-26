package DivinumOfficium::Time;

use strict;
use warnings;

use Carp;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(julian_ordinal_date gregorian_ordinal_date ordinal_date
    sunday_a_year_ago_mdy get_easter_mdy get_easter_ordinal
    sundays_after_pentecost sundays_after_epiphany leap_year days_in_month);
}



#*** julian_ordinal_date($month, $day, $year)
#*** gregorian_ordinal_date($month, $day, $year)
# Returns an ordinal number representing the day $month-$day-$year, where day
# 1 is 1-1-1 and subsequent days are numbered sequentially.
{
  # For efficient calculation, we define a pseudo-year to be a cycle of 64
  # pseudo-months that maps onto the 48-month Julian cycle. Pseudo-months
  # 12--15 (mod 16) have zero days. We build an array of day-offsets for the
  # beginning of each of these pseudo-months.
  my @pseudo_month_days =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 0, 0, 0, 0) x 4;
  $pseudo_month_days[16 * 3 + 1]++;  # 29 February.
  my $sum;
  # Offset of each month within the cycle.
  my @pseudo_month_offsets = map { $sum += $_ } @pseudo_month_days;
  unshift @pseudo_month_offsets, 0;
  my $pseudo_year_days = pop @pseudo_month_offsets;

  sub julian_ordinal_date
  {
    my ($month, $day, $year) = @_;
    $year--;
    $month--;
    # But we leave $day alone, because the ordinal is 1-based.

    my $pseudo_year = $year >> 2;
    my $pseudo_month = (($year & 3) << 4) + $month;
    return $pseudo_year * $pseudo_year_days +
      $pseudo_month_offsets[$pseudo_month] + $day;
  }

  # We take the first day of the Gregorian calendar, more Romano, to be
  # 15 October 1582.
  my $first_gregorian_day = julian_ordinal_date(10, 15, 1582);
  
  sub gregorian_ordinal_date
  {
    my ($month, $day, $year) = @_;

    # Find the Julian ordinal first.
    my $ordinal = julian_ordinal_date($month, $day, $year);

    # Apply Gregorian correction. There is a block of dates between the end of
    # the Julian calendar and the beginning of the Gregorian that are
    # undefined, but the simplest thing to do is to treat them as Julian days.
    if ($ordinal >= $first_gregorian_day)
    {
      # We want integer division in order to count centuries.
      use integer;

      # We're looking for overcounted leap days, and we can only have one of
      # those in this year if we're at least in March.
      my $effective_year = ($month >= 3) ? $year : $year - 1;

      # We overcount a leap day each year that is zero modulo 100 but nonzero
      # modulo 400. So by inclusion--exclusion...
      my $overcounted_leap_days = $effective_year / 100 - $effective_year / 400;

      # As well as adjusting for leap days, there is a fixed two-day offset
      # with respect to the beginning of the Julian calendar.
      $ordinal -= $overcounted_leap_days - 2;
    }

    return $ordinal;
  }

  # Wrapper to make it easy to select Gregorian or Julian date automatically
  # at some point in the future.
  sub ordinal_date { &gregorian_ordinal_date }
}

sub julian_leap_year
{
  my $year = shift;
  return !($year & 3);
}

sub gregorian_leap_year
{
  my $year = shift;
  return 0 if (!julian_leap_year($year));
  return 1 if ($year % 400 == 0);
  return 0 if ($year % 100 == 0);
  return 1;
}

sub leap_year { &gregorian_leap_year }

sub year_ago_mdy
{
  my @date_mdy = @_;
  $date_mdy[2]--;
  $date_mdy[1]-- if($date_mdy[0] == 2 && $date_mdy[1] == 29);
  return @date_mdy;
}


sub dates_mdy_equal
{
  my ($a_ref, $b_ref) = @_;
  return
    $a_ref->[0] == $b_ref->[0] &&
    $a_ref->[1] == $b_ref->[1] &&
    $a_ref->[2] == $b_ref->[2];
}


# Given an extended date in which we allow out-of-range days and months to be
# interpreted in the natural way, return an equivalent date expressed in the
# more conventional form.
sub canonicalise_date_mdy
{
  my ($month, $day, $year) = @_;

  do
  {
    while ($month > 12)
    {
      $month -= 12;
      $year++;
    }

    while ($day > days_in_month($month, $year) && $month <= 12) {
      $day -= days_in_month($month, $year);
      $month++;
    }
  } while ($month > 12);

  do
  {
    while ($month < 1)
    {
      $month += 12;
      $year--;
    }

    while ($day < 1 && $month > 0)
    {
      my $prev_month = $month - 1;
      $prev_month = 12 if ($month == 0);
      $day += days_in_month($prev_month, $year);
      $month--;
    }
  } while ($month < 1);

  return ($month, $day, $year);
}


# Return the day of the week corresponding to an ordinal date.  This is
# independent of Gregorian/Julian-ness.
sub day_of_week_ordinal
{
  # 1-1-1 was a Friday, apparently.
  my $first_jan_year_one = 5;
  return (shift() + $first_jan_year_one) % 7;
}


# Go back a year less one day, and then keep going back until we land on a
# Sunday.
sub sunday_a_year_ago_mdy
{
  my ($month, $day, $year) = year_ago_mdy(@_);
  my $year_ago_less_one_day = ordinal_date($month, $day, $year) + 1;
  return canonicalise_date_mdy(
    $month,
    $day + 1 - day_of_week_ordinal($year_ago_less_one_day),
    $year);
}


sub sundays_after_pentecost
{
  use integer;

  my $year = shift;
  my $christmas_eve = ordinal_date(12, 24, $year);
  my $advent4 = $christmas_eve - day_of_week_ordinal($christmas_eve);
  my $easter = get_easter_ordinal($year);

  # $advent4 - $easter counts the days from Easter Sunday inclusive to the
  # fourth Sunday of Advent exclusive.  From these we want to subtract the
  # eight Sundays of Paschaltide and the three of Advent that were counted.
  my $overcounted_sundays = 8 + 3;

  confess if($advent4 < $easter);
  confess if($advent4 - $easter > (28 + $overcounted_sundays) * 7);

  return ($advent4 - $easter) / 7 - $overcounted_sundays;
}


sub sundays_after_epiphany
{
  use integer;

  my $year = shift;
  my $epi_octave = ordinal_date(1, 13, $year);
  my $epi1 = $epi_octave - day_of_week_ordinal($epi_octave);
  my $septuagesima = get_easter_ordinal($year) - 9 * 7;

  confess if($septuagesima < $epi1);
  confess if($septuagesima - $epi1 > 6 * 7);

  return ($septuagesima - $epi1) / 7;
}


sub get_easter_mdy
{
  use integer;

  my $year = shift;

  my $c = $year / 100;
  my $n = $year - 19 * ($year / 19);
  my $k = ($c - 17) / 25;
  my $i = $c - ($c / 4) - (($c - $k) / 3) + 19 * $n + 15;
  $i = $i - 30 * ($i / 30);
  $i = $i - ($i / 28) * (1 - ($i / 28) * (29 / ($i + 1))) * ((21 - $n) / 11);
  my $j = $year + ($year / 4) + $i + 2 - $c + ($c / 4);
  $j = $j - 7 * ($j / 7);
  my $l = $i - $j;
  my $m = 3 + (($l + 40) / 44);
  my $d = $l + 28 - 31 * ($m / 4);
  return ($m, $d, $year);
}


sub get_easter_ordinal
{
  return ordinal_date(get_easter_mdy(shift));
}


sub days_in_month
{
  my ($month, $year) = @_;
  return 29 if($month == 2 && leap_year($year));
  return (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$month - 1];
}


1;

