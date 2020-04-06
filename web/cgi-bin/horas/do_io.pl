# do_io
use utf8;

# Text-based IO for Divinum Officium Project.
#
# do_read(filename)
#
# Read a data file, assumed to be text, and return array of its lines.
# Returns () if nothing can be read or decoded.
# Returned data are decoded to internal form.
# This sub tries to guess the encoding of the input.
# Try encodings in order, looking for "text" = ASCII, accented letters, a few symbols.
# If find one, use it.
# If none, decode as utf-8 and hope for the best.
use Encode;
my @encodings = (Encode::find_encoding('cp1252'), Encode::find_encoding('utf-8'));

sub do_read($) {
  my $file = shift;
  my $content;

  if (open(INP, $file)) {

    # Slurp
    local $/;
    my $data = <INP>;
    close INP;
    my $decoded = undef;

    for my $encoding (@encodings) {

      # Try this encoding.
      $content = $encoding->decode($data);

      # If the text has a UTF-8 BOM but happens otherwise to be plain
      # text, the heuristic will misidentify it. Avoid this.
      next if $content =~ /^\x{ef}\x{bb}\x{bf}/;

      # Furthermore, a BOM will be returned in the decoded stream. Strip
      # it.
      $content =~ s/^\x{feff}//;

      # Check for characters we want, throughout.
      # Basically all Latin, Greek, Semitic, plus puncutation and crosses.
      $decoded = ($content =~ /^(?:[\x{01}-\x{1F} -~«»¡¿À-ݿḀ-῾‐-‡✙-✥])*$/ox);
      last if $decoded;
    }
    my @result = (
      $content =~ /\r\n/
      ? split(/\r\n/, $content)
      : split(/\n/, $content)
    );
    return @result;
  } else {
    return ();
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
