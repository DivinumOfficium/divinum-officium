# do_io
#
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

@encodings = ( Encode::find_encoding('cp1252'), Encode::find_encoding('utf-8') );

sub do_read($)
{
    my $file = shift;
    my %content;

    if ( open(INP, $file) )
    {
        # Slurp
        local $/;
        my $data = <INP>;
        close INP;

        my $decoded = undef;

        for my $encoding ( @encodings )
        {
            # Check for characters we want, throughout.
            $content = $encoding->decode($data);
            $decoded = ($content =~ /^(?:[\x{01}-\x{1F}\x{20}-\x{7E}\x{AB}\x{BB}\x{A1}\x{BF}\x{BF}-\x{750}\x{1E00}-\x{1FFE}\x{2010}-\x{2021}\x{2719}-\x{2721}])*$/ox);
            last if $decoded;
        }

        my @result = ($content =~ /\r\n/ ?
                    split(/\r\n/, $content) :
                    split(/\n/, $content)
                );

        return @result;
    }
    else
    {
        return ()
    }
}

# do_write
# Now we're in charge.  Write in utf-8, never mind.
sub do_write($@)
{
    my $file = shift;
    if ( open(OUT, ">:encoding(utf-8)", $file) )
    {
        print OUT for @_;
        close OUT;
        return 1;
    }
}
1;
