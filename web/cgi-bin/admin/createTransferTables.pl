#!/usr/bin/perl

#--------------------------------------------------------------------
# createTransferTables.pl
# Created: December 15, 2025
# creating Transfer tables for Dioceses
# To be run in folder above divinum-officium

use utf8;

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Cookie;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use Time::Local;

use locale;
use lib "$Bin/..";
use DivinumOfficium::FileIO qw(do_read do_write);
use DivinumOfficium::Date qw(geteaster get_sday day_of_week monthday ydays_to_date);
use DivinumOfficium::Directorium qw(get_from_directorium transfered );
use DivinumOfficium::RunTimeOptions qw(check_version);

binmode(STDOUT, ":encoding(UTF-8)");    #  Ensure UTF-8 when printing status in Terminal

our $q = new CGI;

our @dayname;                           #0=Adv|{Nat|Epi|Quadp|Quad|Pass|Pent 1=winner|2=commemoratio/scriptura
our $winner;                            #the folder/filename for the winner of precedence
our $commemoratio;                      #the folder/filename for the commemorated
our $scriptura;                         #the folder/filename for the scripture reading (if winner is sancti)
our $commune;                           #the folder/filename for the used commune
our $communetype;                       #ex|vide
our $rank;                              #the rank of the winner
our $vespera;                           #1 | 3 index for ant, versum, oratio

#filled by precedence()
our %winner;                            #the hash of the winner
our %commemoratio;                      #the hash of the commemorated
our %scriptura;                         #the hash for the scriptura
our %commune;                           # the hash of the commune
our $rule;                              # $winner{Rank}
our $communerule;                       # $commune{Rank}
our $duplex;                            #1= simplex 2=semiduplex, 3=duplex 0=rest

#4 = duplex majus, 5=duplex II class 6=duplex I class 7=higher
our $initia;
our $dayofweek;

our $border;
our $smallblack;
our $smallfont;

require "../DivinumOfficium/SetupString.pl";
require "../horas/horascommon.pl";
require "../DivinumOfficium/dialogcommon.pl";
require "../horas/webdia.pl";
require "../DivinumOfficium/setup.pl";

#require "../horas/horas.pl";
#require "../horas/horasscripts.pl";
#require "../horas/specials.pl";
require "../horas/specmatins.pl";
require "../horas/monastic.pl";

#require "../horas/altovadum.pl";
#require "../horas/horasjs.pl";
#require "../horas/officium_html.pl";

#*** get parameters
our $compare = 0;
my $officium = 'officium.pl';

if ($compare) {
  $officium = "C$officium" unless $officium =~ /^[PC]/;
} else {
  $officium =~ s/^C//;
}

# use the right date arg
my $date_arg = $officium =~ /Pofficium/ ? 'date1' : 'date';

my $officium_name = $officium =~ /missa/ ? 'missa' : 'horas';

$htmlurl = '../../www/horas';
$datafolder = "../../www/horas";
$link = 'blue';
$visitedlink = 'blue';
$dialogbackground = '#eeeeee';
$dialogfont = 'maroon';
$border = '1';
$cookieexpire = '+1y';
$savefiles = '0';
$lang = 'Latin';

my $ckname =
  ($officium_name =~ /officium/) ? "${officium_name}go" : ($compare) ? "${officium_name}gc" : "${officium_name}g";
my $csname = $compare ? 'generalc' : 'general';

my $setupsave = strictparam('setup');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies("${officium_name}p", 'parameters');
  getcookies($ckname, $csname);
}

set_runtime_options($csname);         #$expand, $version, $lang2
our $votive = 'Hodie';
set_runtime_options('parameters');    # priest, lang1 ... etc

# Configuration
my $basedir = './divinum-officium/web/www';    # Directory for the Database
my @versions = (
  'Tridentine - 1570',
  'Tridentine - 1888',
  'Tridentine - 1906',
  'Divino Afflatu - 1939',
  'Divino Afflatu - 1954',
  'Rubrics 1960 - 1960',
  'Rubrics 1960 - 2020 USA',
  'Monastic Tridentinum 1617',
  'Monastic Divino 1930',
  'Monastic - 1963',
);
my @versions2 = ('1570', '1888', '1906', 'DA', '1954', '1960', 'Newcal', 'M1617', 'M1930', 'M1963');

print "This is createTransferTables.pl\n";
our $dioecesis = shift or die "Usage: $0 (Generale|Urbis|etc.) year\n";
my $kyear = shift or die "Usage: $0 (Generale|Urbis|etc.) year\n";
my $tempVersion = shift;
our $version;

#my $parts = shift or die "Usage: $0 (all|horas|missa) (all|Sancti|Tempora|Commune) (base|Latin|...)\n";
#my $folders = shift or die "Usage: $0 (all|horas|missa) (all|Sancti|Tempora|Commune) (base|Latin|...)\n";
#my $lang = shift or die "Usage: $0 (all|horas|missa) (all|Sancti|Tempora|Commune) (base|Latin|...)\n";
#my $outputfile = shift;
#$outputfile ||= './test_sitemap.csv';

