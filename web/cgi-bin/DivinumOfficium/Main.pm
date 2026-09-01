package DivinumOfficium::Main;

use utf8;
use strict;
use warnings;
use Carp;
use DivinumOfficium::FileIO qw(do_read);

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(vernaculars liturgical_color);
}

#*** vernaculars($basedir)
# Returns a list of available vernacular languages for the datafiles rooted at
# $basedir.
# TODO: vernaculars() seems to be dead code (nothing calls it since d08ac5615d)
# TODO: Remove this function and the test, or rework it to enumerate the actual language dirs from the filesystem
# TODO: instead of reading a static file.
sub vernaculars {
  my $basedir = shift;
  my @lines = do_read("$basedir/Linguae.txt") or croak q(Couldn't load language list.);
  return @lines;
}

sub liturgical_color {
  $_ = shift;
  return 'blue' if (/(?:Beat|Sanct)(?:ae|æ) Mari/ && !/Vigil/);
  return 'red' if (/(?:Vigilia Pentecostes|Quattuor Temporum Pentecostes|Decollatione|Martyr|Reliquia)/i);
  return 'grey' if (/(?:Defunctorum|Parasceve|Morte)/i);

  # NB: '^In Vigilia Ascensionis' looks like it might be unreachable, since
  # the natural-language title for Ascension Eve is normally "Feria Quarta in
  # Rogationibus in Vigilia Ascensionis" (which doesn't match this anchor,
  # and correctly falls through to the purple branch below instead, since
  # older rubrics keep the Rogation Days themselves violet). However, under
  # the 1960 rubrics specifically, the same day's [Officium] title is
  # shortened to exactly "In Vigilia Ascensionis" (see e.g.
  # web/www/horas/Latin/Tempora/Pasc5-3.txt, the "(rubrica 1960)" variant),
  # which does match here. So this branch is real, but reachable only for
  # that one rubrics version. See t/DivinumOfficium/LiturgicalColor.t.
  return 'black' if (/^In Vigilia Ascensionis|^In Vigilia Epiphaniæ/);
  return 'purple'
    if (
    /(?:Vigilia|Quattuor|Rogatio|Passion|Palmis|gesim|(?:Majoris )?Hebdomadæ(?: Sanctæ)?|Sabbato Sancto|Dolorum|Ciner|Adventus)/i
      && !/commemoratione|votivum/i);
  return 'black' if (/(?:Conversione|Dedicatione|Cathedra|oann|Pasch|Confessor|Ascensio|Cena)/i);
  return 'green' if (/(?:Pentecosten(?!.*infra octavam)|Epiphaniam|post octavam)/i);
  return 'red' if (/(?:Pentecostes|Evangel|Innocentium|Sanguinis|Cruc|Apostol)/i);
  return 'black';
}
1;
