package horas::calendar;

use strict;
use warnings;

use List::Util qw(first);

use FindBin qw($Bin);
use lib "$Bin/..";

use horas::caldef;
use horas::caldata qw(get_all_offices);

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(resolve_occurrence resolve_concurrence);
}


# dignity($office)
# Returns some (rather ill-defined) measure of the dignity of an office for
# tie-breaking purposes. Higher is better.
sub dignity($)
{
  my $office = shift;

  my $dignity = 1000;

  return $dignity if($$office{tags} =~ /Festum Domini/);
  $dignity--;

  # TODO: Fill this out. See General Rubrics XI.2.

  return $dignity;
}


# cmp_occurrence_1960($a, $b)
# A 1960 version of cmp_occurrence.
sub cmp_occurrence_1960
{
  my ($a, $b) = @_;

  # Assume that $b wins until we find otherwise. We multiply the return value by
  # +/- 1 according to the winning office.
  my $sign = 1;

  # Higher-ranked days always win.
  ($a, $b, $sign) = ($b, $a, -1) if($$a{rankord} < $$b{rankord});
  if($$b{rankord} < $$a{rankord})
  {
    my $privileged =
      $$a{category} == SUNDAY_OFFICE ||
      ($$a{category} == FERIAL_OFFICE && $$a{rankord} <= 3);

    return $sign * OMIT_LOSER if(
      # IV. cl. ferias are never commemorated, and neither is any feria on a
      # I. cl. vigil.
      (
        $$a{category} == FERIAL_OFFICE &&
        (
          $$a{rankord} == 4 ||
          ($$b{category} == VIGIL_OFFICE && $$b{rankord} == 1)
        )
      ) ||

      # Non-privileged commemorations are omitted on Sundays and first-class days.
      (($$b{rankord} == 1 || $$b{category} == SUNDAY_OFFICE) && !$privileged));

    return $sign * COMMEMORATE_LOSER;
  }

  # In the case of equal ranks:

  # Make sure that Office A is a feast if we have any feasts.
  ($a, $b, $sign) = ($b, $a, -1) if($$b{category} == FESTAL_OFFICE);
  
  if($$b{rankord} == 1)
  {
    # Certain I. cl. days beat I. cl. Sundays.
    ($a, $b, $sign) = ($b, $a, -$sign) if(exists($$a{'praefertur dominicis'}) && $$b{category} == SUNDAY_OFFICE);
    if(exists($$b{'praefertur dominicis'}) && $$a{category} == SUNDAY_OFFICE)
    {
      return $sign * ($$b{category} == VIGIL_OFFICE ? OMIT_LOSER : COMMEMORATE_LOSER);
    }

    # I. cl. feasts yield to first-class non-feasts
    # (including days in octaves), and are translated.
    return $sign * TRANSLATE_LOSER if($$b{category} != FESTAL_OFFICE);

    # If two I. cl. feasts occur, a universal feast is
    # preferred to a particular one.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == UNIVERSAL_OFFICE);
    return $sign * TRANSLATE_LOSER if($$a{partic} == PARTICULAR_OFFICE && $$b{partic} == UNIVERSAL_OFFICE);
    
    # Otherwise, the feast of greater dignity wins.
    my $dignity = dignity($b) <=> dignity($a);
    return $sign * ($dignity || -1) * TRANSLATE_LOSER;
  }
  elsif($$b{rankord} == 2)
  {
    if($$a{category} == FESTAL_OFFICE)
    {
      # II. cl. feast beats day in II. cl. octave and
      # II. cl. vigil.
      return -$sign * COMMEMORATE_LOSER if(grep($$b{category} == $_, (WITHIN_OCTAVE_OFFICE, VIGIL_OFFICE)));

      if($$b{category} == FERIAL_OFFICE)
      {
        # II. cl. feast beats II. cl feria iff
        # feast is universal.
        $sign = -$sign if($$a{partic} == UNIVERSAL_OFFICE);
        return $sign * COMMEMORATE_LOSER;
      }

      return $sign * COMMEMORATE_LOSER if($$b{category} == SUNDAY_OFFICE);

      # Two II. cl. feasts. Universal beats particular.
      ($a, $b, $sign) = ($b, $a, -$sign) if($$b{partic} == PARTICULAR_OFFICE);
      return $sign * COMMEMORATE_LOSER if($$b{partic} == UNIVERSAL_OFFICE);
      
      # Two particular II. cl. feasts. Movable beats fixed.
      ($a, $b, $sign) = ($b, $a, -$sign) if($$b{calpoint} =~ /^\d\d-\d\d$/);
      return $sign * COMMEMORATE_LOSER;

    }
    else
    {
      # No feasts. This should happen only when a II.
      # cl. Sunday and vigil occur.
      ($a, $b, $sign) = ($b, $a, -$sign) if($$a{category} == SUNDAY_OFFICE);
      return $sign * OMIT_LOSER if ($$a{category} == VIGIL_OFFICE && $$b{category} == SUNDAY_OFFICE);

      warn 'cmp_occurrence_1960: Unexpected II. cl. occurrence.';
    }
  }
  elsif($$b{rankord} == 3)
  {
    # Office A should always be a feast at this point.
    
    return -$sign * COMMEMORATE_LOSER if($$b{category} == VIGIL_OFFICE);

    # III. cl. feasts beat Advent ferias but yield to
    # Lenten ones.
    return ($$b{calpoint} =~ /Quad/i ? $sign : -$sign) * COMMEMORATE_LOSER if($$a{category} == FERIAL_OFFICE);

    # III. cl. particular feast beats III. cl. universal
    # feast, in contrast to the II. cl. case.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == PARTICULAR_OFFICE);
    return $sign * COMMEMORATE_LOSER if($$a{partic} == UNIVERSAL_OFFICE);

    # Movable particular feast beats fixed.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$b{calpoint} =~ /^\d\d-\d\d$/);
    return $sign * COMMEMORATE_LOSER;
  }
  else
  {
    # IV. cl., which means commemorations and lesser ferias.
    return $sign * COMMEMORATE_LOSER if($$b{category} == FERIAL_OFFICE);
  }

  # In an invalid occurrence (1960 has no dignity tie-breaker).
  return 0;
}


