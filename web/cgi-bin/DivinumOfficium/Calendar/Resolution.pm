package DivinumOfficium::Calendar::Resolution;

use strict;
use warnings;

use List::Util qw(first min max);

use DivinumOfficium::Calendar::Definitions;
use DivinumOfficium::Calendar::Data qw(get_all_offices);
use DivinumOfficium::Common qw(
  FIRST_VESPERS_AND_COMPLINE
  SECOND_VESPERS_AND_COMPLINE
  MATINS_TO_NONE
);
use DivinumOfficium::Time qw(
  sunday_a_year_ago_mdy
  ordinal_date
  sundays_after_pentecost
  sundays_after_epiphany
  days_in_month
);

use Carp;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(
    get_day_offices
    get_evening_offices
    resolve_translation
    get_week
  );
}


# dignity($office)
# Returns some (rather ill-defined) measure of the dignity of an office for
# tie-breaking purposes. Higher is better.
sub dignity($)
{
  my $office = shift;

  my $dignity = 1000;

  # Conditions in order of decreasing dignity. Some of these are not strictly
  # necessary for the implementation, but are valid and help testing.
  # TODO: Fill this out. See General Rubrics XI.2.
  my @conditions = (
    # Feasts of the Lord.
    sub { exists($$office{tags}) && $$office{tags} =~ /Festum Domini/ },
    # Privileged octaves.
    sub { exists($$office{octrank}) &&
          $$office{octrank} <= SECOND_ORDER_OCTAVE },
    sub { exists($$office{octrank}) &&
          $$office{octrank} == THIRD_ORDER_OCTAVE },
    # Everything else.
    sub { 1 }
  );

  # Iterate over the conditions, decrementing the dignity until we get a match.
  foreach my $condition_ref (@conditions)
  {
    return $dignity if $condition_ref->();
    $dignity--;
  }

  confess(q(Shouldn't get here.));
}


# resolution($sign, $resolution)
# Helper to account for the two sort of return from the various cmp_
# subroutines. In list context we return both the the sign (i.e. which office
# wins) and the resolution (i.e. what to do with the loser; in scalar context
# we return the product of these. In the latter case we become more natural to
# use with sort(), but we lose the resolution in the case of a tie.
sub resolution
{
  return wantarray() ?
    (sign => $_[0], rule => $_[1]) :
    $_[0] * $_[1];
}


sub calpoint_is_lenten { $_[0] =~ /Quad(?!p)|Quadp3-[456]/ }

# cmp_occurrence_1960($a, $b, $version)
# A 1960 version of cmp_occurrence.
sub cmp_occurrence_1960
{
  my ($a, $b, $version) = @_;

  # Assume that $b wins until we find otherwise. We multiply the return value by
  # +/- 1 according to the winning office.
  my $sign = 1;

  # Higher-ranked days always win.
  ($a, $b, $sign) = ($b, $a, -$sign) if($$a{rankord} < $$b{rankord});
  if($$b{rankord} < $$a{rankord})
  {
    my $privileged =
      $$a{category} == SUNDAY_OFFICE ||
      ($$a{category} == FERIAL_OFFICE && $$a{rankord} <= 3);

    return resolution($sign, OMIT_LOSER) if(
      # IV. cl. ferias are never commemorated, and neither is any feria on a
      # I. cl. vigil.
      (
        $$a{category} == FERIAL_OFFICE &&
        (
          $$a{rankord} == 4 ||
          ($$b{category} == VIGIL_OFFICE && $$b{rankord} == 1)
        )
      ) ||
      # Our Lady on Saturday is omitted when it doesn't win.
      $$a{calpoint} eq BVM_SATURDAY_CALPOINT ||
      # Non-privileged commemorations are omitted on Sundays and first-class days.
      (($$b{rankord} == 1 || $$b{category} == SUNDAY_OFFICE) && !$privileged));

    return resolution($sign, COMMEMORATE_LOSER);
  }

  # In the case of equal ranks:

  # Make sure that Office A is a feast if we have any feasts.
  ($a, $b, $sign) = ($b, $a, -$sign) if($$b{category} == FESTAL_OFFICE);
  
  if($$b{rankord} == 1)
  {
    # Certain I. cl. days beat I. cl. Sundays.
    ($a, $b, $sign) = ($b, $a, -$sign) if(exists($$a{'praefertur dominicis'}) && $$b{category} == SUNDAY_OFFICE);
    if(exists($$b{'praefertur dominicis'}) && $$a{category} == SUNDAY_OFFICE)
    {
      return resolution($sign, $$b{category} == VIGIL_OFFICE ? OMIT_LOSER : COMMEMORATE_LOSER);
    }

    # I. cl. feasts yield to first-class non-feasts
    # (including days in octaves), and are translated.
    return resolution($sign, TRANSLATE_LOSER) if($$b{category} != FESTAL_OFFICE);

    # If two I. cl. feasts occur, a universal feast is
    # preferred to a particular one.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == UNIVERSAL_OFFICE);
    return resolution($sign, TRANSLATE_LOSER)
      if($$a{partic} == PARTICULAR_OFFICE && $$b{partic} == UNIVERSAL_OFFICE);
    
    # Otherwise, the feast of greater dignity wins.
    my $dignity = dignity($b) <=> dignity($a);
    return resolution($dignity || -$sign, TRANSLATE_LOSER);
  }
  elsif($$b{rankord} == 2)
  {
    if($$a{category} == FESTAL_OFFICE)
    {
      # II. cl. feast beats day in II. cl. octave and
      # II. cl. vigil.
      return resolution(-$sign, COMMEMORATE_LOSER)
        if(grep($$b{category} == $_, (WITHIN_OCTAVE_OFFICE, VIGIL_OFFICE)));

      if($$b{category} == FERIAL_OFFICE)
      {
        # II. cl. feast beats II. cl feria iff
        # feast is universal.
        $sign = -$sign if($$a{partic} == UNIVERSAL_OFFICE);
        return resolution($sign, COMMEMORATE_LOSER);
      }

      return resolution($sign, COMMEMORATE_LOSER)
        if($$b{category} == SUNDAY_OFFICE);

      # Two II. cl. feasts. Universal beats particular.
      ($a, $b, $sign) = ($b, $a, -$sign) if($$b{partic} == PARTICULAR_OFFICE);
      return resolution($sign, COMMEMORATE_LOSER)
        if($$b{partic} == UNIVERSAL_OFFICE);
      
      # Two particular II. cl. feasts. Movable beats fixed.
      ($a, $b, $sign) = ($b, $a, -$sign) if($$b{calpoint} =~ /^\d\d-\d\d$/);
      return resolution($sign, COMMEMORATE_LOSER);

    }
    else
    {
      # No feasts. This should happen only when a II.
      # cl. Sunday and vigil occur.
      ($a, $b, $sign) = ($b, $a, -$sign) if($$a{category} == SUNDAY_OFFICE);
      return resolution($sign, OMIT_LOSER)
        if ($$a{category} == VIGIL_OFFICE && $$b{category} == SUNDAY_OFFICE);

      warn 'cmp_occurrence_1960: Unexpected II. cl. occurrence.';
    }
  }
  elsif($$b{rankord} == 3)
  {
    # Office A should always be a feast at this point.
    
    return resolution(-$sign, COMMEMORATE_LOSER)
      if($$b{category} == VIGIL_OFFICE);

    # III. cl. feasts beat Advent ferias but yield to
    # Lenten ones.
    return
      resolution(
        calpoint_is_lenten($$b{calpoint}) ? $sign : -$sign,
        COMMEMORATE_LOSER)
      if($$a{category} == FERIAL_OFFICE);

    # III. cl. particular feast beats III. cl. universal
    # feast, in contrast to the II. cl. case.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == PARTICULAR_OFFICE);
    return resolution($sign, COMMEMORATE_LOSER)
      if($$a{partic} == UNIVERSAL_OFFICE);

    # Movable particular feast beats fixed.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$b{calpoint} =~ /^\d\d-\d\d$/);
    return resolution($sign, COMMEMORATE_LOSER);
  }
  else
  {
    # IV. cl., which means commemorations, lesser ferias and our Lady on
    # Saturday.

    # BVM on Saturday always wins amongst IV.-cl. offices, and takes the place
    # of the feria.
    ($a, $b, $sign) = ($b, $a, -$sign)
      if($$a{calpoint} eq BVM_SATURDAY_CALPOINT);
    return resolution($sign,
      $$a{category} == FERIAL_OFFICE ? OMIT_LOSER : COMMEMORATE_LOSER)
      if($$b{calpoint} eq BVM_SATURDAY_CALPOINT);

    # In the absence of BVM on Saturday, the feria wins.
    return resolution($sign, COMMEMORATE_LOSER)
      if($$b{category} == FERIAL_OFFICE);
  }

  # In an invalid occurrence (1960 has no dignity tie-breaker).
  return 0;
}


# cmp_occurrence($a, $b, $version)
# Determines which of two offices should win in occurrence, and also what
# should be done to the loser. $a and $b are references to the calentry hashes
# for the offices. Returns a symbolic constant indicating what to do to the
# loser, which is positive if $b wins and negative if $a wins.
sub cmp_occurrence
{
  my ($a, $b, $version) = @_;

  # Apply office-specific rules.
  return resolution(-1, $a->{occurrencetable}{$b->{id}})
    if(exists($a->{occurrencetable}) && exists($a->{occurrencetable}{$b->{id}}));
  return resolution(1, $b->{occurrencetable}{$a->{id}})
    if(exists($b->{occurrencetable}) && exists($b->{occurrencetable}{$a->{id}}));

  return cmp_occurrence_1960(@_) if($version =~ /1960/);

  # Lesser ferias are always omitted in occurrence.
  # XXX: With simple feasts and Ember Days and suchlike this becomes
  # complicated... see RG V.2.
  return resolution( 1, OMIT_LOSER)
    if($$a{category} == FERIAL_OFFICE && $$a{standing} == LESSER_DAY);
  return resolution(-1, OMIT_LOSER)
    if($$b{category} == FERIAL_OFFICE && $$b{standing} == LESSER_DAY);

  # Assume that $b wins until we find otherwise. We multiply the return value by
  # +/- 1 according to the winning office.
  my $sign = 1;

  # (Other) octaves cease in Lent and the two first-order octaves.
  sub lent_or_first_order_octave
  {
    my $office_ref = shift;
    return
      (
        $$office_ref{category} == FERIAL_OFFICE &&
        calpoint_is_lenten($$office_ref{calpoint})
      ) ||
      (
        (grep
          {$$office_ref{category} == $_}
          (WITHIN_OCTAVE_OFFICE, OCTAVE_DAY_OFFICE)) &&
        $$office_ref{octrank} == 1
      ) ||
      ($$office_ref{category} == VIGIL_OFFICE && $$office_ref{rankord} == 1);
  }

  ($a, $b, $sign) = ($b, $a, -$sign) if(lent_or_first_order_octave($a));
  return resolution($sign, OMIT_LOSER) if
    ((grep {$$a{category} == $_} (WITHIN_OCTAVE_OFFICE, OCTAVE_DAY_OFFICE)) &&
      lent_or_first_order_octave($b));

  # Having dealt with the preceding exceptions, higher-ranked days always win.
  ($a, $b, $sign) = ($b, $a, -$sign) if($$a{rankord} < $$b{rankord});
  if($$b{rankord} < $$a{rankord})
  {
    return resolution($sign, TRANSLATE_LOSER) if(
      # II.-cl. feast yielding to I.-cl. day.
      ($$b{rankord} == 1 && $$a{rankord} == 2 &&
        $$a{category} != SUNDAY_OFFICE &&
        $$a{category} != WITHIN_OCTAVE_OFFICE) ||
      # Loser marked explicitly as tranferrable.
      exists($$a{'transferri potest'})
    );

    return resolution($sign, OMIT_LOSER) if(
      # Simple feasts and octave days are omitted on I. cl. doubles.
      ($$b{rankord} == 1 && $$b{rite} >= DOUBLE_RITE &&
        $$b{category} == FESTAL_OFFICE && $$a{rite} == SIMPLE_RITE &&
        grep($$a{category} == $_,
          (FESTAL_OFFICE, OCTAVE_DAY_OFFICE))) ||
      # Furthermore, simple octave days are omitted on octave days of the
      # second order. This is labelled as an impossible occurrence in the
      # table, but we'll handle it this way anyway.
      ($$b{category} == OCTAVE_DAY_OFFICE &&
       $$b{octrank} <= SECOND_ORDER_OCTAVE &&
       $$a{category} == OCTAVE_DAY_OFFICE &&
       $$a{octrank} == SIMPLE_OCTAVE) ||
      # Even greater ferias are omitted on I. cl. vigils.
      ($$a{category} == FERIAL_OFFICE && $$b{category} == VIGIL_OFFICE
        && $$b{rankord} == 1) ||
      # Vigils are omitted on greater ferias and days that are
      # genuinely of the first class. Also, we don't handle anticipation of
      # vigils at this point, so just omit them (other than the vigil of
      # Christmas, which we identify as being of the first class) on Sundays.
      ($$a{category} == VIGIL_OFFICE &&
        (($$b{rankord} == 1 && $$b{category} != OCTAVE_DAY_OFFICE) ||
          ($$b{category} == FERIAL_OFFICE && $$b{rankord} >= 3) ||
          ($$b{category} == SUNDAY_OFFICE && $$a{rankord} > 1))) ||
      # The office of our Lady on Saturday is omitted if it doesn't win.
      $$a{calpoint} eq BVM_SATURDAY_CALPOINT ||
      # Days within common octaves are omitted on doubles of
      # the I. or II. class.
      ($$a{category} == WITHIN_OCTAVE_OFFICE && $$a{octrank} == COMMON_OCTAVE &&
        $$b{rankord} <= 2 && $$b{rite} >= DOUBLE_RITE &&
        $$b{category} == FESTAL_OFFICE));

    return resolution($sign, COMMEMORATE_LOSER);
  }

  # Equal ranks.
  
  if($$b{rankord} <= 2)
  {
    # Sundays win.
    ($a, $b, $sign) = ($b, $a, -$sign) if($$a{category} == SUNDAY_OFFICE);
    return resolution($sign, TRANSLATE_LOSER)
      if($$b{category} == SUNDAY_OFFICE);

    # At this point, at least one of the offices must be a feast,
    # which yields to all non-feasts (which must be a I. cl. vigil,
    # privileged feria or day within an octave of the appropriate
    # order).
    ($a, $b, $sign) = ($b, $a, -$sign) if($$b{category} == FESTAL_OFFICE);
    return resolution($sign, TRANSLATE_LOSER)
      if($$b{category} != FESTAL_OFFICE);

    # Must have two feasts now.
    my $dignity = dignity($a) <=> dignity($b);
    # XXX: What to do with offices of equal dignity? -$sign will at least give
    # stability.
    return resolution($dignity || -$sign, TRANSLATE_LOSER);
  }
  else
  {
    # For the remaining possibilities (i.e. a tie between III. or IV. cl.
    # days), we synthesise a sub-rank:
    #   Sunday (non-Tridentine) >
    #   Greater-double octave day >
    #   Greater double >
    #   Double >
    #   Semi-double Sunday (Tridentine 1910) >
    #   Semi-double (feast) >
    #   Semi-double Sunday (Tridentine not-1910) >
    #   (Semi-double) day in III. ord. octave >
    #   (Semi-double) day in common octave >
    #   (Simple) greater feria >
    #   (Simple) vigil >
    #   Simple octave day >
    #   BVM on Saturday >
    #   Simple (feast).
    my $synthsubrank_ref = sub
    {
      my $office_ref = shift;
      my @conditions = (
        $office_ref->{category} == SUNDAY_OFFICE && $version !~ /Trident/i,
        $office_ref->{rite}     == GREATER_DOUBLE_RITE &&
          $office_ref->{category} == OCTAVE_DAY_OFFICE,
        $office_ref->{rite}     == GREATER_DOUBLE_RITE,
        $office_ref->{rite}     == DOUBLE_RITE,
        $office_ref->{category} == SUNDAY_OFFICE && $version =~ /1910/i,
        $office_ref->{rite}     == SEMIDOUBLE_RITE &&
          $office_ref->{category} == FESTAL_OFFICE,
        $office_ref->{category} == SUNDAY_OFFICE && $version =~ /Trident/i,
        $office_ref->{category} == WITHIN_OCTAVE_OFFICE &&
          $office_ref->{octrank}  == THIRD_ORDER_OCTAVE,
        $office_ref->{category} == WITHIN_OCTAVE_OFFICE, # Common octave
        $office_ref->{category} == FERIAL_OFFICE,
        $office_ref->{category} == VIGIL_OFFICE,
        $office_ref->{category} == OCTAVE_DAY_OFFICE,
        $office_ref->{calpoint} eq BVM_SATURDAY_CALPOINT,
        1, # The only remaining possibility is a simple feast.
      );

      # With List::MoreUtils, this would be: firstidx {$_} @conditions
      return (
        first
          {$_->{truth}}
          map
            {{idx => $_, truth => $conditions[$_]}}
            (0..$#conditions)
      )->{idx};
    };

    my $a_subrank = $synthsubrank_ref->($a);
    my $b_subrank = $synthsubrank_ref->($b);
    ($a, $b, $a_subrank, $b_subrank, $sign) = ($b, $a, $b_subrank, $a_subrank, -$sign) if($b_subrank > $a_subrank);

    # The office of our Lady on Saturday is omitted if it doesn't win.
    return resolution($sign, OMIT_LOSER)
      if($a->{calpoint} eq BVM_SATURDAY_CALPOINT);

    return resolution($sign, COMMEMORATE_LOSER)
      unless($a_subrank == $b_subrank);
  }

  # If we're still tied, choose the feast of greater dignity, or return zero if
  # they're tied even then.
  my $dignity = dignity($b) <=> dignity($a);
  return resolution($sign * $dignity,
    ($$b{rankord} <= 2) ? TRANSLATE_LOSER : COMMEMORATE_LOSER);
}


# cmp_concurrence_1960($preceding, $following, $version)
# A 1960 version of cmp_concurrence.
sub cmp_concurrence_1960
{
  my ($preceding, $following, $version) = @_;

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
  return OMIT_LOSER;
}


# cmp_concurrence($preceding, $following, $version)
# In a similar spirit to cmp_occurrence, determines what should happen when the
# $preceding office concurs with $following. See cmp_occurrence for the return
# semantics, except that we can also return FROM_THE_CHAPTER when Vespers
# should be such.
sub cmp_concurrence
{
  my ($preceding, $following, $version) = @_;

  return cmp_concurrence_1960(@_) if($version =~ /1960/);

  sub concurrence_rank
  {
    my $office = shift;
    # Synthetic rank in concurrence. Smaller is better. Sundays and privileged
    # octave days are in the same category.
    # XXX: This is not nice. Replace with array of anonymous subs.
    exists($$office{rite}) or confess();
    return
      $$office{rite} >= DOUBLE_RITE && $$office{rankord} <= 2 &&
        $$office{category} != OCTAVE_DAY_OFFICE ? $$office{rankord} :
      $$office{category} == SUNDAY_OFFICE ?
        3 :
      $$office{category} == OCTAVE_DAY_OFFICE &&
        $$office{octrank} <= COMMON_OCTAVE ?
        ($$office{octrank} <= THIRD_ORDER_OCTAVE ? 3 : 5) :  # Sic!
      $$office{rite} == GREATER_DOUBLE_RITE ?
        6 :
      $$office{rite} == DOUBLE_RITE ?
        7 :
      $$office{rite} == SEMIDOUBLE_RITE && $$office{category} == FESTAL_OFFICE ?
        8 :
      $$office{category} == WITHIN_OCTAVE_OFFICE ?
        ($$office{octrank} <= THIRD_ORDER_OCTAVE ? 9 : 10) :
      $$office{category} == FERIAL_OFFICE && $$office{standing} >= GREATER_DAY ?
        11 :
        12;
  }

  my $preceding_rank = concurrence_rank($preceding);
  my $following_rank = concurrence_rank($following);

  if($preceding_rank < $following_rank)
  {
    # Office of preceding. What to do with the following?

    # Omit low-ranking days at first vespers of high-ranking doubles.
    return -(OMIT_LOSER) if(
      $$preceding{rite} == DOUBLE_RITE &&
      $$preceding{rankord} <= 2 &&
      $following_rank >= concurrence_rank({
        category => WITHIN_OCTAVE_OFFICE,
        octrank => COMMON_OCTAVE,
        rite => SEMIDOUBLE_RITE,
        rankord => 3,
      }));

    # Don't commemorate first vespers of the second day in the octave in second
    # vespers of the feast itself.
    return -(OMIT_LOSER) if(
      $$following{category} == WITHIN_OCTAVE_OFFICE &&
      exists($$preceding{octid}) && $$following{octid} eq $$preceding{octid});

    return -(COMMEMORATE_LOSER);
  }
  elsif($following_rank < $preceding_rank)
  {
    # Office of following.

    # Don't commemorate II. vespers of seventh day in the octave at first
    # vespers of the octave day. Notice that, since the following office beat
    # the preceding, we can't have concurrence of two days in the octave here.
    return OMIT_LOSER
      if ($$preceding{category} == WITHIN_OCTAVE_OFFICE &&
        exists($$preceding{octid}) && exists($$following{octid}) &&
        $$preceding{octid} eq $$following{octid});

    # Check for some days that are low-ranking in concurrence but
    # nonetheless are always commemorated when they lose.
    return COMMEMORATE_LOSER
      if(
        ($$preceding{category} == FERIAL_OFFICE &&
          $$preceding{standing} == GREATER_DAY) ||
        ($$preceding{category} == WITHIN_OCTAVE_OFFICE &&
          $$preceding{octrank} <= THIRD_ORDER_OCTAVE)
      );

    # Doubles of the I. or II. class cause low-ranking days to be
    # omitted in concurrence.
    if($$following{rite} == DOUBLE_RITE)
    {
      if($$following{rankord} == 2)
      {
        return OMIT_LOSER
          if($preceding_rank >=
            concurrence_rank(
              {
                category => FESTAL_OFFICE,
                rite => SEMIDOUBLE_RITE,
                rankord => 3
              }
            )
          );
      }
      elsif($$following{rankord} == 1)
      {
        return OMIT_LOSER
          if($preceding_rank >=
            concurrence_rank(
              {
                category => OCTAVE_DAY_OFFICE,
                octrank => COMMON_OCTAVE,
                rite => GREATER_DOUBLE_RITE,
                rankord => 3,
              }
            )
          );
      }
    }

    return COMMEMORATE_LOSER;
  }

  # Both days are in the same concurrence category.

  # In concurrence of days within the same octave, second vespers take
  # precedence and first vespers of the following are omitted.
  return -(OMIT_LOSER)
    if($$preceding{category} == WITHIN_OCTAVE_OFFICE &&
      exists($$following{octid}) && $$following{octid} eq $$preceding{octid});

  # In a Sunday or privileged octave day vs. a privileged octave day or vice
  # versa, the office is always of the preceding.
  my $vs_privileged_octave_day = sub
  {
    my ($a, $b) = @_;
    my $privileged_octave_day = sub
    {
      my $office = shift;
      $$office{category} == OCTAVE_DAY_OFFICE &&
        $$office{octrank} <= THIRD_ORDER_OCTAVE;
    };
    $privileged_octave_day->($b) &&
      ($$a{category} == SUNDAY_OFFICE || $privileged_octave_day->($a));
  };
  return -(COMMEMORATE_LOSER)
    if($vs_privileged_octave_day->($preceding, $following) ||
      $vs_privileged_octave_day->($following, $preceding));
  
  # Office of the day of greater dignity; or, in parity, from the chapter of
  # the following.
  my $sign = dignity($following) <=> dignity($preceding);
  return $sign ? $sign * COMMEMORATE_LOSER : FROM_THE_CHAPTER;
}


sub cmp_commemoration
{
  my ($a, $b, $version) = @_;

  # With 1960 rubrics, commemorations of the season always come first.
  if($version =~ /1960/)
  {
    my $sign = -1;
    ($a, $b, $sign) = ($b, $a, -$sign) if($$b{cycle} == TEMPORAL_OFFICE);
    return $sign if($$a{cycle} == TEMPORAL_OFFICE);
  }

  return cmp_occurrence(@_);
}


sub next_date_mdy
{
  my @date_mdy;
  @date_mdy[1,0,2] = horas::nday(@_[1,0,2]);
  return @date_mdy;
}


sub next_date
{
  return join('-', next_date_mdy(split(/-/, shift)));
}


sub generate_calpoints
{
  use integer;

  my ($date, $version) = @_;
  my ($month, $day, $year) = split(/-/, $date);
  my ($week, $day_of_week) = get_week($month, $day, $year);

  my @days = qw(Dominica FeriaII FeriaIII FeriaIV FeriaV FeriaVI Sabbato);
  my $month_prefix = sprintf('%02d-', $month);

  my @calpoints = (
    # Calendar day: mm-dd.
    $month_prefix . sprintf('%02d', $day),

    # nth x-day *in* the month.
    "$month_prefix$days[$day_of_week]-" . ($day / 7 + 1)
  );

  # nth x-day *of* the month.
  my $reading_day = horas::reading_day($month, $day, $year);
  push @calpoints, $reading_day if($reading_day);

  # Last x-day.
  push @calpoints, "$month_prefix$days[$day_of_week]-Ult"
    if($day_of_week == 0 && days_in_month($month) - $day < 7);

  # Temporal cycle, except for Christmas-Epiphany.
  push @calpoints, "$week-$day_of_week" if($week);

  # Sundays in the Christmas-Epiphany cycle move around a bit. With some
  # rubrics the Sunday in the octave of Christmas is observed on the Sunday
  # itself, which is straightforward; and with others it's on the 30th if
  # that day lies in Tues-Fri, and otherwise on the Sunday.
  if ($month == 12 && $day >= 25)
  {
    push @calpoints, 'Nat1-0' if(
      ($version =~ /1960/i) ? ($day_of_week == 0 && $day > 25) :
                              (($day >= 29 && $day_of_week == 0) ||
                               ($day == 30 && $day_of_week >= 2 &&
                                $day_of_week <= 5))
    );
  }

  # The office of the Sunday after the octave of Christmas has a complex
  # history, but all we need to do here is place the 'Nat2-0' office.  This
  # falls on the Sunday in 2-4 Jan inclusive (or 2-5 Jan post-1955), or on
  # 2 Jan if there is no such Sunday.
  if ($month == 1)
  {
    my $nat2_sunday_limit = ($version =~ /1960|1955/) ? 5 : 4;
    push @calpoints, 'Nat2-0'
      if(($day_of_week == 0 && $day >= 2 && $day <= $nat2_sunday_limit) ||
        ($day == 2 && $day_of_week >= 1 &&
          $day_of_week <= 8 - $nat2_sunday_limit));
  }

  # Office of our Lady on Saturday.
  push @calpoints, BVM_SATURDAY_CALPOINT if($day_of_week == 6);

  return @calpoints;
}


# get_week($month, $day, $year)
# A wrapper for &horas::getweek to hide the use of package variables. Returns
# the week in scalar context and (week, day_of_week) in list context.
sub get_week
{
  package horas;

  local our @date1 = @_;
  local our $month = shift;
  local our $day = shift;
  local our $year = shift;
  local our $dayofweek;

  my $week = getweek(0);
  $week =~ s/(.*?)\s*=.*$/$1/;

  return wantarray ? ($week, $dayofweek) : $week;
}


# Given a list of office references, returns a list of the same references such
# that the first element of the list is the winner in occurrence.  The order of
# the remaining elements is mostly undefined, except that we guarantee not to
# reorder equally-ranked elements with respect to one another.
sub bring_winner_to_front
{
  use sort 'stable';
  my $version = shift;
  return sort {cmp_occurrence($a, $b, $version)} @_;
}


# Returns a closure that calculates the occurrence-resolution rule of an
# arbitrary office against $office.
sub make_occurrence_comparator
{
  my ($office, $version) = @_;
  return sub
  {
    my %resolution = cmp_occurrence($office, shift, $version);
    $resolution{rule};
  }
}


sub resolve_occurrence
{
  my ($calendar_ref, $date, $version, @translated_offices) = @_;

  # Get all calpoints falling on this date and expand them to the lists of
  # offices assigned thereto. This also gets any implicit offices.
  # XXX: We should be using the offices after translation has been performed.
  my @office_lists = map {[get_all_offices($calendar_ref, $_)]}
    generate_calpoints($date, $version);

  # Combine the lists of offices and find the winner.
  my @sorted_offices = bring_winner_to_front($version, map {@$_} @office_lists);

  if (@translated_offices)
  {
    # The next office to be translated is at the head of the list, so it's
    # the only one we care about. It will be dropped here if and only if
    # (a) the day is free of semidoubles, doubles and privileged ferias; or
    # (b) in non-Tridentine rubrics, if the day is free of first- and second-
    #     class offices; or
    # (c) the office is one of a few singled out in the rubrics, and it would
    #     win in occurrence.
    my $current_winner = $sorted_offices[0];
    if (($current_winner->{rite} < SEMIDOUBLE_RITE &&
        $current_winner->{standing} != GREATER_PRIVILEGED_DAY) ||
      ($version !~ /Trident/i && $current_winner->{rankord} > 2) ||
      (exists($translated_offices[0]->{'dignitate maiore in translatione'}) &&
        cmp_occurrence($translated_offices[0], $current_winner) < 0))
    {
      unshift @sorted_offices, shift @translated_offices;
    }
  }

  my $winner = shift @sorted_offices;

  my $rule_against_winner = make_occurrence_comparator($winner, $version);

  # Add any offices that should be translated to the translation list. They'll
  # be filtered out of the day's offices subsequently.
  push @translated_offices,
    grep { $rule_against_winner->($_) == TRANSLATE_LOSER } @sorted_offices;

  # Remove any offices that should be translated in occurrence with the winner.
  # Offices that would be omitted are kept for the time being as they might
  # cease to be omitted at Vespers; get_day_offices() and get_evening_offices()
  # will filter those out as appropriate.
  my @resolved_offices = (
    $winner,
    grep { $rule_against_winner->($_) != TRANSLATE_LOSER } @sorted_offices
  );

  return
    (\@resolved_offices),
    (first {$_->{cycle} == TEMPORAL_OFFICE} ($winner, @sorted_offices)),
    (\@translated_offices);
}


# Removes offices from @tail that would be omitted in occurrence with $winner.
# Translation should already have been handled, so no office in tail should be
# translated in occurrence with $winner.
sub filter_omitted_offices
{
  my ($version, $winner, @tail) = @_;
  my $rule_against_winner = make_occurrence_comparator($winner, $version);
  return (
    $winner,
    grep
    {
      my $rule = $rule_against_winner->($_);
      confess if($rule == TRANSLATE_LOSER);
      $rule != OMIT_LOSER;
    }
    @tail
  );
}

sub get_day_offices
{
  # When two offices are tied in dignity, preserve the order in which they were
  # specified in the calendar. Also, when transferring offices of equal rank,
  # transfer the first one first.
  use sort 'stable';

  my ($calendar_ref, $date, $version, $transfer_cache_ref) = @_;

  # Get the offices that will be observed on this day.  The first one will be
  # the office of the day, but we will still have to sort the rest and filter
  # them for omission.
  my ($offices_pair) =
    resolve_translation($calendar_ref, $version, $date, 1, $transfer_cache_ref);
  my ($offices_ref, $temporal_ref) = @$offices_pair;
  my $winner = shift @$offices_ref;

  # Sort the tail into the order in which the offices should be commemorated.
  @$offices_ref = sort {cmp_commemoration($a, $b, $version)} @$offices_ref;

  # Remove any offices that should be omitted in occurrence with the winner.
  my @resolved_offices =
    filter_omitted_offices($version, $winner, @$offices_ref);

  return (\@resolved_offices, $temporal_ref);
}


sub get_evening_offices
{
  # We will require stability when sorting commemorations. See below.
  use sort 'stable';

  my ($calendar_ref, $date, $version) = @_;

  # Find the offices from the two days.
  my @resolution = resolve_translation($calendar_ref, $version, $date, 2);
  confess unless(@resolution == 2);
  my ($preceding_ref, $preceding_temporal_ref) = @{shift @resolution};
  my ($following_ref, $following_temporal_ref) = @{shift @resolution};

  # Filter out preceding offices without second vespers and following ones
  # without first vespers.
  my @preceding = grep {$_->{secondvespers}} @$preceding_ref;
  my @following = grep {$_->{firstvespers}}  @$following_ref;

  # Handle intra-day omission now that we've restricted ourselves to offices
  # intersecting with this evening.
  foreach my $array_ref (\@preceding, \@following) {
    @$array_ref =
      filter_omitted_offices($version,
        bring_winner_to_front($version, @$array_ref));
  }

  # When a day within an octave is only commemorated, it loses its second
  # vespers. Accordingly, we drop such offices from the list.
  @preceding = $preceding[0], grep {$_->{category} != WITHIN_OCTAVE_OFFICE} @preceding[1..$#preceding] if(@preceding >= 2);

  # Label each office to indicate whether it's of first or second vespers.
  @preceding = map {{office => $_, segment => SECOND_VESPERS_AND_COMPLINE}} @preceding;
  @following = map {{office => $_, segment => FIRST_VESPERS_AND_COMPLINE}}  @following;

  my $concurrence_resolution =
    (@preceding == 0) ? OMIT_LOSER :
    (@following == 0) ? -(OMIT_LOSER) :
    cmp_concurrence($preceding[0]{office}, $following[0]{office}, $version);

  # Abstract out the asymmetry.
  my ($winning_arr_ref, $concurring_arr_ref, $filter_key, $comparator) =
    ($concurrence_resolution == FROM_THE_CHAPTER || $concurrence_resolution > 0) ?
      (\@following, \@preceding, 'v1filter',
        \&cmp_concurrence) :
      (\@preceding, \@following, 'v2filter',
        sub { -cmp_concurrence($_[1], $_[0], $version) });

  my $winner = shift @$winning_arr_ref;

  # Apply the explicit filter if we have one.
  if(exists($winner->{office}{$filter_key}))
  {
    my %permitted_commemorations;
    @permitted_commemorations{split /,/, $winner->{office}{$filter_key}} = ();

    foreach my $arr_ref ($winning_arr_ref, $concurring_arr_ref)
    {
      @$arr_ref = grep {exists $permitted_commemorations{$_->{office}{id}}} @$arr_ref;
    }
  }

  # Filter the losing half for omission.
  @$concurring_arr_ref =
    grep
      {$comparator->($_->{office}, $winner->{office}, $version) != OMIT_LOSER}
      @$concurring_arr_ref;

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
    if($version =~ /1570/)
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
  push @result,
    sort {cmp_concurrence($a->{office}, $b->{office}, $version)} @tail;

  # Sort out which temporal office is nominally active (even if it would be
  # omitted).
  my $temporal_ref =
    # We test whether the preceding office should win. It does so if it has
    # second Vespers, and...
    $preceding_temporal_ref->{secondvespers} &&
    (
      # ...either the following office doesn't have first Vespers, or...
      !$following_temporal_ref->{firstvespers} ||
      # ...the first office beats the second in concurrence.
      cmp_concurrence(
        $preceding_temporal_ref,
        $following_temporal_ref,
        $version) < 0
    ) ? $preceding_temporal_ref : $following_temporal_ref;

  return
    \@result,
    $concurrence_resolution,
    $temporal_ref;
}


# Set a constant upper bound on the number of loop iterations as a sanity
# check, equal to the length of a leap year rounded up to a whole multiple of
# a week.
use constant TRANSLATION_CALC_LIMIT => 371;

sub resolve_translation
{
  my ($calendar_ref, $version, $start_date, $days_count, $cache_ref) = @_;
  my @date_mdy = split(/-/, $start_date);
  my $ordinal_start_date = ordinal_date(@date_mdy);

  # Round the number of days up to a multiple of a week.
  $days_count //= 1;
  my $requested_days_count = $days_count;
  $days_count += (-$days_count) % 7;

  confess('Invalid $days_count.')
    if($days_count < 1 || $days_count > TRANSLATION_CALC_LIMIT);

  # If we have no external cache, create one for use for the duration of this
  # subroutine only.
  $cache_ref //= {};

  # Go back a year less a day and find a Sunday.
  my @transfer_date_mdy = sunday_a_year_ago_mdy(@date_mdy);

  my $translated_offices_ref = [];

  # Heuristic: The typical cache-hit scenario is that the day before the start
  # of the request is in the cache, so check for this case. A more general
  # solution would be to binary-search the first cache-hit, but it's not
  # worth the effort as the cache is a temporary measure to support the old
  # precedence() interface.
  my $yesterday = $ordinal_start_date - 1;
  if (exists($cache_ref->{$yesterday}))
  {
    # Start the loop from the first required day.
    @transfer_date_mdy = @date_mdy;
    (undef, undef, $translated_offices_ref) = @{$cache_ref->{$yesterday}};
  }

  my $days_to_first_day = $ordinal_start_date -
      ordinal_date(@transfer_date_mdy);
  confess $days_to_first_day if($days_to_first_day > TRANSLATION_CALC_LIMIT);

  # Resolve occurrence for each day, picking up and dropping feasts as
  # appropriate.
  for(
    my $remaining_days = $days_count + $days_to_first_day;
    $remaining_days > 0;
    $remaining_days--, @transfer_date_mdy = next_date_mdy(@transfer_date_mdy)
  )
  {
    my $transfer_date_ord = ordinal_date(@transfer_date_mdy);
    my ($resolved_offices_ref, $temporal_ref);
    if (exists($cache_ref->{$transfer_date_ord}))
    {
      ($resolved_offices_ref, $temporal_ref, $translated_offices_ref) =
        @{$cache_ref->{$transfer_date_ord}};
    }
    else
    {
      my $transfer_date_string = join('-', @transfer_date_mdy);
      ($resolved_offices_ref, $temporal_ref, $translated_offices_ref) =
        resolve_occurrence($calendar_ref, $transfer_date_string, $version,
          @$translated_offices_ref);

      # Add the result to the cache.
      $cache_ref->{$transfer_date_ord} =
        [$resolved_offices_ref, $temporal_ref, $translated_offices_ref];

      # Place an anticipated Sunday if necessary.
      if (my $anticipated_ref =
        get_floating_anticipated_office($calendar_ref, @transfer_date_mdy))
      {
        # Plop the anticipated Sunday on the appropriate day in the cache.
        # Start by walking backwards from the Saturday and looking for a day
        # not impeded by a feast of nine lessons.
        my $days_back;
        for ($days_back = 0; $days_back < 7; $days_back++)
        {
          # If the winner is of simple rite (i.e. of three lessons), then the
          # Sunday is anticipated here.
          my $offices_ref = $cache_ref->{$transfer_date_ord - $days_back}->[0];
          if ($offices_ref->[0]->{rite} == SIMPLE_RITE)
          {
            @{$cache_ref->{$transfer_date_ord - $days_back}}[0, 1] = (
              [$anticipated_ref, @$offices_ref], $anticipated_ref
            );
            last;
          }
        }
        if ($days_back == 7)
        {
          # Commemorate on the Saturday.  Take a copy and simplify the office.
          my %simplified = %{$anticipated_ref};
          $simplified{rite} = SIMPLE_RITE;

          # Stick the simplified Sunday at the end of the list of offices for
          # the Saturday.  Other than having the winner at the front, that list
          # isn't sorted yet anyway.
          push(@{$cache_ref->{$transfer_date_ord}->[0]}, \%simplified);
        }
      }
    }
  }

  # TODO: Resumed Sundays:
  # - Sunday in the octave of the Epiphany
  # - Other Sundays (or Sunday Masses??) impeded by feasts?

  # Build the list of the requested range of results.  Take a shallow copy of
  # any collections that will persist in the cache.
  return map {
    my ($resolved_offices_ref, $temporal_ref) = @{$cache_ref->{$_}};
    [[@$resolved_offices_ref], $temporal_ref];
  } ($ordinal_start_date..$ordinal_start_date + $requested_days_count - 1);
}


# Handles the anticipation of the last Sunday before Septuagesima and the 23rd
# Sunday after Pentecost.  Returns a descriptor for the anticipated office if
# the day passed in is the Saturday of the week in which it should be
# anticipated.
sub get_floating_anticipated_office
{
  my ($calendar_ref, $month, $day, $year) = @_;
  my ($week, $day_of_week) = get_week($month, $day, $year);

  # We're only interested in Saturdays.
  return undef unless($day_of_week == 6);

  my $sundays_after_pentecost = sundays_after_pentecost($year);
  if ($week eq 'Pent22')
  {
    # Anticipation of the 23rd Sunday after Pentecost is simple: it happens iff
    # there are 23 Sundays after Pentecost.
    return gen_anticipated_office($calendar_ref, 'Pent23-0')
      if($sundays_after_pentecost == 23);
    return undef;
  }

  # Are we in the last week after the Epiphany?
  my $sundays_after_epiphany = sundays_after_epiphany($year);
  if ($week eq "Epi${sundays_after_epiphany}")
  {
    # There will be an anticipated Sunday before Septuagesima if the sum of the
    # number of Sundays after the Epiphany and the "extra" Sundays after
    # Pentecost (i.e. max(num_sundays - 24, 0)) is less than six, and that
    # Sunday will be the (num_after_epi + 1)th Sunday after the Epiphany.
    if ($sundays_after_epiphany + max($sundays_after_pentecost - 24, 0) < 6)
    {
      my $anticipated_idx =  $sundays_after_epiphany + 1;
      # TODO: At Mass, this should be PentEpi.
      my $category = 'Epi';
      return gen_anticipated_office(
        $calendar_ref, "${category}${anticipated_idx}-0")
    }
  }
}


sub gen_anticipated_office
{
  my ($calendar_ref, $calpoint) = @_;
  my @offices = get_all_offices($calendar_ref, $calpoint);

  # We expect only a single office assigned to that calpoint.
  confess "${calpoint}: Wrong number of offices." unless(@offices == 1);

  my %anticipated_office = %{$offices[0]};
  $anticipated_office{secondvespers} = 0;
  # TODO: Simplify with Tridentine rubrics.

  return \%anticipated_office;
}



1;

