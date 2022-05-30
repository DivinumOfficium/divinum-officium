#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
package horas;

#1;
#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Cookie;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use Time::Local;

#use DateTime;
use locale;
use lib "$Bin/..";
use DivinumOfficium::Main qw(liturgical_color);
$error = '';
$debug = '';

our $Tk = 0;
our $Hk = 0;
our $Ck = 0;
our $notes = 0;
our $missa = 0;
our $officium = 'officium.pl';
our $version = '';

#***common variables arrays and hashes
#filled  getweek()
our @dayname;    #0=Advn|Natn|Epin|Quadpn|Quadn|Pascn|Pentn 1=winner title|2=other title

#filled by getrank()
our $winner;     #the folder/filename for the winner of precedence
our $commemoratio;    #the folder/filename for the commemorated
our $scriptura;       #the folder/filename for the scripture reading (if winner is sancti)
our $commune;         #the folder/filename for the used commune
our $communetype;     #ex|vide
our $rank;            #the rank of the winner
our $laudes;          #1 or 2
our $vespera;         #1 | 3 index for ant, versum, oratio
our $cvespera;        #for commemoratio
our $commemorated;    #name of the commemorated for vigils
our $comrank = 0;     #rank of the commemorated office
our $litaniaflag = 0;

#filled by precedence()
our %winner;          #the hash of the winner
our %commemoratio;    #the hash of the commemorated
our %scriptura;       #the hash for the scriptura
our %commune;         # the hash of the commune
our (%winner2, %commemoratio2, %commune2);    #same for 2nd column
our $rule;                                    # $winner{Rank}
our $communerule;                             # $commune{Rank}
our $duplex;                                  #1=simplex-feria, 2=semiduplex-feria privilegiata, 3=duplex
    # 4= duplex majus, 5 = duplex II classis 6=duplex I classes 7=above  0=none

binmode(STDOUT, ':encoding(utf-8)');

#*** collect standard items
require "$Bin/horascommon.pl";
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/setup.pl";
require "$Bin/horas.pl";
require "$Bin/specials.pl";
require "$Bin/specmatins.pl";

if (-e "$Bin/monastic.pl") { require "$Bin/monastic.pl"; }
require "$Bin/do_io.pl";
$q = new CGI;

#get parameters
getini('horas');    #files, colors
our ($lang1, $lang2, $expand, $votive, $column, $local);
our %translate;     #translation of the skeleton labels
our $command = strictparam('command');
our $hora = substr($command,4);    #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
our $browsertime = strictparam('browsertime');
our $buildscript = '';    #build script
our $searchvalue = strictparam('searchvalue');

if (!$searchvalue) { $searchvalue = '0'; }

our $caller = strictparam('caller');
our $dirge = 0;           #1=call from 1st vespers, 2=call from Lauds
our $dirgeline = '';      #dates for dirge from Trxxxxyyyy
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';
our $italicfont = 'italic';

$setupsave = strictparam('setup');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('horasp', 'parameters');
  getcookies('horasgo', 'general');
}

set_runtime_options('general'); #$expand, $version, $lang2
set_runtime_options('parameters'); # priest, lang1 ... etc

if ($command eq 'changeparameters') { getsetupvalue($command); }

setcookies('horasp', 'parameters');
setcookies('horasgo', 'general');

# save parameters
$setupsave = savesetup(1);
$setupsave =~ s/\r*\n*//g;

#*** handle different actions
#after setup

#prepare testmode
our $testmode = strictparam('testmode');
if ($testmode !~ /(Season|Saint|Common)/i) { $testmode = 'regular'; }
$expandnum = strictparam('expandnum');
$notes = strictparam('notes');

$only = ($lang1 =~ /^$lang2$/i) ? 1 : 0;
setmdir($version);

precedence();    #fills our hashes et variables
our $psalmnum1 = 0;
our $psalmnum2 = 0;
our $octavam = '';    #to avoid duplication of commemorations

# prepare title
$daycolor = liturgical_color($dayname[1], $commune);
build_comment_line();

#prepare main pages
my @horas = getdialog('horas');

my $title = "Divinum Officium";
if (($hora =~ /setup/) || (grep { $_ eq $hora } @horas)) {
  $title .= " $hora";
}

$completed = getcookie1('completed');
if ( $date1 eq gettoday()
  && $command =~ /pray/i
  && $completed < 8
  && $command =~ substr($horas[$completed + 1], 0, 4))
{
  $completed++;
  setcookie1('completed', $completed);
}
my @local = splice(@local, @local);

