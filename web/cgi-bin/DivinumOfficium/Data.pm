# Routines for manipulating office data.

package DivinumOfficium::Data;

use strict;
use warnings;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(get_office_part get_office_data get_rank_section
                      get_common_field);
}

use Carp;

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

      my @specials_sections = map($name_to_ss_ref, @names);

      my $datafile_ref = is_psalter_section($name) ?
        psalter_datafile($hour, $lang) :
        specials_datafile($hour, $lang);

      $part = get_first_named_part($datafile_ref, @names);
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
  /^Pasc/     ? 'Pasc'  :
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
  $template =~ s/\$d/$daycode/g;
  return $template;
}


#*** specials_section($office_desc_ref, $base_name, $dayofweek, $hour, $version)
# Maps names of proper sections to the corresponding names in the specials or
# psalter.
{
  # XXX: Is this right? Do people ask for 'Capitulum', or 'Capitulum Laudes'?
  my %templates = (
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



###############################################################################
# TODO: When Latin data files no longer include language-neutral stuff, change
# this to load precisely those things, wherever they end up, rather than the
# Latin files.
###############################################################################

#*** get_office_data($office_desc_ref, $version, $lang)
# Returns reference to office data, loading it through the descriptor's cache
# and ensuring that any load-time processing is done if necessary.
sub get_office_data
{
  my ($office_desc_ref, $version, $lang) = @_;

  $office_desc_ref && $version && $lang or confess;

  if (!defined($office_desc_ref->{__private}{office_data}{$lang}))
  {
    # TODO: Move &officestring into a (this?) module.
    my $office_data_ref =
      $office_desc_ref->{__private}{office_data}{$lang} =
      horas::officestring(
        $horas::datafolder,
        $lang,
        "$office_desc_ref->{filename}.txt");

    ref($office_data_ref) eq 'HASH' && keys(%$office_data_ref) or
      confess "Error loading $lang $office_desc_ref->{filename}.txt";

    if ($lang eq 'Latin')
    {
      my $common_field;
      @{$office_desc_ref}{'common_type', 'common'} =
        ($common_field = get_common_field($office_data_ref, $version)) ?
          horas::extract_common($office_desc_ref, $common_field) :
          ('', '');
    }
    else
    {
      # Ignore return value.
      get_office_data($office_desc_ref, $version, 'Latin');
    }
  }

  return $office_desc_ref->{__private}{office_data}{$lang};
}


#*** sub data_is_loaded($office_desc_ref)
# Returns whether any data files have been loaded for this office.
sub data_is_loaded
{
  my $office_desc_ref = shift;
  return $office_desc_ref->{__private}{office_data};
}


#*** sub get_common_field($office_data_ref, $version)
# Gets the common field for the office, without parsing it.
sub get_common_field
{
  my $rank_section = get_rank_section(@_) or confess;
  return (split /;;/, $rank_section)[-1];
}


#*** sub get_rank_section($office_data_ref, $version)
# Gets the appropriate rank section for the office according to the active
# version.
sub get_rank_section
{
  my ($office_data_ref, $version) = @_;

  return ($version =~ /1960/ && $office_data_ref->{Rank1960}) ||
    $office_data_ref->{Rank};
}


#*** get_common_data($office_desc_ref, $lang)
# Retrieves the data for the common. Returns something that evaluates to false
# if there's no common.
sub get_common_data
{
  my ($office_desc_ref, $lang) = @_;

  data_is_loaded($office_desc_ref) or confess;

  my $common_data_section_ref =
    $office_desc_ref->{__private}{common_data} ||= {};

  if (!exists($common_data_section_ref->{$lang}))
  {
    $common_data_section_ref->{$lang} = $office_desc_ref->{common} &&
      horas::officestring(
        $horas::datafolder,
        $lang,
        $office_desc_ref->{common});
  }

  return $common_data_section_ref->{$lang};
}


1;

