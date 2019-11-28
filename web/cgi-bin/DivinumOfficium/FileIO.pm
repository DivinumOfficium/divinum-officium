package DivinumOfficium::FileIO;
use strict;
use warnings;

# Temporary measure: if we got here, the parent directory is on the library
# search path, so this will work.
BEGIN {

  package DivinumOfficium::FileIO;
  require "horas/do_io.pl";
}

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(do_read do_write);
}
1;
