#!/usr/bin/perl
# vim: set encoding=utf-8 :
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 02-01-2008
# Show/edit files

package missa;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use LWP::Simple;
use Time::Local;
#use DateTime;

$q = new CGI;
$error = '';
require "$Bin/../horas/do_io.pl";
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";

binmode(STDOUT, ':encoding(utf-8)');

#*** collect parameters
getini('missa'); #files, colors

%dialog = %{setupstring("$datafolder/missa.dialog")};
if (!$setupsave) {%setup = %{setupstring("$datafolder/missa.setup")};}
else {%setup = split(';;;', $setupsave);}

eval($setup{'parameters'});
eval($setup{'general'});	 


#*** load files 
$title = 'Sources';
                                           
$source = '';
$line = '';
if (my @sources = do_read("$datafolder/source.txt")) {
    $_ = "$_<BR>" for @sources;
    $source = join('',@sources);
} else {$error .= "$datafolder/source.txt cannot open";}

my @toc;
if (@toc = do_read("$datafolder/TOC1920.txt")) {
  $_ = "$_\n" for @toc;
} else {$error .= "$datafolder/TOC1920.txt cannot open";}

$setupsave = printhash(\%setup, 1);
$setupsave =~ s/\r*\n*//g;
$setupsave =~ s/\"/\~24/g;	 

#*** generate HTML head widgets
htmlHead($title, 2);
print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND=\"$htmlurl/horasbg.jpg\"> 
<FORM ACTION="source.pl" METHOD=post TARGET=_self>
<TABLE ALIGN=CENTER BORDER=1 CELLPADDING=8>
<TR><TD COLSPAN=2 BGCOLOR="#F8F8F8">
<H2 ALIGN=CENTER>$title</H2>
$source</TD></TR></TABLE>
<TABLE ALIGN=CENTER BORDER=0 CELLPADDING=1 BGCOLOR=white>
PrintTag
$flag = 1;
foreach $item (@toc) {
  if ($item =~ /([0-9]+)\s*$/) {
    $str = $`;
	$num = $1;
	$str =~ s/\s*$//;
	print "<TR><TD>";
	if ($flag) {
	  print "<FONT SIZE=+1><B><A HREF=\"$htmlurl/m1920.pdf#page=$num\" TARGET=_NEW>$str</A></B></FONT></TD>\n";} 
	  else {print "&nbsp;&nbsp;<A HREF=\"$htmlurl/m1920.pdf#page=$num\" TARGET=_NEW>$str</A></TD>\n";}
	$flag = 0;
	print "<TD>$num</TD></TR>\n";
  } else {
    $flag = 1;
	print "<TR><TD COLSPAN=2> </TD></TR>";
  }
}  		 

print "</TABLE>\n";

if ($error) {print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n";}

print "</FORM></BODY></HTML>\n";

 
#*** javascript functions
sub horasjs {
 print << "PrintTag";

<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

</SCRIPT>
PrintTag
} 

