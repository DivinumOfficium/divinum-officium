#!/usr/bin/perl
use utf8;

# name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
package horas;

#1;
#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FaTaL=>qw(all);

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
our $notes = 0;
our $missa = 0;
our $officium = 'officium.pl';
our $version = 'Rubrics 1960';

@versions = ('Tridentine 1570', 'Tridentine 1910', 'Divino afflatu', 'Reduced 1955', 'Rubrics 1960', '1960 Newcalendar');

#***common variables arrays and hashes
#filled  getweek()
our @dayname;    #0=advn|Natn|Epin|Quadpn|Quadn|Pascn|Pentn 1=winner title|2=other title

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
$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
our ($lang1, $lang2, $expand, $column, $accented, $local);
our %translate;     #translation of the skeleton labels

#internal script, cookies
%dialog = %{setupstring($datafolder, '', 'horas.dialog')};

if (!$setupsave) {
  %setup = %{setupstring($datafolder, '', 'horas.setup')};
} else {
  %setup = split(';;;', $setupsave);
}
if (!$setupsave && !getcookies('horasp', 'parameters')) { setcookies('horasp', 'parameters'); }
if (!$setupsave && !getcookies('horasgo', 'general')) { setcookies('horasgo', 'general'); }

our $command = strictparam('command');
our $hora = $command;    #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
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
if ($testmode !~ /(Season|Saint|Common)/i) { $testmode = 'regular'; }
our $votive = strictparam('votive');
$expandnum = strictparam('expandnum');
$notes = strictparam('notes');
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
  setsetupvalue('parametrs', 12, $screenheight);
}
$p = strictparam('textwidth');

if ($p) {
  $textwidth = $p;
  setsetupvalue('parametrs', 13, $textwidth);
}

#expand (all, psalms, nothing, skeleton) parameter
$flag = 0;
$p = strictparam('lang2');
if ($p) { $lang2 = $p; $flag = 1; }
$p = strictparam('version');
if ($p) { $version = $p; $flag = 1; }
$p = strictparam('expand');
if ($p) { $expand = $p; $flag = 1; }
$p = strictparam('accented');
if ($p) { $accented = $p; $flag = 1; }
$p = strictparam('local');
if ($p) { $local = $p; $flag = 1; }

if ($flag) {
  setsetup('general', $expand, $version, $lang2, $accented, $local);
  setcookies('horasgo', 'general');
}
if (!$expand) { $expand = 'all'; }
if (!$version) { $version = 'Rubrics 1960'; }
if (!$lang2) { $lang2 = 'English'; }
$only = ($lang1 =~ /^$lang2$/i) ? 1 : 0;
setmdir($version);

# save parameters
$setupsave = printhash(\%setup, 1);
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;
precedence();    #fills our hashes et variables
our $psalmnum1 = 0;
our $psalmnum2 = 0;
our $octavam = '';    #to avoid duplication of commemorations

# prepare title
$daycolor =
    ($commune =~ /(C1[0-9])/) ? "blue"
  : ($dayname[1] =~ /(Cathedra|oann|Pasch|Confessor|ascensio|Vigilia Nativitatis|Cena)/i) ? "black"
  : ($dayname[1] =~ /(Pentecosten|Epiphaniam|post octavam)/i) ? "green"
  : ($dayname[1] =~ /(Pentecostes|Evangel|Martyr|Innocentium|Cruc|apostol)/i) ? "red"
  : ($dayname[1] =~ /(Defunctorum|Parasceve|Morte)/i) ? "grey"
  : ($dayname[1] =~ /(Quattuor|Vigilia|Passionis|Quadragesima|Hebdomadæ Sanctæ|Septuagesim|Sexagesim|Quinquagesim|Ciner|adventus)/i) ? "purple"
  : "black";
build_comment_line();

#prepare main pages
my $h = $hora;

