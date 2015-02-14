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
our $Ck = 0;
our $officium = 'Eofficium.pl';
our $version = 'Rubrics 1960';
@versions = ('Trident 1570', 'Trident 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1960 Newcalendar');

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
our $commemorated; #name of the commemorated for vigils
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
require "$Bin/Ewebdia.pl";
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

#internal script, cookies
%dialog = %{setupstring($datafolder, '', 'horas.dialog')};
if (!$setupsave) {%setup = %{setupstring($datafolder, '', 'Ehoras.setup')};}
else {%setup = split(';;;', $setupsave);}

if (!$setupsave && !getcookies('horasp', 'parameters')) {setcookies('horasp', 'parameters');}
if (!$setupsave && !getcookies('horasgp', 'general')) {setcookies('horasgp', 'general');}

our $command = strictparam('command');
our $hora = $command; #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
our $date1 = strictparam('date1');
if (!$date1) {$date1 = gettoday();}
if ($command =~ /next/i) {$date1 = prevnext($date1, 1); $command = '';}
if ($command =~ /prev/i) {$date1 = prevnext($date1, -1); $command = '';}

our $browsertime = strictparam('browsertime');
our $buildscript = ''; #build script
our $searchvalue = strictparam('searchvalue');
if (!$searchvalue) {$searchvalue = '0';}

our $caller = strictparam('caller');
our $dirge = 0; #1=call from 1st vespers, 2=call from Lauds
our $dirgeline = ''; #dates for dirge from Trxxxxyyyy
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';

#*** handle different actions
#after setup
if ($command =~ /change/i ) {
 $command = $';
 getsetupvalue($command);
 if ($command =~ /parameters/) {setcookies('horasp', 'parameters');}
}

eval($setup{'parameters'}); #$priest, $lang1, colors, sizes
eval($setup{'general'});  #$expand, $version, $lang2

#prepare testmode
our $testmode = strictparam('testmode');
if (!$testmode) {$testmode = strictparam('testmode1');}
if (!$testmode) {$testmode = 'regular';}
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

$p = strictparam('screenheight');
if ($p) {
  $screenheight = $p;
  setsetupvalue('parametrs', 11, $screenheight);
}

$p = strictparam('textwidth');
if ($p) {
  $textwidth = $p;
  setsetupvalue('parametrs', 11, $textwidth);
}
$expand = 'all';

$flag = 0;
$p = strictparam('lang2');
if ($p) {$lang2 = $p; $flag = 1;}
$p = strictparam('version');
if ($p) {$version = $p; $flag = 1;}
$p = strictparam('accented');
if ($p) {$accented = $p; $flag = 1;}
if ($flag) {
  setsetup('general', $expand, $version, $lang2, $accented);
  setcookies('horasgp', 'general');
}
if (!$version) {$version = 'Rubrics 1960';}
if (!$lang2) {$lang2 = 'English';}
$only = ($lang1 =~ $lang2) ? 1 : 0;

setmdir($version);

# save parameters
$setupsave = printhash(\%setup, 1);
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;


precedence($date1); #fills our hashes et variables
our $psalmnum1 = 0;
our $psalmnum2 = 0;

# prepare title
$daycolor =   ($commune =~ /(C1[0-9])/) ? "blue" :
   ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? "black" :
   ($dayname[1] =~ /duplex/i) ? "red" :
    "grey";
build_comment_line();

#prepare main pages
my $h = $hora;
if ($h =~ /(Ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Post|Setup)/i)
  {$h = " $1";}
else {$h = '';}
$title = "Divinum Officium$h - $date1";
@horas=getdialogcolumn('horas','~',0);
for ($i = 0; $i < 10; $i++) {$hcolor[$i] = 'black';}
$completed = getcookie1('completed');
if ($date1 eq gettoday() && $command =~ /pray/i && $completed < 8 &&
    $command =~ substr($horas[$completed+1], 0, 4)) {
  $completed++;
  setcookie1('completed', $completed);
}
for ($i = 1; $i <= $completed; $i++) {$hcolor[$i] = 'maroon';}

#*** print pages (setup, hora=pray, mainpage)
  #generate HTML
  htmlHead($title, 2);
    print << "PrintTag";
