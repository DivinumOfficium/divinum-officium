# Common routines, constants etc.

package horas::common;

use strict;
use warnings;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(
    FIRST_VESPERS_AND_COMPLINE
    MATINS_TO_NONE
    SECOND_VESPERS_AND_COMPLINE);
}

use constant
{
  FIRST_VESPERS_AND_COMPLINE  => 1,
  MATINS_TO_NONE              => 2,
  SECOND_VESPERS_AND_COMPLINE => 3,
};

1;

