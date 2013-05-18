package horas::calendar;

use strict;
use warnings;

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
      # IV. cl. ferias are never commemorated.
      ($$a{category} == FERIAL_OFFICE && $$a{rankord} == 4) ||

      # Non-privileged commemorations are omitted on Sundays and first-class days.
      (($$b{rankord} == 1 || $$b{category} == SUNDAY_OFFICE) && !$privileged));

    return $sign * COMMEMORATE_LOSER;
  }

  # In the case of equal ranks:

  # Make sure that Office A is a feast if we have any feasts.
  ($a, $b, $sign) = ($b, $a, -1) if($$b{category} == FESTAL_OFFICE);
  
  if($$b{rankord} == 1)
  {
    # I. cl. feasts yield to first-class non-feasts
    # (including days in octaves), and are translated.
    return $sign * TRANSLATE_LOSER if($$b{category} != FESTAL_OFFICE);

    # If two I. cl. feasts occur, a universal feast is
    # preferred to a particular one.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == UNIVERSAL_OFFICE);
    return $sign * TRANSLATE_LOSER if($$a{partic} == PARTICULAR_OFFICE && $$b{partic} == UNIVERSAL_OFFICE);
    
    # Otherwise, the feast of greater dignity wins. For now, we
    # guess!
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

  # In the case of parity, or of an invalid combination, indicate that
  # Office A wins. This is intended to reflect the order of feasts in the
  # calendar lists, where higher-ranking feasts come first.
  return -$sign * COMMEMORATE_LOSER;
}


# cmp_occurrence($a, $b)
# Determines which of two offices should win in occurrence, and also what
# should be done to the loser. $a and $b are references to the calentry hashes
# for the offices. Returns a symbolic constant indicating what to do to the
# loser, which is positive if $b wins and negative if $a wins.
sub cmp_occurrence
{
  return cmp_occurrence_1960(@_) if($::version =~ /1960/);

  my ($a, $b) = @_;

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

    return $sign * TRANSLATE_LOSER if($$b{rankord} == 1 && $$a{rankord} == 2);

    return $sign * OMIT_LOSER if(
      # Simple feasts and octave days are omitted on I. cl. doubles.
      ($$b{rankord} == 1 && $$b{rite} >= DOUBLE_RITE && $$a{rite} == SIMPLE_RITE && grep($$a{category} == $_, (FESTAL_OFFICE, OCTAVE_DAY_OFFICE))) ||
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

  # If we're still tied, choose the feast of greater dignity.
  my $dignity = dignity($b) <=> dignity($a);
  return $sign * ($dignity || -1) * (($$b{rankord} >= 2) ? TRANSLATE_LOSER : COMMEMORATE_LOSER);
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
    return -(OMIT_LOSER) if(
      $$preceding{rite} == DOUBLE_RITE &&
      $$preceding{rankord} <= 2 &&
      $following_rank >= concurrence_rank({category => WITHIN_OCTAVE_OFFICE, octrank => COMMON_OCTAVE}));

    return -(COMMEMORATE_LOSER);
  }
  elsif($following_rank < $preceding_rank)
  {
    # Office of following.

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

  # Both days are in the same concurrence category. Office of the day of
  # greater dignity; or, in parity, from the chapter of the following.
  my $sign = dignity($following) - dignity($preceding);
  return $sign ? $sign * COMMEMORATE_LOSER : FROM_THE_CHAPTER;
}


sub days_in_month
{
  my ($month, $year) = @_;
  return 29 if($month == 2 && ::leapyear($year));
  return (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$month - 1];
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
    local $::day = $date_mdy[0];
    local $::month = $date_mdy[1];
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
  push @calpoints, "$month_prefix$days[$day_of_week]-Ult" if($day_of_week == 0 && days_in_month($date_mdy[1]) - $date_mdy[1] < 7);

  # Temporal cycle, except for Christmas-Epiphany.
  push @calpoints, "$week-$day_of_week" if($week);

  return @calpoints;
}


sub resolve_occurrence
{
  my ($calendar_ref, $date) = @_;

  # Get all calpoints falling on this date and expand them to the lists of
  # offices assigned thereto. This also gets any implicit offices.
  my @office_lists = map {[get_all_offices($calendar_ref, $_)]} generate_calpoints($date);

  # Combine and sort the lists of offices. Really the sorting is doing two
  # tasks: it finds the winning office, and it also sorts the commemorations.
  # TODO: Formally speaking these are governed by two different sets of rules,
  # so this might need adjusted.
  my @sorted_offices = sort {cmp_occurrence($a, $b)} map {@$_} @office_lists;

  # Remove any offices that should be translated or omitted in occurrence with
  # the winner.
  my $winner = shift @sorted_offices;
  return
    $winner,
    grep
    {
      my $loser_rule = cmp_occurrence($_, $winner);
      $loser_rule != OMIT_LOSER && $loser_rule != TRANSLATE_LOSER;
    }
    @sorted_offices;
}

1;

