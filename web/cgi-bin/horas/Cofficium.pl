#!/usr/bin/perl
use utf8;
# vim: set encoding=utf-8 :

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
use CGI::Cookie;;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use LWP::Simple;
use Time::Local;
#use DateTime;
use locale;

$error = '';	 
$debug = '';
our $Tk = 0;
our $Hk = 0;
our $Ck = 1;
our $notes = 0;
our $missa = 0;
our @ctext1 = splice(@ctext1, @ctext1);
our @ctext2 = splice(@ctext2, @ctext2);

our $officium = 'Cofficium.pl';
our $version1 = 'Divino Afflatu';
our $version2 = 'Rubrics 1960';
our $version = '';
@versions = ('Trident 1570', 'Trident 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1960 Newcalendar');
if (-e "$Bin/monastic.pl") {unshift(@versions, 'pre Trident Monastic');}

#***common variables arrays and hashes
#filled  getweek()
our @dayname; #0=Advn|Natn|Epin|Quadpn|Quadn|Pascn|Pentn 1=winner title|2=other title

#filled by getrank()
our $winner; #the folder/filename for the winner of precedence
our $commemoratio; #the folder/filename for the commemorated
our $scriptura; #the folder/filename for the scripture reading (if winner is sancti)
our $commune; #the folder/filename for the used commune
our $communetype; #ex|vide
our $rank; #the rank of the winner
our $laudes; #1 or 2
our $vespera; #1 | 3 index for ant, versum, oratio
our $cvespera; #for commemoratio
our $commemorated; #name of the commemorated for Vigils
our $comrank = 0; #rank of the commemorated office

#filled by precedence()
our %winner; #the hash of the winner 
our %commemoratio; #the hash of the commemorated
our %scriptura; #the hash for the scriptura
our %commune; # the hash of the commune
our (%winner2, %commemoratio2, %commune2); #same for 2nd column
our $rule; # $winner{Rank}
our $communerule; # $commune{Rank}
our $duplex; #1=simplex-feria, 2=semiduplex-feria privilegiata, 3=duplex 
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
if (-e "$Bin/monastic.pl") {require "$Bin/monastic.pl";}
require "$Bin/tfertable.pl";

binmode(STDOUT,':encoding(utf-8)');

$q = new CGI;

#get parameters
getini('horas'); #files, colors

$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;

our ($lang1, $lang2, $expand, $column, $accented);
our %translate; #translation of the skeleton label for 2nd language 
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';

#internal script, cookies
%dialog = %{setupstring("$datafolder/horas.dialog")};
if (!$setupsave) {%setup = %{setupstring("$datafolder/horas.setup")};}
else {%setup = split(';;;', $setupsave);}

if (!$setupsave && !getcookies('horasp', 'parameters')) {setcookies('horasp', 'parameters');}
if (!$setupsave && !getcookies('horasgc', 'generalc')) {setcookies('horasgc', 'generalc');}

our $command = strictparam('command');
our $hora = $command; #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
our $browsertime = strictparam('browsertime');
our $buildscript = ''; #build script
our $searchvalue = strictparam('searchvalue');
if (!$searchvalue) {$searchvalue = '0';}
    
#*** handle different actions
#after setup
if ($command =~ /change/i ) { 
 $command = $';                 
 getsetupvalue($command);   
 if ($command =~ /parameters/) {setcookies('horasp', 'parameters');}
}    

eval($setup{'parameters'}); #$priest, $lang1, colors, sizes
eval($setup{'generalc'});  #$expand, $version, $lang2       

#prepare testmode
our $testmode = strictparam('testmode');
if ($testmode !~ /(Season|Saint|Common)/i) {$testmode = 'regular';}
our $votive = strictparam('votive');
$expandnum = strictparam('expandnum');

$p = strictparam('priest');
if ($p) {
  $priest = 1;
  setsetupvalue('parameters', 0, $priest);
}

$p = strictparam('screenheight');
if ($p) {
  $screenheight = $p;
  setsetupvalue('parametrs', 11, $screenheight);
}

#expand (all, psalms, nothing, skeleton) parameter
$flag = 0;
$p = strictparam('lang2');
if ($p) {$lang2 = $p; $flag = 1;}
$p = strictparam('version1');
if ($p) {$version1 = $p; $flag = 1;}
$p = strictparam('version2');
if ($p) {$version2 = $p; $flag = 1;}
$p = strictparam('expand');
if ($p) {$expand = $p; $flag = 1;}
$p = strictparam('accented');
if ($p) {$accented = $p; $flag = 1;}   
if ($flag) {
  setsetup('generalc', $expand, $version1, $version2, $lang2, $accented);
  setcookies('horasgc', 'generalc');
}
if (!$expand) {$expand = 'psalms';}
if (!$version) {$version = 'Divino Afflatu';}
if (!$lang2) {$lang2 = 'English';}
$only = ($version1 =~ /$version2/) ? 1 : 0;	 

