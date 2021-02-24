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
use DivinumOfficium::Main qw(vernaculars);
$error = '';
$debug = '';

our $Tk = 0;
our $Hk = 0;
our $Ck = 0;
our $officium = 'Pofficium.pl';
our $version = 'Rubrics 1960';

@versions = ('Tridentine 1570', 'Tridentine 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', 'Ordo Praedicatorum', '1960 Newcalendar');

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
require "$Bin/do_io.pl";
require "$Bin/horascommon.pl";
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/setup.pl";
require "$Bin/horas.pl";
require "$Bin/specials.pl";
require "$Bin/specmatins.pl";

if (-e "$Bin/monastic.pl") { require "$Bin/monastic.pl"; }
binmode(STDOUT, ':encoding(utf-8)');
$q = new CGI;

#get parameters
getini('horas');    #files, colors
$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
our ($lang1, $lang2, $expand, $column, $accented);
our %translate;     #translation of the skeleton label for 2nd language

#internal script, cookies
%dialog = %{setupstring($datafolder, '', 'horas.dialog')};

if (!$setupsave) {
  %setup = %{setupstring($datafolder, '', 'horas.setup')};
} else {
  %setup = split(';;;', $setupsave);
}
if (!$setupsave && !getcookies('horasp', 'parameters')) { setcookies('horasp', 'parameters'); }
if (!$setupsave && !getcookies('horasgp', 'general')) { setcookies('horasgp', 'general'); }
our $command = strictparam('command');
our $hora = $command;    #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
our $date1 = strictparam('date1');
if (!$date1) { $date1 = gettoday(); }
if ($command =~ /next/i) { $date1 = prevnext($date1, 1); $command = ''; }
if ($command =~ /prev/i) { $date1 = prevnext($date1, -1); $command = ''; }
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

#*** handle different actions
#after setup
if ($command =~ /change(.*)/i) {
  $command = $1;
  getsetupvalue($command);
  if ($command =~ /parameters/) { setcookies('horasp', 'parameters'); }
}
$setup{'parameters'} = clean_setupsave($setup{'parameters'});
eval($setup{'parameters'});    #$priest, $lang1, colors, sizes
eval($setup{'general'});       #$expand, $version, $lang2

#prepare testmode
our $testmode = strictparam('testmode');
if (!$testmode) { $testmode = strictparam('testmode1'); }
if (!$testmode) { $testmode = 'regular'; }
our $votive = strictparam('votive');
$expandnum = strictparam('expandnum');
$p = strictparam('priest');

if ($p) {
  $priest = 1;
  setsetupvalue('parameters', 0, $priest);
}
$p = strictparam('lang1');

if ($p) {
  $lang1 = $p;
  setsetupvalue('parameters', 2, $lang1);
}
$p = strictparam('psalmvar');

if ($p) {
  $psalmvar = $p;
  setsetupvalue('parameters', 3, $psalmvar);
}
$p = strictparam('screenheight');

if ($p) {
  $screenheight = $p;
  setsetupvalue('parameters', 12, $screenheight);
}
$p = strictparam('textwidth');

if ($p) {
  $textwidth = $p;
  setsetupvalue('parameters', 13, $textwidth);
}
$expand = 'all';
$flag = 0;
$p = strictparam('lang2');
if ($p) { $lang2 = $p; $flag = 1; }
$p = strictparam('version');
if ($p) { $version = $p; $flag = 1; }
$p = strictparam('accented');
if ($p) { $accented = $p; $flag = 1; }

if ($flag) {
  setsetup('general', $expand, $version, $lang2, $accented);
  setcookies('horasgp', 'general');
}
if (!$version) { $version = 'Rubrics 1960'; }
if (!$lang2) { $lang2 = 'English'; }
$only = ($lang1 =~ $lang2) ? 1 : 0;
setmdir($version);

# save parameters
$setupsave = printhash(\%setup, 1);
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;
precedence($date1);    #fills our hashes et variables
our $psalmnum1 = 0;
our $psalmnum2 = 0;

# prepare title
$daycolor =
    ($commune =~ /(C1[0-9])/) ? "blue"
  : ($dayname[1] =~ /(Vigilia Pentecostes|Quattuor Temporum Pentecostes|Martyr)/i) ? "red"
  : ($dayname[1] =~ /(Conversione|Dedicatione|Cathedra|oann|Pasch|Confessor|Ascensio|Cena)/i) ? "black"
  : ($dayname[1] =~ /(Vigilia|Quattuor|Passionis|gesim|Hebdomadæ Sanctæ|Ciner|Adventus)/i) ? "purple"
  : ($dayname[1] =~ /(Pentecosten|Epiphaniam|post octavam)/i) ? "green"
  : ($dayname[1] =~ /(Pentecostes|Evangel|Innocentium|Sanguinis|Cruc|Apostol)/i) ? "red"
  : ($dayname[1] =~ /(Defunctorum|Parasceve|Morte)/i) ? "grey"
  : "black";