if ($h =~ /(ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Post|Setup)/i) {
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
my @local = splice(@local, @local);

#if (opendir(DIR, "$datafolder/Latin/Tabulae")) {
#  my @a = readdir(DIR);
#  close DIR;
#  foreach my $item (@a) {
#    if ($item =~ /K([a-Z]+)/) {push (@local, $1);}
#  }
#  unshift(@local, 'none');
#}
if ($command =~ /kalendar/) {    # kalendar widget
  print "access-Control-allow-Origin: *\n";
  print "Content-type: text/html; charset=utf-8\n";
  print "\n";
  $headline = setheadline();
  headline2($head);
} else {

  #*** print pages (setup, hora=pray, mainpage)
  #generate HTML
  htmlHead($title, 2);
  print << "PrintTag";
<body vlink=$visitedlink LINK=$link onload="startup();">
<link rel="stylesheet" href="../../www/style/main.css" />
<link rel="stylesheet" href="../../www/style/normalize.css" />
<script>
// https redirect
if (location.protocol !== 'https:' && (location.hostname == "divinumofficium.com" || location.hostname == "www.divinumofficium.com")) {
    location.replace(`https:\${location.href.substring(location.protocol.length)}`);
}
</script>
<form aCTION="$officium" METHOD=post TaRGET=_self>
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
    $head = ($title =~ /(ante|Post)/i) ? "$title divinum officium" : "ad $title";
    $head =~ s/ad Vesperam/ad Vesperas/i;
    $headline = setheadline();
    headline($head);

    #eval($setup{'parameters'});
    # $background = ($whitebground) ? "BGcolor=\"white\"" : "BaCKGROUND=\"../../www/horas/horasbg.jpg\"";
    horas($command);
    print << "PrintTag";
<p align=center>
<input type=SUBMIT name='button' value='$hora persolut.' onclick="okbutton();">
</p>
<input type=hidden name=expandnum value="">
<input type=hidden name=popup value="">
<input type=hidden name=popuplang value="">
PrintTag
  } else {    #mainpage
    $pmode = 'main';
    $command = "";
    $height = floor($screenheight * 4 / 14);
    $height2 = floor($height / 2);
    $headline = setheadline();
    headline($title);
    print << "PrintTag";
<p align=center>
<table border=0 HEIGHT=$height><TR>
<TD align=center><font color=MaROON>Ordinarium</font></TD>
<TD align=center><font color=MaROON>Psalterium</font></TD>
<TD align=center><font color=MaROON>Proprium de Tempore</font></TD>

</TR><TR><TD align=center ROWSPaN=2>
<!-- "htmlurl" not used for image links because of slow rendering -->
<IMG SRC="../../www/horas/breviarium.jpg" HEIGHT=$height aLT=""></TD>
<TD HEIGHT=50% Valign=MIDDLE align=center>
<IMG SRC="../../www/horas/psalterium.jpg" HEIGHT=$height2 aLT=""></TD>
<TD HEIGHT=50% Valign=MIDDLE align=center>
<IMG SRC="../../www/horas/tempore.jpg" HEIGHT=$height2 aLT=""></TD>
</TR><TR>
<TD HEIGHT=50% Valign=MIDDLE align=center>
<IMG SRC="../../www/horas/commune.jpg" HEIGHT=$height2 aLT=""></TD>
<TD HEIGHT=50% Valign=MIDDLE align=center>
<IMG SRC="../../www/horas/sancti.jpg" HEIGHT=$height2 aLT=""></TD>
</TR><TR>
<TD align=center><font color=RED></font></TD>
<TD align=center><font color=MaROON>Commune Sanctorum</font></TD>
<TD align=center><font color=MaROON>Proprium Sanctorum</font></TD>
</TR></table>
<BR>
</p>
PrintTag
  }

  #common widgets for main and hora
  if ($pmode =~ /(main|hora)/i) {
    if ($votive ne 'C9') {
      print << "PrintTag";
<p align=center><I><font size=+1>
<a href=# onclick="hset('Matutinum');">$horas[1]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Laudes');">$horas[2]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Prima');">$horas[3]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Tertia');">$horas[4]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Sexta');">$horas[5]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Nona');">$horas[6]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Vespera');">$horas[7]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Completorium');">$horas[8]</a>
</I></p>
PrintTag
    } else {
      print << "PrintTag";
<p align=center><i>
<a href=# onclick="hset('Matutinum');">$horas[1]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Laudes');">$horas[2]</a>
&nbsp;&nbsp;
<a href=# onclick="hset('Vespera');">$horas[7]</a>
&nbsp;&nbsp;
</i></p>
PrintTag
    }
    $ch1 = ($expand =~ /all/i) ? 'selectED' : '';
    $ch2 = ($expand =~ /psalms/i) ? 'selectED' : '';

    #  $ch3 = ($expand =~ /nothing/i) ? 'selectED' : '';
    #  $ch4 = ($expand =~ /skeleton/i) ? 'selectED' : '';
    @chv = splice(@chv, @chv);
    if (-e "$Bin/monastic.pl") { unshift(@versions, 'Monastic'); }
    for ($i = 0; $i < @versions; $i++) { $chv[$i] = $version =~ /$versions[$i]/ ? 'selectED' : ''; }
    print << "PrintTag";
<p align=center>
&nbsp;&nbsp;&nbsp;
<label FOR=expand class=offscreen>Expand</label>
<select ID=expand name=expand size=2 onchange="parchange();">
<option $ch1 value='all'>all
<option $ch2 value='psalms'>psalms
</select>
&nbsp;&nbsp;&nbsp;
PrintTag
    my $vsize = @versions;
    print "<label FOR=version class=offscreen>Version</label>";
    print "<select ID=version name=version size=$vsize onchange=\"parchange();\">\n";
    for ($i = 0; $i < @versions; $i++) { print "<option $chv[$i] value=\"$versions[$i]\">$versions[$i]\n"; }
    print "</select>\n";

    #if ($savesetup > 1) {
    #my $sel10 = (!$testmode || $testmode =~ /Regular/i) ? 'selectED' : '';
    #my $sel11 = ($testmode =~ /Seasonal/i) ? 'selectED' : '';
    #my $sel12 = ($testmode =~ /^Season$/i) ? 'selectED' : '';
    #my $sel13 = ($testmode =~ /Saint/i) ? 'selectED' : '';
    #my $sel14 = ($testmode =~ /Common/i) ? 'selectED' : '';
    #  print << "PrintTag";
    #&nbsp;&nbsp;&nbsp;
    #<select name=testmode size=4 onchange="parchange();">
    #<option $sel10 value='Regular'>Regular
    #<option $sel11 value='Seasonal'>Seasonal
    #<option $sel12 value='Season'>Season
    #<option $sel13 value='Saint'>Saint
    #<option $sel14 value='Common'>Common
    #</select>
    #PrintTag
    #} else {
    #my $sel10 = (!$testmode || $testmode =~ /Regular/i) ? 'selectED' : '';
    #my $sel11 = ($testmode =~ /Seasonal/i) ? 'selectED' : '';
    #  print << "PrintTag";
    #&nbsp;&nbsp;&nbsp;
    #<select name=testmode size=2 onchange="parchange();">
    #<option $sel10 value='Regular'>Regular
    #<option $sel11 value='Seasonal'>Seasonal
    #</select>
    #PrintTag
    #}
    $sel1 = '';    #($date1 eq gettoday()) ? 'selectED' : '';
    $sel2 = ($votive =~ /C8/) ? 'selectED' : '';
    $sel3 = ($votive =~ /C9/) ? 'selectED' : '';
    $sel4 = ($votive =~ /C12/) ? 'selectED' : '';
    $addvotive =
      ($version !~ /monastic/i)
      ? "&nbsp;&nbsp;&nbsp;\n"
      . "<label FOR=votive class=offscreen>Votive</label>"
      . "<select ID=votive name=votive size=4 onchange='parchange()'>\n"
      . "<option $sel1 value='Hodie'>Hodie\n"
      . "<option $sel2 value=C8>Dedicatio\n"
      . "<option $sel3 value=C9>Defunctorum\n"
      . "<option $sel4 value=C12>Parvum B.M.V.\n"
      . "</select>\n"
      : '';

    if (@local) {
      my @lsel = splice(@lsel, @lsel);

      for ($i = 0; $i < @local; $i++) {
        $lsel[$i] = ($local[$i] =~ /$local/i) ? 'selectED' : '';
      }
      my $sizelocal = (@local > 7) ? 7 : @local;
      $addlocal = "&nbsp;&nbsp;&nbsp;\n<select name=local size=$sizelocal onchange='parchange()'>\n";

      for ($i = 0; $i < @local; $i++) {
        $addlocal .= "<option $lsel[$i] value=$local[$i]>$local[$i]\n";
      }
      $addlocal .= "</select>\n";
    }
    my @languages = ('Latin', vernaculars($datafolder));
    my $lang_count = @languages;
    my $vers = $version;
    $vers =~ s/ /_/g;
    print << "PrintTag";
&nbsp;&nbsp;&nbsp;
<label FOR=lang2 class=offscreen>Language</label>
<select ID=lang2 name=lang2 size=$lang_count onchange="parchange()">
PrintTag

    foreach my $lang (@languages) {
      my $sel = ($lang2 =~ /$lang/i) ? 'selectED' : '';
      print qq(<option $sel value="$lang">$lang\n);
    }
    print << "PrintTag";
</select>
$addvotive
$addlocal
<br>
<div class="horizontal_rule"></div>
<footer class="footer">
  <a href="../../www/horas/Help/versions.html">Versions</a>
  <a href="../../www/horas/Help/credits.html">Credits</a>
  <a href="../../www/horas/Help/download.html">Download</a>
  <a href="../../www/horas/Help/rubrics.html">Rubrics</a>
  <a href="../../www/horas/Help/technical.html">Technical</a>
  <a href="../../www/horas/Help/help.html">Help</a>
</footer>
PrintTag

    if ($building && $buildscript) {
      $buildscript =~ s/[\n]+/\n/g;
      $buildscript =~ s/\n/<BR>/g;
      $buildscript =~ s/\_//g;
      $buildscript =~ s/\,\,\,/\&nbsp\;\&nbsp\;\&nbsp\;/g;
      print << "PrintTag";
<table border=3 align=center width=60% cellpadding=8><TR><TD ID=L$searchind>
$buildscript
</TD></TR><table><BR>
PrintTag
    }
  }

  #common end for programs
  if ($error) { print "<p align=center><font color=red>$error</font></p>\n"; }
  if ($debug) { print "<p align=center><font color=blue>$debug</font></p>\n"; }
  $command =~ s/(pray|setup)//ig;
  print << "PrintTag";
<input type=hidden name=setup value="$setupsave">
<input type=hidden name=command value="$command">
<input type=hidden name=searchvalue value="0">
<input type=hidden name=officium value="$officium">
<input type=hidden name=browsertime value="$browsertime">
<input type=hidden name=accented value="$accented">
<input type=hidden name=caller value='0'>
<input type=hidden name='notes' value="$notes">
</form>
</body></HTML>
PrintTag
}

