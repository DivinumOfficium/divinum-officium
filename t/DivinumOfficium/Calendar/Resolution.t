use strict;
use warnings;

use DivinumOfficium::Calendar::Resolution;
use DivinumOfficium::Calendar::Definitions;
use DivinumOfficium::Calendar::Data qw(generate_rank_line);
use DivinumOfficium::Test qw(mock_office_descriptor);

use Test::More;
use List::Util qw(reduce);

# The idea here is that we encode the occurrence/concurrence tables from various
# breviaries and test whether our implementation conforms to them.

divino_occurrence();
divino_concurrence();
done_testing();

sub divino_occurrence
{
  my $version = 'Divino Afflatu';

  # First, we create mock descriptors for the rows and columns of the tables.

  my @row_descriptors = mock_descriptor_list($version,
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

  my @col_descriptors = mock_descriptor_list($version,
    # [[SIMPLE_RITE, FESTAL_OFFICE]], BVM on Saturday. TODO.
    [['Dies octava simplex simplex']],
    # We take an Advent feria as the archetype of a greater non-privileged
    # feria, and test some Lenten special cases later.
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

  my @table = map {[split //]} (
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

  my @verifiers = (
    # 0. In the table this means the occurrence is impossible, but in principle
    # we might need to handle it anyway. The loser would have to be omitted or
    # transferred.
    sub { my $r = abs shift; grep {$_ == $r} (OMIT_LOSER, TRANSLATE_LOSER) },
    # 1. Office of the first, nothing of the second.
    sub { shift == -(OMIT_LOSER) },
    # 2. Office of the second, nothing of the first.
    sub { shift == OMIT_LOSER },
    # 3. Office of the first, commemoration of the second.
    sub { shift == -(COMMEMORATE_LOSER) },
    # 4. Office of the second, commemoration of the first.
    sub { shift == COMMEMORATE_LOSER },
    # 5. Office of the first, translation of the second.
    sub { shift == -(TRANSLATE_LOSER) },
    # 6. Office of the second, translation of the first.
    sub { shift == TRANSLATE_LOSER },
    # 7. Office of the more noble, commemoration of the other. Our mock
    # descriptors aren't distinguished in dignity, so just check that the loser
    # is commemorated.
    sub { abs shift == COMMEMORATE_LOSER },
    # 8. Office of the more noble, translation of the other. As above.
    sub { abs shift == TRANSLATE_LOSER },
  );

  verify_occurrence_table(
    \@row_descriptors,
    \@col_descriptors,
    \@table,
    \@verifiers,
    $version);

  # The occurrence table doesn't distinguish between Advent and Lenten greater
  # (unprivileged) ferias, but we have to handle them differently as we deal
  # with cessation of octaves in Lent in the occurrence-resolution logic.
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
      $resolution{sign} < 0 && $resolution{rule} == OMIT_LOSER,
      'Lenten feria vs. ' . generate_rank_line($desc)
    );
  }
}


sub divino_concurrence
{
  my $version = 'Divino Afflatu';

  # These classes appear both as rows and columns.
  my $infra_oct_priv = [
    # Double days in I.-ord.-octaves (i.e. Easter and Pentecost Mondays and
    # Tuesdays) are treated as feasts.
    ['Dies infra octavam I. ordinis semiduplex I. classis'],
    ['Dies infra octavam II. ordinis semiduplex'],
    ['Dies infra octavam III. ordinis semiduplex'],
  ];
  my $dominica = [
    ['Dominica semiduplex'],
    ['Dominica semiduplex II. classis'],
    ['Dominica semiduplex I. classis'],
    # Double Sundays of the first class don't belong in this category.
  ];
  my $duplex_primae_classis = [
    ['Festum Duplex I. classis'],
    ['Dominica duplex I. classis'],
    ['Dies infra octavam I. ordinis duplex I. classis'],
  ];


  my @row_descriptors = mock_descriptor_list($version,
    $dominica,
    $duplex_primae_classis,
    [['Festum Duplex II. classis']],
    [
      ['Dies octava II. ordinis duplex majus'],
      ['Dies octava III. ordinis duplex majus'],
    ],
    [['Dies octava communis duplex majus']],
    [['Festum duplex majus']],
    [['Festum duplex']],
    [['Festum semiduplex']],
    $infra_oct_priv,
    [['Dies infra octavam communem semiduplex']],
  );

  my @col_descriptors = mock_descriptor_list($version,
    [
      ['Dies octava simplex simplex'],
      ['Festum simplex'],
    ],
    [['Festum simplex', 'calpoint' => BVM_SATURDAY_CALPOINT]],
    [['Dies infra octavam communem semiduplex']],
    $infra_oct_priv,
    [['Festum semiduplex']],
    [['Festum duplex']],
    [['Festum duplex majus']],
    [
      ['Dies octava II. ordinis duplex majus'],
      ['Dies octava III. ordinis duplex majus'],
      ['Dies octava communis duplex majus'],
    ],
    [['Festum Duplex II. classis']],
    $duplex_primae_classis,
    # Table also has Vigil of the Epiphany here. TODO?
    $dominica,
  );

  my @table = map {[split //]} (
    # TODO: BVM on Sat.
    '40444444330',
    '22244444454',
    '22244444534',
    '44444444334',
    '44444445313',
    '44444453313',
    '44444533313',
    '44445333113',
    '40003333333',
    '40003333113',
  );

  my @verifiers = (
    # 0. In the table this means the concurrence is impossible, but there are
    # several cases that could happen on particular calendars. The correct
    # resolution depends on the particular case, so there's nothing we can
    # test.
    sub { 1 },
    # 1. All of the following, nothing of the preceding.
    sub { shift == OMIT_LOSER },
    # 2. All of the preceding, nothing of the following.
    sub { shift == -(OMIT_LOSER) },
    # 3. All of the following, commemoration of the preceding.
    sub { shift == COMMEMORATE_LOSER },
    # 4. All of the preceding, commemoration of the following.
    sub { shift == -(COMMEMORATE_LOSER) },
    # 5. All of the the office of greater nobility, commemoration of the other;
    # or, in parity, from the chapter of the following with a commemoration of
    # the preceding. TODO: We don't have many tests that fall into the first
    # case: fix this.
    sub
    {
      my ($result, $first, $second) = @_;
      # This is just dignity($second) <=> dignity($first).
      my $dignity_tie =
        reduce {$b <=> $a}
          map { DivinumOfficium::Calendar::Resolution::dignity($_) }
            ($first, $second);
      # If we're not from-the-chapter, check that dignity was respected.
      return $result == FROM_THE_CHAPTER ||
        (abs($result) == COMMEMORATE_LOSER && $dignity_tie * $result > 0);
    },
  );

  verify_concurrence_table(
    \@row_descriptors,
    \@col_descriptors,
    \@table,
    \@verifiers,
    $version);
}


sub verify_occurrence_table
{
  verify_table(\&DivinumOfficium::Calendar::Resolution::cmp_occurrence, @_);
}

sub verify_concurrence_table
{
  verify_table(\&DivinumOfficium::Calendar::Resolution::cmp_concurrence, @_);
}

sub verify_table
{
  my ($comparator_ref, $row_descriptors_ref, $col_descriptors_ref, $table_ref,
    $verifiers_ref, $version) = @_;

  for my $row (0..$#$row_descriptors_ref) {
    for my $col (0..$#$col_descriptors_ref) {
      foreach my $row_desc (@{$row_descriptors_ref->[$row]}) {
        foreach my $col_desc (@{$col_descriptors_ref->[$col]}) {
          # Some comparators return hashes in list context and others merrily
          # return a single value. In the former case we need to examine the
          # hash, but in the latter case we can't assign straight to a hash,
          # so stick the result in an array and check the length to determine
          # which behaviour the comparator exhibits.
          my @resolution = $comparator_ref->($row_desc, $col_desc, $version);
          my $result;
          if (@resolution > 1) {
            my %resolution = @resolution;
            $result = ($resolution{sign} || 1) * $resolution{rule};
          }
          else {
            $result = $resolution[0];
          }

          my $table_says = $table_ref->[$row][$col];
          ok(
            $verifiers_ref->[$table_says]->($result, $row_desc, $col_desc),
            generate_rank_line($row_desc) .
              ' vs. ' .
              generate_rank_line($col_desc) .
              " ($result; $table_says)"
          );
        }
      }
    }
  }
}


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