#if (opendir(DIR, "$datafolder/Latin/Tabulae")) {
#  my @a = readdir(DIR);
#  close DIR;
#  foreach my $item (@a) {
#    if ($item =~ /K([A-Z]+)/) {push (@local, $1);}
#  }
#  unshift(@local, 'none');
#}
if ($command =~ /kalendar/) {    # kalendar widget
  print "Access-Control-Allow-Origin: *\n";
  print "Content-type: text/html; charset=utf-8\n";
  print "\n";
  $headline = setheadline();
  headline2($head);
} else {

  #*** print pages (setup, hora=pray, mainpage)
  #generate HTML
  htmlHead($title, 2);
  print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg" onload="startup();">
<script>
// https redirect
if (location.protocol !== 'https:' && (location.hostname == "divinumofficium.com" || location.hostname == "www.divinumofficium.com")) {
    location.replace(`https:\${location.href.substring(location.protocol.length)}`);
}
</script>
<FORM ACTION="$officium" METHOD=post TARGET=_self>
PrintTag

  if ($command =~ /setup(.*)/i) {
    $pmode = 'setup';
    $command = $1;
    print setuptable($command, $title);
    $command = "change" . $command;
  } elsif ($command =~ /pray/) {
    $pmode = 'hora';
    $command =~ s/(pray|change|setup)//ig;
    $title = $command;
    $title =~ s/a$/am/;
    $head = ($title =~ /(Ante|Post)/i) ? "$title divinum officium" : "Ad $title";
    $head =~ s/Ad Vespera.*/Ad Vesperas/i;
    $headline = setheadline();
    headline($head);

    #eval($setup{'parameters'});
    $background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";
    horas($command);
    print << "PrintTag";
<P ALIGN=CENTER>
<INPUT TYPE=SUBMIT NAME='button' VALUE='$command persolut.' onclick="okbutton();">
</P>
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=popuplang VALUE="">
PrintTag
  } else {    #mainpage
    $pmode = 'main';
    $command = "";
    $height = floor($screenheight * 4 / 14);
    $height2 = floor($height / 2);
    $headline = setheadline();
    headline($title);
    print << "PrintTag";
<P ALIGN=CENTER>
<TABLE BORDER=0 HEIGHT=$height><TR>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Ordinarium</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Psalterium</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Proprium de Tempore</FONT></TD>

</TR><TR><TD ALIGN=CENTER ROWSPAN=2>
<IMG SRC="$htmlurl/breviarium.jpg" HEIGHT=$height ALT=""></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/psalterium.jpg" HEIGHT=$height2 ALT=""></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/tempore.jpg" HEIGHT=$height2 ALT=""></TD>
</TR><TR>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/commune.jpg" HEIGHT=$height2 ALT=""></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/sancti.jpg" HEIGHT=$height2 ALT=""></TD>
</TR><TR>
<TD ALIGN=CENTER><FONT COLOR=RED></FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Commune Sanctorum</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Proprium Sanctorum</FONT></TD>
</TR></TABLE>
<BR>
</P>
PrintTag
  }

  #common widgets for main and hora
  if ($pmode =~ /(main|hora)/i) {
    print "<P ALIGN=CENTER><I><FONT SIZE=+1>";
    print horas_menu($completed, $date1, $version, $lang2, $votive, $testmode);
    print "</FONT>\n</I></P>\n";

    $votive ||= 'Hodie';
    print "<P ALIGN=CENTER>";
    print selectables('general');
    print "</P>\n";

    print "<P ALIGN=CENTER><FONT SIZE=+1>\n";
    print bottom_links_menu();
    print "</FONT>\n</P>\n";

    if ($building && $buildscript) {
      $buildscript =~ s/[\n]+/\n/g;
      $buildscript =~ s/\n/<BR>/g;
      $buildscript =~ s/\_//g;
      $buildscript =~ s/\,\,\,/\&nbsp\;\&nbsp\;\&nbsp\;/g;
      print << "PrintTag";
<TABLE BORDER=3 ALIGN=CENTER WIDTH=60% CELLPADDING=8><TR><TD ID=L$searchind>
$buildscript
</TD></TR><TABLE><BR>
PrintTag
    }
  }

  #common end for programs
  if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n"; }
  if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n"; }
  $command =~ s/(pray|setup)//ig;
  print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=setup VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=searchvalue VALUE="0">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=version1 VALUE="$version">
<INPUT TYPE=HIDDEN NAME=caller VALUE='0'>
<INPUT TYPE=HIDDEN NAME=compare VALUE=0>
<INPUT TYPE=HIDDEN NAME='notes' VALUE="$notes">
</FORM>
</BODY></HTML>
PrintTag
}

#*** headline2($head) prints just two lines of header (for widget)
sub headline2 {
  my $head = shift;
  $headline =~ s{!(.*)}{<FONT SIZE=1>$1</FONT>}s;
  $comment =~ s/([\w]+)=([\w+-]+)/$1="$2"/g;
  print "<p><span style='text-align:center;color:$daycolor'>$headline<br/></span>";
  print "<span>$comment<BR/><BR/></span></p>";
}

