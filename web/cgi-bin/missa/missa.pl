#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 03-30-10
# Sancta Missa
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
use DivinumOfficium::Main qw(vernaculars liturgical_color);
$error = '';
$debug = '';

our $Ck = 0;
our $missa = 1;
our $NewMass = 0;
our $officium = 'missa.pl';

@versions =
  ('Tridentine 1570', 'Tridentine 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1965-1967', '1960 Newcalendar', 'Dominican');

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
#require "$Bin/ordocommon.pl";
require "$Bin/../horas/do_io.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../horas/dialogcommon.pl";
require "$Bin/../horas/webdia.pl";
require "$Bin/../horas/setup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

binmode(STDOUT, ':encoding(utf-8)');
$q = new CGI;

#get parameters
getini('missa');    #files, colors
our ($version, $lang1, $lang2, $column);
our %translate;     #translation of the skeleton label for 2nd language
our $testmode;
our $votive;
$first = strictparam('first');
our $Propers = strictparam('Propers');
our $command = strictparam('command');
our $browsertime = strictparam('browsertime');
our $searchvalue = strictparam('searchvalue');
if (!$searchvalue) { $searchvalue = '0'; }
if (!$command) { $command = 'praySanctaMissa'; }
our $missanumber = strictparam('missanumber');
if (!$missanumber) { $missanumber = 1; }
our $caller = strictparam('caller');

$setupsave = strictparam('setupm');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('missap', 'parameters');
  getcookies('missag', 'general');
}

set_runtime_options('general'); #$expand, $version, $lang2
set_runtime_options('parameters'); # priest, lang1 ... etc

if ($command eq 'changeparameters') { getsetupvalue($command); }

setcookies('missap', 'parameters');
setcookies('missag', 'general');

# save parameters
$setupsave = savesetup(1);
$setupsave =~ s/\r*\n*//g;

#*** handle different actions
#after setup

if ($testmode !~ /(Seasonal|Season|Saint)/i) { $testmode = 'regular'; }
$rubrics = strictparam('rubrics');
$solemn = strictparam('solemn');

$only = ($lang1 =~ /$lang2/) ? 1 : 0;

# save parameters
precedence();    #fills our hashes et variables

# prepare title
$daycolor = liturgical_color($dayname[1], $commune);
build_comment_line();

#prepare main pages
$title = "Sancta Missa";

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

if ($command =~ /setup(.*)/is) {
  $pmode = 'setup';
  $command = $1;
  print setuptable($command, $title);
  $command = "change" . $command;
} elsif ($command =~ /pray/i) {
  $pmode = 'missa';
  $command =~ s/(pray|change|setup)//ig;
  $head = $title;
  $headline = setheadline();
  headline($head);

  #eval($setup{'parameters'});
  $background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";
  ordo();
  print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
PrintTag
} else {    #mainpage
  $pmode = 'main';
  $command = "";
  $height = floor($screenheight * 3 / 12);
  $headline = setheadline();
  headline($title);
  print << "PrintTag";
<P ALIGN=CENTER>
<TABLE BORDER=0 HEIGHT=$height><TR>
<TD><IMG SRC="$htmlurl/missa.jpg" HEIGHT=$height></TD>
</TR></TABLE>
<BR>
</P>
PrintTag
}