my $kmonth = 14;
use constant MONTHLENGTH => ('', 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, '', 365);
my $to = (MONTHLENGTH)[$kmonth];

if (($kmonth == 2 || $kmonth == 14) && leapyear($kyear)) { $to++; }    # in February or for the whole year (14)

my @easter = geteaster($kyear);
my $easter = $easter[1] * 100 + $easter[0];

my $letter = ($easter - 319 + ($easter[1] == 4 ? 1 : 0)) % 7;
my @letters = ('a', 'b', 'c', 'd', 'e', 'f', 'g');

my @dpx1, @dpx2, @dxm, @dpx, @sdx, @transferTable, %transferVer, %transferStrings, %dirge;

push(@transferTable, "Transfer Table Diœcesis $dioecesis; Littera Dominicales: $letters[$letter]; Easter: $easter");

for my $ver (1 .. @versions) {

  if ($tempVersion) { $ver = $tempVersion; }
  $version = $versions[$ver - 1];
  $verT = $versions2[$ver - 1];
  push(@transferTable, "\n$version: $verT");
  print "\n Executing $version\n";
  $transferVer{$verT} = ();
  $dirge{$verT} = ();
  my $dirgemonth = 1;

  my $ranklimit =
      $version =~ /1570|1617/ ? 2.2
    : $version =~ /1888|1906/ ? 4
    : $version =~ /196/ ? 6
    : 5;
  my $ranklimit2 = $version =~ /1888|1906/ ? 2.2 : $ranklimit;

  for my $cday (1 .. $to) {
    my ($day, $month, $year) = ydays_to_date($cday, $kyear);
    my $date1 = sprintf("%02i-%02i-%04i", $month, $day, $year);
    my $d1 = sprintf("%02i", $day);

    my %kalsaint, $kalRank, @kalRank;

    precedence($date1);

    my $sday = get_sday($month, $day, $year);
    my $transfertemp = get_from_directorium('tempora', $version, $sday, 0, $dioecesis);
    $transfertemp =~ s/;;.*//;    # strip dioecesis flag and discard

    if ($transfertemp =~ s/::([a-g])//) {

      my $litdom = $1;

      if (leapyear($year) && $sday =~ /^(?:01|02-[01]|02-2[01239])/) {
        $transfertemp = '' unless $litdom =~ $letters[$letter - 6];
      } else {
        $transfertemp = '' unless $litdom =~ $letters[$letter];
      }
    }
    my $kalentries = $transfertemp || get_from_directorium('kalendar', $version, $sday);

    @commemoentries = split("~", $kalentries);

    foreach $kalentry (@commemoentries) {
      if ($kalentry) {
        if ($kalentry !~ /tempora/i) {

          #$kalentry = subdirname('Sancti', $version) . "$kalentry";
        }    # add path to Sancti folder if necessary
        else {
          $kalentry = subdirname('Tempora', $version) . ($kalentry =~ s/Tempora\///r);
        }
      }
    }
    my $kalFile = shift @commemoentries;    # get the filename for the Sanctoral office from the Kalendarium
    $kalFile = subdirname('Sancti', $version) . $kalFile;

    if (checklatinfile(\$kalFile)) {
      $kalsname = "$kalFile.txt";
      %kalsaint = %{setupstring('Latin', $kalsname)};
      $kalRank = $kalsaint{Rank};
      $kalRank =~ s/\s*$//;
      @kalRank = split(";;", $kalRank);
    } else {
      %kalsaint = {};
      $kalRank = '';
      @kalRank = ();
    }

    my @winRank = split(";;", $winner{Rank});

    if (
      $winner ne $kalsname
      && ($kalRank[2] >= $ranklimit
        || ($version =~ /1888|1906/ && $kalRank[2] >= 3 && $kalRank[0] =~ /Ecclesiæ Doctoris/))
      && $kalRank[0] !~ /Dominica|Sabbato|in(?:.*)Octava/i
    ) {
      print "$sday :: $kalentries ::: $winner :::: $kalRank \n";

      # We need to transfer this saint
      $kalFile =~ s/SanctiM?\///;

      if ($kalRank[2] >= 6 || $kalFile eq '03-25') {
        if ($kalFile eq '03-25') {
          unshift(@dpx1, $kalFile);
        } else {
          push(@dpx1, $kalFile);
        }
        push(@transferTable, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        push(@{$transferVer{$verT}}, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        print "Stashed Duplex I. classis: $kalFile ::: Keeping: " . join('~', @commemoentries) . "\n";
      } elsif ($kalRank[2] >= 5) {
        push(@dpx2, $kalFile);
        push(@transferTable, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        push(@{$transferVer{$verT}}, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        print "Stashed Duplex II. classis: $kalFile ::: Keeping: " . join('~', @commemoentries) . "\n";
      } elsif ($kalRank[2] >= 4 && $version !~ /1570/) {
        push(@dxm, $kalFile);
        push(@transferTable, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        push(@{$transferVer{$verT}}, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        print "Stashed Duplex majus: $kalFile ::: Keeping: " . join('~', @commemoentries) . "\n";
      } elsif ($kalRank[2] >= 3) {
        push(@dpx, $kalFile);
        push(@transferTable, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        push(@{$transferVer{$verT}}, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        print "Stashed Duplex minus: $kalFile ::: Keeping: " . join('~', @commemoentries) . "\n";
      } else {
        push(@sdx, $kalFile);
        push(@transferTable, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        push(@{$transferVer{$verT}}, "$sday=" . join('~', @commemoentries)) if @commemoentries;
        print "Stashed Semiduplex: $kalFile ::: Keeping: " . join('~', @commemoentries) . "\n";
      }

      if (
           $winRank[2] < 2.19
        && $winRank[0] !~ /in(?:fra)? Octav|Dominica/i
        && $version =~ /Trident/i
        && (
          (
            ($dayname[0] =~ /Epi|Pent|Quadp[12]/i || ($dayname[0] =~ /Quadp3/ && $dayofweek <= 2))
            && $dirgemonth <= $month
          )
          || ($dayname[0] =~ /Adv|Quad[1-5]/ && $dayofweek == 1)
        )
      ) {
        push(@{$dirge{$verT}}, "$sday");
        $dirgemonth = $month + 1;
      }
    } elsif ($winRank[2] < $ranklimit2
      || ($version =~ /Trident/i && $winRank[0] =~ /(?:Feria|Sabbato).*infra Octavam Corporis/i && (@dpx1 || @dpx2)))
    {
      my $transfer = '';

      if (@dpx1) {
        $transfer = shift(@dpx1);
      } elsif (@dpx2) {
        $transfer = shift(@dpx2);
      } elsif (@dxm) {
        $transfer = shift(@dxm);
      } elsif (@dpx) {
        $transfer = shift(@dpx);
      } elsif (@sdx) {
        $transfer = shift(@sdx);
      }

      if ($transfer) {
        print "$sday ::Transfer $sday=$transfer \n";
        push(@transferTable, "$sday=$transfer");
        push(@{$transferVer{$verT}}, "$sday=$transfer");
        $kalFile =~ s/SanctiM?\///;

        $transferTable[-1] .= "~$kalFile" if $kalFile;
        $transferVer{$verT}[-1] .= "~$kalFile" if $kalFile;
        $transferTable[-1] .= "~" . join('~', @commemoentries) if @commemoentries;
        $transferVer{$verT}[-1] .= "~" . join('~', @commemoentries) if @commemoentries;
      } elsif (
        $winRank[2] < 2.19
        && $winRank[0] !~ /in(?:fra)? Octav|Dominica/i
        && $version =~ /Trident/i
        && (
          (
            ($dayname[0] =~ /Epi|Pent|Quadp[12]/i || ($dayname[0] =~ /Quadp3/ && $dayofweek <= 2))
            && $dirgemonth <= $month
          )
          || ($dayname[0] =~ /Adv|Quad[1-5]/ && $dayofweek == 1)
        )
      ) {
        push(@{$dirge{$verT}}, "$sday");
        $dirgemonth = $month + 1;
      }
    } else {

      #      print "$sday :::: $winner :: $dpx1[0]\n" if $winner =~ /Sancti/;

      if (@dpx1) {
        if ($winner =~ /$dpx1[0]/) {
          print "$sday :::: Dropped Duplex I. classis $dpx1[0]\n";
          shift(@dpx1);
        }
      } elsif (@dpx2) {
        if ($winner =~ /$dpx2[0]/) {
          print "$sday :::: Dropped Duplex II. classis $dpx2[0]\n";
          shift(@dpx2);
        }
      } elsif (@dxm) {
        if ($winner =~ /$dxm[0]/) {
          print "$sday :::: Dropped Duplex majus $dxm[0]\n";
          shift(@dxm);
        }
      } elsif (@dpx) {
        if ($winner =~ /$dpx[0]/) {
          print "$sday :::: Dropped Duplex minus $dpx[0]\n";
          shift(@dpx);
        }
      } elsif (@sdx) {
        if ($winner =~ /$sdx[0]/) {
          print "$sday :::: Dropped Semiduplex $sdx[0]\n";
          shift(@sdx);
        }
      }
    }
  }    # for days of year

  foreach my $vEntry (@{$transferVer{$verT}}) {
    my ($testDay, $testEntry) = split('=', $vEntry);
    my $transfer = get_from_directorium('transfer', $version, $testDay, $year, 'Generale');
    push(@{$transferStrings{$vEntry}}, $verT) unless $testEntry eq $transfer;
  }

  last if $tempVersion;
}    # for Versions

print "\n\n";
print join("\n", @transferTable);
print "\n\n";
print "$transferTable[0]\n";

foreach my $vEntry (sort keys %transferStrings) {
  print "$vEntry;;" . join(" ", @{$transferStrings{$vEntry}}) . "\n";
}

foreach my $dirV (sort keys %dirge) {
  print "dirge=" . join(" ", @{$dirge{$dirV}}) . ";;$dirV\n" if @{$dirge{$dirV}};
}

print "\n\tDone.\n";
1;
