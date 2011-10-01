#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office ordo

package horas;
#1;

#use warnings;
#use strict fs";
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

our $error = '';
$debug = '';
our $officium = 'officium.pl';
our $version = 'Divino Afflatu';
our ($browsertime, $date1);
our ($popupwindow, $popupcell, $popupheight, $voicegrey1, $voicegrey2);
our $caller = 0; #1=office is called for dirge
our $caller1 = 0; #actual value of $caller for the case calling Lauds from dirge Matins
our $dirge = 0; #1=call from 1st vespers, 2=call from Lauds
our $dirgeline = ''; #dates for dirge from Trxxxxyyyy

#*** common variables arrays and hashes
#filled  getweek()
our @dayname; #0=Adv|{Nat|Epi|Quadp|Quad|Pass|Pent 1=winner|2=commemoratio/scriptura

#filled by getrank()
our $winner; #the folder/filename for the winner of precedence
our $commemoratio; #the folder/filename for the commemorated
our $scriptura; #the folder/filename for the scripture reading (if winner is sancti)
our $commune; #the folder/filename for the used commune
our $communetype; #ex|vide
our $rank; #the rank of the winner
our $vespera; #1 | 3 index for ant, versum, oratio

#filled by precedence()
our %winner; #the hash of the winner 
our %commemoratio; #the hash of the commemorated
our %commemoratio1;
our %commemorated;
our %cc;
our %scriptura; #the hash for the scriptura
our %commune; # the hash of the commune
our (%winner2, %commemoratio2, %commune2); #same for 2nd column
our $rule; # $winner{Rank}
our $communerule; # $commune{Rank}
our $duplex; #1= simplex 2=semiduplex, 3=duplex 0=rest
             #4 = duplex majus, 5=duplex II class 6=duplex I class 7=higher 
our ($dirge, $initia);

our $lang1 = 'Latin';
our $hora;

our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';

our $Tk = 0;
our $Hk = 0;
our $Ck = 0;
our $ordostatus = 'Ordo';

require "$Bin/horascommon.pl";
require "$Bin/dialogcommon.pl";
require "$Bin/webdia.pl";
require "$Bin/tfertable.pl";
require "$Bin/specmatins.pl";
require "$Bin/horas.pl";
require "$Bin/specials.pl";

if (-e "$Bin/monastic.pl") {require "$Bin/monastic.pl";}
$q = new CGI;

#*** get parameters
getini('horas'); #files, colors      
if ($savesetup > 1) {require "$Bin/Aordo.pl";}

$setupsave = strictparam('setup');
$setupsave =~ s/\~24/\"/g;
$date1= strictparam('date1');
$browsertime = strictparam('browsertime');
$title = 'Ordo';

$O1960 = maketable('1960');
$ODA = maketable('DA');
$O1570 = maketable('1570');

                                  
#*** generate HTML
  htmlHead($title, 2);
    print << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg" > 
<FORM ACTION="ordo.pl" METHOD=post TARGET=_new>
<H1 ALIGN=CENTER>Officium divinum : Ordo</H1>
<TABLE WIDTH=90% ALIGN=CENTER BORDER=0 CELLPADDING=8><TR><TD> 
<H2 ALIGN=CENTER>Rubrics 1960</H2>
$O1960<BR>
<H2 ALIGN=CENTER>Divino afflatu version</H2>
$ODA<BR>
<H2 ALIGN=CENTER>Trident 1570 version</H2>
$O1570
</TD></TR></TABLE>
<P ALIGN=CENTER><FONT COLOR=red>$error</FONT></P>
</FORM></BODY></HTML>
PrintTag

#*** horasjs()
# javascript functions called by htmlhead
sub horasjs {
 print << "PrintTag";
<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>

</SCRIPT>
PrintTag
} 

sub maketable {
  $version = shift;
  my $o = '';
  my @mm = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec');
  $abbr = ($version =~ /1960/) ? "Abbreviations1" : "Abbreviations";

  $o .= "<P ALIGN=CENTER><A HREF=\"$htmlurl/Help/rubrics.html#$version\" TARGET=_new>Rubrics</A>&nbsp;&nbsp;&nbsp;\n";
  $o .= "<A HREF=\"$htmlurl/Help/$abbr.html\" TARGET=_new>Abbreviations</A></P>\n";
  $o .= "<TABLE ALIGN=CENTER BORDER=1 CELLPADDING=4>\n";
  my @a = split('-', gettoday());
  my $oryear = $a[2];
  for ($ory = $oryear-1; $ory <= $oryear+1; $ory++) {
    $o .= "<TR><TD><B>$ory</B></TD>\n";
	for ($orm = 0; $orm < 12; $orm++) {
  	  my $fname = "$htmlurl/Ordo/" . sprintf("K%s/%i-%i.html", $version, $ory, $orm+1);
  	  if ($savesetup > 1 && !(-e "$fname")) {ordohtml($version, $ory, $orm+1);} 
	  $o .= "<TD><A HREF=\"$fname\" TARGET=_new>$mm[$orm]</A></TD>\n";
    }
	$o .= "</TR>\n";
  }
  $o .= "</TABLE>\n";
  return $o;
}