#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office

package horas;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Cookie;;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use LWP::Simple;
use Time::Local;
#use DateTime;
use locale;

$lang = 'Latin';
$error = '';
$debug = '';

#*** collect standard items
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/tfertable.pl";

$q = new CGI;

#get parameters
getini('horas'); #files, colors  

$year1 = strictparam('kalendar1');
if (!$year1) {$year1 = 1942;}
$year2 = strictparam('kalendar2');
if (!$year2) {$year2 = 1960;}
$month = strictparam('month');
if (!$month) {$month = 1;}
@months = ('January', 'February', 'March', 'April', 'May', 'June', 'July',
  'Augustus', 'September', 'October', 'November', 'December');
@mdays = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

@tradtable = ('none', 'Simplex', 'Semiduplex', 'Duplex', 'Duplex majus', 
  'Duplex II. classis', 'Duplex I. classis', 'Duplex I. clasis');
@table1960 = ('none', 'Commemoratio', 'IV. classis', 'III. classis', 'III. classis',
  'II. classis', 'I. classis', 'I. classis');
@newtable = ('none', 'none', 'Optional', 'Memorial', 'Memorial',
  'Feast', 'Solemnity', 'Solemnity');
	   
my $kalfiles1 = '';
$ch = ($year2 =~ /none/) ? 'SELECTED' : '';
my $kalfiles2 = "<OPTION $ch VALUE=\"none\">none\n";
$title = "Permanent calendars";
if (opendir(DIR, "$datafolder/Latin/Tabulae")) {
  my $file;
  while ($file = readdir(DIR)) {
   if ($file =~ /K([0-9]+)\.txt/) {
    my $y = $1;
    my $ch = ($year1 =~ /$y/) ? 'SELECTED' : '';
    $kalfiles1 .= "<OPTION $ch VALUE=\"$y\">$y\n";
    $ch = ($year2 =~ /$y/) ? 'SELECTED' : '';
    $kalfiles2 .= "<OPTION $ch VALUE=\"$y\">$y\n";
  }}
  closedir DIR;
} else {$error .= "$datafolder/Latin/Tabulae cannot open<BR>";}

my $monthline = '';

for ($i = 0; $i < @months; $i++) {
  my $j = $i + 1;
  $monthline .=  "<A HREF=# onclick=\"setmonth($j);\">$months[$i]</A>&nbsp;&nbsp;\n";
}

%h1 = undef;
%h2 = undef;

