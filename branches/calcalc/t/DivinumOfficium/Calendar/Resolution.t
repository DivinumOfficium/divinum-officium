use strict;
use warnings;

use DivinumOfficium::Calendar::Resolution;
use DivinumOfficium::Calendar::Definitions;
use DivinumOfficium::Calendar::Data qw(generate_rank_line);
use DivinumOfficium::Test qw(mock_office_descriptor);

use Test::More;

# The idea here is that we encode the occurrence/concurrence tables from various
# breviaries and test whether our implementation conforms to them. First, we
# create mock descriptors for the rows and columns of the tables.

my $version = 'Divino Afflatu';

# Divino occurrence rows.
my @divino_occ_rows = mock_descriptor_list($version,
  [['Festum Duplex I. classis']],
  [['Festum Duplex II. classis']],
  [['Dies octava communis duplex majus']],
  [['Festum duplex majus']],
  [['Festum duplex']],
  [['Festum semiduplex']],
  [['Dies infra octavam communem semiduplex']],
  [['Vigilia simplex']],
  [['Dies octava simplex simplex']],
  [['Festum simplex']],
);

my @divino_occ_cols = mock_descriptor_list($version,
  # [[SIMPLE_RITE, FESTAL_OFFICE]], BVM on Saturday. TODO.
  [['Dies octava simplex simplex']],
  # We take an Advent feria as the archetype of a greater non-privileged feria,
  # and test some Lenten special cases later.
  [['Feria major simplex', 'calpoint' => 'Adv1-1']],
  [['Dies infra octavam communem semiduplex']],
  [['Dies infra octavam III. ordinis semiduplex']],
  [['Dies infra octavam II. ordinis semiduplex']],
  [['Festum semiduplex']],
  [['Festum duplex']],
  [['Festum duplex majus']],
  [
    ['Dies octava communis duplex majus'],
    ['Dies octava III. ordinis duplex majus'],
  ],
  [['Dies octava II. ordinis duplex majus']],
  [['Festum Duplex II. classis']],
  [['Festum Duplex I. classis']],
  [
    ['Feria major privilegiata simplex', 'calpoint' => 'Quadp3-4'],
    ['Vigilia semiduplex I. classis'],
    # The table just has "day within I.-ord. octave", but these come in two
    # varieties.
    ['Dies infra octavam I. ordinis duplex I. classis'],
    ['Dies infra octavam I. ordinis semiduplex I. classis'],
  ],
  [
    ['Dominica semiduplex'],
    # Table also has Vigil of the Epiphany here. TODO?
  ],
  [['Dominica semiduplex II. classis']],
  [
    ['Dominica semiduplex I. classis'],
    ['Dominica duplex I. classis'],
  ],
);

my @divino_occ_table = map {[split //]} (
  # TODO: BVM on Sat.
  '1313333336586336',
  '3313633336868366',
  '3333433374440444',
  '3333433744444444',
  '3333437444444444',
  '3333474444444444',
  '3374444444220444',
  '3244444444422000',
  '7444444440420444',
  '4444444444424444',
);

my @divino_occ_verifiers = (
  # 0. In the table this means the occurrence is impossible, but in principle
  # we might need to handle it anyway. The loser would have to be omitted or
  # transferred.
  sub { my $r = abs shift; grep {$_ == $r} (OMIT_LOSER, TRANSLATE_LOSER) },
  # 1. Office of the first, nothing of the second.
  sub { shift == OMIT_LOSER },
  # 2. Office of the second, nothing of the first.
  sub { shift == -(OMIT_LOSER) },
  # 3. Office of the first, commemoration of the second.
  sub { shift == COMMEMORATE_LOSER },
  # 4. Office of the second, commemoration of the first.
  sub { shift == -(COMMEMORATE_LOSER) },
  # 5. Office of the first, translation of the second.
  sub { shift == TRANSLATE_LOSER },
  # 6. Office of the second, translation of the first.
  sub { shift == -(TRANSLATE_LOSER) },
  # 7. Office of the more noble, commemoration of the other. Our mock
  # descriptors aren't distinguished in dignity, so just check that the loser
  # is commemorated.
  sub { abs shift == COMMEMORATE_LOSER },
  # 8. Office of the more noble, translation of the other. As above.
  sub { abs shift == TRANSLATE_LOSER },
);

for my $row (0..$#divino_occ_rows) {
  for my $col (0..$#divino_occ_cols) {
    foreach my $row_desc (@{$divino_occ_rows[$row]}) {
      foreach my $col_desc (@{$divino_occ_cols[$col]}) {
        my %resolution = DivinumOfficium::Calendar::Resolution::cmp_occurrence(
          $row_desc,
          $col_desc,
          $version
        );
        my $result = ($resolution{sign} || 1) * $resolution{rule};

        ok(
          $divino_occ_verifiers[$divino_occ_table[$row][$col]]->($result),
          generate_rank_line($row_desc) .
            ' vs. ' .
            generate_rank_line($col_desc)
        );
      }
    }
  }
}

# The occurrence table doesn't distinguish between Advent and Lenten greater
# (unprivileged) ferias, but we have to handle them differently as we deal with
# cessation of octaves in Lent in the occurrence-resolution logic.
print "# Special case: Lenten ferias.\n";

my $lenten_feria = mock_office_descriptor(
  $version, 'Feria major simplex', 'calpoint' => 'Quad1-1');

foreach my $rank (
  'Dies infra octavam communem semiduplex',
  'Dies octava communis duplex majus',
  'Dies octava simplex simplex'
)
{
  my $desc = mock_office_descriptor($version, $rank);
  my %resolution = DivinumOfficium::Calendar::Resolution::cmp_occurrence(
    $lenten_feria, $desc, $version);
  use Data::Dumper;
  local $Data::Dumper::Pad = '# ';
  print Dumper(\%resolution);
  ok(
    $resolution{sign} > 0 && $resolution{rule} == OMIT_LOSER,
    'Lenten feria vs. ' . generate_rank_line($desc)
  );
}

done_testing();

sub mock_descriptor_list
{
  my $version = shift;
  return map
    {
      [
        map
          {
            mock_office_descriptor($version, @$_)
          }
          @$_
      ]
    }
    @_;
}