<BODY VLINK="black" LINK="black" STYLE="font-family:'Gentium Book Basic'; font-size:87%; line-height:130%;">
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

  $head = ($title =~ /(Ante|Post)/i) ? "$title divinum officium" : "Ad $title";
  $head =~ s/Ad Vesperam/Ad Vesperas/i;

  $headline = setheadline();
  headline($head);

  horas($command);

  print << "PrintTag";
PrintTag

} else {	#mainpage
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
<P ALIGN="center">
<A HREF="$date1-1-Matutinum.html"><FONT COLOR="$hcolor[1]">$horas[1]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-2-Laudes.html"><FONT COLOR="$hcolor[2]">$horas[2]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-3-Prima.html"><FONT COLOR="$hcolor[3]">$horas[3]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-4-Tertia.html"><FONT COLOR="$hcolor[4]">$horas[4]</FONT></A>
<BR>
<A HREF="$date1-5-Sexta.html"><FONT COLOR="$hcolor[5]">$horas[5]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-6-Nona.html"><FONT COLOR="$hcolor[6]">$horas[6]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-7-Vespera.html"><FONT COLOR="$hcolor[7]">$horas[7]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-8-Completorium.html"><FONT COLOR="$hcolor[8]">$horas[8]</FONT></A>
</P>
PrintTag
} else {
print << "PrintTag";
<P ALIGN="center">
<A HREF="$date1-1-Matutinum.html"><FONT COLOR="$hcolor[1]">$horas[1]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-2-Laudes.html"><FONT COLOR="$hcolor[2]">$horas[2]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-7-Vespera.html"><FONT COLOR="$hcolor[7]">$horas[7]</FONT></A>
&nbsp;&nbsp;
</P>
PrintTag
}
}

#common end for programs
  if ($error) {print "<P ALIGN=\"center\"><FONT COLOR=\"red\">$error</FONT><\P>\n";}
  if ($debug) {print "<P ALIGN=\"center\"><FONT COLOR=\"blue\">$debug</FONT><\P>\n";}

  $command =~ s/(pray|setup)//ig;

  print << "PrintTag";
</BODY></HTML>
PrintTag



#*** hedline($head) prints headlibe for main and pray
sub headline {
  my $head = shift;
  if ($headline =~ /\!/) {$headline = $` . "<FONT SIZE=\"1\">" . $' . "</FONT>";}
  my $h = ($hora =~ /(Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium)/i) ? $hora : '';
  my $daten = prevnext($date1, 1);
  my $datep = prevnext($date1, -1);
  print << "PrintTag";
<P ALIGN="center"><FONT COLOR="$daycolor">$headline<BR></FONT>
$comment<BR><BR>
<SPAN STYLE="font-size:113%; color:maroon;">$h</SPAN>&nbsp;&nbsp;&nbsp;
<A HREF="$datep-1-Matutinum.html">&darr;</A>
$date1
<A HREF="$daten-1-Matutinum.html">&uarr;</A>
</P>
<P ALIGN="center">
<A HREF="$date1-1-Matutinum.html"><FONT COLOR="$hcolor[1]">$horas[1]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-2-Laudes.html"><FONT COLOR="$hcolor[2]">$horas[2]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-3-Prima.html"><FONT COLOR="$hcolor[3]">$horas[3]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-4-Tertia.html"><FONT COLOR="$hcolor[4]">$horas[4]</FONT></A>
<BR>
<A HREF="$date1-5-Sexta.html"><FONT COLOR="$hcolor[5]">$horas[5]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-6-Nona.html"><FONT COLOR="$hcolor[6]">$horas[6]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-7-Vespera.html"><FONT COLOR="$hcolor[7]">$horas[7]</FONT></A>
&nbsp;&nbsp;
<A HREF="$date1-8-Completorium.html"><FONT COLOR="$hcolor[8]">$horas[8]</FONT></A>
</P>
PrintTag
}

sub prevnext {
  my $date1 = shift;
  my $inc = shift;

  $date1 =~ s/\//\-/g;
  my ($month,$day,$year) = split('-',$date1);

  my $d= date_to_days($day,$month-1,$year);

  my @d = days_to_date($d + $inc);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;
  return sprintf("%02i-%02i-%04i", $month, $day, $year);
}



#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {
 print << "PrintTag";
PrintTag
}
