#!/usr/bin/perl
use utf8;

# Name : Stepan Srubar
# Date : 2015-10-28
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
#use CGI::Cookie;;
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
require "$Bin/Ewebdia.pl";
require "$Bin/headline.pl";

#allow the script to be started directly from the "standalone/tools/epubgen2" subdirectory
if( ! -e "$Bin/do_io.pl") {
	$Bin = "$Bin/../../../web/cgi-bin/horas";
}

require "$Bin/do_io.pl";
require "$Bin/horascommon.pl";
require "$Bin/dialogcommon.pl";

require "$Bin/setup.pl";
require "$Bin/horas.pl";
require "$Bin/specials.pl";
require "$Bin/specmatins.pl";
if (-e "$Bin/monastic.pl") {require "$Bin/monastic.pl";}
#require "$Bin/tfertable.pl";

binmode(STDOUT,':encoding(utf-8)');

$q = new CGI;

#Handle parameters given to the script.
 
getini('horas'); #files, colors

$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;

our ($lang1, $lang2, $expand, $column, $accented);
our %translate; #translation of the skeleton label for 2nd language

#internal script, cookies
%dialog = %{setupstring($datafolder, '', 'horas.dialog')};
if (!$setupsave) {%setup = %{setupstring('.', '', 'Ehoras.setup')};}
else {%setup = split(';;;', $setupsave);}

our $command = strictparam('command');
our $hora = $command; #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
my $h = $hora;
if ($h =~ /(Ante|Matutinum|Laudes|Prima|Tertia|Sexta|Nona|Vespera|Completorium|Post)/i) { 
  $h = " $1"; # parse out the second word of the command ('prayMatutinum' => ' Matutinum')
} else {
  die "Unrecognized value for parameter 'command' specified: '$hora'. Expected one of prayMatutinum, prayLaudes, prayTertia, praySexta, prayNona, prayVespera, prayCompletorium, prayAnte, prayPost";
}

our $date1 = strictparam('date1');
if (!$date1) {
	die "No date specified. Specify parameter 'date1' with a value in MM-DD-YYYY format (e.g. 09-28-2023).";
}

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

our $linkmissa = length strictparam('linkmissa');
our $nofancychars = strictparam('nofancychars');

#*** handle different actions
#after setup
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
$nonumbers = strictparam('nonumbers');
if ($flag) {
  setsetup('general', $expand, $version, $lang2, $accented);
  #setcookies('horasgp', 'general');
}
if (!$version) {$version = 'Rubrics 1960';}
if (!$lang2) {$lang2 = 'English';}
$only = ($lang1 =~ $lang2) ? 1 : 0;

setmdir($version);

precedence($date1); #fills our hashes et variables
our $psalmnum1 = 0;
our $psalmnum2 = 0;

#prepare main pages
$title = "Divinum Officium$h - $date1";
@horas=getdialog('horas','~',0);

#*** print pages (hora=pray)
#generate HTML

$pmode = 'hora';
$command =~ s/(pray)//ig;
$title = $command;
$hora = $command;
if (substr($title,-1) =~ /a/i) {$title .= 'm';}

$head = ($title =~ /(Ante|Post)/i) ? "$title divinum officium" : "Ad $title";
$head =~ s/Ad Vesperam/Ad Vesperas/i;

$headline = setheadline();
headline();

horas($command, true);

#common end for programs
if ($error) {print "<p class=\"cen rd\">$error</p>\n";}
if ($debug) {print "<p class=\"cen rd\">$debug</p>\n";}

print "</div></body></html>";
