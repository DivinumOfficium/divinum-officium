#!/usr/bin/perl
use utf8;
use open ':encoding(UTF-8)';
use warnings;
use strict;
use Getopt::Long 'GetOptions';
use Date::Format 'asctime';
use URI;
use URL::Encode 'url_encode';
use Date::Calc
  'check_date',
  'Date_to_Days',
  'Add_Delta_Days',
  'Decode_Date_US',
  'Today';
use File::Temp 'tempfile';
use Data::Dumper 'Dumper';             # DEBUG

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my ($y, $m, $d) = Today();
my $from = "$m-$d-$y";
my $to;

my @prayers = (
  'Matutinum', 'Laudes', 'Prima', 'Tertia',
  'Sexta', 'Nona', 'Vespera', 'Completorium', 'SanctaMissa'
);
my $prayers = join(' ', @prayers);
my %prayers = map (($_,$_), @prayers);

my @versions = (
  'Trident 1570',
  'Trident 1910',
  'Divino Afflatu',
  'Reduced 1955',
  'Rubrics 1960',
  'Monastic',
  'Ordo Praedicatorum'
);
my $versions = join('|', @versions);

my @actions = ('pray', 'kalendar', 'popup');
my $actions = join(' ', @actions);
my %actions = map (($_,$_), @actions);

my $prayer;
my $action = 'pray';
my $compare;
my $mobile;
my $version;
my $update;
my $from_arg;
my $jar;
my $cookies;

my $path;
my @kvp = ();

my $path_query;
my $dir = '';
my $base_url = 'http://divinumofficium.com/';
sub resource_to_filename($);

my $no_timestamp;

my $help;

my $USAGE = <<USAGE ;
Establish divinumofficium web results for a given hour and a range of dates.
Usage:
  divinum-get --prayer=PRAYER --version=VERSION [option..]
  divinum-get --path=URL [option..]
  divinum-get --update [option..] FILE [FILE..]

Options:
Specify a page by options:
--action=ACTION  what to do [default: $action]
--prayer=PRAYER  an Hour of the Divine Office, or the Mass
                 required for action=pray and action=popup
--version=VERSION rubric version [no default]
--compare        retrieve "comparison" variant if any
--mobile         retrieve "mobile" variant if any
--kvp=KEY=VALUE  additional query parameter (unchecked)

Or omit all the above and instead specify explicitly:
--path=URL       URL to download relative to base

Specify a range of dates: each date results in a new file
--from=MM-DD-YYYY start of date range [default: $from]
--to=MM-DD-YYYY   end of date range [default: from-date]

--dir=DIR      put downloads into DIR
               [default: current directory]

Or omit all the above and refresh existing test case files:
--update         replace content of existing test case
                 uses URL from existing test case
                 can be rebased using --base
                 other options are not allowed
                 warning: overwrites existing files
--cookie         send previously received cookies
                 [default: resend previously sent cookies]

Other options:
--base=BASE    base URL [default: $base_url]
--no-timestamp suppress timestamp in test files
--help         this

--jar=COOKIEJAR   cookies to send to server (see curl -b)

Cookies are saved in the output if specified or received.
Cookie domain, path, and expiry date are not observed.

PRAYER   [$prayers]
VERSION  [$versions]
ACTION   [$actions]
VERSION can be abbreviated as long as it's unambiguous.
BASE     A URL: the schema, authority, and path are used
PATH     A URL: its path extends the base, and its query is used
KEY      Any name is accepted.
VALUE    Any value (string) is accepted.
FILE     An existing test case file, overwritten by --update

All HTTP is done using GET.

Downloaded files are named by summarizing their path and query.

To replay tests, use divinum-replay.
USAGE

my $version_arg;  # possibly  abbreviated
GetOptions(
  'prayer=s' => \$prayer,
  'action=s' => \$action,
  'compare' => \$compare,
  'mobile' => \$mobile,
  'version=s' => \$version_arg,
  'path=s' => \$path,
  'update' => \$update,
  'from=s' => \$from_arg,
  'to=s' => \$to,
  'kvp=s' => \@kvp,
  'base=s' => \$base_url,
  'jar=s' => \$jar,
  'cookies' => \$cookies,
  'dir=s' => \$dir,
  'no-timestamp' => \$no_timestamp,
  'help' => \$help
) or die $USAGE;

if ( $help )
{
  print STDOUT $USAGE;
  exit 0;
}

# Assemble parameters.
my %params = ();
for ( @kvp )
{
  $params{$1}=$2 if /^(\w+)=(\S*)\s*$/;
}

# Construct path and parameters as required.

