#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
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

#use DateTime;
$error = '';
$debug = '';
$q = new CGI;
our $missa = 1;

use lib "$Bin/..";
use DivinumOfficium::LanguageTextTools qw(prayer translate load_languages_data);

#*** collect standard items
require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/../horas/webdia.pl";
require "$Bin/../DivinumOfficium/setup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

#require "$Bin/ordocommon.pl";
binmode(STDOUT, ':encoding(utf-8)');

#*** get parameters
getini('missa');    #files, colors

$setupsave = strictparam('setup');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('missap', 'parameters');
  getcookies('missago', 'general');
}

set_runtime_options('general');       #$expand, $version, $lang2
set_runtime_options('parameters');    # priest, lang1 ... etc

$popup = strictparam('popup');
$background = ($whitebground) ? ' class="contrastbg"' : '';
$only = ($lang1 && $lang1 =~ /$lang2/) ? 1 : 0;
$title = "$popup";
$title =~ s/[\$\&]//;

#$tlang = ($lang1 !~ /Latin/) ? $lang1 : $lang2;
$text = gettext($popup, $lang1);
$t = length($text);
$width = ($t > 300) ? 600 : 400;
$height = ($t > 300) ? $screenheight - 100 : 3 * $screenheight / 4;

#*** generate HTML
# prints the requested item from prayers hash as popup
htmlHead($title, 'setsize()');
print "<H3 ALIGN=CENTER><FONT COLOR=MAROON><B><I>$title</I></B></FONT></H3>\n";
my @script1 = ($text);
my @script2 = (gettext($popup, $lang2));
print_content($lang1, \@script1, $lang2, \@script2);
print "<P ALIGN=CENTER><A HREF=# onclick=\"window.close()\">Close</A></P>";
htmlEnd();

#*** javascript functions
sub horasjs {
  "function setsize() { window.resizeTo($width, $height); }";
}

sub gettext {
  my $popup = shift;
  my $lang = shift;
  my $text = '';
  my %popup_files = (
    Ante => 'Ante.txt',
    Communio => 'Communio.txt',
    Post => 'Post.txt',
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
