# Routines for manipulating office data.

package DivinumOfficium::Propers;

use strict;
use warnings;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(get_office_part);
}

use Carp;

use DivinumOfficium::Data qw(get_office_data common_directory data_is_loaded
  get_common_data);

###############################################################################


#*** may_use_common($office_desc_ref, $name)
# May we look in the common for $name? This handles the vide/ex distinction.
{
  # Parts actually fom the Psalter are detected by is_psalter_section.
  my %vide_psalterium;
  @vide_psalterium{
    (map {'Responsory' . $_} 4..9),
  } = ();

  sub may_use_common
  {
    my ($office_desc_ref, $name) = @_;

    data_is_loaded($office_desc_ref) or confess;

    return ($office_desc_ref->{'common_type'} eq 'ex') ||
      !(exists($vide_psalterium{$name}) || is_psalter_section($name));
  }
}


#*** get_office_part($office_desc_ref, $name, $hour, $segment, $dayofweek,
#                    $version, $lang)
# Gets the text of the $name-d part of the office specified by
# $office_desc_ref, where $segment is FIRST_VESPERS_AND_COMPLINE,
# MATINS_TO_NONE or SECOND_VESPERS_AND_COMPLINE. We fall back to the common
# and/or season as necessary, and we might do some special processing depending
# on the value of $name.
#
# TODO: This probably doesn't work for Matins specials/psalter.
{
  my %use_segment_suffix;
  @use_segment_suffix{'Ant', 'Oratio', 'Versum'} = ();

  sub get_office_part
  {
    my ($office_desc_ref, $name, $hour, $segment, $dayofweek, $version,
      $lang) = @_;
    my @names = ($name);

    # Handle things like "Ant 3".
    if (exists($use_segment_suffix{$name}))
    {
      unshift @names, "$name $segment";
    }

    if ($name eq 'Oratio')
    {
      unshift @names, "$name $hour";
    }

    my $office_data_ref = get_office_data($office_desc_ref, $version, $lang);
    my $part = get_first_named_part($office_data_ref, @names);

    if (!defined($part) && may_use_common($office_desc_ref, $name))
    {
      # No proper part found, so try the common.
      my $common_data_ref = get_common_data($office_desc_ref, $lang);
      if ($common_data_ref)
      {
        $part = get_first_named_part($common_data_ref, @names);
      }
    }
    
    if (!defined($part))
    {
      # Not in proper or common. Try specials or psalter, as appropriate.
      my $name_to_ss_ref = sub
      {
        specials_section($office_desc_ref, shift, $dayofweek, $hour, $version);
      };

      my @specials_sections = map {$name_to_ss_ref->($_)} @names;

      my $datafile_ref = is_psalter_section($name) ?
        psalter_datafile($hour, $lang) :
        specials_datafile($hour, $lang);

      $part = get_first_named_part($datafile_ref, @specials_sections);
    }

    return $part;
  }
}


#*** psalter_datafile($hour, $lang)
# Loads the psalter datafile for the specified hour.
sub psalter_datafile
{
  my ($hour, $lang) = @_;
  my $basename =
    ($hour =~ /Matutinum/i)      ? 'Psalmi matutinum' :
    ($hour =~ /Laudes|Vespera/i) ? 'Psalmi major'     :
                                   'Psalmi minor'     ;
  return horas::setupstring($horas::datafolder, $lang,
    "Psalterium/$basename.txt");
}


#*** specials_datafile($hour, $lang)
# Loads the specials datafile for the specified hour.
sub specials_datafile
{
  my ($hour, $lang) = @_;
  my $basename =
    ($hour =~ /Matutinum/i)      ? 'Matutinum Special' :
    ($hour =~ /Laudes|Vespera/i) ? 'Major Special'     :
                                   'Minor Special'     ;
  return horas::setupstring($horas::datafolder, $lang,
    "Psalterium/$basename.txt");
}


#*** get_first_named_part($data_ref, @names)
# Tries each of @names in turn as a key to %$data_ref, starting from the first,
# and returns the first value that is defined, or undef if no such value
# exists.
sub get_first_named_part
{
  my ($data_ref, @names) = @_;
  my $part;

  ref($data_ref) eq 'HASH' or confess;

  $part = $data_ref->{shift @names} while (!defined($part) && @names > 0);
  return $part;
}


