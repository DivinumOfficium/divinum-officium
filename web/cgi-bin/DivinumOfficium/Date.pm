package DivinumOfficium::Date;

use strict;
use warnings;
use POSIX qw/floor/;

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(getweek leapyear geteaster get_sday nextday day_of_week monthday prevnext ydays_to_date);
}

use FindBin qw($Bin);

#*** getweek($flag)
# returns $week string list using date1 = mm-dd-yyy string as parameter
# next day if $flag
sub getweek {
  my ($day, $month, $year, $tomorrow, $missa) = @_;

  my $t= date_to_ydays($day, $month, $year);
  $t++ if $tomorrow;
  my $n;

  my $advent1 = getadvent($year);
	my $christmas = date_to_ydays(25, 12, $year);
	my $tDay = $tomorrow ? $day+1 : $day;
	
  #Advent in december
  if ($t >= $advent1) {
    if ($t < $christmas) {
      $n = 1 + floor(($t - $advent1) / 7);
      if ($month == 11 || $day < 25) { return "Adv$n"; }
    }
    return "Nat$tDay";
  }

  if ($month == 1 && $day < (7-$tomorrow)) {
    return '';
  }
  my $ordtime = 6 + 7 - day_of_week(6, 1, $year);
  my $easter = date_to_ydays(geteaster($year));

  if ($t < $easter - 63) {
    $n = floor(($t - $ordtime) / 7) + 1;
    return "Epi$n";
  }
  if ($t < $easter - 56) { return "Quadp1"; }
  if ($t < $easter - 49) { return "Quadp2"; }
  if ($t < $easter - 42) { return "Quadp3"; }

  if ($t < $easter) {
    $n = 1 + floor(($t - ($easter - 42)) / 7);
    return "Quad$n";
  }

  if ($t < ($easter + 56)) {
    $n = floor(($t - $easter) / 7);
    return "Pasc$n";
  }
  $n = floor(($t - ($easter + 49)) / 7);
  if ($n < 23) { return sprintf("Pent%02i", $n); }
  my $wdist = floor(($advent1 - $t + 6) / 7);
  if ($wdist < 2) { return "Pent24"; }
  if ($n == 23) { return "Pent23"; }

  if ($missa) {
    return sprintf("PentEpi%1i", 8 - $wdist);
  } else {
    return sprintf("Epi%1i", 8 - $wdist);
  }
}

#*** getadvent($year)
# return time for the first sunday of advent in the given year
sub getadvent {
  my $year = shift;
  my @christmas = (25, 12, $year);
  my $christmas = date_to_ydays(@christmas);
  my $christmas_dow = day_of_week(@christmas) || 7;
  return $christmas - $christmas_dow - 21;         #1st Sunday of Advent
}

#*** geteaster(year)
# returns easter date (dd,mm,yyyy);
# code source CPAN module Date::Easter 1.22
sub geteaster {
  my ($year) = @_;
  my ( $G, $C, $H, $I, $J, $L, $month, $day, );
  $G = $year % 19;
  $C = int( $year / 100 );
  $H = ( $C - int( $C / 4 ) - int( ( 8 * $C + 13 ) / 25 ) + 19 * $G + 15 ) % 30;
  $I = $H - int( $H / 28 ) *
    ( 1 - int( $H / 28 ) * int( 29 / ( $H + 1 ) ) * int( ( 21 - $G ) / 11 ) );
  $J     = ( $year + int( $year / 4 ) + $I + 2 - $C + int( $C / 4 ) ) % 7;
  $L     = $I - $J;
  $month = 3 + int( ( $L + 40 ) / 44 );
  $day   = $L + 28 - ( 31 * int( $month / 4 ) );
  return ( $day, $month, $year );
}

#*** leapyear($year)
# returns true if year is leap
sub leapyear {
  my $year = shift;
  !(($year % 4) or !($year % 100) and ($year % 400))
}

#*** day_of_week($day, $month, $year)
# day of week
sub day_of_week {
  my($day, $month, $year) = @_;

  ($year*365 + int(($year-1) / 4) - int(($year-1) / 100) + int(($year-1) / 400) - 1 + date_to_ydays(@_)) % 7
}

###* ydays_to_date($days, $year)
# date for day number in year
sub ydays_to_date {
  my($days, $year) = @_;

  my @months = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  if (leapyear($year)) { $months[2]++ }

  my $month = 1;
  my $day =$days;

  while ($day > $months[$month] && $month < 13) {
      $day -= $months[$month];
      $month++;
  }

  ($day, $month, $year)
}
my @MONTHSUP = (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);