# cmp_occurrence($a, $b)
# Determines which of two offices should win in occurrence, and also what
# should be done to the loser. $a and $b are references to the calentry hashes
# for the offices. Returns a symbolic constant indicating what to do to the
# loser, which is positive if $b wins and negative if $a wins.
sub cmp_occurrence
{
  my ($a, $b) = @_;

  # Apply office-specific rules.
  return -$a->{occurrencetable}{$b->{id}}
    if(exists($a->{occurrencetable}) && exists($a->{occurrencetable}{$b->{id}}));
  return $b->{occurrencetable}{$a->{id}}
    if(exists($b->{occurrencetable}) && exists($b->{occurrencetable}{$a->{id}}));

  return cmp_occurrence_1960($a, $b) if($::version =~ /1960/);

  # Lesser ferias are always omitted in occurrence.
  return  OMIT_LOSER   if($$a{category} == FERIAL_OFFICE && $$a{standing} == LESSER_DAY);
  return -(OMIT_LOSER) if($$b{category} == FERIAL_OFFICE && $$b{standing} == LESSER_DAY);

  # Assume that $b wins until we find otherwise. We multiply the return value by
  # +/- 1 according to the winning office.
  my $sign = 1;

  # Higher-ranked days always win.
  ($a, $b, $sign) = ($b, $a, -$sign) if($$a{rankord} < $$b{rankord});
  if($$b{rankord} < $$a{rankord})
  {
    # TODO: Vigils vs. Sundays.

    return $sign * TRANSLATE_LOSER if($$b{rankord} == 1 && $$a{rankord} == 2 && $$a{category} != SUNDAY_OFFICE);

    return $sign * OMIT_LOSER if(
      # Simple feasts and octave days are omitted on I. cl. doubles.
      ($$b{rankord} == 1 && $$b{rite} >= DOUBLE_RITE && $$a{rite} == SIMPLE_RITE && grep($$a{category} == $_, (FESTAL_OFFICE, OCTAVE_DAY_OFFICE))) ||
      # Even greater ferias are omitted on I. cl. vigils.
      ($$a{category} == FERIAL_OFFICE && $$b{category} == VIGIL_OFFICE && $$b{rankord} == 1) ||
      # Vigils are omitted on greater ferias and days that are
      # genuinely of the first class.
      ($$a{category} == VIGIL_OFFICE && (($$b{rankord} == 1 && $$b{category} != OCTAVE_DAY_OFFICE) || ($$b{category} == FERIAL_OFFICE && $$b{rankord} >= 3))) ||
      # Days within common octaves are omitted on doubles of
      # the I. or II. class.
      ($$a{category} == WITHIN_OCTAVE_OFFICE && $$a{octrank} == COMMON_OCTAVE && $$b{rankord} <= 2 && $$b{rite} >= DOUBLE_RITE));

    return $sign * COMMEMORATE_LOSER;
  }

  # Equal ranks.
  
  if($$b{rankord} <= 2)
  {
    # Sundays win.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{category} == SUNDAY_OFFICE);
    return $sign * TRANSLATE_LOSER if($$b{category} == SUNDAY_OFFICE);

    # At this point, at least one of the offices must be a feast,
    # which yields to all non-feasts (which must be a I. cl. vigil,
    # privileged feria or day within an octave of the appropriate
    # order).
    ($a, $b, $sign) = ($b, $a, -$sign) if($$b{category} == FESTAL_OFFICE);
    return $sign * TRANSLATE_LOSER if($$b{category} != FESTAL_OFFICE);

    # Must have two feasts now.
    my $dignity = dignity($b) <=> dignity($a);
    return $sign * ($dignity || -1) * TRANSLATE_LOSER;
  }
  else
  {
    # For the remaining possibilities, we synthesise a sub-rank:
    #   Greater-double octave day >
    #   Greater double >
    #   Double >
    #   Semi-double (feast) >
    #   (Semi-double) day in III. ord. octave >
    #   (Semi-double) day in common octave >
    #   (Simple) greater feria >
    #   (Simple) vigil >
    #   Simple octave day >
    #   TODO: [BVM on Saturday >]
    #   Simple (feast).
    sub synthsubrank
    {
      my $office = shift;
      return
        $$office{rite} == GREATER_DOUBLE_RITE ?
          $$office{category} == OCTAVE_DAY_OFFICE ? 1 : 2 :
        $$office{rite} == DOUBLE_RITE ? 3 :
        $$office{rite} == SEMIDOUBLE_RITE ?
          $$office{category} == FESTAL_OFFICE ? 4 :
          # Must be in an octave:
          $$office{octrank} == THIRD_ORDER_OCTAVE ? 5 : 6 :
        # Must be simple rite.
        $$office{category} == FERIAL_OFFICE ? 7 :
        $$office{category} == VIGIL_OFFICE ? 8 :
        $$office{category} == OCTAVE_DAY_OFFICE ? 9 :
        10;
    }

    my $a_subrank = synthsubrank($a);
    my $b_subrank = synthsubrank($b);
    ($a, $b, $a_subrank, $b_subrank, $sign) = ($b, $a, $b_subrank, $a_subrank, -$sign) if($b_subrank > $a_subrank);

    return $sign * COMMEMORATE_LOSER unless($a_subrank == $b_subrank);
  }

  # If we're still tied, choose the feast of greater dignity, or return zero if
  # they're tied even then.
  my $dignity = dignity($b) <=> dignity($a);
  return $sign * $dignity * (($$b{rankord} <= 2) ? TRANSLATE_LOSER : COMMEMORATE_LOSER);
}


