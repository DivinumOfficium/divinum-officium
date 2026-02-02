package DivinumOfficium::FindBinFix;
use strict;
use warnings;
use Apache2::RequestRec ();
use Apache2::Const -compile => qw(OK);
use File::Basename ();

# Fix FindBin for mod_perl: set $Bin based on actual script location before each request
sub handler {
    my $r = shift;
    my $filename = $r->filename;
    if ($filename && $filename =~ /\.pl$/) {
        $FindBin::Bin = File::Basename::dirname($filename);
        $FindBin::RealBin = $FindBin::Bin;
    }
    return Apache2::Const::OK;
}

1;
