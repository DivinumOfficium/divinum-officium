#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office   popup
package missa;

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
$error = '';
$debug = '';
$q = new CGI;
our $missa = 1;

#*** collect standard items
require "$Bin/../horas/horascommon.pl";
require "$Bin/../horas/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

#require "$Bin/ordocommon.pl";
require "$Bin/../horas/do_io.pl";
binmode(STDOUT, ':encoding(utf-8)');

#*** get parameters
getini('missa');    #files, colors
%dialog = %{setupstring($datafolder, '', 'missa.dialog')};
%setup = %{setupstring($datafolder, '', 'missa.setup')};
eval($setup{'parameters'});
eval($setup{'general'});
$popup = strictparam('popup');
$rubrics = strictparam('rubrics');
$lang1 = strictparam('lang1');
$lang2 = strictparam('lang2');
$background = ($whitebground) ? "BGCOLOR=\"white\"" : "BACKGROUND=\"$htmlurl/horasbg.jpg\"";
$only = ($lang1 && $lang1 =~ /$lang2/) ? 1 : 0;
$title = "$popup";
$title =~ s/[\$\&]//;

#$tlang = ($lang1 !~ /Latin/) ? $lang1 : $lang2;
#%translate = %{setupstring($datafolder, $tlang, "Ordo/Translate.txt")};
cache_prayers();
$text = gettext($popup, $lang1);
$t = length($text);
$width = ($t > 300) ? 600 : 400;
$height = ($t > 300) ? $screenheight - 100 : 3 * $screenheight / 4;

#*** generate HTML
# prints the requested item from prayers hash as popup
htmlHead($title, 2);
print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg" onload="setsize()">
<FORM ACTION="popup.pl" METHOD=post TARGET=_self>
<H3 ALIGN=CENTER><FONT COLOR=MAROON><B><I>$title</I></B></FONT></H3>
<P ALIGN=CENTER><BR>
<TABLE BORDER=0 WIDTH=90% ALIGN=CENTER CELLPADDING=8 CELLSPACING=$border BGCOLOR='maroon'>
<TR>
PrintTag
$text =~ s/\_/ /g;
print "<TD $background WIDTH=50% VALIGN=TOP>" . setfont($blackfont, $text) . "</TD>\n";
$lang = $lang2;

if (!$only) {
  $text = gettext($popup, $lang2);
  $text =~ s/\_/ /g;
  print "<TD $background VALIGN=TOP>" . setfont($blackfont, $text) . "</TD></TR>\n";
}
print "</TABLE><BR>\n";
print "<A HREF=# onclick=\"window.close()\">Close</A>";
if ($error) { print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT><\P>\n"; }
if ($debug) { print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT><\P>\n"; }
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

sub gettext {
  my $popup = shift;
  my $lang = shift;
  my $text = '';
  my %popup_files = (
    Ante => 'Ante.txt',
    Communio => 'Communio.txt',
    Post => 'Post.txt'
  );

  # File must be one of those explicitly permitted.
  my $fname = $popup_files{$popup} or return 'Invalid filename.';
  $fname = checkfile($lang, "Ordo/$fname");
  $text = join("\n", do_read($fname)) or return "Cannot open $datafolder/$lang/Ordo/$fname.txt";
  $text =~ s/[#!].*?\n//g unless $rubrics;
  $text =~ s/#/!/g;
  $text = resolve_refs($text, $lang);
  return $text;
}