# cmp_concurrence_1960($preceding, $following)
# A 1960 version of cmp_concurrence.
sub cmp_concurrence_1960
{
  my ($preceding, $following) = @_;

  # Since we have concurrence at all, the following office must be a
  # Sunday or a first-class feast. The only way the preceding office can
  # win, then, is if it's first-class or if it's a second-class feast and
  # the following is second-class (necessarily a Sunday).
  return -(COMMEMORATE_LOSER) if(
    $$preceding{rankord} == 1 ||
    ($$preceding{rankord} == 2 && $$following{rankord} == 2));

  # Now we know that the following office wins, so we need only determine
  # whether to commemorate the preceding office, which happens iff that
  # office is privileged in commemoration.
  return   COMMEMORATE_LOSER  if(
    $$following{rankord} == 1 &&
    $$preceding{category} != FESTAL_OFFICE &&
    ($$preceding{category} != FERIAL_OFFICE || $$preceding{rankord} <= 3));

  # Otherwise, office of the following, nothing of the preceding. The
  # reverse situation never happens: when a day has first Vespers, it's
  # always privileged in commemoration.
  return   OMIT_LOSER;
}


# cmp_concurrence($preceding, $following)
# In a similar spirit to cmp_occurrence, determines what should happen when the
# $preceding office concurs with $following. See cmp_occurrence for the return
# semantics, except that we can also return FROM_THE_CHAPTER when Vespers
# should be such.
sub cmp_concurrence
{
  return cmp_concurrence_1960(@_) if($::version =~ /1960/);

  sub concurrence_rank
  {
    my $office = shift;
    return
      $$office{category} == FESTAL_OFFICE && $$office{rankord} <= 2 ?
        $$office{rankord} :
      $$office{category} == SUNDAY_OFFICE ?
        3 :
      $$office{category} == OCTAVE_DAY_OFFICE ?
        ($$office{octrank} <= THIRD_ORDER_OCTAVE ? 4 : 5) :
      $$office{rite} == GREATER_DOUBLE_RITE ?
        6 :
      $$office{rite} == DOUBLE_RITE ?
        7 :
      $$office{rite} == SEMIDOUBLE_RITE ?
        8 :
      $$office{category} == WITHIN_OCTAVE_OFFICE ?
        ($$office{octrank} <= THIRD_ORDER_OCTAVE ? 9 : 10) :
      $$office{category} == FERIAL_OFFICE && $$office{standing} >= GREATER_DAY ?
        11 :
        12;
  }


  my ($preceding, $following) = @_;
  my $preceding_rank = concurrence_rank($preceding);
  my $following_rank = concurrence_rank($following);

  if($preceding_rank < $following_rank)
  {
    # Office of preceding. What to do with the following?

    # Omit low-ranking days at first vespers of high-ranking doubles.
    return -(OMIT_LOSER) if(
      $$preceding{rite} == DOUBLE_RITE &&
      $$preceding{rankord} <= 2 &&
      $following_rank >= concurrence_rank({category => WITHIN_OCTAVE_OFFICE, octrank => COMMON_OCTAVE}));

    # Don't commemorate first vespers of the second day in the octave in second
    # vespers of the feast itself.
    return -(OMIT_LOSER) if(
      $$following{category} == WITHIN_OCTAVE_OFFICE &&
      $$following{octid} eq $$preceding{octid});

    return -(COMMEMORATE_LOSER);
  }
  elsif($following_rank < $preceding_rank)
  {
    # Office of following.

    # Don't commemorate II. vespers of seventh day in the octave at first
    # vespers of the octave day. Notice that, since the following office beat
    # the preceding, we can't have concurrence of two days in the octave here.
    return OMIT_LOSER if(
      $$preceding{category} == WITHIN_OCTAVE_OFFICE && $$preceding{octid} eq $$following{octid});

    # Check for some days that are low-ranking in concurrence but
    # nonetheless are always commemorated when they lose.
    return COMMEMORATE_LOSER if(
      ($$preceding{category} == FERIAL_OFFICE && $$preceding{standing} == GREATER_DAY) ||
      ($$preceding{category} == WITHIN_OCTAVE_OFFICE && $$preceding{rankord} <= THIRD_ORDER_OCTAVE));

    # Doubles of the I. or II. class cause low-ranking days to be
    # omitted in concurrence.
    if($$following{rite} == DOUBLE_RITE)
    {
      if($$following{rankord} == 2)
      {
        return OMIT_LOSER if($preceding_rank >= concurrence_rank({category => FESTAL_OFFICE, rite => SEMIDOUBLE_RITE, rankord => 3}));
      }
      elsif($$following{rankord} == 1)
      {
        return OMIT_LOSER if($preceding_rank >= concurrence_rank({category => WITHIN_OCTAVE_OFFICE, octrank => COMMON_OCTAVE}));
      }
    }

    return COMMEMORATE_LOSER;
  }

  # Both days are in the same concurrence category.

  # In concurrence of days within the same octave, second vespers take
  # precedence and first vespers of the following are omitted.
  return -(OMIT_LOSER) if(
    $$preceding{category} == WITHIN_OCTAVE_OFFICE && $$preceding{octid} eq $$following{octid});
  
  # Office of the day of greater dignity; or, in parity, from the chapter of
  # the following.
  my $sign = dignity($following) - dignity($preceding);
  return $sign ? $sign * COMMEMORATE_LOSER : FROM_THE_CHAPTER;
}