if ( $update )
{
  die "Do not specify --prayer with --update\n" if $prayer;
  die "Do not specify --path with --update\n" if $path;
  die "Do not specify --version with --update\n"
    if $version_arg;
  die "Do not specify --kvp with --update\n" if @kvp;

  $path = '';
}
elsif ( $path )
{
  die "Do not specify --prayer with --path\n" if $prayer;
  die "Do not specify --version with --path\n"
    if $version_arg;
}
else
{
  die "--action=$action is unknown\n"
    unless $actions{$action};

  die "Specify a --version.\n" unless $version_arg;

  # Translate version_arg to version
  my $matches = 0;
  for my $v ( @versions )
  {
    if ( index($v, $version_arg) >= 0 )
    {
      $version = $v;
      $matches = $matches + 1
    }
  }
  die "error: --version=$version_arg is ambiguous\n"
    unless $matches < 2;
  die "error: --version=$version_arg is invalid\n"
    unless $matches > 0;
  $params{version} = $version;
 
  # Construct path and required parameters.

  $path = 'cgi-bin/';
  if ( $action eq 'kalendar' )
  {
    $path .= 'horas/kalendar.pl';
    $params{compare} = 1 if $compare;
  }
  else # $action eq 'pray' || $action eq 'popup'
  {
    # Assign $path for an Hour, or Mass.

    die "--pray=$prayer is unknown\n"
      unless $prayers{$prayer};
    $params{command} = "pray$prayer";

    if ( $action eq 'pray' )
    {
      if ( $prayer =~ /Missa/i )
      {
        if ($compare)
        {
          $path .= 'missa/Cmissa.pl';
        }
        else
        {
          $path .= 'missa/missa.pl';
        }
        warn "No --mobile exists for Missa\n" if $mobile;
      }
      else
      {
        if ( $mobile )
        {
          $path .= 'horas/Pofficium.pl';
        }
        elsif ( $compare )
        {
          $path .= 'horas/Cofficium.pl'
        }
        else
        {
          $path .= 'horas/officium.pl';
        }
      }  
    }
    elsif ( $action eq 'popup' )
    {
      if ( $prayer =~ /Missa/i )
      {
        $path .= 'missa/mpopup.pl';
      }
      else
      {
        $path .= 'horas/popup.pl';
      }
    }
  }
}

# Form the initial URL.
$base_url .= '/' if $base_url !~ m{/$};
my $url = URI->new($base_url)->canonical;
if ( $path )
{
  if ( $path =~ m{^/} )
  {
    $url->path_query($path);
  }
  else
  {
    $url->path_query($url->path.$path);
  }
}
#print STDERR "init URL: $url\n";

# Validate and default the range: dates, or files.
# At this point $path is true unless --update.

my ($y1,$m1,$d1);
my ($y2,$m2,$d2);
my $which = $prayer ? '--pray' : '--path';

# Files or dates required
if ( $update )
{
  die "Specify files for --update\n" if @ARGV < 1;
  die "Don't specify dates for --update\n"
    if $from_arg || $to;
}
else
{
  die "Do not specify files for $which\n" if @ARGV;

  # Use dates for both --path and --pray
  $from = $from_arg if $from_arg;
  $to = $from unless $to;

  die "Invalid date $from .\n"
    unless ($y1,$m1,$d1) = Decode_Date_US($from);
  die "Invalid date $to .\n"
    unless ($y2,$m2,$d2) = Decode_Date_US($to);
  die "End date must be on or after start date.\n"
    unless Date_to_Days($y1,$m1,$d1) <= Date_to_Days($y2,$m2,$d2);
}

# Process directory option.
if ( $dir )
{
  die "Don't specify --dir with --update\n"
    if $update;
  mkdir $dir;
  die "Can't find or create directory $dir\n"
    unless -d $dir;
}

# Ingest sending cookies from $jar if specified.
# If --cookies, will ingest from test code instead.

my %snd_cookies = ();

if ( $update )
{
  die "Don’t specify both --cookies and --jar with --update.\n"
    if $cookies && $jar;
}
else
{
  die "Don’t specify --cookies with $which.\n" if $cookies;
}

if ( $jar )
{
  open COOKIES, "<$jar" or die "Cannot read $jar.\n";
  for ( <COOKIES> )
  {
    chomp;
    if ( /^Set-Cookie:\s*(.*)$/ )
    {
      # Header-style jar
      for ( split /;/, $1 )
      {
        $snd_cookies{$1} = $2 if /^\s*(\w+)=(\S*)\s*$/;
      }
    }
    elsif ( /\t/ )
    {
      # Netscape-style jar: ignore hostname etc
      my @c = split /\t/;
      $snd_cookies{$c[5]} = $c[6] if @c > 6;
    }
  }
}

# Iterate all the cases, be it by date or by file name.
# At this point $url only needs ->query to be set each time.
# Except for $update, when the $path will be adjusted too.

my $update_base_path = $url->path;
$update_base_path =~ s {/$} {};
#print STDERR "UBP: '$update_base_path'\n";