#*** headline($head) prints headline for main and pray
sub headline {
  my $head = shift;
  $headline =~ s{!(.*)}{<FONT SIZE=1>$1</FONT>}s;
  print << "PrintTag";
<P ALIGN=CENTER><FONT COLOR=$daycolor>$headline<BR></FONT>
$comment<BR><BR>
<FONT COLOR=MAROON SIZE=+1><B><I>$head</I></B></FONT>
&nbsp;<FONT COLOR=RED SIZE=+1>$version</FONT></P>
<P ALIGN=CENTER><A HREF=# onclick="callcompare()">Compare</A>
&nbsp;&nbsp;&nbsp;<A HREF=# onclick="callmissa();">Sancta Missa</A>
&nbsp;&nbsp;&nbsp;
<LABEL FOR=date CLASS=offscreen>Date</LABEL>
<INPUT TYPE=TEXT ID=date NAME=date VALUE="$date1" SIZE=10>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=submit NAME=SUBMIT VALUE=" " onclick="parchange();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Ordo</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="pset('parameters')">Options</A>
</P>
PrintTag
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {

  # $caller in principle might not be defined.
  my $caller_flag = $caller || 0;
  print << "PrintTag";

<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

//position
function startup() {
  if (!"$browsertime") {
    var d = new Date();
    var day = d.getDate();
    document.forms[0].browsertime.value = (d.getMonth() + 1) + "-" + day + "-" + d.getFullYear();
    if (!"$date1") {
      var a = (day > $day) ? "-+" : (day < $day) ? "--" : "";
      document.forms[0].date.value = document.forms[0].browsertime.value + a;
      if (a) document.forms[0].submit();
    }
  }
  var i = 1;
  while (i <= $searchvalue) {
    a = document.getElementById('L' + i);
    i++;
    if (a) a.scrollIntoView();
  }
}

//prepare position
function setsearch(ind) {
  document.forms[0].searchvalue.value = ind;
  parchange();
}

//call a setup table
function pset(p) {
  document.forms[0].command.value = "setup" + p;
  document.forms[0].submit();
}

//call an individual hora
function hset(p, d) {
  clearradio();

  if (p != 'Laudes' && d) {
    document.forms[0].date.value = d;
    document.forms[0].caller.value = 1;
  }
  if ($caller_flag) {document.forms[0].caller.value = 1;}
  document.forms[0].command.value = "pray" + p;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

// Jump straight to an hour of the Office for the Dead.
function defunctorum(hour) {
  clearradio();

  document.forms[0].caller.value = 1;
  document.forms[0].votive.value = "C9";
  document.forms[0].command.value = "pray" + hour;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//to prevent inhearitance of popup
function clearradio() {
  var a= document.forms[0].popup;
  if (a) a.value = 0;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  return;
}

// set a popup tab
function linkit(name,ind,lang) {
  document.forms[0].popup.value = name;
  document.forms[0].popuplang.value=lang;
  document.forms[0].expandnum.value=ind;
  if (ind == 0) {
     document.forms[0].action = 'popup.pl';
     document.forms[0].target = '_BLANK';
  } else {
     var c = document.forms[0].command.value;
     if (!c.match('pray')) document.forms[0].command.value = "pray" + c;
  }
  document.forms[0].submit();
}

//finishing horas back to main page
function okbutton() {
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].command.value = '';
  document.forms[0].submit();
}

//restart the programramlet if parameter change
function parchange() {
  var c = document.forms[0].command.value;
  if (c && !c.match("change")) {
     clearradio();
  }
  if (c && !c.match("pray")) document.forms[0].command.value = "pray" + c;
  document.forms[0].submit();
}

//calls kalendar
function callkalendar() {
  document.forms[0].action = 'kalendar.pl';
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls missa
function callmissa() {
  document.forms[0].action = "../missa/missa.pl";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls compare
function callcompare() {
  document.forms[0].action = "Cofficium.pl";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

function prevnext(ch) {
  var dat = document.forms[0].date.value;
  var adat = dat.split('-');
  var mtab = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
  var m = eval(adat[0]);
  var d = eval(adat[1]);
  var y = eval(adat[2]);
  var c = eval(ch);

  var leapyear = 0;
  if ((y % 4) == 0) leapyear = 1;
  if ((y % 100) == 0) leapyear = 0;
  if ((y % 400) == 0) leapyear = 1;
  if (leapyear) mtab[1] = 29;
  d = d + c;
  if (d < 1) {
    m--;
	if (m < 1) {y--; m = 12;}
	d = mtab[m-1];
  }
  if (d > mtab[m-1]) {
    m++;
	  d = 1;
	  if (m > 12) {y++; m = 1;}
  }
  document.forms[0].date.value = m + "-" + d + "-" + y;
}

</SCRIPT>
PrintTag
}
