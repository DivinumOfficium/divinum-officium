package DivinumOfficium::Test;

use strict;
use warnings;

use DivinumOfficium::Calendar::Definitions;
use DivinumOfficium::Calendar::Data;

use Digest::MD5 qw(md5_hex);

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(mock_office_descriptor);
}

#*** mock_office_descriptor($version, $rankline, %other_key_value_pairs)
# Builds a reference to a mock office descriptor with sensible defaults for
# omitted fields.
sub mock_office_descriptor
{
  my $version = shift;
  my %desc = ('rank' => shift, @_);
  my %defaults = (
    'partic'   => UNIVERSAL_OFFICE,
    'calpoint' => '',
    'title'    => '',
  );

  foreach my $field (keys %defaults)
  {
    $desc{$field} = $defaults{$field} unless exists($desc{$field});
  }

  $desc{id} //= "$desc{calpoint}-" . md5_hex(\%desc);

  # Dig into some internal subroutines here...
  DivinumOfficium::Calendar::Data::generate_internal_office_fields(
    $version, \%desc);

  return \%desc;
}

1;