#*** headline2($head) prints just two lines of header (for widget)
sub headline2 {
  my $head = shift;
  $headline =~ s{!(.*)}{<font size=1>$1</font>}s;
  $comment =~ s/([\w]+)=([\w+-]+)/$1="$2"/g;
  print "<p><span style='text-align:center;color:$daycolor'>$headline<br/></span>";
  print "<span>$comment<BR/><BR/></span></p>";
}

#*** headline($head) prints headline for main and pray
sub headline {
  my $head = shift;
  $headline =~ s{!(.*)}{<font size=1>$1</font>}s;
  print << "PrintTag";
<p align=center><font color=$daycolor>$headline<BR></font>
$comment<BR><BR>
<font color=MaROON size=+1><B><I>$head</I></B></font>
&nbsp;<font color=RED size=+1>$version</font></p>
<p align=center><a href="Cofficium.pl">Compare</a>
&nbsp;&nbsp;&nbsp;<a href=# onclick="callmissa();">Sancta Missa</a>
&nbsp;&nbsp;&nbsp;
<label FOR=date class=offscreen>Date</label>
<input type=TEXT ID=date name=date value="$date1" size=10>
<a href=# onclick="prevnext(-1)">&darr;</a>
<input type=submit name=SUBMIT value=" " onclick="parchange();">
<a href=# onclick="prevnext(1)">&uarr;</a>
&nbsp;&nbsp;&nbsp;
<a href=# onclick="callkalendar();">Ordo</a>
&nbsp;&nbsp;&nbsp;
<a href=# onclick="pset('parameters')">Options</a>
</p>
PrintTag
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {

  # $caller in principle might not be defined.
  my $caller_flag = $caller || 0;
  print << "PrintTag";

<SCRIPT type='text/JavaScript' LaNGUaGE='JavaScript1.2'>

//position
function startup() {
  if (!"$browsertime") {
    var d = new Date();
    var day = d.getDate();
    document.forms[0].browsertime.value = (d.getMonth() + 1) + "-" + day + "-" + d.getFullYear();
    var a = (day > $day) ? "-+" : (day < $day) ? "--" : "";
    document.forms[0].date.value = document.forms[0].browsertime.value + a;
	  if (a) document.forms[0].submit();
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
     document.forms[0].target = '_BLaNK';
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

function prevnext(ch) {
  var dat = document.forms[0].date.value;
  var adat = dat.split('-');
  var mtab = new array(31,28,31,30,31,30,31,31,30,31,30,31);
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
