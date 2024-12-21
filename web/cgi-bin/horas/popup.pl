#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office   popup
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

use lib "$Bin/..";
use DivinumOfficium::LanguageTextTools qw(prayer rubric prex translate load_languages_data);

#use DateTime;
use locale;
$error = '';
$debug = '';
$q = new CGI;

#***common variables arrays and hashes
#filled  getweek()
our @dayname;    #0=Adv|{Nat|Epi|Quadp|Quad|Pass|Pen 1=winner title|2=other title

#filled by occurence()
our $winner;          #the folder/filename for the winner of precedence
our $commemoratio;    #the folder/filename for the commemorated
our $commune;         #the folder/filename for the used commune
our $communetype;     #ex|vide
our $rank;            #the rank of the winner
our $laudes;          #1 or 2
our $vespera;         #1 | 3 index for ant, versum, oratio
our $cvespera;        #for commemoratio

#filled by precedence()
our %winner;                                  #the hash of the winner
our %commemoratio;                            #the hash of the commemorated
our %commune;                                 # the hash of the commune
our (%winner2, %commemoratio2, %commune2);    #same for 2nd column
our $rule;                                    # $winner{Rank}
our $communerule;                             # $commune{Rank}
our $duplex;                                  #1= simplex 2=semiduplex, 3=duplex 0=rest
                                              #4 = duplex majus, 5=duplex II class 6=duplex I class 7=higher
our ($lang1, $lang2);

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

binmode(STDOUT, ':encoding(utf-8)');

#*** get parameters
getini('horas');    #files, colors
@dayname = split('=', $dayname);
$daycolor = ($dayname =~ /feria/i) ? "black" : ($dayname =~ /Sabbato|Vigil/i) ? "blue" : "red";
$command = $hora = strictparam('command');

$setupsave = strictparam('setup');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('horasp', 'parameters');
  getcookies('horasgo', 'general');
}

set_runtime_options('general');       #$expand, $version, $lang2
set_runtime_options('parameters');    # priest, lang1 ... etc

$popup = strictparam('popup');

if ($popup !~ /^[\$\&][\w ]+$/) {
  print $q->header(
    -type => 'text/plain',
    -status => '400 Bad request',
  );
  exit;
}

$background = ($whitebground) ? ' class="contrastbg"' : '';
$border = 0;
$textwidth = 90;
$only = $lang1 && $lang1 =~ /^$lang2$/i;
precedence();
setsecondcol();

load_languages_data($lang1, $lang2, $version, $missa);

# We need to revert the masked parantheses at this point
$popup =~ s/\&lpar/\(/;
$popup =~ s/\&rpar/\)/;
$popup =~ s/\&apos/\'/g;
my $title = $popup;
$title =~ s/^[\$\&]?([a-z])/\u$1/;
$title =~ s/\-//;
$title =~ s/,/:/;
$title =~ s/,/–/;
$title =~ s/\'//g;
$title =~ s/\(/ \(/;
$title = translate(get_link_name($title), $lang1);
$title =~ s/[\$\&]//;
$expand = 'tota';
if ($popup =~ /\&/) { $popup =~ s/\s/\_/g; }
$text = resolve_refs($popup, $lang1);
$t = length($text);

#$text = resolve_refs($text, $lang1);
$width = ($t > 300) ? 600 : 400;
$height = ($t > 300) ? $screenheight - 100 : 3 * $screenheight / 4;

#*** generate HTML
# prints the requested item from prayers hash as popup
htmlHead($title, 'setsize()');
print "<H3 ALIGN=CENTER><FONT COLOR=MAROON><B><I>$title</I></B></FONT></H3>\n";
my @script = ($popup);
print_content($lang1, \@script, $lang2, \@script);
print "<P ALIGN=CENTER><A HREF=# onclick=\"window.close()\">Close</A></P>";
htmlEnd();

#*** javascript functions
sub horasjs {
  "function setsize() { window.resizeTo($width, $height); }";
}
