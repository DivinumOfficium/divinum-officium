#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
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
use DivinumOfficium::Main qw(liturgical_color);
use DivinumOfficium::Date qw(prevnext);
use DivinumOfficium::RunTimeOptions qw(check_version check_horas check_language);
use DivinumOfficium::LanguageTextTools
  qw(prayer rubric translate load_languages_data omit_regexp suppress_alleluia process_inline_alleluias alleluia_ant ensure_single_alleluia ensure_double_alleluia);

$error = '';
$debug = '';

our $Ck = 0;
our $notes = 0;
our $missa = 0;
our $officium = substr($0, rindex($0, '/') + 1);
our $Ck = substr($officium, 0, 1) eq 'C';
our $version = '';

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
our $laudes;          #1 or 2
our $vespera;         #1 | 3 index for ant, versum, oratio
our $cvespera;        #for commemoratio
our $commemorated;    #name of the commemorated for vigils
our $comrank = 0;     #rank of the commemorated office
our $litaniaflag = 0;
our $octavam = '';    #to avoid duplication of commemorations

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
require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/horascommon.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/../DivinumOfficium/setup.pl";
require "$Bin/horas.pl";
require "$Bin/horasscripts.pl";
require "$Bin/specials.pl";
require "$Bin/specmatins.pl";
require "$Bin/monastic.pl";
require "$Bin/altovadum.pl";
require "$Bin/horasjs.pl";
require "$Bin/officium_html.pl";

$q = new CGI;

#get parameters
getini('horas');    #files, colors

our ($lang1, $lang2, $langfb, $expand, $votive, $column, $local);
our %translate;     #translation of the skeleton label for 2nd language

our $command = strictparam('command');
our $browsertime = strictparam('browsertime');
our $buildscript = '';    #build script
our $searchvalue = strictparam('searchvalue');

if (!$searchvalue) { $searchvalue = '0'; }

our $caller = strictparam('caller');
our $expandind = 0;

$setupsave = strictparam('setup');
loadsetup($setupsave);

my $cookies_suffix = lc(substr($officium, 0, 1));

if (!$setupsave) {
  getcookies('horasp', 'parameters');
  getcookies("horasg$cookies_suffix", 'general');
}

set_runtime_options('general' . ($Ck ? 'c' : ''));    #$expand, $version, $lang2
set_runtime_options('parameters');                    # priest, lang1 ... etc