sub cmp_commemoration
{
  my ($a, $b) = @_;

  # With 1960 rubrics, commemorations of the season always come first.
  if($::version =~ /1960/)
  {
    ($a, $b) = ($b, $a) if($$a{cycle} == TEMPORAL_OFFICE);
    return 1 if($$b{cycle} == TEMPORAL_OFFICE);
  }

  return cmp_occurrence(@_);
}


sub days_in_month
{
  my ($month, $year) = @_;
  return 29 if($month == 2 && ::leapyear($year));
  return (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$month - 1];
}


sub next_date
{
  my $date = shift;
  my @date_mdy = split(/-/, $date);

  @date_mdy[1,0,2] = ::nday(@date_mdy[1,0,2]);

  return join('-', @date_mdy);
}


sub generate_calpoints
{
  use integer;

  my $date = shift;
  my @date_mdy = split(/-/, $date);
  my $week;
  my $day_of_week;

  # Find which week we're in. &::getweek uses globals, which we localise until
  # such a time as &::getweek is rewritten.
  {
    local @::date1 = @date_mdy;
    local $::month = $date_mdy[0];
    local $::day = $date_mdy[1];
    local $::year = $date_mdy[2];
    local $::dayofweek;

    $week = ::getweek(0);

    # &getweek calculated $::dayofweek, which we want to remember, but which we
    # don't want to persist globally.
    $day_of_week = $::dayofweek;
  }

  my @days = qw(Dominica FeriaII FeriaIII FeriaIV FeriaV FeriaVI Sabbato);
  my $month_prefix = sprintf('%02d-', $date_mdy[0]);

  my @calpoints = (
    # Calendar day: mm-dd.
    $month_prefix . sprintf('%02d', $date_mdy[1]),

    # nth x-day *in* the month.
    "$month_prefix$days[$day_of_week]-" . ($date_mdy[1] / 7 + 1)
  );

  # nth x-day *of* the month.
  my $reading_day = ::reading_day(@date_mdy);
  push @calpoints, $reading_day if($reading_day);

  # Last x-day.
  push @calpoints, "$month_prefix$days[$day_of_week]-Ult" if($day_of_week == 0 && days_in_month($date_mdy[0]) - $date_mdy[1] < 7);

  # Temporal cycle, except for Christmas-Epiphany.
  push @calpoints, "$week-$day_of_week" if($week);

  return @calpoints;
}