#*** specials_daycode($calpoint)
# Gets the season for use in specials/psalters, given the calpoint.
sub season_specials_name
{
  # Calpoint.
  local $_ = shift;

  /^Adv/      ? 'Adv'   :
  /^Quad[56]/ ? 'Quad5' :
  /^Quad/     ? 'Quad'  :
  /^Pasc/     ? 'Pasch' :
                ''      ;
}


#*** specials_daycode($dayofweek, $version)
# Gets the code for the day of the week for use in specials/psalters. For
# example, Tridentine Wednesday is Day3a.
sub specials_daycode
{
  my ($dayofweek, $version) = @_;

  local $_ = $version;

  my $version_letter = /Monastic/i ? 'm' :
                       /Trident/i  ? 'a' :
                                     '';

  return "Day$version_letter$dayofweek";
}


#*** expand_specials_template($template, $dayofweek, $specials_season, $hour,
#                             $version)
# Fills out a templated name of a specials/psalter section.
sub expand_specials_template
{
  my ($template, $dayofweek, $specials_season, $hour, $version) = @_;

  my $daycode = specials_daycode($dayofweek, $version);
  $template =~ s/\$h/$hour/g;
  $template =~ s/\$d/$specials_season || $daycode/ge;
  return $template;
}


#*** specials_section($office_desc_ref, $base_name, $dayofweek, $hour, $version)
# Maps names of proper sections to the corresponding names in the specials or
# psalter.
{
  # XXX: Is this right? Do people ask for 'Capitulum', or 'Capitulum Laudes'?
  my %templates = (
    'Ant'       => '$d $h',
    'Capitulum' => '$d $h',
    'Hymnus'    => 'Hymnus $d $h',
    'HymnusM'   => 'HymnusM $d $h',
  );

  sub specials_section
  {
    my ($office_desc_ref, $base_name, $dayofweek, $hour, $version) = @_;
    my $template = $templates{$base_name} || "\$d $base_name";
    return expand_specials_template($template, $dayofweek,
      season_specials_name($office_desc_ref->{calpoint}), $hour, $version);
  }
}


#*** is_psalter_section($section_name)
# Determines whether a named section should be taken from the psalter when it's
# not proper.
{
  my %psalter_sections;
  @psalter_sections{
    (map {'Ant ' . $_} 'Matutinum', 'Laudes', 'Vespera'),
  } = ();

  sub is_psalter_section
  {
    return exists($psalter_sections{shift()});
  }
}


#*** papal_prayer($lang, $plural, $class, $name, $type, $version)
# Returns the collect, secret or postcommunion from the Common of Supreme
# Pontiffs, where $lang is the language; $plural, $class and $name are as
# returned by papal_rule; and $type is the key for the template.
sub papal_prayer
{
  my ($lang, $plural, $class, $name, $type, $version) = @_;

  # Get the prayer from the common.
  my (%common, $num);
  my $prayer;
  my $communename = common_directory($version);

  if (0)  # TODO: if($missa). Try to make this uniform.
  {
    %common = %{horas::setupstring(
      $horas::datafolder, $lang, "$communename/C4b.txt")};
    $num = $plural && $type eq 'Oratio' ? 91 : '';
  }
  else
  {
    %common = %{horas::setupstring(
      $horas::datafolder, $lang, "$communename/C4.txt")};
    $num = $plural ? 91 : 9;
  }

  $prayer = $common{"$type$num"};

  # Fill in the name(s).
  $prayer =~ s/ N\.([a-z ]+N\.)*/ $name/;

  # If we're not a martyr, get rid of the bracketed part; if we are,
  # then just get rid of the brackets themselves.
  if ($class !~ /M/i) {$prayer =~ s/\s*\((.|~[\s\n\r]*)*?\)//;}
  else {$prayer =~ tr/()//d;}

  return $prayer;
}


#*** papal_rule($rule, %params)
# Determines whether a rule contains a clause for the office of a Pope. If
# $params{'commemoration'} is true, a commemorated Pope (only) is checked for;
# otherwise, only in the office of the day.
#
# Returns a list ($plural, $class, $name), where $plural is true if the office
# is of several Popes; $class is 'C', 'M' or 'D' as the Pope is a confessor,
# doctor or martyr, respectively; and $name is the name(s) of the Pope(s). The
# empty list is returned if there is no match.
sub papal_rule
{
  my ($rule, %params) = @_;
  my $classchar = $params{'commemoration'} ? 'C' : 'O';
  
  return ($rule =~ /${classchar}Papa(e)?([CMD])=(.*?);/i);
}


1;

