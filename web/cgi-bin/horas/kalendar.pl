#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office Kalendarium
package main;

# use warnings;
# use strict;

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Cookie;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use Time::Local;

use locale;
use lib "$Bin/..";
use DivinumOfficium::Main qw(liturgical_color);
use DivinumOfficium::Directorium qw(dirge);
use DivinumOfficium::Date qw(ydays_to_date);
use DivinumOfficium::RunTimeOptions qw(check_version);

#*** common variables arrays and hashes
our $error;
our $debug;

#filled by occurence()
our @dayname;         #0=Adv|{Nat|Epi|Quadp|Quad|Pass|Pent 1=winner|2=commemoratio/scriptura
our $winner;          #the folder/filename for the winner of precedence
our $commemoratio;    #the folder/filename for the commemorated
our $scriptura;       #the folder/filename for the scripture reading (if winner is sancti)
our $commune;         #the folder/filename for the used commune
our $communetype;     #ex|vide
our $rank;            #the rank of the winner
our $vespera;         #1 | 3 index for ant, versum, oratio

#filled by precedence()
our %winner;          #the hash of the winner
our %commemoratio;    #the hash of the commemorated
our %scriptura;       #the hash for the scriptura
our %commune;         # the hash of the commune
our $rule;            # $winner{Rank}
our $communerule;     # $commune{Rank}
our $duplex;          #1= simplex 2=semiduplex, 3=duplex 0=rest
                      #4 = duplex majus, 5=duplex II class 6=duplex I class 7=higher
our $initia;
our $dayofweek;

our $border;
our $smallblack;
our $smallfont;

require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/horascommon.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/../DivinumOfficium/setup.pl";
require "$Bin/monastic.pl";

binmode(STDOUT, ':encoding(utf-8)');
our $q = new CGI;

#*** get parameters
our $compare = strictparam('compare') || 0;
my $officium = strictparam('officium') || 'officium.pl';

if ($compare) {
  $officium = "C$officium" unless $officium =~ /^[PC]/;
} else {
  $officium =~ s/^C//;
}

# use the right date arg
my $date_arg = $officium =~ /Pofficium/ ? 'date1' : 'date';

my $officium_name = $officium =~ /missa/ ? 'missa' : 'horas';
getini("horas");    #files, colors

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

#*** saves parameters
$setupsave = savesetup(1);
$setupsave =~ s/\r*\n*//g;

our $version1 = check_version(our $version) || (error("Unknown version: $version1") && 'Rubrics 1960 - 1960');
our $version2 = check_version($version2) || '';
if ($version1 eq $version2) { $version2 = 'Divino Afflatu - 1954'; }
if ($version1 eq $version2) { $version2 = 'Rubrics 1960 - 1960'; }

my ($xmonth, $xday, $xyear) = split('-', strictparam($date_arg) || gettoday());
our $kmonth = strictparam('kmonth') || $xmonth;
our $kyear = strictparam('kyear') || $xyear;

my $mode = $kmonth == 15 ? 'kal' : 'ordo';
require "$Bin/kalendar/$mode.pl";

if (strictparam('format') eq 'ical') {
  require "$Bin/kalendar/ical.pl";
  ical_output();
} else {
  html_output($mode);
}

# End of program

#entries 13 (placeholder) and 14 (actually) are added for the Whole Year (Totus) Option
use constant MONTHNAMES => qw/''
  Januarius Februarius Martius Aprilis Maius Junius
  Julius Augustus September October November December/;
use constant MONTHLENGTH => ('', 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, '', 365);
use constant DAYNAMES => qw/Dom. F.II F.III F.IV F.V F.VI Sabb./;

# output html table with entries

