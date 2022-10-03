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
sub vernaculars {
  my $basedir = shift;
  my @lines = do_read("$basedir/Linguae.txt") or croak q(Couldn't load language list.);
  return @lines;
}

sub liturgical_color {
  $_ = shift;
  my($commune) = @_;
  return 'blue' if ($commune && $commune =~ /(C1[0-9])/);
  return 'red' if (/(Vigilia Pentecostes|Quattuor Temporum Pentecostes|Martyr)/i);
  return 'grey' if (/(Defunctorum|Parasceve|Morte)/i);
  return 'black' if (/^In Vigilia Ascensionis/);
  return 'purple' if (/(Vigilia|Quattuor|Rogatio|Passion|Palmis|gesim|(?:Majoris )?Hebdomadæ(?: Sanctæ)?|Sabbato Sancto|Dolorum|Ciner|Adventus)/i);
  return 'black' if (/(Conversione|Dedicatione|Cathedra|oann|Pasch|Confessor|Ascensio|Cena)/i);
  return 'green' if (/(Pentecosten|Epiphaniam|post octavam)/i);
  return 'red' if (/(Pentecostes|Evangel|Innocentium|Sanguinis|Cruc|Apostol)/i);
  return 'black'
}
1;
