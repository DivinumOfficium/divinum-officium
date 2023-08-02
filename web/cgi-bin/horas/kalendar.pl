#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office Kalendarium
package horas;

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

#*** common variables arrays and hashes
our $error;
our $debug;

#filled by getrank()
our @dayname;    #0=Adv|{Nat|Epi|Quadp|Quad|Pass|Pent 1=winner|2=commemoratio/scriptura
our $winner;     #the folder/filename for the winner of precedence
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
our $rule;                                    # $winner{Rank}
our $communerule;                             # $commune{Rank}
our $duplex;                                  #1= simplex 2=semiduplex, 3=duplex 0=rest
                                              #4 = duplex majus, 5=duplex II class 6=duplex I class 7=higher
our $initia;
our $dayofweek;

our $border;
our $smallblack;
our $smallfont;

require "$Bin/do_io.pl";
require "$Bin/horascommon.pl";
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/setup.pl";
require "$Bin/monastic.pl";

binmode(STDOUT, ':encoding(utf-8)');
our $q = new CGI;

#*** get parameters
my $compare =  strictparam('compare') || 0;
my $officium = strictparam('officium') || 'officium.pl';

if ($compare) {
  $officium = "C$officium" unless $officium =~ /^[PC]/;
} else {
  $officium =~ s/^C//;
}

# use the right date arg
my $date_arg = $officium =~ /Pofficium/? 'date1': 'date';

my $officium_name = $officium =~ /missa/ ? 'missa' : 'horas';
getini("horas");    #files, colors

my $ckname = ($officium_name =~ /officium/) ? "${officium_name}go" : ($compare) ? "${officium_name}gc" : "${officium_name}g";
my $csname = $compare ? 'generalc' : 'general';

my $setupsave = strictparam('setup');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies("${officium_name}p", 'parameters');
  getcookies($ckname, $csname);
}

set_runtime_options($csname); #$expand, $version, $lang2
set_runtime_options('parameters'); # priest, lang1 ... etc

#*** saves parameters
$setupsave = savesetup(1);
$setupsave =~ s/\r*\n*//g;

my @ver;
push(@ver, strictparam('version') || 'Rubrics 1960');
push(@ver, strictparam('version2') || 'Divino Afflatu') if ($compare);

my ($xmonth, $xday, $xyear) = split('-', strictparam($date_arg) || gettoday());
my $kmonth = strictparam('kmonth') || $xmonth;
my $kyear = strictparam('kyear') || $xyear;

if (strictparam('format') eq 'ical') {
  ical_output()
} else {
  html_output()
}

# End of program

#entries 13 (placeholder) and 14 (actually) are added for the Whole Year (Totus) Option
use constant MONTHNAMES => qw/''
                              Januarius Februarius Martius Aprilis Maius Junius
                              Julius Augustus September October November December/;
use constant MONTHLENGTH => ('', 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, '', 365);
use constant DAYNAMES => qw/Dom. F.II F.III F.IV F.V F.VI Sabb./;

# abbreviate entries for ical
sub abbreviate_entry {
  $_ = shift;
  s/Duplex majus/dxm/;
  s/Duplex/dx/;
  s/Semiduplex/sdx/;
  s/Simplex/splx/;
  s/classis/cl./;
  s/ Domini Nostri Jesu Christi/ D.N.J.C./;
  s/Beatæ Mariæ Virginis/B.M.V./;
  s/Abbatis/Abb./;
  s/Apostoli/Ap./;
  s/Apostolorum/App./;
  s/Confessor\w+/Conf./g;
  s/Doctoris/Doct./;
  s/Ecclesiæ/Eccl./;
  s/Episcopi/Ep./;
  s/Episcoporum/Epp./;
  s/Evangelistæ/Evang./;
  s/Martyris/M./g;
  s/Martyrum/Mm./g;
  s/Papæ/P./g;
  s/Viduæ/Vid./;
  s/Virgin\w+/Vir./;
  s/Hebdomadam/Hebd./i;
  s/Quadragesim./Quad./i;
  s/Secunda/II/;
  s/Tertia/III/;
  s/Quarta/IV/;
  s/Quinta/V/;
  s/Sexta/VI/;
  s/Dominica minor/Dom. min./;
  s/ Ferial//;
  s/Feria major/Fer. maj./;
  s/Feria privilegiata/Fer. priv./;
  s/post Octavam/post Oct./;
  s/Augusti/Aug./;
  s/(Septem|Octo|Novem|Decem)bris/${1}b./;
  $_
}

