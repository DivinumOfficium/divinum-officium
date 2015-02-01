# Definitions of calendar constants.

package DivinumOfficium::Calendar::Definitions;

use strict;
use warnings;


BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT =
  qw(
    FESTAL_OFFICE SUNDAY_OFFICE FERIAL_OFFICE VIGIL_OFFICE WITHIN_OCTAVE_OFFICE OCTAVE_DAY_OFFICE
    LESSER_DAY GREATER_DAY GREATER_PRIVILEGED_DAY
    SIMPLE_RITE SEMIDOUBLE_RITE DOUBLE_RITE GREATER_DOUBLE_RITE
    PRIMARY_OFFICE SECONDARY_OFFICE
    FIRST_ORDER_OCTAVE SECOND_ORDER_OCTAVE THIRD_ORDER_OCTAVE COMMON_OCTAVE SIMPLE_OCTAVE
    OMIT_LOSER COMMEMORATE_LOSER TRANSLATE_LOSER FROM_THE_CHAPTER
    PARTICULAR_OFFICE UNIVERSAL_OFFICE
    TEMPORAL_OFFICE SANCTORAL_OFFICE

    office_category_string office_standing_string office_rite_string
    office_nobility_string office_octrank_string office_octrank_string_infra
  );
}

use constant
{
  FESTAL_OFFICE  => 0,
  SUNDAY_OFFICE  => 1,
  FERIAL_OFFICE  => 2,
  VIGIL_OFFICE  => 3,
  WITHIN_OCTAVE_OFFICE  => 4,
  OCTAVE_DAY_OFFICE  => 5
};

my %category_strings = (
  FESTAL_OFFICE,        'festum',
  SUNDAY_OFFICE,        'Dominica',
  FERIAL_OFFICE,        'feria',
  VIGIL_OFFICE,         'vigilia',
  WITHIN_OCTAVE_OFFICE, 'dies infra octavam',
  OCTAVE_DAY_OFFICE,    'dies octava',
);

sub office_category_string { $category_strings{$_[0]} }

use constant
{
  LESSER_DAY    => 0,
  GREATER_DAY    => 1,
  GREATER_PRIVILEGED_DAY  => 2
};

my %standing_strings = (
  LESSER_DAY,             '',
  GREATER_DAY,            'major',
  GREATER_PRIVILEGED_DAY, 'major privilegiata',
);

sub office_standing_string { $standing_strings{$_[0]} }

use constant
{
  SIMPLE_RITE    => 0,
  SEMIDOUBLE_RITE    => 1,
  DOUBLE_RITE    => 2,
  GREATER_DOUBLE_RITE  => 3
};

my %rite_strings = (
  SIMPLE_RITE,         'simplex',
  SEMIDOUBLE_RITE,     'semiduplex',
  DOUBLE_RITE,         'duplex',
  GREATER_DOUBLE_RITE, 'duplex majus',
);

sub office_rite_string { $rite_strings{$_[0]} }

use constant
{
  PRIMARY_OFFICE    => 1,
  SECONDARY_OFFICE  => 2
};

my %nobility_strings = (
  PRIMARY_OFFICE,   'primaria',
  SECONDARY_OFFICE, 'secundaria',
);

sub office_nobility_string { $nobility_strings{$_[0]} }

use constant
{
  FIRST_ORDER_OCTAVE  => 1,
  SECOND_ORDER_OCTAVE  => 2,
  THIRD_ORDER_OCTAVE  => 3,
  COMMON_OCTAVE    => 4,
  SIMPLE_OCTAVE    => 5
};

my %octrank_strings = (
  FIRST_ORDER_OCTAVE,  'I. ordinis',
  SECOND_ORDER_OCTAVE, 'II. ordinis',
  THIRD_ORDER_OCTAVE,  'III. ordinis',
  COMMON_OCTAVE,       'communis',
  SIMPLE_OCTAVE,       'simplex',
);

# For 'infra octavam', 'communis' needs declined to 'communem'. The genitive
# descriptions stay genitive, and simple octaves don't occur.
sub office_octrank_string { $octrank_strings{$_[0]} }
sub office_octrank_string_infra
{
  $_[0] == COMMON_OCTAVE ? 'communem' : $octrank_strings{$_[0]};
}

use constant
{
  OMIT_LOSER    => 1,
  COMMEMORATE_LOSER  => 2,
  TRANSLATE_LOSER    => 3,
  FROM_THE_CHAPTER  => 0  # The fact that this is zero is an implementation detail!
};

use constant
{
  UNIVERSAL_OFFICE  => 0,
  PARTICULAR_OFFICE  => 1
};

use constant
{
  TEMPORAL_OFFICE  => 0,
  SANCTORAL_OFFICE => 1
};

1;