build_comment_line();

#prepare main pages
my $h = $hora;

if ($h =~ /(Ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Post|Setup)/i) {
  $h = " $1";
} else {
  $h = '';
}
$title = "Divinum Officium$h";
$title =~ s/Vespera/Vesperae/i;
@horas = getdialogcolumn('horas', '~', 0);
for ($i = 0; $i < 10; $i++) { $hcolor[$i] = 'blue'; }
$completed = getcookie1('completed');

if ( $date1 eq gettoday()
  && $command =~ /pray/i
  && $completed < 8
  && $command =~ substr($horas[$completed + 1], 0, 4))
{
  $completed++;
  setcookie1('completed', $completed);
}
for ($i = 1; $i <= $completed; $i++) { $hcolor[$i] = 'maroon'; }

#*** print pages (setup, hora=pray, mainpage)
#generate HTML
htmlHead($title, 2);
print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg">
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
  setuptable($command);
} elsif ($command =~ /pray/) {
  $pmode = 'hora';
  $command =~ s/(pray|change|setup)//ig;
  $title = $command;
  $hora = $command;
  if (substr($title, -1) =~ /a/i) { $title .= 'm'; }
  $head = ($title =~ /(Ante|Post)/i) ? "$title divinum officium" : "Ad $title";
  $head =~ s/Ad Vesperam/Ad Vesperas/i;
  $headline = setheadline();
  headline($head);

  #eval($setup{'parameters'});
  $background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";
  horas($command);
  print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=popuplang VALUE="">
PrintTag
} else {    #mainpage
  $pmode = 'main';
  $command = "";
  $height = floor($screenheight * 4 / 12);
  $height2 = floor($height / 2);
  $headline = setheadline();
  headline($title);
}

