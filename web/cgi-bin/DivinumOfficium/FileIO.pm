package DivinumOfficium::FileIO;
use strict;
use warnings;
use utf8;

# Text-based IO for Divinum Officium Project.
#
BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(do_read do_write);
}

# do_read(filename)
#
# Read a data file, assumed to be text, and return array of its lines.
# Returns () if nothing can be read.
sub do_read($) {
  my $file = shift;

  if (open(INP, '<:encoding(UTF-8)', $file)) {
    local $/;    # Slurp
    local ($_) = <INP>;
    close INP;
    s/^\x{FEFF}//;
    split(/\r?\n/);
  } else {
    ();
  }
}

# do_write
# Now we're in charge.  Write in utf-8, never mind.
sub do_write($@) {
  my $file = shift;

  if (open(OUT, ">:encoding(utf-8)", $file)) {
    print OUT for @_;
    close OUT;
    return 1;
  }
}
1;
1;
