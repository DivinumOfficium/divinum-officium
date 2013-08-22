# Main routines for building the hours.

require 'horas/horascommon.pl';
require 'horas/webdia.pl';

package horas::main;

use strict;
use warnings;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(initialise_hour);
}

use FindBin qw($Bin);
use lib "$Bin/..";

use horas::common qw(
  FIRST_VESPERS_AND_COMPLINE
  MATINS_TO_NONE
  SECOND_VESPERS_AND_COMPLINE);

use horas::calendar qw(resolve_occurrence resolve_concurrence get_week);
use horas::caldata qw(load_calendar_file);



# initialise_hour($calendar_ref, $date, $hour)
# Sets all the package variables needed to generated the specified hour. For
# now, parts of this are simply copied from &getrank and &precedence; these
# will be cleaned up before being merged into trunk.
sub initialise_hour
{
  my ($calendar_ref, $date, $hour) = @_;

  my $vespers_or_compline = ($hour =~ /Vespera/i || $hour =~ /Completorium/i);


  # Get offices for the hour. If we only care about occurrence, we expand the
  # entries returned by resolve_occurrence for uniformity with
  # resolve_concurrence.

  my (@offices, $concurrence_resolution);

  if($vespers_or_compline)
  {
    (my $offices_ref, $concurrence_resolution) = resolve_concurrence($calendar_ref, $date);
    @offices = @$offices_ref;
  }
  else
  {
    @offices = map {{office => $_, segment => MATINS_TO_NONE}} resolve_occurrence($calendar_ref, $date);
  }


  my $winning_office_ref = $offices[0]{office};

  {
    # Switch into the main package for the time being so that 'our' does what
    # we want.
    package horas;

    use horas::caldef qw(
      SANCTORAL_OFFICE TEMPORAL_OFFICE
      FERIAL_OFFICE VIGIL_OFFICE SUNDAY_OFFICE
      FROM_THE_CHAPTER
      GREATER_DAY
      SIMPLE_RITE SEMIDOUBLE_RITE DOUBLE_RITE);

    use List::Util qw(first);
    

    our $version;
    
    our ($datafolder, $lang1, $lang2);

    # This should already have been set, but do it again for completeness.
    our $hora = $hour;

    our $date1 = $date;
    our @date1 = our ($month, $day, $year) = split /-/, $date;

    (my $week, our $dayofweek) = horas::calendar::get_week(@date1);

    our $duplex = do
    {
      my $rite = $winning_office_ref->{rite};
      if   ($rite == DOUBLE_RITE)     {3}
      elsif($rite == SEMIDOUBLE_RITE) {2}
      elsif($rite == SIMPLE_RITE)     {1}
    };

    # Take everything from $week up to the first =. We set @dayname[1,2] later.
    our @dayname = ($week =~ /(.*?)\s*=/);

    our $temporaname;
    my $temporal_propers_fname = "$temporaname/$dayname[0]-$dayofweek.txt";
    my $temporal_propers_ref = officestring($datafolder, $lang1, $temporal_propers_fname);

    our $winner  = "$winning_office_ref->{filename}.txt";
    our %winner  = %{officestring($datafolder, $lang1, $winner)};
    our %winner2 = %{officestring($datafolder, $lang2, $winner)};

    our $rule = $winner{Rule};

    our $laudes = do
    {
      if($version =~ /Trident/i)
        {''}
      elsif($winning_office_ref->{Rule} =~ /Laudes 2/i ||
          ($winning_office_ref->{category} == FERIAL_OFFICE && $winning_office_ref->{standing} == GREATER_DAY) ||
          ($winning_office_ref->{category} == VIGIL_OFFICE && $winning_office_ref->{calpoint} !~ /Pasc/i) ||
          ($winning_office_ref->{category} == SUNDAY_OFFICE && $winning_office_ref->{calpoint} =~ /Quad/i))
        {2}
      else
        {1}
    };

    my @rank = split /;;/, $winner{Rank};
    our $rank = $rank[2];
    
    # Name and rank.
    $dayname[1] = "$winning_office_ref->{title} $rank[1]";

    our ($communetype, $commune, $communename);

    # Common. TODO: Move all this logic into extract_common.
    if($winning_office_ref->{cycle} == SANCTORAL_OFFICE)
    {
      if (my ($new_communetype, $new_commune) = extract_common($rank[3], $rank[2]))
      {
        ($communetype, $commune) = ($new_communetype, $new_commune);
      }

      # Genuine common?
      if ($rank[3] =~ /^(ex|vide)\s*(C[0-9]+[a-z]*)/i)
      {
        # Get names of all the commons.
        our %dialog;
        (my $all_common_names = $dialog{communes}) =~ s/\n//g;
        my %communenames = split /,/, $all_common_names;

        # Append some common info to the name and rank.
        $dayname[1] .= " $communetype $communenames{$commune} [$commune]";
      }
    }
    elsif($rank[3] =~ /(ex|vide)\s*(.*)\s*$/i)
    {
      $communetype = $1;
      my $name = $2;
      if($name =~ /^C[0-9]/i) {$name = "$communename/$name";}
      elsif($name !~ /(Sancti|Commune|Tempora)/i) {$name = "$temporaname/$name";}
      $commune = "$name.txt";
      if($version =~ /trident/i && $version !~ /monastic/i) {$communetype = 'ex';}
    }

    if($winning_office_ref->{cycle} == SANCTORAL_OFFICE && $dayname[0])
    {
      our $scriptura  = $temporal_propers_fname;
      our %scriptura  = %{officestring($datafolder, $lang1, $scriptura)};
      our %scriptura2 = %{officestring($datafolder, $lang2, $scriptura)};
    }

    our $initia = ($temporal_propers_ref->{Lectio1} =~ /!.*? 1:1-/);

    our $testmode;

    our $seasonalflag = (
      $testmode !~ /Seasonal/i ||
      $winner !~ /Sancti/ ||
      $rank >= 5 ||
      $version =~ /Newcal/i);

    if($commune)
    {
      our %commune  = %{officestring($datafolder, $lang1, $commune)};
      our %commune2 = %{officestring($datafolder, $lang2, $commune)};
      
      if(exists($commune{Responsory7c}))
      {
        our %scriptura;

        my @a = split("\n", $commune{Responsory7});
        my @b = split("\n", $scriptura{Responsory1});
        if ($a[0] =~ /$b[0]/i) {
          $commune{Responsory7} = $commune{Responsory7c};
          $commune2{Responsory7} = $commune2{Responsory7c};
        }
      }

      my $C10 =
        ($dayname[0] =~ /Adv/i) ?
          'a' :
        ($month == 1 || ($month == 2 && $day == 1)) ?
          'b' :
        ($dayname[0] =~ /(Epi|Quad)/i) ?
          'c' :
        ($dayname[0] =~ /Pasc/i) ?
          'Pasc' :
          '';
      $C10 = (our $missa) ? "C10$C10" : 'C10';

      if($commune =~ /C10/) {
        $rule .= "ex $C10";
        $rule =~ s/Oratio Dominica//gi;
        $winner{Rank} = "Sanctae Mariae Sabbato;;Feria;;1;;ex $C10";
      }

      if($winner{Rank} =~ /\;\;ex\s/ ||
        ($version =~ /Trident/i && $rank =~ /\;\;(ex|vide)/i && $duplex > 1))
      {
        our $communerule = $commune{Rule};
      }

      if($testmode =~ /Commune/i)
      {
        my $key;
        foreach $key (keys %winner)
        {
          if ($key =~ /Rank/i) {next;}
          if (exists($commune{$key})) {$winner{$key} = $commune{$key}}
          else {delete($winner{$key});}
        }
        foreach $key (keys %winner2)
        {
          if ($key =~ /Rank/i) {next;}
          if (exists($commune2{$key})) {$winner2{$key} = $commune2{$key}}
          else {delete($winner2{$key});}
        }
      }
    }

    # Minimal commemoration stuff until such a time as we plumb in the new
    # commemoration system.
    our $marian_commem = 0;
    our ($commemoratio, $commemoration1, $commemorated) = ('', '', '');
    our $comrank = 0;
    our $svesp = our $tvesp = our $cvespera = 3;
    $dayname[2] = '';

    if($vespers_or_compline)
    {
      our $vespera = $offices[0]{segment};
      
      my $sanctoral_ref =
        first {$_->{office}{cycle} == SANCTORAL_OFFICE} @offices;
      my $temporal_ref =
        first {$_->{office}{cycle} == TEMPORAL_OFFICE} @offices;

      $svesp = $sanctoral_ref->{segment} if($sanctoral_ref);
      $tvesp = $temporal_ref->{segment}  if($temporal_ref);

      $cvespera = $offices[1]{segment} if(@offices > 1);
    }

    # TODO: This needn't be calculated so early. It can be deferred to the
    # calculation of Vespers itself. All that needs to be done is to remember
    # whether we're from the chapter. Then furthermore support for antiphons
    # from a common will have to be added.
    if($hora =~ /Vespera/i && $concurrence_resolution == FROM_THE_CHAPTER)
    {
      my $concurring_office_ref = $offices[1]{office};
      my $concurring  = "$concurring_office_ref->{filename}.txt";
      my $concurring_propers_ref  = officestring($datafolder, $lang1, $concurring);
      my $concurring_propers_ref2 = officestring($datafolder, $lang2, $concurring);

      our $antecapitulum =
        $concurring_propers_ref->{'Ant Vespera 3'} ||
        $concurring_propers_ref->{'Ant Vespera'};
      our $antecapitulum2 =
        $concurring_propers_ref2->{'Ant Vespera 3'} ||
        $concurring_propers_ref2->{'Ant Vespera'};
    }

    # Postponed stuff. TODO: Handle it properly!
    our $transfervigil = 0;
    our $dirge = 0;
    our $dirgeline = '';
    our $hymncontract = 0;
  }
}


# precedence($date)
# Temporary wrapper for &initialise_hour that mimics the interface of the
# old &precedence in horascommon.pl. TODO: Remove.
sub precedence
{
  no warnings 'once';

  my $date =
    ($horas::votive =~ /hodie/ && !$horas::Hk) ?
      horas::gettoday()
      :
      (
        shift ||
        (($horas::Tk || $horas::Hk) ? '' : horas::strictparam('date')) ||
        horas::gettoday()
      );

  initialise_hour(
    load_calendar_file(
      $horas::datafolder,
      'Kalendaria/generalis.txt'),
    $date,
    $horas::hora);
}