# prepare one day entry
sub kalendar_entry {
  my($date, $ver, $compare, $winneronly) = @_;

  our $version = $ver;
  precedence($date);
  my @c1 = split(';;', $winner{Rank});
  my @c2 =
    (exists($commemoratio{Rank})) ? split(';;', $commemoratio{Rank})
    : (
    exists($scriptura{Rank})
      && $c1[3] && ($c1[3] !~ /ex C[0-9]+[a-z]*/i
      || ($version =~ /trident/i && $c1[2] !~ /vide C[0-9]/i))
    ) ? split(';;', "Scriptura: $scriptura{Rank}")
    : (exists($scriptura{Rank})) ? split(';;', "Tempora: $scriptura{Rank}")
    : ();
  my $smallgray = "1 maroon";
  my($c1, $c2) = ('', '');

  if (@c1) {
    my($h1, $h2) = split(/\s*~\s*/, setheadline($c1[0], $c1[2]));
    return "$h1, $h2" if $winneronly; # finish here for ical
    $c1 = "<B>".setfont(liturgical_color($c1[0], $c1[3]), $h1)."</B>"
        . setfont($smallgray, "&nbsp;&nbsp;$h2");
    $c1 =~ s/Hebdomadam/Hebd/i;
    $c1 =~ s/Quadragesima/Quadr/i;
  }

  if (@c2) {
    my($h1, $h2) = split('~', setheadline($c2[0], $c2[2]));
    $c2 = "<I>".setfont(liturgical_color($c2[0], $c2[3]), $h1)."</I>"
        . setfont($smallgray, "&nbsp;&nbsp;$h2");
  }

  if (substr($date, 0, 5) lt '12-24' && substr($date, 0, 5) gt '01-13') {
    # outside Nat put Sancti winner in right column
    ($c2, $c1) = ($c1, $c2) if $winner =~ /sancti/i;
  } else {
    # inside Nat clear right column unless it is commemoratio of saint
    $dayname[2] = $c2 = '' unless $dayname[2] =~ /Commemoratio/ && !$c2;
  }

  if (dirge($version, 'Laudes', $day, $month, $year)) { $c1 .= setfont($smallblack, ' dirge'); }
  if ($version !~ /1960/ && $initia) { $c1 .= setfont($smallfont, ' *I*'); }

  if (!$c2 && $dayname[2]) {
    $c2 = setfont($smallblack, $dayname[2]);
  } elsif (!$c1 && $dayname[2]) {
    $c1 = setfont($smallblack, $dayname[2]);
  }

  if ($version !~ /1955|1960|Monastic/ && $winner{Rule} =~ /\;mtv/i) {
    $c2 .= setfont($smallblack, ' m.t.v.');
  }

  if ( $version !~ /1960|Monastic/
    && $winner =~ /Sancti/
    && exists($winner{Lectio1})
    && $winner{Lectio1} !~ /\@Commune/i
    && $winner{Lectio1} !~ /\!(Matt|Marc|Luc|Joannes)\s+[0-9]+\:[0-9]+\-[0-9]+/i)
  {
    $c2 .= setfont($smallfont, " *L1*");
  }

  if ($compare) {
    $c2 ||= '_';
  }
  return ($c1, $c2);
}

# prepare html table with entries
sub kalendar_table {
  my($kyear, $kmonth) = @_;

  my $output = << "PrintTag";
<P ALIGN=CENTER>
<TABLE BORDER=$border WIDTH=90% CELLPADDING=3 STYLE="color: black">
<TR><TH>Dies</TH><TH>de Tempore</TH><TH>Sanctorum</TH><TH>d.h.</TH></TR>
PrintTag

  my $to = (MONTHLENGTH)[$kmonth];
  if (($kmonth == 2 || $kmonth == 14) && leapyear($kyear)) { $to++; } # in February or for the whole year (14)
  for my $cday (1..$to) {
    my $date1;
    my $d1;
    if($kmonth < 13) {					# loop over the days of a single month
      $date1 = sprintf("%02i-%02i-%04i", $kmonth, $cday, $kyear);
      $d1 = sprintf("%02i", $cday);
    } else {										# loop over all days of the year
      my ($yday, $ymonth, $yyear) = ydays_to_date($cday, $kyear);
      $date1 = sprintf("%02i-%02i-%04i", $ymonth, $yday, $yyear);
      $d1 = sprintf("%02i", $yday);
      if ($yday == 1) {					# add extra headline at the start of a new month
        $output .= << "PrintTag";
<TR><TH COLSPAN="4" ALIGN=CENTER">
<A HREF=# onclick=\"setkm($ymonth)\">@{[(MONTHNAMES)[$ymonth]]} $kyear</A>
</TH></TR>
PrintTag
      }
    }
    my(@c1, @c2) = ((), ());
    for (0..$compare) {
      my($c1, $c2) = kalendar_entry($date1, $ver[$_], $compare);
      push(@c1, $c1); push(@c2, $c2);
    }
    my $c1 = join('<BR>', @c1);
    my $c2 = join('<BR>', @c2);
    $output .= << "PrintTag";
<TR><TD ALIGN=CENTER><A HREF=# onclick="callbrevi('$date1');">$d1</A></TD>
<TD>$c1</TD>
<TD>$c2</TD>
<TD ALIGN=CENTER>@{[(DAYNAMES)[$dayofweek]]}</TD>
</TR>
PrintTag
  }
  $output . '</TABLE></P>'
}