if ($pmode =~ /(main|missa)/i) {
  #common widgets for main and hora
  $crubrics = ($rubrics) ? 'CHECKED' : '';
  $csolemn = ($solemn) ? 'CHECKED' : '';
  @chv = splice(@chv, @chv);
  for ($i = 0; $i < @versions; $i++) { $chv[$i] = $version =~ /$versions[$i]/ ? 'SELECTED' : ''; }
  $ctext = ($pmode =~ /(main)/i) ? 'Sancta Missa' : 'Sancta Missa Persoluta';
  print << "PrintTag";
<P ALIGN=CENTER><FONT SIZE=+1><I>
<LABEL FOR=rubrics>Rubrics : </LABEL><INPUT ID=rubrics TYPE=CHECKBOX NAME='rubrics' $crubrics Value=1  onclick="parchange()">
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="hset('$ctext');"><FONT COLOR=blue>$ctext</FONT></A>
&nbsp;&nbsp;&nbsp;
<LABEL FOR=solemn>Solemn : </LABEL><INPUT ID=solemn TYPE=CHECKBOX NAME='solemn' $csolemn Value=1 onclick="parchange()">
</I></P>
<P ALIGN=CENTER>
PrintTag

  print option_selector("Version", "parchange();", $version, @versions );

#$testmode = 'Regular' unless $testmode;
#if ($savesetup > 1) {
#  print option_selector("testmode", "parchange();", $testmode, qw(Regular Seasonal Season Saint Common));
#} else {
#  print option_selector("testmode", "parchange();", $testmode, qw(Regular Seasonal));
#}
  my $propname = ($Propers) ? 'Full' : 'Propers';
  print "&nbsp;&nbsp;&nbsp;";
  print htmlInput('lang2', $lang2, 'options', 'languages', , "parchange()" );
  @votive = ('Hodie;');
  if (opendir(DIR, "$datafolder/Latin/Votive")) {
    @a = sort readdir(DIR);
    closedir DIR;
    foreach (@a) { push(@votive, $_) if (s/\.txt//i); }
  }
  print option_selector("Votive", "parchange();", $votive, @votive );
  print "</P>\n";
  print qq(<P ALIGN=CENTER><FONT SIZE=+1>\n<A HREF=# onclick="hset('Propers')">$propname</A>\n</FONT></P>\n);
  print "<P ALIGN=CENTER><FONT SIZE=+1>\n" . bottom_links_menu() . "</FONT>\n</P>\n";
}    

#common end for programs
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n"; }
$command =~ s/(pray|setup)//ig;
print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=setupm VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=searchvalue VALUE="0">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=caller VALUE='0'>
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=first VALUE="$first">
<INPUT TYPE=HIDDEN NAME=Propers VALUE="$Propers">
<INPUT TYPE=HIDDEN NAME=compare VALUE=0>
</FORM>
</BODY></HTML>
PrintTag

#*** hedline($head) prints headlibe for main and pray
sub headline {
  my $head = shift;
  my $numsel = setmissanumber();
  $numsel = "<BR><BR>$numsel<BR>" if $numsel;
  $headline =~ s{!(.*)}{<FONT SIZE=1>$1</FONT>}s;
  print << "PrintTag";
<P ALIGN=CENTER><FONT COLOR=$daycolor>$headline<BR></FONT>
$comment<BR><BR>
<FONT COLOR=MAROON SIZE=+1><B><I>$head</I></B></FONT><P>
<P ALIGN=CENTER><A HREF=# onclick="callcompare()">Compare</A>
&nbsp;&nbsp;&nbsp;<A HREF=# onclick="callofficium();">Divinum Officium</A>
&nbsp;&nbsp;&nbsp;
<LABEL FOR=date CLASS=offscreen>Date</LABEL>
<INPUT ID=date TYPE=TEXT NAME=date VALUE="$date1" SIZE=10>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=submit NAME=SUBMIT VALUE=" " onclick="parchange();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Ordo</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="pset('parameters')">Options</A>
$numsel
</P>
PrintTag
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {
  print << "PrintTag";

<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

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
function hset(p) {
  if (p.match('Persoluta')) {
	return okbutton();
  }
  if (p.match('Propers')) {
    p = "$Propers";
	if (!p) p = 0;
	p = 1 - p;
	document.forms[0].Propers.value = p;
	p = 'Sancta Missa';
  }
  clearradio();
  if ("$caller") {document.forms[0].caller.value = 1;}
  document.forms[0].command.value = "pray" + p;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}


//finishing horas back to main page
function okbutton() {
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].command.value = ' ';
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

//restart the programramlet if parameter change
function parchange() {
  clearradio();
  var c = document.forms[0].command.value;
  if (c && !c.match("pray")) document.forms[0].command.value = "pray" + c;
  document.forms[0].submit();
}

//calls kalendar
function callkalendar() {
  document.forms[0].action = '../horas/kalendar.pl';
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls officium
function callofficium() {
  document.forms[0].action = '../horas/officium.pl';
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls compare
function callcompare() {
  document.forms[0].action = "Cmissa.pl";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls popup
function callpopup(popup) {
  document.forms[0].action = 'mpopup.pl';
  document.forms[0].target = "_new"
  document.forms[0].popup.value = popup;
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

# This procedure handles days on which there qre more than one proper Mass.
# It returns HTML offering the choice as a radio button sequence.
sub setmissanumber {
  our $missanumber;
  my $str;

  if ($winner{Rule} =~ /(multiple|celebranda aut\s+)(.*)/) {
    my $object = $2;
    my $lim;
    my @missae;

    if ($object =~ /[0-9]/) {
      @missae = 1 .. $object;
    } else {
      @missae = split /\baut\s+/i, $object;
    }
    my $i = 0;

    for (@missae) {
      $i = $i + 1;
      my $m = $i == $missanumber ? 'checked' : '';
      s/\bmissa/Missa/;
      $str .= "<input type='radio' $m onclick='parchange();' name='missanumber' value='$i'>$_</input>&nbsp;";
    }
  } else {
    $str = '';
  }
  return $str;
}
