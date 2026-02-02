#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 03-30-10
# Sancta Missa
package main;

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
use DivinumOfficium::LanguageTextTools
  qw(prayer translate load_languages_data omit_regexp suppress_alleluia process_inline_alleluias alleluia_ant ensure_single_alleluia ensure_double_alleluia);
use DivinumOfficium::RunTimeOptions qw(check_version check_language);
use DivinumOfficium::Cache
  qw(get_cache_key get_cached_content store_cached_content cache_enabled serve_from_cache_enabled build_cache_params start_output_capture end_output_capture);

$error = '';
$debug = '';

our $Ck = 0;
our $missa = 1;
our $NewMass = 0;
our $officium = 'missa.pl';

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
our %winner;                                 #the hash of the winner
our %commemoratio;                           #the hash of the commemorated
our %scriptura;                              #the hash for the scriptura
our %commune;                                # the hash of the commune
our (%winner2, %commemoratio2, %commune2);   #same for 2nd column
our $rule;                                   # $winner{Rank}
our $communerule;                            # $commune{Rank}
our $duplex;                                 #1=simplex-feria, 2=semiduplex-feria privilegiata, 3=duplex
                                             # 4= duplex majus, 5 = duplex II classis 6=duplex I classes 7=above  0=none

binmode(STDOUT, ':encoding(utf-8)');

#*** collect standard items
#require "$Bin/ordocommon.pl";
require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/../horas/webdia.pl";
require "$Bin/../DivinumOfficium/setup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

$q = new CGI;

#get parameters
getini('missa');    #files, colors

our ($version, $lang1, $lang2, $langfb, $column);
our %translate;     #translation of the skeleton label for 2nd language
our $testmode;
our $votive;
our $first = strictparam('first');
our $Propers = strictparam('Propers');
our $command = strictparam('command');
our $browsertime = strictparam('browsertime');
our $searchvalue = strictparam('searchvalue');
our $content = strictparam('content');    # if set output only content wihout html headers menus etc
our $buildscript = '';                    #build script

if (!$searchvalue) { $searchvalue = '0'; }
our $missanumber = strictparam('missanumber');
if (!$missanumber) { $missanumber = 1; }
our $caller = strictparam('caller');

$setupsave = strictparam('setupm');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('missap', 'parameters');
  getcookies('missag', 'general');
}

set_runtime_options('general');       #$expand, $version, $lang2
set_runtime_options('parameters');    # priest, lang1 ... etc

if ($command eq 'changeparameters') { getsetupvalue($command); }

#print "Content-type: text/html; charset=utf-8\n\n"; <= uncomment for debuggin "Internal Server Errors"
$version = check_version($version, $missa) || (error("Unknown version: $version") && 'Rubrics 1960 - 1960');
$lang1 = check_language($lang1) || (error("Unknown language: $lang1") && 'Latin');
$lang2 = check_language($lang2) || 'English';
$langfb = check_language($langfb) || 'English';

$content = 0 unless $command =~ /^pray/;

setcookies('missap', 'parameters') unless $content;
setcookies('missag', 'general') unless $content;

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
setsecondcol();

#prepare main pages
$title = "Sancta Missa";

#*** Caching logic
# Build cache key from all parameters that affect output
my %cache_params = build_cache_params(
  type => 'missa',
  date1 => $date1,
  version => $version,
  lang1 => $lang1,
  lang2 => $lang2,
  langfb => $langfb,
  Propers => $Propers,
  missanumber => $missanumber,
  votive => $votive,
  rubrics => $rubrics,
  solemn => $solemn,
  Ck => $Ck,
  content => $content,
  whitebground => $whitebground,
  building => $building,
  testmode => $testmode,
);
my $cache_key = get_cache_key(%cache_params);
my $cache_type = 'missa';

# Check if we have cached content and should serve from cache
if (serve_from_cache_enabled() && $command =~ /pray/i && $command !~ /setup/i) {
  my $cached = get_cached_content($cache_key, $cache_type, \%cache_params);

  if (defined $cached && $cached ne '') {
    binmode(STDOUT, ':raw');    # Cached content is already UTF-8 encoded bytes
    print "X-Cache: hit\n";
    print $cached;
    exit;
  }
}

# Start output capture for caching (only for cacheable requests)
my $cache_enabled = cache_enabled() && $command =~ /pray/i && $command !~ /setup/i;
start_output_capture() if $cache_enabled;

#*** print pages (setup, hora=pray, mainpage)
#generate HTML
$background = ($whitebground) ? ' class="contrastbg"' : '';
htmlHead($title, 'startup()');