if (open(INP, "$datafolder/Latin/Tabulae/K$year1.txt")) {
  my @a = <INP>;
  close INP;
  foreach $item (@a) {if ($item =~ /=/) {$h1{$`} = $';}}
} else {$error .= "$datafolder/Latin/Tabulae/K$year1.txt cannot open<BR>";}

if ($year2 !~ /none/i) {
  if (open(INP, "$datafolder/Latin/Tabulae/K$year2.txt")) {
    my @a = <INP>;
    close INP;
    foreach $item (@a) {if ($item =~ /=/) {$h2{$`} = $';}}
  } else {$error .= "$datafolder/Latin/Tabulae/K$year2.txt cannot open<BR>";}
}

#*** print page
  #generate HTML
  htmlHead($title, 2);
    print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg" > 
<FORM ACTION="kalendarcomp.pl" METHOD=post TARGET=_self>
<H2 ALIGN=CENTER>$title</H2>
<P ALIGN=CENTER>
<FONT SIZE=1>$monthline<BR><BR></FONT>
<SELECT NAME=kalendar1 SIZE=4 onchange="document.forms[0].submit();">
$kalfiles1
</SELECT>
&nbsp;&nbsp;&nbsp;&nbsp;
<SELECT NAME=kalendar2 SIZE=4 onchange="document.forms[0].submit();">
$kalfiles2
</SELECT
<INPUT TYPE=HIDDEN NAME=month VALUE="$month"><BR><BR>
<TABLE BORDER=2 CELLPADDING=8 BGCOLOR=white WIDTH=90%>
<TR><TH COLSPAN=3>$year1 $months[$month-1]</TH><TH></TH><TH COLSPAN=2>$year2 $months[$month-1]</TH></TR>
<TR><TH>Day</TH><TH>file</TH><TH>Name</TH><TH></TH><TH>file</TF><TH>name</TH></TR>
PrintTag
		
for ($i = 0; $i < $mdays[$month-1]; $i++) {
  $j = $i + 1;
  $key = sprintf("%02i-%02i", $month, $j);
  $n1 = $h1{$key};
  $file1 = $name1 = $flink1 ='-';
  if ($n1 =~ /=/) {
    $file1 = $`; 
	$name1 = adjustname($', $year1, $file1); 
  	$file1=~ s/ //g;
	  #$flink1 = "<A HREF=\"$htmlurl/$lang/Sancti/$file1.txt\" TARGET=_new>$file1</A>";
	  $flink1 = "<A HREF=\"edit.pl?folder1=Sancti&filename1=$file1&edit1=on\" ".
	  "TARGET=_new>$file1</A>";
  }
  $n2 = $h2{$key};
  $file2 = $name2 = $flink2 = '-';
  if ($n2 =~ /=/) {
    $file2 = $`; 
	$name2 = adjustname($', $year2, $file2); 
  	$file2=~ s/ //g;
	$flink2 = "<A HREF=\"$htmlurl/$lang/Sancti/$file2.txt\" TARGET=_new>$file2</A>";
  }
  print "<TR><TD ALIGN=center>$j. </TD><TD ALIGN=center>$flink1</TD><TD>$name1</TD>" .
    "<TD></TD><TD ALIGN=center>$flink2</TD><TD>$name2</TD></TR>\n";
}
print << "PrintTag";
</TABLE>
<BR>
</P>
<P ALIGN=CENTER><FONT SIZE=1>$monthline</FONT></P>
PrintTag

#common end for programs
  if ($error) {print "<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>\n";}
  if ($debug) {print "<P ALIGN=center><FONT COLOR=blue>$debug</FONT></P>\n";}

  $command =~ s/(pray|setup)//ig;

  print << "PrintTag";
</FORM>
</BODY></HTML>
PrintTag

sub adjustname {
  my $name = shift;
  my $year = shift;
  my $file = shift;

  my $size1 = "<BR><FONT SIZE=1>";
  my $size2 = "</FONT>";
  my $trank = 0;
  
  while ($name =~ /=([0-9.]+)=/) {
    if (!$trank) {$trank = floor($1);}
	  my $prev = $`;
	  my $post = $';
	  $class = ($year < 1960) ? $tradtable[$trank] : ($year < 1970) ? $table1960[$trank] :
      $newtable[$trank];
    if ($year > 1959 && $year < 1970 && $dayname[1] =~ /feria/i) {$class = 'Feria';}
    $name = "$prev <FONT COLOR=maroon SIZE=-1>$class</FONT> $size1$post$size2";
    $size1 = $size2 = '';
  }

  my $missing = (-e "$datafolder/$lang/Sancti/$file.txt") ? '' :  'missing';  
  if ($missing) {$name .= "<BR><FONT COLOR=red>$missing</FONT>";}
  else {
    my %w = %{setupstring("$datafolder/$lang/Sancti/$file.txt")};
	  %w = updaterank(\%w, $year); 
    my @r = split(';;', $w{Rank});
    my $r = floor($r[2]);
    if ($r > 6) {$r = 6;}
	$check = 0;
    if ($r != $trank) {$check = 1;}
    if ($year > 1960 && $trank == 3 && $r > 1 && $r < 5) {$check = 0;}
    if ($year == 1570 && $trank >= 3 && $r >= 3) {$check = 0;}
	if ($check) {$name .= "<BR><FONT COLOR=RED>Check rank $trank=$r</FONT>";}
    #elsif ($file =~ /o$/i) {$name .= "<BR><FONT COLOR=RED>Check</FONT>";}
	  $name .= "<BR><FONT COLOR=BLUE SIZE=1>$w{Rank}</FONT>";
  }
  return $name;
}

#*** updaterank \%office
#updates $office{Rank} for 1960 Trid versions if any
sub updaterank {
  my $w = shift;
  my $version = shift;
  if ($version < 1911 && $version > 1570) {$version = 'Trident';}
  if ($version > 1970) {$version = 'Newcal';}

  my %w = %$w;
  if ($version =~ /Newcal/i && exists($w{RankNewcal})) {$w{Rank}=$w{RankNewcal};}
  elsif ($version =~ /(1955|1960|Newcal)/ && exists($w{Rank1960})) {$w{Rank}=$w{Rank1960};}
  if ($version =~ /1570/i && exists($w{Rank1570})) {$w{Rank}=$w{Rank1570};}
  elsif ($version =~ /(Trident|1570)/i && exists($w{RankTrident})) {$w{Rank}=$w{RankTrident};}
   
  return %w;
}

#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {
 print << "PrintTag";

<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

function setmonth(m) {  
  document.forms[0].month.value = m;
  document.forms[0].submit();
}

</SCRIPT>
PrintTag
} 

