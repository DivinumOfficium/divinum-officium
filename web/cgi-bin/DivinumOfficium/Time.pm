package DivinumOfficium::Time;

use strict;
use warnings;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(julian_ordinal_date gregorian_ordinal_date);
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
}

1;