# save parameters
$setupsave = printhash(\%setup, 1);   
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;	  


$version = $version1;
$lang1 = $lang2;
setmdir($version);
precedence(); #fills our hashes et variables  
our $psalmnum1 = 0;
our $psalmnum2 = 0;                           
our $octavam = ''; #to avoid duplication of commemorations

# prepare title
$daycolor =   ($commune =~ /(C1[0-9])/) ? "blue" :
   ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? "black" : 
   ($dayname[1] =~ /duplex/i) ? "red" : 
    "grey"; 
$commentcolor = ($dayname[2] =~ /(Feria)/i) ? 'black' : (/Sabbato/i) ? 'blue' : 'maroon';
$comment = ($dayname[2]) ? "<FONT COLOR=$commentcolor SIZE=-1><I>$dayname[2]</I></FONT>" : "";

#prepare main pages
my $h = $hora;
if ($h =~ /(Ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Post|Setup)/i)
  {$h = " $1";}
else {$h = '';}
$title = "Divinum Officium$h";
@horas=getdialogcolumn('horas','~',0);
for ($i = 0; $i < 10; $i++) {$hcolor[$i] = 'blue';}
#$completed = getcookie1('completed');
#if ($date1 eq gettoday() && $command =~ /pray/i && $completed < 8 && 
#    $command =~ substr($horas[$completed+1], 0, 4)) {
#  $completed++;
#  setcookie1('completed', $completed);
#}
#for ($i = 1; $i <= $completed; $i++) {$hcolor[$i] = 'maroon';}


#*** print pages (setup, hora=pray, mainpage)  
  #generate HTML
  htmlHead($title, 2);
    print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg" onload="startup();"> 
<FORM ACTION="$officium" METHOD=post TARGET=_self>
PrintTag

if ($command =~ /setup/i) {	  
  $pmode = 'setup';
  $command = $';
  setuptable($command);

} elsif ($command =~ /pray/) {
  $pmode = 'hora';
  $command =~ s/(pray|change|setup)//ig;
  $title = $command;
  $hora = $command;
  if (substr($title,-1) =~ /a/i) {$title .= 'm';}
  $background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";

  $head = ($title =~ /(Ante|Post)/i) ? "$title divinum officium" : "Ad $title";

  headline($head);
  horas($command); 

  print << "PrintTag";
<P ALIGN=CENTER>
<INPUT TYPE=SUBMIT NAME='button' VALUE='$hora completed' onclick="okbutton();">
</P>
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=popuplang VALUE="">
PrintTag

} else {	#mainpage
  $pmode = 'main';
  $command = "";
  $height = floor($screenheight * 4 / 12);
  $height2 = floor($height / 2);

  $background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";
  headline($title);
  
  print << "PrintTag";
<P ALIGN=CENTER>
<TABLE BORDER=0 HEIGHT=$height><TR>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Ordinarium</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Psalterium</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Proprium de tempore</FONT></TD>

</TR><TR><TD ALIGN=CENTER ROWSPAN=2>
<IMG SRC="$htmlurl/breviarium.gif" HEIGHT=$height></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/psalterium.gif" HEIGHT=$height2></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/tempore.gif" HEIGHT=$height2></TD>
</TR><TR>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/commune.gif" HEIGHT=$height2></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/sancti.gif" HEIGHT=$height2></TD>
</TR><TR>
<TD ALIGN=CENTER><FONT COLOR=RED>$version</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Commune Sanctorum</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Proprium Sanctorum</FONT></TD>
</TR></TABLE>
<BR>
</P>
PrintTag
}