# day number in year
sub date_to_ydays {
  my($day, $month, $year) = @_;

  $MONTHSUP[$month-1] + $day + ($month > 2) * leapyear($year)
}

#*** next day for vespera
# input month, day, year
# returns the name for saint folder
sub nextday {
  my $month = shift;
  my $day = shift;
  my $year = shift;
  my $time = date_to_ydays($day, $month, $year) + 1;
  if ($time > 365 && (!leapyear($year) || $time == 367)) {
    get_sday(1, 1, $year + 1)
  } else {
    my @d = ydays_to_date($time, $year);
    get_sday($d[1], $d[0], $d[2])
  }
}

#*** monthday($day, $month, $year, $version, $tomorrow)
# returns an empty string or mmn-d format
# e.g. 081-1 for monday after the firs Sunday of August
sub monthday {
  my ($day, $month, $year, $modernstyle, $tomorrow) = @_;
  return '' if $month < 7;

  my $leapyear = leapyear $year;
  my $day_of_year = date_to_ydays($day, $month, $year);
  $day_of_year++ if $tomorrow;

  my $lit_month = 0;
  my @first_sunday_day_of_year = ();
  for (8..12) { # fill above table from Aug to Dec, find lit(urgial)_month
    my $first_of_month = $MONTHSUP[$_ - 1] + 1 + $leapyear;
    my $dofweek = day_of_week(1, $_, $year);
    push @first_sunday_day_of_year, $first_of_month - $dofweek;
    $first_sunday_day_of_year[$#first_sunday_day_of_year] += 7
      if $dofweek >= 4 || ($dofweek and $modernstyle);
    if ($day_of_year >= $first_sunday_day_of_year[$#first_sunday_day_of_year]) {
      $lit_month = $_
    } else {
      last
    }
  }
  return '' unless $lit_month;

  my $advent;
  if ($lit_month > 10) {
    $advent = getadvent($year);
    return '' if $day_of_year >= $advent;
  }

  my $week = int(($day_of_year - $first_sunday_day_of_year[$lit_month - 8]) / 7);

  # Special handling for October with the 1960 rubrics: the III. week vanishes
  # in years when its Sunday would otherwise fall on the 18th-21st (i.e. when
  # the first Sunday in October falls on 4th-7th).
  $week++ if $lit_month == 10 && $modernstyle && $week >= 2
             && (ydays_to_date($first_sunday_day_of_year[10 - 8], $year))[0] >= 4;

  # Special handling for November: the II. week vanishes most years (and always
  # with the 1960 rubrics). Achieve this by counting backwards from Advent.
  if ($lit_month == 11 && ($week > 0 || $modernstyle)) {
    $week = 4 - floor(($advent - $day_of_year - 1) / 7);
    $week = 0 if $modernstyle && $week == 1;
  }

  my $day_of_week = day_of_week($day, $month, $year);
  $day_of_week = ($day_of_week + 1) % 7 if $tomorrow;

  sprintf('%02i%01i-%01i', $lit_month, $week + 1, $day_of_week);
}

#*** get_sday($month, $day, $year)
# get a name (mm-dd) for sancti folder
sub get_sday {
  my $month = shift;
  my $day = shift;
  my $year = shift;

  # The leap day is kept on 24 Feb, and is numbered internally as 29 Feb.
  # Subsequent days in the calendar for the month are deferred by one day, so
  # that offices ordinarily assigned to 24 Feb are kept on 25 Feb, and so on.
  if (leapyear($year) && $month == 2) {
    if ($day == 24) {
      $day = 29;
    }
    elsif ($day > 24) {
      $day -= 1;
    }
  }

  sprintf("%02i-%02i", $month, $day);
}

sub prevnext {
  my $date1 = shift;
  my $inc = shift;
  $date1 =~ s/\//\-/g;
  my ($month, $day, $year) = split('-', $date1);
  my $d = date_to_ydays($day, $month, $year) + $inc;
  ($day, $month, $year) = $d > 365 && (!leapyear($year) || $d == 367) ? (1, 1, $year + 1)
                          : $d ? ydays_to_date($d, $year) : (31, 12, $year - 1);
  sprintf("%02i-%02i-%04i", $month, $day, $year)
}

1;
