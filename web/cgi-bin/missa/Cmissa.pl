#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
package missa;

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

our $Ck = 0;
our $NewMass = 1;
our $missa = 1;
our $officium = 'Cmissa.pl';

@versions =
  ('Ambrosian', 'Mozarabic', 'Sarum', 'Dominican', 'Trident 1570', 'Divino Afflatu', 'Rubrics 1960', 'Rubrics 1967', 'New Mass');
%ordos = split(',',
      "Mozarabic,OrdoM,Sarum,OrdoS,Ambrosian,OrdoA,Dominican,OrdoOP,Trident 1570,Ordo,"
    . "Divino Afflatu,Ordo,Rubrics 1960,Ordo,Rubrics 1967,Ordo67,New Mass,OrdoN");

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
our $commemorated;    #name of the commemorated for Vigils
our $comrank = 0;     #rank of the commemorated office

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

#*** collect standard items
#require "ordocommon.pl";
require "$Bin/../horas/do_io.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../horas/dialogcommon.pl";
require "$Bin/../horas/webdia.pl";
require "$Bin/../horas/setup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

binmode(STDOUT, ':encoding(utf-8)');
$q = new CGI;

our ($version1, $version2, $lang1, $lang2, $expand, $column, $accented);
our %translate;     #translation of the skeleton label for 2nd language

#get parameters
getini('missa');    #files, colors

$setupsave = strictparam('setupm');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('missapc', 'parameters');
  getcookies('missagc', 'generalc');
}

set_runtime_options('generalc'); #$expand, $version, $lang2
set_runtime_options('parameters'); # priest, lang1 ... etc

if ($command eq 'changeparameters') { getsetupvalue($command); }

setcookies('missap', 'parameters');
setcookies('missagc', 'generalc');

# save parameters
$setupsave = savesetup(1);
$setupsave =~ s/\r*\n*//g;

our $command = strictparam('command');
our $hora = $command;    #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
our $browsertime = strictparam('browsertime');
our $searchvalue = strictparam('searchvalue');
if (!$searchvalue) { $searchvalue = '0'; }
our $rubrics = strictparam('rubrics');
our $solemn = strictparam('solemn');
$rubrics = 1;
$solemn = 0;
if (!$command || $command =~ /^Sancta/i) { $command = 'praySanctaMissa'; }

#prepare testmode
our $testmode = 'regular';
our $votive = '';
$expandnum = strictparam('expandnum');

$only = ($lang1 eq $lang2 && $version1 eq $version2) ? 1 : 0;

$version = $version1;
precedence($winner);    #fills our hashes et variables
setsecondcol();
our $psalmnum1 = 0;
our $psalmnum2 = 0;

#prepare main pages
$title = "Sancta Missa Comparison";

#*** print pages (setup, hora=pray, mainpage)
#generate HTML
htmlHead($title, 'startup()');
print << "PrintTag";
<P ALIGN=CENTER>
<A HREF="Cmissa.pl?searchvalue=2&lang1=$lang1&lang2=$lang2&version1=$version1&version2=$version2">[Incipit]</A>&nbsp;&nbsp;
<A HREF="Cmissa.pl?searchvalue=11&lang1=$lang1&lang2=$lang2&version1=$version1&version2=$version2">[Missa Catechumenorum]</A>&nbsp;&nbsp;
<A HREF="Cmissa.pl?searchvalue=16&lang1=$lang1&lang2=$lang2&version1=$version1&version2=$version2">[Offertorium]</A>&nbsp;&nbsp;
<A HREF="Cmissa.pl?searchvalue=23&lang1=$lang1&lang2=$lang2&version1=$version1&version2=$version2">[Canon Missae]</A>&nbsp;&nbsp;
<A HREF="Cmissa.pl?searchvalue=38&lang1=$lang1&lang2=$lang2&version1=$version1&version2=$version2">[Communio]</A>&nbsp;&nbsp;
<A HREF="Cmissa.pl?searchvalue=52&lang1=$lang1&lang2=$lang2&version1=$version1&version2=$version2">[Conclusio]</A></P>
PrintTag

