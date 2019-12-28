#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office   popup
package horas;

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
$error = '';
$debug = '';
$q = new CGI;

#***common variables arrays and hashes
#filled  getweek()
our @dayname;    #0=Adv|{Nat|Epi|Quadp|Quad|Pass|Pen 1=winner title|2=other title

#filled by getrank()
our $winner;     #the folder/filename for the winner of precedence
our $commemoratio;    #the folder/filename for the commemorated
our $commune;         #the folder/filename for the used commune
our $communetype;     #ex|vide
our $rank;            #the rank of the winner
our $laudes;          #1 or 2
our $vespera;         #1 | 3 index for ant, versum, oratio
our $cvespera;        #for commemoratio

#filled by precedence()
our %winner;          #the hash of the winner
our %commemoratio;    #the hash of the commemorated
our %commune;         # the hash of the commune
our (%winner2, %commemoratio2, %commune2);    #same for 2nd column
our $rule;                                    # $winner{Rank}
our $communerule;                             # $commune{Rank}
our $duplex;                                  #1= simplex 2=semiduplex, 3=duplex 0=rest
                                              #4 = duplex majus, 5=duplex II class 6=duplex I class 7=higher
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';
our ($lang1, $lang2);

#*** collect standard items
require "$Bin/do_io.pl";
require "$Bin/horascommon.pl";
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/setup.pl";
require "$Bin/horas.pl";
require "$Bin/specials.pl";
require "$Bin/specmatins.pl";

binmode(STDOUT, ':encoding(utf-8)');

#*** get parameters
getini('horas');    #files, colors
@dayname = split('=', $dayname);
$daycolor = ($dayname =~ /feria/i) ? "black" : ($dayname =~ /Sabbato|Vigil/i) ? "blue" : "red";
$command = $hora = strictparam('command');
$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
%dialog = %{setupstring($datafolder, '', 'horas.dialog')};

if (!$setupsave) {
  %setup = %{setupstring($datafolder, '', 'horas.setup')};
} else {
  %setup = split(';;;', $setupsave);
}

# We don't use the popuplang parameter, and instead use lang1 and lang2.
$setup{'parameters'} = clean_setupsave($setup{'parameters'});
eval($setup{'parameters'});
eval($setup{'general'});
$popup = strictparam('popup');
$lang1 = strictparam('lang1') || $lang1;
$lang2 = strictparam('lang2') || $lang2;
$background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";
$only = ($lang1 && $lang1 =~ /^$lang2$/i) ? 1 : 0;
precedence();

foreach my $lang ('Latin', $lang1, $lang2) {
  $translate{$lang} ||= setupstring($datafolder, $lang, 'Psalterium/Translate.txt');
}
$title = translate(get_link_name($popup), 'Latin');
$title =~ s/[\$\&]//;
$expand = 'all';
if ($popup =~ /\&/) { $popup =~ s /\s/\_/g; }
cache_prayers();
print STDERR "\$popup = $popup\n";
$text = resolve_refs($popup, $lang1);
$t = length($text);

#$text = resolve_refs($text, $lang1);
$width = ($t > 300) ? 600 : 400;
$height = ($t > 300) ? $screenheight - 100 : 3 * $screenheight / 4;

#*** generate HTML
# prints the requested item from prayers hash as popup
htmlHead($title, 2);
print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg"
  onload="setsize()">
<FORM>
<H3 ALIGN=CENTER><FONT COLOR=MAROON><B><I>$title</I></B></FONT></H3>
<P ALIGN=CENTER><BR>
<TABLE BORDER=0 WIDTH=90% ALIGN=CENTER CELLPADDING=8 CELLSPACING=$border BGCOLOR='maroon'>
<TR>
PrintTag
$text =~ s/\_/ /g;
if ($lang1 =~ /Latin/i) { $text = spell_var($text); }
print "<TD $background WIDTH=50% VALIGN=TOP>" . setfont($blackfont, $text) . "</TD>\n";

if (!$only) {
  $text = resolve_refs($popup, $lang2);

  #$text = resolve_refs($text, $lang2);
  $text =~ s/\_/ /g;
  if ($lang2 =~ /Latin/i) { $text = spell_var($text); }
  print "<TD $background VALIGN=TOP>" . setfont($blackfont, $text) . "</TD></TR>\n";
}
print "</TABLE><BR>\n";
print "<A HREF=# onclick=\"window.close()\">Close</A>";
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n"; }
print "</FORM></BODY></HTML>";

#*** javascript functions
sub horasjs {
  print << "PrintTag";

<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

function setsize() {
  window.resizeTo($width, $height);
}

</SCRIPT>
PrintTag
}
