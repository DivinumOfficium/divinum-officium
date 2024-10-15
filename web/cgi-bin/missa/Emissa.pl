#!/usr/bin/perl
use utf8;

# Name : Geremia (based off missa.pl)
# Date : 2020-06-13
# Sancta Missa
package main;

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
use lib "$Bin/../../../web/cgi-bin";
use DivinumOfficium::Main qw(vernaculars liturgical_color);
use DivinumOfficium::Date qw(prevnext);
use DivinumOfficium::LanguageTextTools
  qw(prayer translate load_languages_data omit_regexp suppress_alleluia process_inline_alleluias alleluia_ant ensure_single_alleluia ensure_double_alleluia);

$error = '';
$debug = '';

our $Ck = 0;
our $missa = 1;
our $NewMass = 0;
our $officium = 'Emissa.pl';
our $version = 'Rubrics 1960 - 1960';

#***common variables arrays and hashes
#filled  getweek()
our @dayname;    #0=Advn|Natn|Epin|Quadpn|Quadn|Pascn|Pentn 1=winner title|2=other title

#filled by occurence()
our $winner;          #the folder/filename for the winner of precedence
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
our %winner;                                  #the hash of the winner
our %commemoratio;                            #the hash of the commemorated
our %scriptura;                               #the hash for the scriptura
our %commune;                                 # the hash of the commune
our (%winner2, %commemoratio2, %commune2);    #same for 2nd column
our $rule;                                    # $winner{Rank}
our $communerule;                             # $commune{Rank}
our $duplex;                                  #1=simplex-feria, 2=semiduplex-feria privilegiata, 3=duplex

# 4= duplex majus, 5 = duplex II classis 6=duplex I classes 7=above  0=none

#*** collect standard items
#allow the script to be started directly from the "standalone/tools/epubgen2" subdirectory
if (!-e "$Bin/../DivinumOfficium/do_io.pl") {
  $Bin = "$Bin/../../../web/cgi-bin/missa";
}

require "$Bin/../DivinumOfficium/do_io.pl";
require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";

require "$Bin/../DivinumOfficium/setup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

require "$Bin/../horas/webdia.pl";
require "$Bin/../../../standalone/tools/epubgen2/Ewebdia.pl";

binmode(STDOUT, ':encoding(utf-8)');
$q = new CGI;

#replaced methods
#*** build_comment_line_xhtml()
#  Replacement for build_comment_line() from horascommon.pl
#
#  Sets $comment to the HTML for the comment line.
sub build_comment_line_xhtml() {
  our @dayname;
  our ($comment, $marian_commem);

  my $commentcolor = ($dayname[2] =~ /(Feria)/i) ? '' : ($marian_commem && $dayname[2] =~ /^Commem/) ? ' rb' : ' m';
  $comment = ($dayname[2]) ? "<span class=\"s$commentcolor\">$dayname[2]</span>" : "";
}

#get parameters
getini('missa');    #files, colors
$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
our ($lang1, $lang2, $column);
our %translate;     #translation of the skeleton label for 2nd language

if (!$setupsave) {
  %setup = %{setupstring('', '../../../standalone/tools/epubgen2/Emissa.setup')};
} else {
  %setup = split(';;;', $setupsave);
}
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

#*** handle different actions
#after setup
if ($command =~ /change(.*)/is) {
  $command = $1;
  getsetupvalue($command);
}
eval($setup{'parameters'});    #$lang1, colors, sizes
eval($setup{'general'});       #$version, $testmode,$lang2,$votive,$rubrics, $solemn

$rubrics = 0;

#prepare testmode
our $testmode = strictparam('testmode');
if ($testmode !~ /(Seasonal|Season|Saint)/i) { $testmode = 'regular'; }
our $votive = strictparam('votive');
$p = strictparam('lang1');
our $nofancychars = strictparam('nofancychars');

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

if (!$version) { $version = 'Rubrics 1960 - 1960'; }
if (!$lang2) { $lang2 = 'Latin'; }

# save parameters
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;
precedence();    #fills our hashes et variables

# prepare title
$daycolor =
    ($commune =~ /(C1[0-9])/) ? "blue"
  : ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? "black"
  : ($dayname[1] =~ /duplex/i) ? "red"
  : "grey";

build_comment_line_xhtml();

#prepare main pages
$title = "Sancta Missa";

$command =~ s/(pray|change|setup)//ig;
$title = "Sancta Missa";

#*** print pages (setup, hora=pray, mainpage)
#generate HTML
htmlHead($title, 2);

#note the whole content is wrapped in a <div> for XHTML standard compatibilty
print << "PrintTag";
<body><div>
PrintTag

load_languages_data($lang1, $lang2, $version, $missa);
$head = $title;
$headline = setheadline();
headline($head);

$only = 1;    # single-column
ordo();

print << "PrintTag";
PrintTag

#common end for programs
if ($error) { print "<p class=\"cen rd\">$error</p>\n"; }
if ($debug) { print "<P class=\"cen rd\">$debug</p>\n"; }

print << "PrintTag";
</div></body></html>
PrintTag

#*** hedline($head) prints headlibe for main and pray
sub headline {
  my $head = shift;
  if ($headline =~ /\!/) { $headline = $` . "<FONT SIZE=\"1\">" . $' . "</FONT>"; }
  my $daten = prevnext($date1, 1);
  my $datep = prevnext($date1, -1);

  #convert $daycolor to $daycolorclass
  my $daycolorclass = "";    #rely on default being black font color

  if ($daycolor eq "blue") {
    $daycolorclass = "rb";
  } elsif ($daycolor eq "gray") {
    $daycolorclass = "rb";
  } elsif ($daycolor eq "red") {
    $daycolorclass = "rd";
  }

  print << "PrintTag";
<p class="cen"><span class="$daycolorclass">$headline<br/></span>
$comment<br/><br/>
<span class="c">Missa</span>&ensp;
<a href="$datep-9-Missa.html">&darr;</a>
$date1
<a href="$daten-9-Missa.html">&uarr;</a>
</p>
<p class="cen">
<a href="$date1-1-Matutinum.html">Matutinum</a>
&nbsp;&nbsp;
<a href="$date1-2-Laudes.html">Laudes</a>
&nbsp;&nbsp;
<a href="$date1-3-Prima.html">Prima</a>
&nbsp;&nbsp;
<a href="$date1-4-Tertia.html">Tertia</a>
<br/>
<a href="$date1-5-Sexta.html">Sexta</a>
&nbsp;&nbsp;
<a href="$date1-6-Nona.html">Nona</a>
&nbsp;&nbsp;
<a href="$date1-7-Vespera.html">Vespera</a>
&nbsp;&nbsp;
<a href="$date1-8-Completorium.html">Completorium</a>
</p>
PrintTag
}

# the sub is called from htmlhead
sub horasjs {
}