if ($command !~ /setup/i) {
  print "<P ALIGN=CENTER>";
  print option_selector("Version 1", "parchange();", $version1, @versions );
  print option_selector("lang1", "parchange();", $lang1, qw(Latin English));
  print option_selector("lang2", "parchange();", $lang2, qw(Latin English));
  print option_selector("Version 2", "parchange();", $version2, @versions );
}

if ($command =~ /setup(.*)/is) {
  $pmode = 'setup';
  $command = $1;
  print setuptable($command);
} elsif ($command =~ /pray/) {
  $pmode = 'hora';
  $command =~ s/(pray|change|setup)//ig;
  $title = $command;
  $hora = $command;
  $background = ($whitebground) ? ' class="contrastbg"' : '';
  $head = $title;
  headline($head);
  print << "PrintTag";
<TABLE BORDER=0 WIDTH=80% ALIGN=CENTER><TR>
<TD ALIGN=CENTER><FONT COLOR=MAROON>$version1</FONT></TD><TD ALIGN=CENTER><FONT COLOR=MAROON>$version2</FONT></TD>
</TR></TABLE>
PrintTag
  ordo();
  print << "PrintTag";
<P ALIGN=CENTER>
<INPUT TYPE=submit NAME='button' VALUE='Æquiparantia persoluta' onclick="okbutton();">
</P>
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=popuplang VALUE="">
PrintTag
} else {    #mainpage
  $pmode = 'main';
  $command = "";
  $height = floor($screenheight * 6 / 12);
  $height2 = floor($height / 2);
  $background = ($whitebground) ? ' class="contrastbg"' : '';
  headline($title);
  print << "PrintTag";
<P ALIGN=CENTER>
<TABLE BORDER=0 HEIGHT=$height><TR>
<TD><IMG SRC="$htmlurl/missa.png" HEIGHT=$height></TD>
</TR></TABLE>
<BR>
</P>
PrintTag
}

#common widgets for main and hora
if ($pmode =~ /(main|hora)/i) {
  print << "PrintTag";
<P ALIGN=CENTER>
<A HREF="missa.pl">1962 only</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="pset('parameters')">Options</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF=\"$htmlurl/sourceC.html\" TARGET=\"_NEW\">Source</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF=\"$htmlurl/CompPrayers.html\" TARGET=\"_NEW\">Compare Prayers</A></FONT>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF=\"$htmlurl/PartsofMass.html\" TARGET=\"_NEW\">Parts of Mass</A></FONT>
</P>
PrintTag

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
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT><\P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT><\P>\n"; }
$command =~ s/(pray|setup)//ig;
print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=setupm VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=searchvalue VALUE="0">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=accented VALUE="$accented">
<INPUT TYPE=HIDDEN NAME=compare VALUE=1>
</FORM>
</BODY></HTML>
PrintTag

#*** hedline($head) prints headline for main and pray
sub headline {
  my $head = shift;
  print "<P ALIGN=CENTER>" . html_dayhead(setheadline()) ."\n";
  print << "PrintTag";
<P ALIGN=CENTER>
<FONT COLOR=MAROON SIZE=+1><B><I>$head</I></B></FONT>
&nbsp;&nbsp;&nbsp;&nbsp;
<LABEL FOR=date CLASS=offscreen>Date</LABEL>
<INPUT ID=date TYPE=TEXT NAME=date VALUE="$date1" SIZE=10>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=submit NAME=SUBMIT VALUE=" " onclick="parchange();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
</P>
PrintTag
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {
qq(
//position
function startup() {
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
  if (d && p != 'Laudes') {
    document.forms[0].date.value = d;
    document.forms[0].caller.value = 1;
  }
  if ("$caller") {document.forms[0].caller.value = 1;}
  document.forms[0].command.value = "pray" + p;
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
     document.forms[0].target = '_NEW';
  } else {
     var c = document.forms[0].command.value;
     if (!c.match('pray')) document.forms[0].command.value = "pray" + c;
  }
  document.forms[0].submit();
}

//finishing horas back to main page
function okbutton() {
  document.forms[0].action = "missa.pl";
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
)
}