#common widgets for main and hora
if ($pmode =~ /(main|hora)/i) {
  if ($votive ne 'C9') {
print << "PrintTag";
<P ALIGN=CENTER><I>
<A HREF=# onclick="hset('Matutinum');"><FONT COLOR=$hcolor[1]>$horas[1]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Laudes');"><FONT COLOR=$hcolor[2]>$horas[2]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Prima');"><FONT COLOR=$hcolor[3]>$horas[3]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Tertia');"><FONT COLOR=$hcolor[4]>$horas[4]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Sexta');"><FONT COLOR=$hcolor[5]>$horas[5]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Nona');"><FONT COLOR=$hcolor[6]>$horas[6]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Vespera');"><FONT COLOR=$hcolor[7]>$horas[7]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Completorium');"><FONT COLOR=$hcolor[8]>$horas[8]</FONT></A>
</I></P>
PrintTag
} else {
print << "PrintTag";
<P ALIGN=CENTER><I>
<A HREF=# onclick="hset('Matutinum');"><FONT COLOR=$hcolor[1]>$horas[1]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Laudes');"><FONT COLOR=$hcolor[2]>$horas[2]</FONT></A>
&nbsp;&nbsp; 
<A HREF=# onclick="hset('Vespera');"><FONT COLOR=$hcolor[7]>$horas[7]</FONT></A>
&nbsp;&nbsp; 
</I></P>
PrintTag
} 
  $ch1 = ($expand =~ /all/i) ? 'SELECTED' : '';
  $ch2 = ($expand =~ /psalms/i) ? 'SELECTED' : '';
  $ch3 = ($expand =~ /nothing/i) ? 'SELECTED' : '';
  $ch4 = ($expand =~ /skeleton/i) ? 'SELECTED' : '';
  
  @chv1 = splice(@chv, @chv);
  for ($i = 0; $i < @versions; $i++) {$chv1[$i] = ($version1 =~ /$versions[$i]/) ? 'SELECTED' : '';}

  @chv2 = splice(@chv, @chv);
  for ($i = 0; $i < @versions; $i++) {$chv2[$i] = ($version2 =~ /$versions[$i]/) ? 'SELECTED' : '';}
                     
  print << "PrintTag";
<P ALIGN=CENTER>
&nbsp;&nbsp;&nbsp;  
<SELECT NAME=expand SIZE=4 onchange="parchange();">
<OPTION $ch1 VALUE='all'>all
<OPTION $ch2 VALUE='psalms'>psalms
<OPTION $ch3 VALUE='nothing'>nothing
<OPTION $ch4 VALUE='skeleton'>skeleton
</SELECT>
&nbsp;&nbsp;&nbsp;  
PrintTag

  my $vsize = @versions;
  print "<SELECT NAME=version1 SIZE=$vsize onchange=\"parchange();\">\n";
  for ($i = 0; $i < @versions; $i++) {print "<OPTION $chv1[$i] VALUE=\"$versions[$i]\">$versions[$i]\n";}
  print "</SELECT>\n";

  print "<SELECT NAME=version2 SIZE=$vsize onchange=\"parchange();\">\n";
  for ($i = 0; $i < @versions; $i++) {print "<OPTION $chv2[$i] VALUE=\"$versions[$i]\">$versions[$i]\n";}
  print "</SELECT>\n";

if ($savesetup > 1) {
my $sel10 = (!$testmode || $testmode =~ /regular/i) ? 'SELECTED' : '';
my $sel11 = ($testmode =~ /Seasonal/i) ? 'SELECTED' : '';
my $sel12 = ($testmode =~ /^Season$/i) ? 'SELECTED' : '';
my $sel13 = ($testmode =~ /Saint/i) ? 'SELECTED' : '';
my $sel14 = ($testmode =~ /Common/i) ? 'SELECTED' : '';

  print << "PrintTag";
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Kalendarium</A>
&nbsp;&nbsp;&nbsp;
<SELECT NAME=testmode SIZE=4 onclick="parchange();">
<OPTION $sel10 VALUE='regular'>regular
<OPTION $sel11 VALUE='Seasonal'>Seasonal
<OPTION $sel12 VALUE='Season'>Season
<OPTION $sel13 VALUE='Saint'>Saint
<OPTION $sel14 VALUE='Common'>Common
</SELECT>
PrintTag
} else {
my $sel10 = (!$testmode || $testmode =~ /regular/i) ? 'SELECTED' : '';
my $sel11 = ($testmode =~ /Seasonal/i) ? 'SELECTED' : '';
  print << "PrintTag";
&nbsp;&nbsp;&nbsp;
<SELECT NAME=testmode SIZE=2 onclick="parchange();">
<OPTION $sel10 VALUE='regular'>regular
<OPTION $sel11 VALUE='Seasonal'>Seasonal
</SELECT>
PrintTag
}

$chl1 = ($lang2 =~ /Latin/i) ? 'SELECTED' : '';
$chl2 = ($lang2 =~ /English/i) ? 'SELECTED' : '';
$chl3 = ($lang2 =~ /Magyar/i) ? 'SELECTED' : '';
$sel1 = ''; #($date1 eq gettoday()) ? 'SELECTED' : '';
$sel2 = ($votive =~ /C8/) ? 'SELECTED' : '';
$sel3 = ($votive =~ /C9/) ? 'SELECTED' : '';
$sel4 = ($votive =~ /C12/) ? 'SELECTED' : '';

  print << "PrintTag";
&nbsp;&nbsp;&nbsp;
<SELECT NAME=lang2 SIZE=3 onclick="parchange()">
<OPTION $chl1 VALUE='Latin'>Latin
<OPTION $chl2 VALUE=English>English
<OPTION $chl3 VALUE=Magyar>Magyar
</SELECT>
&nbsp;&nbsp;&nbsp;
<SELECT NAME=votive SIZE=4 onclick="parchange()">
<OPTION $sel1 VALUE='hodie'>hodie
<OPTION $sel2 VALUE=C8>Dedication
<OPTION $sel3 VALUE=C9>Defunctorum
<OPTION $sel4 VALUE=C12>Parvum B.M.V.
</SELECT>
<BR>
<P ALIGN=CENTER><FONT SIZE=-1>
<A HREF="officium.pl">One version</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF=edit.pl?lang=$lang2&date=$date1&version=$version" TARGET="_NEW">Show files</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF=# onclick="pset('parameters')">Options</A>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF="$htmlurl/Help/versions.html" TARGET="_NEW">Versions</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF="$htmlurl/Help/credits.html" TARGET="_NEW">Credits</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF="$htmlurl/Help/new.html" TARGET="_NEW">What's new</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF="$htmlurl/Help/download.html" TARGET="_NEW">Download</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF="$htmlurl/Help/rubrics.html" TARGET="_NEW">Rubrics</A>
&nbsp;&nbsp;&nbsp;&nbsp; 
<A HREF="$htmlurl/Help/Ahelp.html" TARGET="_NEW">Help</A>
</FONT>
</P>
PrintTag



  if ($building && $buildscript ) { 
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
  if ($error) {print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n";}
  if ($debug) {print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n";}

  $command =~ s/(pray|setup)//ig;

  print << "PrintTag";
<INPUT TYPE=HIDDEN NAME=setup VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=searchvalue VALUE="0">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=accented VALUE="$accented">
</FORM>
</BODY></HTML>
PrintTag



#*** hedline($head) prints headlibe for main and pray
sub headline {
  my $head = shift;
  my $width = ($only) ? 100 : 50;

  $version = $version1;
  setmdir($version);   
  precedence();
  $daycolor =   ($commune =~ /(C1[0-9])/) ? "blue" :
   ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? "black" : 
   ($dayname[1] =~ /duplex/i) ? "red" : 
    "grey"; 
  $commentcolor = ($dayname[2] =~ /(Feria)/i) ? 'black' : (/Sabbato/i) ? 'blue' : 'maroon';
  $comment = ($dayname[2]) ? "<FONT COLOR=$commentcolor SIZE=-1><I>$dayname[2]</I></FONT>" : "";
  $headline = setheadline();
	if ($headline =~ /\!/) {$headline = $` . "<FONT SIZE=1>" . $' . "</FONT>";}
  print "<CENTER><TABLE BORDER=1 CELLPADDING=5><TR>" .
    "<TD $background ALIGN=CENTER WIDTH=$width%>$version1 : <FONT COLOR=$daycolor>$headline</FONT>" .
    "<BR>$comment</TD>";
  
  if (!$only) {
    $version = $version2;
    setmdir($version);
    precedence();
    $daycolor =   ($commune =~ /(C1[0-9])/) ? "blue" :
     ($dayname[1] =~ /duplex/i) ? "red" : 
     ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? "black" : 
      "grey"; 
    $commentcolor = ($dayname[2] =~ /(Feria)/i) ? 'black' : (/Sabbato/i) ? 'blue' : 'maroon';
    $comment = ($dayname[2]) ? "<FONT COLOR=$commentcolor SIZE=-1><I>$dayname[2]</I></FONT>" : "";
    $headline = setheadline();
	  if ($headline =~ /\!/) {$headline = $` . "<FONT SIZE=1>" . $' . "</FONT>";}
    print "<TD $background ALIGN=CENTER WIDTH=$width%>$version2 : <FONT COLOR=$daycolor>$headline</FONT>" .
    "<BR>$comment</TD>";
  }
  print "</TR></TABLE></CENTER>\n";

  print << "PrintTag";
<P ALIGN=CENTER>
<FONT COLOR=MAROON SIZE=+1><B><I>$head</I></B></FONT>
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE=TEXT NAME=date VALUE="$date1" SIZE=10>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=BUTTON NAME=SUBMIT VALUE=" " onclick="parchange();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Kalendarium</A>
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
  document.forms[0].action = 'Ckalendar.pl';		  
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

