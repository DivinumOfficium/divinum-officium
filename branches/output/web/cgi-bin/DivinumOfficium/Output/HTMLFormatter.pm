# Wrapper around the old-style HTML formatting code. The main purpose of this
# module is to establish a clean interface with the rest of the code to ease
# the migration to a CSS-defined design.

package DivinumOfficium::Output::HTMLFormatter;

use strict;
use warnings;

use Carp;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  # TODO: Stop exporting this when it's no longer called from outside the
  # package.
  our @EXPORT = qw(setfont);
}


my $singleton = 0;


#*** new($class, %formats)
# Constructs an HTMLFormatter object. %formats is a hash of formatting strings
# as given in horas.setup. For each key in %formats, a method will be generated
# that formats text accordingly.
sub new
{
  my $class = shift;
  my %formats = @_;

  croak "Tried to create second instance of singleton $class" if $singleton++;

  foreach my $format (keys(%formats))
  {
    no strict 'refs';

    # Make sure we don't redefine or override any methods.
    croak "Illegal format name '$format'" if $class->can($format);
    *{$format} = sub { setfont($formats{$format}, $_[1]) };
  }

  return bless \{}, $class;
}


###############################################################################
# Internal subroutines.
###############################################################################


#*** setfont($font, $text)
# input font description is "[size][ italic][ bold] color" format, and the text
# returns <FONT ...>$text</FONT> string
sub setfont
{
  my $istr = shift;
  my $text = shift;
  
  my $size = ($istr =~ /^\.*?([0-9\-\+]+)/i) ? $1 : 0;
  my $color = ($istr =~ /([a-z]+)\s*$/i)  ? $1 : '';
  if ($istr =~ /(\#[0-9a-f]+)\s*$/i || $istr =~ /([a-z]+)\s*$/i) {$color = $1;}

  my $font = "<FONT ";
  if ($size) {$font .= "SIZE=$size ";}
  if ($color) {$font .= "COLOR=\"$color\"";}
  $font .= ">";
  if (!$text) {return $font;}

  my $bold = '';
  my $bolde = '';
  my $italic = '';
  my $italice = '';
  if ($istr =~ /bold/) {$bold = "<B>"; $bolde = "</B>";}
  if ($istr =~ /italic/) {$italic = "<I>"; $italice = "</I>";}
  return "$font$bold$italic$text$italice$bolde</FONT>";
}

1;

