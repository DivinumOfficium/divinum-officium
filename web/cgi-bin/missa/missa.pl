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
use DivinumOfficium::Main qw(vernaculars);
$error = '';
$debug = '';

our $Tk = 0;
our $Hk = 0;
our $Ck = 0;
our $missa = 1;
our $NewMass = 0;
our $officium = 'missa.pl';
our $version = 'Rubrics 1960';

@versions =
  ('Tridentine 1570', 'Tridentine 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1965-1967', '1960 Newcalendar');

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
require "$Bin/webdia.pl";
require "$Bin/msetup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

binmode(STDOUT, ':encoding(utf-8)');
$q = new CGI;

#get parameters
getini('missa');    #files, colors
$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
our ($lang1, $lang2, $column);
our %translate;     #translation of the skeleton label for 2nd language

#internal script, cookies
%dialog = %{setupstring($datafolder, '', 'missa.dialog')};

if (!$setupsave) {
  %setup = %{setupstring($datafolder, '', 'missa.setup')};
} else {
  %setup = split(';;;', $setupsave);
}
if (!$setupsave && !getcookies('missap', 'parameters')) { setcookies('missap', 'parameters'); }
if (!$setupsave && !getcookies('missago', 'general')) { setcookies('missago', 'general'); }
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
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';

#*** handle different actions
#after setup
if ($command =~ /change(.*)/is) {
  $command = $1;
  getsetupvalue($command);
  if ($command =~ /parameters/) { setcookies('missap', 'parameters'); }
}
eval($setup{'parameters'});    #$lang1, colors, sizes
eval($setup{'general'});       #$version, $testmode,$lang2,$votive,$rubrics, $solemn

#prepare testmode
our $testmode = strictparam('testmode');
if ($testmode !~ /(Seasonal|Season|Saint)/i) { $testmode = 'regular'; }
our $votive = strictparam('votive');
$p = strictparam('lang1');

if ($p) {
  $lang1 = $p;
  setsetupvalue('parameters', 2, $lang1);
}
$p = strictparam('screenheight');

if ($p) {
  $screenheight = $p;
  setsetupvalue('parametrs', 11, $screenheight);
}
$p = strictparam('textwidth');

if ($p) {
  $textwidth = $p;
  setsetupvalue('parametrs', 12, $screenheight);
}

#expand (all, psalms, nothing, skeleton) parameter
$flag = 0;
$p = strictparam('lang2');
if ($p) { $lang2 = $p; $flag = 1; }
$p = strictparam('version');
if ($p) { $version = $p; $flag = 1; }

if (!$first) {
  $first = 1;
} else {
  $flag = 1;
  $rubrics = strictparam('rubrics');
  $solemn = strictparam('solemn');
}

if ($flag) {
  setsetup('general', $version, $testmode, $lang2, $votive, $rubrics, $solemn);
  setcookies('missago', 'general');
}
if (!$version) { $version = 'Rubrics 1960'; }
if (!$lang2) { $lang2 = 'English'; }
$only = ($lang1 =~ /$lang2/) ? 1 : 0;
setmdir($version);

