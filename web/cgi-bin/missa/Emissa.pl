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
use DivinumOfficium::Main qw(vernaculars liturgical_color);
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
require "$Bin/../horas/webdia.pl";
require "$Bin/../../../standalone/tools/epubgen2/Ewebdia.pl";
require "$Bin/../../../standalone/tools/epubgen2/headline.pl";
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

if ( !$version ) { $version = 'Rubrics 1960'; }
if ( !$lang2 )   { $lang2   = 'Latin'; }
setmdir($version);

# save parameters
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;
precedence();    #fills our hashes et variables

#prepare main pages
$title = "Sancta Missa";
$head     = $title;

$command =~ s/(pray|change|setup)//ig;
$headline = setheadline();

headline();

$only = 1; # single-column
ordo();

#common end for programs
if ($error) {print "<p class=\"cen rd\">$error</p>\n";}
if ($debug) {print "<p class=\"cen rd\">$debug</p>\n";}

print "</div></body></html>";

# the sub is called from htmlhead
sub horasjs {
}