if ($command =~ /setup(.*)/is) {
  $pmode = 'setup';
  $command = $1;
  print setuptable($command, $title);
  $command = "change" . $command;
} elsif ($command =~ /pray/i) {
  $pmode = 'missa';
  $command =~ s/(pray|change|setup)//ig;
  $head = $title;
  headline($head);
  load_languages_data($lang1, $lang2, $langfb, $version, $missa);

  #eval($setup{'parameters'});
  $background = ($whitebground) ? ' class="contrastbg"' : '';
  ordo();

  exit if $content;

  print <<"PrintTag";
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
PrintTag
} else {    #mainpage
  $pmode = 'main';
  $command = "";
  $height = floor($screenheight * 6 / 12);
  headline($title);
  print <<"PrintTag";
<P ALIGN=CENTER>
<TABLE BORDER=0 HEIGHT=$height><TR>
<TD><IMG SRC="$htmlurl/missa.png" HEIGHT=$height></TD>
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
  $ctext = ($pmode =~ /(main)/i) ? 'Sancta Missa' : 'Sancta Missa Persoluta';
  print <<"PrintTag";
<P ALIGN=CENTER><FONT SIZE=+1><I>
<LABEL FOR=rubrics>Rubrics : </LABEL><INPUT ID=rubrics TYPE=CHECKBOX NAME='rubrics' $crubrics Value=1  onclick="parchange()">
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="hset('$ctext');"><FONT COLOR=blue>$ctext</FONT></A>
&nbsp;&nbsp;&nbsp;
<LABEL FOR=solemn>Solemn : </LABEL><INPUT ID=solemn TYPE=CHECKBOX NAME='solemn' $csolemn Value=1 onclick="parchange()">
</I></P>
<P ALIGN=CENTER>
PrintTag

  #$testmode = 'Regular' unless $testmode;
  #if ($savesetup > 1) {
  #  print option_selector("testmode", "parchange();", $testmode, qw(Regular Seasonal Season Saint Common));
  #} else {
  #  print option_selector("testmode", "parchange();", $testmode, qw(Regular Seasonal));
  #}
  print(selectables('general' . ($Ck ? 'c' : '')));
  print "</P>\n";
  my $propname = ($Propers) ? 'Full' : 'Propers';
  print qq(<P ALIGN=CENTER><FONT SIZE=+1>\n<A HREF=# onclick="hset('Propers')">$propname</A>\n</FONT></P>\n);
  print "<P ALIGN=CENTER><FONT SIZE=+1>\n" . bottom_links_menu() . "</FONT>\n</P>\n";
  if ($building && $buildscript) { print buildscript($buildscript); }
}

#common end for programs
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n"; }
$command =~ s/(pray|setup)//ig;
print <<"PrintTag";
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
<INPUT TYPE="HIDDEN" NAME="kmonth" VALUE="">
</FORM>
</BODY></HTML>
PrintTag

# End output capture and store in cache
if ($cache_enabled) {
  my $captured = end_output_capture();
  store_cached_content($cache_key, $captured, $cache_type, \%cache_params) if $captured;
}

#*** hedline($head) prints headlibe for main and pray
sub headline {
  my $head = shift;
  my $numsel = setmissanumber();
  $numsel = "<BR/><BR/>$numsel<BR/>" if $numsel;
  my $headline = html_dayhead(setheadline(), $dayname[2]);
  print qq(<P ALIGN="CENTER">$headline</P>\n);
  return if our $content;

  print <<"PrintTag";
<P ALIGN="CENTER"><FONT COLOR="MAROON" SIZE="+1"><B><I>$head</I></B>&nbsp;<FONT COLOR="RED" SIZE="+1">$version</FONT></FONT></P>
<P ALIGN="CENTER"><A HREF="#" onclick="callcompare()">Compare</A>
&ensp;<A HREF="#" onclick="callofficium();">Divinum Officium</A>
&ensp;
<LABEL FOR="date" CLASS="offscreen">Date</LABEL>
<INPUT ID="date" TYPE="TEXT" NAME="date" VALUE="$date1" SIZE="10">
<A HREF="#" onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE="submit" NAME="SUBMIT" VALUE=" " onclick="parchange();">
<A HREF="#" onclick="prevnext(1)">&uarr;</A>
&ensp;
<A HREF="#" onclick="callkalendar();">Ordo</A>
&ensp;
<A HREF="#" onclick="callkalendar('kalendar');">Kalendarium</A>
&ensp;
<A HREF="#" onclick="pset('parameters')">Options</A>
$numsel
</P>
PrintTag
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {
  qq(
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
function callkalendar(mode) {
  document.forms[0].action = '../horas/kalendar.pl';
  if (mode == 'kalendar') {
    document.forms[0].kmonth.value = 15;
  }
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
)
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

sub buildscript {
  local ($_) = @_;
  s/[\n]+/<br\/>/g;
  s/\_//g;
  s/\,\,\,/\&ensp\;/g;
  return <<"PrintTag";
<TABLE $background BORDER="3" ALIGN="CENTER" WIDTH="60%" CELLPADDING="8"><TR><TD>
$_
</TD></TR><TABLE><br/>
PrintTag
}

1;