sub resolve_occurrence
{
  # When two offices are tied in dignity, preserve the order in which they were
  # specified in the calendar.
  use sort 'stable';

  my ($calendar_ref, $date) = @_;

  # Get all calpoints falling on this date and expand them to the lists of
  # offices assigned thereto. This also gets any implicit offices.
  my @office_lists = map {[get_all_offices($calendar_ref, $_)]} generate_calpoints($date);

  # Combine and sort the lists of offices. The first sort uses occurrence rank,
  # and is used to find the winning office.
  my @sorted_offices = sort {cmp_occurrence($a, $b)} map {@$_} @office_lists;

  my $winner = shift @sorted_offices;

  # Re-sort the tail using commemoration rank.
  @sorted_offices = sort {cmp_commemoration($a, $b)} @sorted_offices;

  # Remove any offices that should be translated or omitted in occurrence with
  # the winner.
  return
    $winner,
    grep
    {
      my $loser_rule = cmp_occurrence($_, $winner);
      $loser_rule != OMIT_LOSER && $loser_rule != TRANSLATE_LOSER;
    }
    @sorted_offices;
}


sub resolve_concurrence
{
  # We will require stability when sorting commemorations. See below.
  use sort 'stable';

  my ($calendar_ref, $date) = @_;
  my @preceding = resolve_occurrence($calendar_ref, $date);
  my @following = resolve_occurrence($calendar_ref, next_date($date));

  # Filter out preceding offices without second vespers and following ones
  # without first vespers.
  @preceding = grep {$_->{secondvespers}} @preceding;
  @following = grep {$_->{firstvespers}}  @following;

  # When a day within an octave is only commemorated, it loses its second
  # vespers. Accordingly, we drop such offices from the list.
  @preceding = $preceding[0], grep {$_->{category} != WITHIN_OCTAVE_OFFICE} @preceding[1..$#preceding];

  my $concurrence_resolution = cmp_concurrence($preceding[0], $following[0]);

  # Abstract out the asymmetry.
  my ($winning_arr_ref, $concurring_arr_ref, $filter_key, $comparator) =
    ($concurrence_resolution == FROM_THE_CHAPTER || $concurrence_resolution > 0) ?
      (\@following, \@preceding, 'v1filter', \&cmp_concurrence) :
      (\@preceding, \@following, 'v2filter', sub { -cmp_concurrence(reverse @_) });

  my $winner = shift @$winning_arr_ref;

  # Apply the explicit filter if we have one.
  if(exists($winner->{$filter_key}))
  {
    my %permitted_commemorations;
    @permitted_commemorations{split /,/, $winner->{$filter_key}} = ();

    foreach my $arr_ref ($winning_arr_ref, $concurring_arr_ref)
    {
      @$arr_ref = grep {exists $permitted_commemorations{$_->{id}}} @$arr_ref;
    }
  }

  # Filter the losing half for omission.
  @$concurring_arr_ref = grep {$comparator->($_, $winner) != OMIT_LOSER} @$concurring_arr_ref;

  my $concurring = shift @$concurring_arr_ref;

  
  # Put all the offices in place, except that the position of the concurring
  # office depends on the active rubrics and is handled subsequently, and that
  # the tail is yet to be sorted. We place preceding offices before the
  # following in the tail and then rely on the stability of the sorting
  # algorithm to put commemorations of I. vespers first in a tie.
  my @result = ($winner);
  my @tail = (@preceding, @following);

  if(defined($concurring))
  {
    if($::version =~ /1570/)
    {
      # In 1570, commemorations are simply sorted by rank, without affording the
      # concurring office any special treatment.
      unshift @tail, $concurring;
    }
    else
    {
      # From the late 19th century, the concurring office is always commemorated
      # first, and the remaining commemorations are sorted by rank. See Acta
      # Sanctae Sedis 27 (1894-5) p. 437-8.
      push @result, $concurring;
    }
  }

  # Divino afflatu then further specified that, should there be a tie amongst
  # the remaining commemorations, a commemoration for I. vespers is placed
  # before one for II. vespers. Since the earlier rubrics are silent in such
  # cases, we adopt this ordering for those, too.
  return [@result, sort {cmp_concurrence($a, $b)} @tail], $concurrence_resolution;
}

1;