#common widgets for main and hora
if ($pmode =~ /(main|hora)/i) {
  if ($votive ne 'C9') {
    print << "PrintTag";
<P ALIGN=CENTER><I>
<A HREF="Pofficium.pl?date1=$date1&command=prayMatutinum&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
 <FONT COLOR=$hcolor[1]>$horas[1]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=prayLaudes&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[2]>$horas[2]</FONT></A>
<BR>
<A HREF="Pofficium.pl?date1=$date1&command=prayPrima&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[3]>$horas[3]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=prayTertia&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[4]>$horas[4]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=praySexta&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[5]>$horas[5]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=prayNona&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[6]>$horas[6]</FONT></A>
<BR>
<A HREF="Pofficium.pl?date1=$date1&command=prayVespera&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[7]>$horas[7]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&caller=$caller&command=prayCompletorium&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
<FONT COLOR=$hcolor[8]>$horas[8]</FONT></A>
</I></P>
PrintTag
  } else {
    print << "PrintTag";
<P ALIGN=CENTER><I>
<A HREF="Pofficium.pl?date1=$date1&command=prayMatutinum&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive"><FONT COLOR=$hcolor[1]>$horas[1]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=prayLaudes&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive"><FONT COLOR=$hcolor[2]>$horas[2]</FONT></A>
&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=prayVespera&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive"><FONT COLOR=$hcolor[7]>$horas[7]</FONT></A>
&nbsp;&nbsp;
</I></P>
PrintTag
  }
  @chv = splice(@chv, @chv);
  if (-e "$Bin/monastic.pl") { unshift(@versions, 'Monastic'); }
  for ($i = 0; $i < @versions; $i++) { $chv[$i] = $version =~ /$versions[$i]/ ? 'red' : 'blue'; }
  my $vsize = @versions;
  print "<TABLE ALIGN=CENTER BORDER=1><TR><TD ALIGN=CENTER>\n";
  print "Versions<BR>";

  for ($i = 0; $i < @versions; $i++) {
    if ($i > 0) { print "<BR>"; }
    print "<A HREF=\"Pofficium.pl?date1=$date1&version=$versions[$i]&testmode=$testmode&lang2=$lang2\&votive=$votive\">"
      . "<FONT COLOR=$chv[$i]>$versions[$i]</FONT></A>";
  }
  print "</TD></TR>\n";
  my $sel10 = (!$testmode || $testmode =~ /regular/i) ? 'red' : 'blue';
  my $sel11 = ($testmode =~ /Seasonal/i) ? 'red' : 'blue';
  print << "PrintTag";
<TR><TD ALIGN=CENTER VALIGN=MIDDLE>
Language 2</FONT><BR>
PrintTag

  # Write a link for each language.
  foreach my $language ('Latin', vernaculars($datafolder)) {
    my $colour = ($lang2 =~ /$language/i) ? 'red' : 'blue';
    print qq(<A HREF="Pofficium.pl?date1=$date1&)
      . qq(version=$version&testmode=$testmode&lang2=$language&votive=$votive">)
      . qq(<FONT COLOR=$colour>$language</FONT></A><BR>);
  }
  $sel1 = 'blue';
  $sel2 = ($votive =~ /C8/) ? 'red' : 'blue';
  $sel3 = ($votive =~ /C9/) ? 'red' : 'blue';
  $sel4 = ($votive =~ /C12/) ? 'red' : 'blue';
  print << "PrintTag";
</TD></TR>
<TR><TD ALIGN=CENTER VALIGN=MIDDLE>Votive</FONT><BR>
<A HREF="Pofficium.pl?date1=$date1&version=$version&testmode=$testmode&lang2=$lang2&votive=Hodie">
  <FONT COLOR=$sel1>hodie</FONT></A><BR>
<A HREF="Pofficium.pl?date1=$date1&version=$version&testmode=$testmode&lang2=$lang2&votive=C8">
<FONT COLOR=$sel2>Dedicatio</FONT></A><BR>
<A HREF="Pofficium.pl?date1=$date1&version=$version&testmode=$testmode&lang2=$lang2&votive=C9">
<FONT COLOR=$sel3>Defunctorum</FONT></A><BR>
<A HREF="Pofficium.pl?date1=$date1&version=$version&testmode=$testmode&lang2=$lang2&votive=C12">
<FONT COLOR=$sel4>Parvum B.M.V.</FONT></A><BR></TR>
<P ALIGN=CENTER>
<A HREF="Pofficium.pl?date1=$date1&command=setupparameters&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
Options</A>&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callmissa();">Sancta Missa</A>&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Ordo</A>
</TD></TR></TABLE>
</FONT>
</P>
<P ALIGN=CENTER>
<A HREF="../../www/horas/Help/versions.html" TARGET="_BLANK">Versions</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="../../www/horas/Help/credits.html" TARGET="_BLANK">Credits</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="../../www/horas/Help/download.html" TARGET="_BLANK">Download</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="../../www/horas/Help/rubrics.html" TARGET="_BLANK">Rubrics</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="../../www/horas/Help/technical.html" TARGET="_BLANK">Technical</A>
&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="../../www/horas/Help/help.html" TARGET="_BLANK">Help</A>
</FONT>
</P>
PrintTag
PrintTag
}

#common end for programs
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT><\P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT><\P>\n"; }
$command =~ s/(pray|setup)//ig;
print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=setup VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=searchvalue VALUE="0">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=accented VALUE="$accented">
<INPUT TYPE=HIDDEN NAME=caller VALUE='0'>
</FORM>
</BODY></HTML>
PrintTag

#*** hedline($head) prints headline for main and pray
sub headline {
  my $head = shift;
  $headline =~ s{(!.*)}{<FONT SIZE=1>$1</FONT>}s;
  my $h = ($hora =~ /(Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium)/i) ? $hora : '';
  print << "PrintTag";
<P ALIGN=CENTER><FONT COLOR=$daycolor>$headline<BR></FONT>
$comment<BR><BR>
<COLOR=maroon>$head</FONT>&nbsp;&nbsp;&nbsp;
<A HREF="Pofficium.pl?date1=$date1&command=prev&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
&darr;</A>
$date1
<A HREF="Pofficium.pl?date1=$date1&command=next&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
&uarr;</A>
</P>
PrintTag
}

sub prevnext {
  my $date1 = shift;
  my $inc = shift;
  $date1 =~ s/\//\-/g;
  my ($month, $day, $year) = split('-', $date1);
  my $d = date_to_days($day, $month - 1, $year);
  my @d = days_to_date($d + $inc);
  $month = $d[4] + 1;
  $day = $d[3];
  $year = $d[5] + 1900;
  return sprintf("%02i-%02i-%04i", $month, $day, $year);
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {
  print << "PrintTag";

<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

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
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].command.value = '';
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

//restart the programlet if parameter change
function parchange() {
  var c = document.forms[0].command.value;
  if (c && !c.match("change")) {
     clearradio();
  }
  if (c && !c.match("pray")) document.forms[0].command.value = "pray" + c;
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