if ($command =~ s/changeparameters//) { getsetupvalue($command); }

#print "Content-type: text/html; charset=utf-8\n\n"; #<= uncomment for debuggin "Internal Server Errors"
$version = check_version($version) || (error("Unknown version: $version") && 'Rubrics 1960 - 1960');
$lang1 = check_language($lang1) || (error("Unknown language: $lang1") && 'Latin');
$lang2 = check_language($lang2) || 'English';
$langfb = check_language($langfb) || 'English';

our $plures = strictparam('plures');
my @horas = ();

if ($command =~ s/^pray//) {
  $command =~ s/SanctaMissa//;
  @horas = split(/(?=\p{Lu}\p{Ll}+)/, $command);

  if ($horas[0] eq 'Omnes') {
    @horas = gethoras($votive eq 'C9');
  } elsif ($horas[0] ne 'Plures') {
    @horas = map { check_horas($_); } @horas;

    if (@horas > 1 && $votive ne 'C9') {
      $plures = join('', @horas);
    }
  }
}
our $hora = (@horas > 0) ? $horas[0] : '';

setcookies('horasp', 'parameters');
setcookies("horasg$cookies_suffix", 'general');

if ($Ck) {
  $version1 = $version;    # save value for use in horas
  $version2 = check_version($version2);
  $version2 ||= $version;
  if ($version eq $version2) { $version2 = 'Divino Afflatu - 1954'; }
  if ($version eq $version2) { $version2 = 'Rubrics 1960 - 1960'; }
  $lang1 = $lang2 = $langc;
}

# save parameters
$setupsave = savesetup(1);
$setupsave =~ s/\r*\n*//g;

#prepare testmode
our $testmode = strictparam('testmode');
if (!$testmode) { $testmode = strictparam('testmode1'); }
if ($testmode !~ /(Season|Saint|Common)/i) { $testmode = 'regular'; }
our $expandnum = strictparam('expandnum');
$notes = strictparam('notes');

$only = !$Ck && ($lang1 eq $lang2);

if ($officium eq 'Pofficium.pl') {
  our $date1 = strictparam('date1');
  if (!$date1 || $date1 eq 'hodie') { $date1 = gettoday(); }
  if ($date1 eq 'crastina') { $date1 = prevnext(gettoday(), 1); }
  if ($command =~ /next/i) { $date1 = prevnext($date1, 1); $command = ''; }
  if ($command =~ /prev/i) { $date1 = prevnext($date1, -1); $command = ''; }
}

precedence($date1);    #fills our hashes et variables
setsecondcol();
our $psalmnum1 = 0;
our $psalmnum2 = 0;

$completed = getcookie1('completed');

if ( $date1 eq gettoday()
  && $command =~ /pray/i
  && $completed < 8
  && $command =~ substr($horas[$completed + 1], 0, 4))
{
  $completed++;
  setcookie1('completed', $completed);
}

# prepare title
my $dayhead = setheadline();
my $html_dayhead = html_dayhead($dayhead, $dayname[2]);

if ($command =~ /kalendar/) {    # kalendar widget
  print "Access-Control-Allow-Origin: *\n";
  print "Content-type: text/html; charset=utf-8\n";
  print "\n";
  print $html_dayhead;
  exit;
}

#*** print pages (setup, hora=pray, mainpage)
#generate HTML
$background = ($whitebground) ? ' class="contrastbg"' : '';
htmlHead("Divinum Officium " . ($hora || $command), $officium ne 'Pofficium.pl' && 'startup()');

if ($command =~ /setup(.*)/i) {
  $command = $1;
  print setuptable($command, "Divinum Officium setup");
  $command = "change" . $command . strictparam('pcommand');
} else {
  print headline($html_dayhead, substr($officium, 0, 1), $version, $version2);
  load_languages_data($lang1, $lang2, $langfb, $version, $missa);

  if ($command =~ /appendix/i) {
    require "$Bin/appendix.pl";
    appendix($command);
  } else {

    if ($horas[0] eq 'Plures') {
      print setplures();
    } elsif ($horas[0]) {
      foreach (@horas) {
        $hora = $_;    # precedence use global $hora !

        if (/laudes/i && ($horas[0] !~ /laudes/i)) {
          precedence($date1);    # prevent lost commemorations
        } elsif (/vesper/i && ($horas[0] !~ /vesper/i)) {
          precedence($date1);
          setsecondcol();
          my $vesperahead = setheadline();

          if ($dayhead ne $vesperahead) {
            print par_c("<BR/><BR/>" . html_dayhead($vesperahead));
          }
        }
        horas($hora);
      }

      if ($officium ne 'Pofficium.pl' && @horas == 1) {
        print par_c("<INPUT TYPE='SUBMIT' VALUE='$hora persolut.' onclick='okbutton();'>");
      }
    } elsif ($officium ne 'Pofficium.pl') {
      print par_c(mainpage());
    }
  }

  print par_c('<I>' . horas_menu($completed, $date1, $version, $lang2, $votive, $testmode) . '</I>');

  if ($officium ne 'Pofficium.pl') {
    $votive ||= 'Hodie';
    $version = $version1 if ($Ck);
    print par_c(selectables('general' . ($Ck ? 'c' : '')));
  } else {
    print par_c(pmenu());

    print "<TABLE ALIGN='CENTER' BORDER='1' $background>";
    print selectable_p('versions', $version, $date1, $version, $lang2, $votive, $testmode);
    print selectable_p('languages', $lang2, $date1, $version, $lang2, $votive, $testmode, 'Language 2');
    print selectable_p('votives', $votive, $date1, $version, $lang2, $votive, $testmode);
    print "</TABLE>\n";
  }

  print par_c("\n" . bottom_links_menu(substr($officium, 0, 1) eq 'C'));
  if ($building && $buildscript) { print buildscript($buildscript); }
}

print hiddenfields();
htmlEnd();