# prepare html page
sub html_output {

  htmlHead("Ordo: @{[(MONTHNAMES)[$kmonth]]} $kyear");

  print do { # print headline
    my $vers = $ver[0];
    $vers .= " / $ver[1]" if $compare;

    my $output = << "PrintTag";
<H1>
<FONT COLOR=MAROON SIZE=+1><B><I>Divinum Officium</I></B></FONT>&nbsp;
<FONT COLOR=RED SIZE=+1>$vers</FONT>
</H1>
<P ALIGN=CENTER>
<FONT COLOR=MAROON SIZE=+1><B><I>Ordo @{[(MONTHNAMES)[$kmonth]]} A. D.</I></B></FONT>&nbsp;
<LABEL FOR=kyear CLASS=offscreen>Year</LABEL>
<INPUT TYPE=TEXT ID=kyear NAME=kyear VALUE="$kyear" SIZE=4>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=submit NAME=SUBMIT VALUE=" " onclick="document.forms[0].submit();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&nbsp;&nbsp;&nbsp;<A HREF=# onclick="setkm(14)">Totus</A>
</P><P ALIGN=CENTER>
PrintTag

    my @mmenu;
    push(@mmenu, "<A HREF=# onclick=\"setkm(-1)\">«</A>\n") if $kmonth == 1;
    foreach my $i (1..12) {
      my $mn = substr((MONTHNAMES)[$i], 0, 3);
      $mn = "<A HREF=# onclick=\"setkm($i)\">$mn</A>\n" unless $i == $kmonth;
      push(@mmenu, $mn)
    }
    push(@mmenu, "<A HREF=# onclick=\"setkm(13)\">»</A>\n") if $kmonth == 12;

    $output . join('&nbsp;' x 3, @mmenu) . '</P>'
  };

  print kalendar_table($kyear, $kmonth);

  print "<P ALIGN=CENTER>\n";
  print htmlInput('version', $ver[0], 'options', 'versions', , "document.forms[0].submit()");
  if ($compare) {
    print htmlInput('version2', $ver[1], 'options', 'versions', , "document.forms[0].submit()");
  }
  print "</P><P ALIGN=CENTER>\n" . bottom_links_menu() . "</P>\n";

  # if ($savesetup > 1) { print "&nbsp;&nbsp;&nbsp;<A HREF=# onclick=\"readings();\">Readings</A>"; }
  if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n"; }
  if ($debug) { print "<P ALIGN=CENTER><FONT COLOR=blue>$debug</FONT></P>\n"; }
  # if ($Readings) { Readings(); } # not reachable
  if ($compare) {
    print '<P ALIGN=CENTER><A HREF="#" onclick="callkalendar(0)">Single Calendar</A>';
  } else {
    print '<P ALIGN=CENTER><A HREF="#" onclick="callkalendar(1)">Compare Calendars</A>';
  }
  print "&nbsp;&nbsp;&nbsp;<A HREF='$ENV{PATH_INFO}?format=ical&version=$ver[0]'>iCal</A>" unless $compare;

  my $date1 = strictparam('date1');
  my $browsertime = strictparam('browsertime');
  # my $Readings = strictparam('readings'); # unused

  (my $command = strictparam('command')) =~ s/^pray//;
  if ($command =~ /(Ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Past)/i) {
    $command = "pray" . ($compare ? $1 : $command); # Cofficium can't use Plures
  }

  print << "PrintTag";
</P>
<INPUT TYPE=HIDDEN NAME=setup VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=date1 VALUE="$date1">
<INPUT TYPE=HIDDEN NAME=kmonth VALUE=$kmonth>
<INPUT TYPE=HIDDEN NAME=date VALUE="$date1">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=compare VALUE="$compare">
<INPUT TYPE=HIDDEN NAME=readings VALUE="0">
</FORM>
</BODY></HTML>
PrintTag
}

# prepare ical output
sub ical_output {
  my($output) = << "EOH";
Content-Type: text/calendar; charset=utf-8
Content-Disposition: attachment; filename="$ver[0] - $kyear.ics"

BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//divinumofficium.com//
CALSCALE:GREGORIAN
SOURCE:https://divinumofficium.com/cgi-bin/horas/kalendar.pl
EOH

  my($to) = 365 + leapyear($kyear);
  my(@date) = reverse((localtime(time()))[0..5]);
  $date[0] += 1900; $date[1]++;
  my($dtstamp) = sprintf("%04i%02i%02iT%02i%02i%02i", @date);

  for my $cday (1..$to) {
    my ($yday, $ymonth, $yyear) = ydays_to_date($cday, $kyear);
    my($dtstart) = sprintf("%04i%02i%02i", $yyear, $ymonth, $yday);
    my $day = sprintf("%02i-%02i-%04i", $ymonth, $yday, $yyear);
    my($e) = kalendar_entry($day, $ver[0], '', 'winneronly');
    $e = abbreviate_entry($e);
    $output .= << "EOE";
BEGIN:VEVENT
UID:$cday
DTSTAMP:$dtstamp
SUMMARY:$e
DTSTART;VALUE=DATE:$dtstart
END:VEVENT
EOE
  }
  print "${output}END:VCALENDAR\n";
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

//calls compare kalendar
function callkalendar(c) {
  document.forms[0].action = 'kalendar.pl';
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