while ( $update?
  @ARGV :
  Date_to_Days($y1,$m1,$d1) <= Date_to_Days($y2,$m2,$d2)
)
{
  my $in_pathname;
  my $out_pathname;

  my @result;

  # Revision of previous test case?
  if ( $update )
  {
    # Get URL from the test case.
    
    $in_pathname = $ARGV[0]; # shift later
    open IN, "<$in_pathname" or do {
      warn "Cannot read $in_pathname.\n";
      next;
    };
    my $head = scalar <IN>;
    $head =~ /DIVINUM OFFICIUM TEST CASE/ or do
    {
      warn "$in_pathname doesn’t look like a test case\n";
      next;
    };
    my $in_url = URI->new (scalar <IN>);

    # Use its path and query.
    $url->path($update_base_path.$in_url->path);
    $url->query($in_url->query);

    # Maybe read sending cookies from previous
    # Cookie or Set-Cookie.
    %snd_cookies = ();
    for ( <IN> )
    {
      chomp;
      if ( $cookies )
      {
        $snd_cookies{$1} = $2 if /^Set-Cookie:(\w+)=(.*)$/;
      }
      else
      {
        $snd_cookies{$1} = $2 if /^Cookie:(\w+)=(.*)$/;
      }
    }
    #print Dumper(\%snd_cookies);
    close IN;
  }

  # This is a new test case not an update.
  else
  {
    my $datekey = $path =~ /Pofficium/? "date1": "date";
    $params{$datekey}="$m1-$d1-$y1";

    # Encode for URL transmission
    $_ = url_encode($_) for values %params;

    #print STDERR Dumper(\%params);             # DEBUG
    $url->query_form(\%params);
  }
  print STDERR "URL: $url\n";

  # Assemble request (as curl command string).

  my $cmd;
  my ($rcv_jar_h, $rcv_jar_fn) = tempfile(UNLINK=>1);

  $cmd = "curl -s";
  $cmd .= " -b $_=$snd_cookies{$_}" for sort keys %snd_cookies;
  $cmd .= " -c $rcv_jar_fn";
  $cmd .= " '$url'";

  # Finally do the download.

  #print STDERR "\$cmd=$cmd\n";                # DEBUG
  @result = `$cmd`;

  # Determine output file name.

  if ($update)
  {
    $out_pathname = $in_pathname;
  }
  else
  {
    $out_pathname = resource_to_filename($url->path_query);
    $out_pathname = "$dir/$out_pathname" if $dir;
  }

  # Record results.

  open OUT, ">$out_pathname" or die "Can't write $out_pathname\n";
  print STDOUT "$out_pathname\n";

  # Header line maybe with timestamp.
  print OUT "DIVINUM OFFICIUM TEST CASE ";
  my @localtime = localtime;
  my $timestamp_nl = $no_timestamp ? "\n" : asctime(@localtime);
  print OUT $timestamp_nl;

  # Actual used URL.
  print OUT "$url\n";

  # Sent cookies first if any.
  for ( sort keys %snd_cookies )
  {
    print OUT "Cookie:$_=$snd_cookies{$_}\n";
  }

  # Received cookies next if any.
  open $rcv_jar_h, "<$rcv_jar_fn";
  for ( <$rcv_jar_h> )  
  {
    chomp;
    # Header-style jar?
    if ( /^Set-Cookie:\s*(.*)$/ )
    {
      for ( split /;/, $1 )
      {
        print OUT "Set-Cookie:$1=$2\n" if /^\s*(\w+)=(\S*)\s*$/;
      }
    }

    # Netscape-style jar: ignore hostname etc?
    elsif ( /\t/ )
    {
      my @c = split /\t/;
      print OUT "Set-Cookie:$c[5]=$c[6]\n" if @c > 6;
    }
  }
  close $rcv_jar_h;

  # All the actual content.
  print OUT @result;

  # That’s all for this case.
  close OUT;
}
continue
{
  if ( $update )
  {
    shift @ARGV;
  }
  else
  {
    ($y1,$m1,$d1) = Add_Delta_Days($y1,$m1,$d1,1);
  }
}

# Ad hoc conversion of resource identifier to mnemonic filename.
sub resource_to_filename($)
{
  my $resource = shift;

  # Remove common path, param name, punctuation, etc,
  # and join the result using -.
  $resource =~ s {cgi-bin} {};
  $resource =~ s {^/*} {};
  $resource =~ s {\.pl} {}g;
  $resource =~ s {command=(pray|setup)} {}g;
  $resource =~ s {\w+=} {}g;
  $resource =~ s {%[0-9a-f][0-9a-f]} { }i; # cheap urldecode : absolutely works
  $resource =~ s {^\W*} {};

  my $result = join ('-', split(/\W+/, $resource)) || 'index';
  return $result;

}
