# Routines for manipulating office data.

package DivinumOfficium::Data;

use strict;
use warnings;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(get_office_data common_directory data_is_loaded
    get_common_data);
}

use Carp;

###############################################################################


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


#*** common_directory($version)
# Returns the directory for commons, relative to the directory for the
# language.
sub common_directory
{
  my $version = shift;
  return $version =~ /Monastic/i ? 'CommuneM' : 'Commune';
}

1;

