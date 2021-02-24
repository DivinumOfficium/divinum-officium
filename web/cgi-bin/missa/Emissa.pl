#!/usr/bin/perl
use utf8;

# Name : Geremia (based off missa.pl)
# Date : 2020-06-13
# Sancta Missa
package missa;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use Time::Local;

#use DateTime;
use locale;
use lib "$Bin/..";
use DivinumOfficium::Main qw(vernaculars);
$error = '';
$debug = '';

our $Tk       = 0;
our $Hk       = 0;
our $Ck       = 0;
our $missa    = 1;
our $NewMass  = 0;
our $officium = 'missa.pl';
our $version  = 'Rubrics 1960';

#***common variables arrays and hashes
#filled  getweek()
our @dayname
  ;    #0=Advn|Natn|Epin|Quadpn|Quadn|Pascn|Pentn 1=winner title|2=other title

#filled by getrank()
our $winner;          #the folder/filename for the winner of precedence
our $commemoratio;    #the folder/filename for the commemorated
our $scriptura
  ;    #the folder/filename for the scripture reading (if winner is sancti)
our $commune;         #the folder/filename for the used commune
our $communetype;     #ex|vide
our $rank;            #the rank of the winner
our $vespera;         #1 | 3 index for ant, versum, oratio
our $cvespera;        #for commemoratio
our $commemorated;    #name of the commemorated for vigils
our $comrank = 0;     #rank of the commemorated office

#filled by precedence()
our %winner;                                    #the hash of the winner
our %commemoratio;                              #the hash of the commemorated
our %scriptura;                                 #the hash for the scriptura
our %commune;                                   # the hash of the commune
our ( %winner2, %commemoratio2, %commune2 );    #same for 2nd column
our $rule;                                      # $winner{Rank}
our $communerule;                               # $commune{Rank}
our $duplex;    #1=simplex-feria, 2=semiduplex-feria privilegiata, 3=duplex

# 4= duplex majus, 5 = duplex II classis 6=duplex I classes 7=above  0=none

#*** collect standard items
#require "$Bin/ordocommon.pl";
require "$Bin/../horas/do_io.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../horas/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/../../../standalone/tools/epubgen2/Ewebdia.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

binmode( STDOUT, ':encoding(utf-8)' );
$q = new CGI;

#get parameters
getini('missa');    #files, colors
$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
our ( $lang1, $lang2, $column );
our %translate;     #translation of the skeleton label for 2nd language

if ( !$setupsave ) {
    %setup = %{ setupstring( $datafolder, '', 'missa.setup' ) };
}
else {
    %setup = split( ';;;', $setupsave );
}
$first = strictparam('first');
our $Propers     = strictparam('Propers');
our $command     = strictparam('command');
our $browsertime = strictparam('browsertime');
our $searchvalue = strictparam('searchvalue');
if ( !$searchvalue ) { $searchvalue = '0'; }
if ( !$command )     { $command     = 'praySanctaMissa'; }
our $missanumber = strictparam('missanumber');
if ( !$missanumber ) { $missanumber = 1; }
our $caller      = strictparam('caller');
our $sanctiname  = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';

#*** handle different actions
#after setup
if ( $command =~ /change(.*)/is ) {
    $command = $1;
    getsetupvalue($command);
}
eval( $setup{'parameters'} );    #$lang1, colors, sizes
eval( $setup{'general'} ); #$version, $testmode,$lang2,$votive,$rubrics, $solemn

$rubrics = 0;

#prepare testmode
our $testmode = strictparam('testmode');
if ( $testmode !~ /(Seasonal|Season|Saint)/i ) { $testmode = 'regular'; }
our $votive = strictparam('votive');
$p = strictparam('lang1');

if ($p) {
    $lang1 = $p;
    setsetupvalue( 'parameters', 2, $lang1 );
}
$p = strictparam('screenheight');

if ($p) {
    $screenheight = $p;
    setsetupvalue( 'parametrs', 11, $screenheight );
}
$p = strictparam('textwidth');

#expand (all, psalms, nothing, skeleton) parameter
$flag = 0;
$p    = strictparam('lang2');
if ($p) { $lang2 = $p; $flag = 1; }
$p = strictparam('version');
if ($p) { $version = $p; $flag = 1; }

if ( !$first ) {
    $first = 1;
}
else {
    $flag    = 1;
    $rubrics = strictparam('rubrics');
    $solemn  = strictparam('solemn');
}

if ($flag) {
    setsetup( 'general', $version, $testmode, $lang2, $votive, $rubrics,
        $solemn );
}
if ( !$version ) { $version = 'Rubrics 1960'; }
if ( !$lang2 )   { $lang2   = 'Latin'; }
setmdir($version);

# save parameters
$setupsave = printhash( \%setup, 1 );
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;
precedence();    #fills our hashes et variables

# prepare title
$daycolor =
    ($commune =~ /(C1[0-9])/) ? "blue"
  : ($dayname[1] =~ /(Vigilia Pentecostes|Quattuor Temporum Pentecostes|Martyr)/i) ? "red"
  : ($dayname[1] =~ /(Dedicatione|Cathedra|oann|Pasch|Confessor|Ascensio|Cena)/i) ? "black"
  : ($dayname[1] =~ /(Vigilia|Quattuor|Passionis|gesim|Hebdomadæ Sanctæ|Ciner|Adventus)/i) ? "purple"
  : ($dayname[1] =~ /(Pentecosten|Epiphaniam|post octavam)/i) ? "green"
  : ($dayname[1] =~ /(Pentecostes|Evangel|Innocentium|Sanguinis|Cruc|Apostol)/i) ? "red"
  : ($dayname[1] =~ /(Defunctorum|Parasceve|Morte)/i) ? "grey"
  : "black";
build_comment_line();

#prepare main pages
$title = "Sancta Missa";

#generate HTML

$command =~ s/(pray|change|setup)//ig;
$title    = "Sancta Missa";
$head     = $title;
$headline = setheadline();
headline($head);

$only = 1; # single-column
ordo();

#common end for programs
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n"; }

#*** hedline($head) prints headlibe for main and pray
sub headline {
    my $head = shift;
    $headline =~ s{!(.*)}{<FONT SIZE=1>$1</FONT>}s;
  my $daten = prevnext($date1, 1);
  my $datep = prevnext($date1, -1);
    print << "PrintTag";
<P ALIGN=CENTER><a href="$datep-9-Missa.html">&darr;</a>
$date1
<a href="$daten-9-Missa.html">&uarr;</a>
<br />
<a href="$date1-1-Matutinum.html">Matutinum</a>
&nbsp;&nbsp;
<a href="$date1-2-Laudes.html">Laudes</a>
&nbsp;&nbsp;
<a href="$date1-3-Prima.html">Prima</a>
&nbsp;&nbsp;
<a href="$date1-4-Tertia.html">Tertia</a>
<br />
<a href="$date1-5-Sexta.html">Sexta</a>
&nbsp;&nbsp;
<a href="$date1-6-Nona.html">Nona</a>
&nbsp;&nbsp;
<a href="$date1-7-Vespera.html">Vespera</a>
&nbsp;&nbsp;
<a href="$date1-8-Completorium.html">Completorium</a>
<br />
<FONT COLOR=$daycolor>$headline<BR></FONT>
$comment<BR>
<a href="$date1-9-Missa.html"><FONT COLOR=MAROON SIZE=+1><B><I>$head</I></B></FONT></a>
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

# the sub is called from htmlhead
sub horasjs {
}