sub kalendar_table {
  my ($kyear, $kmonth, $mode) = @_;
  my $background = (our $whitebground) ? ' class="contrastbg"' : '';
  my $cols;
  my $output = qq(<P ALIGN="CENTER">\n<TABLE BORDER="$border" WIDTH="90%" CELLPADDING="3" $background>\n);

  if ($mode eq 'kal') {
    $kmonth = 14;
    $kyear = 1977;
    $output .= "<TR><TH>C.E.</TH><TH>D.L.</TH><TH></TH><TH>Dies</TH><TH></TH></TR>\n";
    $cols = 5 + $compare;
  } else {
    $output .= "<TR><TH>Dies</TH><TH>de Tempore</TH><TH>Sanctorum</TH><TH>Vespera</TH><TH>d.h.</TH></TR>\n";
    $cols = 5;

    #    $output .= "<TR><TH>Dies</TH><TH>de Tempore</TH><TH>Sanctorum</TH><TH>d.h.</TH></TR>\n";
    #    $cols = 4;
  }

  my $to = (MONTHLENGTH)[$kmonth];
  if (($kmonth == 2 || $kmonth == 14) && leapyear($kyear)) { $to++; }    # in February or for the whole year (14)

  for my $cday (1 .. $to) {
    my $date1;
    my $d1;

    if ($kmonth < 13) {                                                  # loop over the days of a single month
      $date1 = sprintf("%02i-%02i-%04i", $kmonth, $cday, $kyear);
      $d1 = $cday;
    } else {                                                             # loop over all days of the year
      my ($yday, $ymonth, $yyear) = ydays_to_date($cday, $kyear);
      $date1 = sprintf("%02i-%02i-%04i", $ymonth, $yday, $yyear);
      $d1 = sprintf("%02i", $yday);

      if ($yday == 1) {    # add extra headline at the start of a new month
        $output .= note('bissextal') if $ymonth == 3 && $mode eq 'kal';
        my $ms =
            $mode eq 'kal'
          ? $ymonth == 1
            ? (MONTHNAMES)[$ymonth]
            : qq(<A ID="@{[substr((MONTHNAMES)[$ymonth], 0, 3)]}">@{[(MONTHNAMES)[$ymonth]]}</A> <A HREF="#top">^</A>)
          : qq(<A HREF=# onclick=\"setkm($ymonth)\">@{[(MONTHNAMES)[$ymonth]]} $kyear</A>);
        $output .= qq(<TR><TH COLSPAN="$cols" ALIGN="CENTER">$ms</TH></TR>);
      }
    }

    $output .= '<TR>'
      . join('',
      map { '<TD' . (length($_) < 20 || $_ =~ /\<A/ ? ' ALIGN="CENTER"' : '') . ">$_</TD>" } table_row($date1, $cday),
      ) . "</TR>\n";
  }
  $output .= note('nigra19') if $mode eq 'kal';
  $output =~ s/{(.+?)}/ setfont('maroon', $1) /ge;
  $output . "</TABLE></P>\n";
}

# print html page
sub html_output {
  my ($mode) = @_;

  print html_header();
  print kalendar_table($kyear, $kmonth, $mode);

  print "<P ALIGN='CENTER'>\n";
  print htmlInput('version', $version1, 'options', 'versions', "document.forms[0].submit()");
  print htmlInput('version2', $version2, 'options', 'versions', "document.forms[0].submit()") if $compare;
  print "</P><P ALIGN='CENTER'>\n" . bottom_links_menu() . "</P>\n";

  # if ($Readings) { Readings(); } # not reachable
  if ($compare) {
    print qq(<P ALIGN="CENTER"><A HREF="#" onclick="callkalendar(0, '$mode')">Single Calendar</A>\n);
  } else {
    print qq(<P ALIGN="CENTER"><A HREF="#" onclick="callkalendar(1, '$mode')">Compare Calendars</A>\n);
  }

  if ($mode eq 'ordo') {
    my $tyear;
    ($tyear = gettoday()) =~ s/.*-//;
    my $iyear = $tyear != $kyear ? "&kyear=$kyear" : '';
    print "&nbsp;&nbsp;&nbsp;<A HREF='$ENV{PATH_INFO}?format=ical&version=$version1$iyear'>iCal</A>";
  }

  my $date1 = strictparam('date1');
  my $browsertime = strictparam('browsertime');

  # my $Readings = strictparam('readings'); # unused

  (my $command = strictparam('command')) =~ s/^pray//;

  if ($command =~ /(Ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Past)/i) {
    $command = "pray" . ($compare ? $1 : $command);    # Cofficium can't use Plures
  }

  print <<"PrintTag";
</P>
<INPUT TYPE="HIDDEN" NAME="setup" VALUE="$setupsave">
<INPUT TYPE="HIDDEN" NAME="date1" VALUE="$date1">
<INPUT TYPE="HIDDEN" NAME="kmonth" VALUE=$kmonth>
<INPUT TYPE="HIDDEN" NAME="date" VALUE="$date1">
<INPUT TYPE="HIDDEN" NAME="command" VALUE="$command">
<INPUT TYPE="HIDDEN" NAME="officium" VALUE="$officium">
<INPUT TYPE="HIDDEN" NAME="browsertime" VALUE="$browsertime">
<INPUT TYPE="HIDDEN" NAME="compare" VALUE="$compare">
<INPUT TYPE="HIDDEN" NAME="readings" VALUE="0">
PrintTag

  htmlEnd();
}

#*** horasjs()
# javascript functions called by htmlhead
sub horasjs {
  qq(
function callbrevi(date) {
  if (!date) date = '';
  var officium = "$officium";
  if (!officium || !officium.match('.pl')) officium = "officium.pl";
  document.forms[0].$date_arg.value = date;
  document.forms[0].action = ((officium.match(/missa/)) ? '../missa/' : '' ) + officium;
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls missa
function callmissa() {
  document.forms[0].action = "../missa/missa.pl";
  if (document.forms[0].command.value != "") {
    document.forms[0].command.value = "praySanctaMissa"
  }
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls compare kalendar
function callkalendar(c,m) {
  document.forms[0].action = 'kalendar.pl';
  if (m == 'kal') { document.forms[0].kmonth.value = 15; }
  document.forms[0].compare.value = c;
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

function prevnext(d) {
  document.forms[0].kyear.value = parseInt(document.forms[0].kyear.value) + d;
}

function setkm(km) {
  document.forms[0].kmonth.value = km;
  if (km == -1) {
    document.forms[0].kmonth.value = 12;
    document.forms[0].kyear.value--;
  }
  else {
    if (km == 13) {
      document.forms[0].kmonth.value = 1;
      document.forms[0].kyear.value++;
    }
  }
  document.forms[0].submit();
}

function setky(ky) {
  document.forms[0].kyear.value = ky;
  document.forms[0].submit();
}

function readings() {
  document.forms[0].readings.value = 1;
  document.forms[0].submit();
}
)
}

# below function is unused
# sub Readings {
#   my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
#   my @days = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
#   $hora = 'Laudes';
#   print "<TABLE>\n";
#   print "<TR><TD COLSPAN=3 ALIGN=CENTER><I>Readings $kmonth-$kyear</I></TD></TR>\n";
#
#   for (my $kday = 1; $kday <= $months[$kmonth - 1]; $kday++) {
#     my $date1 = sprintf("%02i-%02i-%04i", $kmonth, $kday, $kyear);
#     my $d1 = sprintf("%02i", $kday);
#     $winner = $commemoratio = $scriptura = '';
#     %winner = %commemoratio = %scriptura = {};
#     $initia = 0;
#     precedence($date1);    #for the daily item
#     my $line = "$d1 $days[$dayofweek] : ";
#     if ($dayofweek == 0) { $line = "<B>$line</B>"; }
#     $line = "<TR><TD>$line</TD><TD>";
#
#     foreach my $i (1, 2, 3) {
#       my $w = lectio($i, 'Latin');
#       if ($w =~ /!([0-9]*\s*[a-z]+ [0-9]+:[0-9]+)/i) { $line .= "$1, " }
#     }
#     print "$line</TD><TD><I>$dayname[1]</I></TD></TR>\n";
#   }
#   print "</TABLE>\n";
# }