# save parameters
$setupsave = printhash(\%setup, 1);
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;
precedence();    #fills our hashes et variables

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
  setuptable($command);
} elsif ($command =~ /pray/i) {
  $pmode = 'missa';
  $command =~ s/(pray|change|setup)//ig;
  $title = "Sancta Missa";
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
$vsize = @versions;
print "
  <LABEL FOR=version CLASS=offscreen>Version</LABEL>
  <SELECT ID=version NAME=version SIZE=$vsize onchange=\"parchange();\">\n
";
for ($i = 0; $i < @versions; $i++) { print "<OPTION $chv[$i] VALUE=\"$versions[$i]\">$versions[$i]\n"; }
print "</SELECT>\n";

#if ($savesetup > 1) {
#my $sel10 = (!$testmode || $testmode =~ /regular/i) ? 'SELECTED' : '';
#my $sel11 = ($testmode =~ /Seasonal/i) ? 'SELECTED' : '';
#my $sel12 = ($testmode =~ /^Season$/i) ? 'SELECTED' : '';
#my $sel13 = ($testmode =~ /Saint/i) ? 'SELECTED' : '';
#  print << "PrintTag";
#&nbsp;&nbsp;&nbsp;
#<SELECT NAME=testmode SIZE=4 onchange="parchange();">
#<OPTION $sel10 VALUE='regular'>regular
#<OPTION $sel11 VALUE='Seasonal'>Seasonal
#<OPTION $sel12 VALUE='Season'>Season
#<OPTION $sel13 VALUE='Saint'>Saint
#</SELECT>
#PrintTag
#} else {
#my $sel10 = (!$testmode || $testmode =~ /regular/i) ? 'SELECTED' : '';
#my $sel11 = ($testmode =~ /Seasonal/i) ? 'SELECTED' : '';
#  print << "PrintTag";
#&nbsp;&nbsp;&nbsp;
#<SELECT NAME=testmode SIZE=2 onchange="parchange();">
#<OPTION $sel10 VALUE='regular'>regular
#<OPTION $sel11 VALUE='Seasonal'>Seasonal
#</SELECT>
#PrintTag
#}
@sel = ();
@votive = ('Hodie');

if (opendir(DIR, "$datafolder/Latin/Votive")) {
  @a = sort readdir(DIR);
  closedir DIR;
  my $item;

  foreach $item (@a) {
    if ($item =~ /\.txt/i) { $item =~ s/\.txt//i; push(@votive, $item); }
  }
}
$sel[0] = '';
for ($i = 1; $i < @votive; $i++) { $sel[$i] = ($votive =~ $votive[$i]) ? 'SELECTED' : ''; }
$osize = (@votive > $vsize) ? $vsize : @votive;
$addvotive = "
  &nbsp;&nbsp;&nbsp;\n
  <LABEL FOR=votive CLASS=offscreen>Votive</LABEL>
  <SELECT ID=votive NAME=votive SIZE=$osize onchange=\"parchange()\">\n
";
for ($i = 0; $i < @votive; $i++) { $addvotive .= "<OPTION $sel[$i] VALUE=\"$votive[$i]\">$votive[$i]\n"; }
$addvotive .= "</SELECT>\n";
my @languages = ('Latin', vernaculars($datafolder));
my $lang_count = @languages;
my $vers = $version;
$vers =~ s/ /_/g;
my $propname = ($Propers) ? 'Full' : 'Propers';
print << "PrintTag";
&nbsp;&nbsp;&nbsp;
<LABEL FOR=lang2 CLASS=offscreen>Language</LABEL>
<SELECT ID=lang2 NAME=lang2 SIZE="$lang_count" onchange="parchange()">
PrintTag
foreach my $lang (@languages) {
  my $sel = ($lang2 =~ /$lang/i) ? 'SELECTED' : '';
  print qq(<OPTION $sel VALUE="$lang">$lang</OPTION>);
}
print << "PrintTag";
</SELECT>
$addvotive</P>
<P ALIGN=CENTER><FONT SIZE=+1>
PrintTag
print << "PrintTag";
<P ALIGN=CENTER>
<A HREF=# onclick="hset('Propers')">$propname</A></P>
PrintTag
print "</FONT></P>\n";
    print << "PrintTag";
</SELECT>
<P ALIGN=CENTER><FONT SIZE=+1>
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
<INPUT TYPE=HIDDEN NAME=caller VALUE='0'>
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=first VALUE="$first">
<INPUT TYPE=HIDDEN NAME=Propers VALUE="$Propers">
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
<P ALIGN=CENTER><A HREF="Cmissa.pl">Compare</A>
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
  if (p.match('Completed')) {
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
  document.forms[0].action = 'kalendar.pl';
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls officium
function callofficium() {
  document.forms[0].action = '../horas/officium.pl';
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
