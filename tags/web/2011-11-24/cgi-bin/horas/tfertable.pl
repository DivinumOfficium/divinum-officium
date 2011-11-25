#!/usr/bin/perl
use utf8;
# vim: set encoding=utf-8 :

# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti

#use warnings;
#use strict "refs";
#use strict "subs";
my $a = 4;

sub tfertable {
  my ($version, $kyear, $datafolder) = @_;

  our $initia;
  our (%tempora, %saint);
  my ($smonth, $say, $syear) = ($month, $day, $year);
  collect_arrays($kyear,$datafolder);


#*** save edited value
$kyearo = sprintf("%04i", $kyear);
$fname = ($version =~ /Newcal/i) ? "TrNewcal$kyearo" : ($version =~ /1955|1960/) ? "Tr1960$kyearo" : 
  ($version =~ /1570/i) ? "Tr1570$kyearo" : ($version =~ /1910/) ? "Tr1910$kyearo" : 
  ($version =~ /Monastic/i) ? "TrM$kyearo" : "TrDA$kyearo";  
$fname1 = $fname;
$fname1 =~ s/^Tr/Str/;  

  my @tfer_out = @tfer;
  $_ = "$_;;\n" for @tfer_out;
  if (do_write("$datafolder/Latin/Tabulae/$fname.txt", @tfer_out)) {
  } else {$error .= "$datafolder/Latin/Tabulae/$fname.txt cannot open for output<BR>\n";}

  my @scriptfer_out = @scriptfer;
  $_ = "$_;;\n" for @scriptfer_out;
  if (do_write("$datafolder/Latin/Tabulae/$fname1.txt")) {
  } else {$error .= "$datafolder/Latin/Tabulae/$fname1.txt cannot open for output<BR>\n";}
}

sub tfgetweek {
  our $month = shift;
  our $day = shift;
  our $year = shift;
  our @date1 = ($month, $day, $year); 
  my $a = getweek(0);
  return $a;	
	
}

sub collect_arrays {
 my $kyear = shift;
 my $datafolder = shift;   

@monthlength = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
@daynames = ('Sun', 'Mon', 'Tue', 'Wen', 'Thu', 'Fri', 'Sat');
my ($kmonth, $kday);

$title = "Transfer table for $kyear $version";

my $kalendarname = ($version =~ /1570/) ? 1570 : ($version =~ /Trident/i) ? 1888 
  : ($version =~ /newcal/i) ? '2009' : ($version =~ /1960/) ? 1960 : '1942';     
our %kalendar = undef;
our $kalendarkey = '';
$tempname = ($version =~ /Monastic/i) ? 'TemporaM' : 'Tempora';
if (my @a = do_read("$datafolder/Latin/Tabulae/K$kalendarname.txt")) {
  foreach (@a) {
    my @item = split('=', $_); 
    $kalendar{$item[0]} = "$item[1]\n";
  }
} else {error("$datafolder/Latin/Tabulae/$kalendarname.txt cannot open");}

#*** Handle  permanent transfers = Tr<Trid|1960|newcal>.txt
  my $vtrans = ($version =~ /monastic/i) ? 'M' : ($version =~ /newcal/i) ? 'newcal' : 
    ($version =~ /(1955|1960)/) ? '1960' : ($version =~ /1570/) ? '1570' : ($version =~ /Trid/i) ? '1910' : 'DA';  
  if ($vtrans && (@a = do_read("$datafolder/Latin/Tabulae/Tr$vtrans.txt"))) {
     my $tr = join('', @a);
     $tr =~ s/\=/\;\;/g;
     %transfertemp = split(';;', $tr);   
     $transfertemp = $transfertemp{$sday}; 
  } else {%transfertemp = undef; $transfertemp = '';} 


  if (@a = do_read("$datafolder/Latin/Tabulae/Tr$vtrans$kyear.txt")) {
     my $tr = join('',@a);
     $tr =~ s/\=/\;\;/g;   
     %transfer = split(';;', $tr);      
  } else {%transfer = {}; }
  $transfer = $transfer{$sday};  

                                  
  @collect = splice(@collect, @collect);  #internal array to collect trasfered days
  @tfer = splice(@tfer, @tfer);  #array of to=transfered items
  @scriptfer = splice(@scriptfer, @scriptfer); #array for days when initial are to be transfered
  $dirge = '';  #list of dirge days for Trident versions

  #Nat1 assignment
  tfgetweek(12, 25, $kyear);
  my $nat1 = '30';
  my $nat1name = ($version =~ /1960/) ? 'Nat1-0r' : 'Nat1-0';
  if ($version =~ /(1955|1960|Monastic)/i && $dayofweek > 0) {$nat1 = 32 - $dayofweek;} 
  elsif ($dayofweek == 1 || $dayofweek == 3) {$nat1 = 32 - $dayofweek;} 
  push(@tfer, sprintf("12-%02i=$tempname/$nat1name", $nat1));

  $epi2flag = 0;

  my @qimpeded = splice(@qimpeded, @qimpeded);
  my @impeded = splice(@impeded, @impeded);
  my @free = splice(@free, @free);
  my @seant = splice(@seant, @seant);
  my $macc2flag = 0;
  my $macc2num = 0;

#*** cycle to build tfer array
  for ($tmonth = 0; $tmonth < @monthlength; $tmonth++) {  
    $dirgemonth = '';
    $initia = 0;
	
    $kmonth = $tmonth + 1;
    for (my $kday = 1; $kday <= $monthlength[$tmonth]; $kday++) {	  
           
      my ($kmp1, $kdp1, $kyp1) = tfprevnext($kmonth, $kday, $kyear, 1); 
      my ($kmm1, $kdm1, $kym1) = tfprevnext($kmonth, $kday, $kyear, -1); 
      
      $transfered = 0; 

      my $dayname = tfgetweek($kmonth, $kday, $kyear);  
      our @dayname=split('=', $dayname);
      $dayname[0] =~ s/\s*$//g;
      $dayname[0] =~ s /^\s*//g; 
      
	  if ($dayname[0] =~ /Epi1/i && $dayofweek == 0) {
	    if ($version =~ /(Trident|Monastic)/i) {push(@tfer, sprintf("%02i-%02i=$tempname/Epi1-0a", $kmonth, $kday));}
        if ($version !~ /Monastic/i) {push(@scriptfer, sprintf("%02i-%02i=Epi1-0a", $kmp1, $kdp1));}
	    if ($version =~ /1960/ && $kday == 13) {
		  pop(@scriptfer);
		  push(@scriptfer, "01-12=Epi1-0a");
        }
	  }   
      if ($version =~ /Monastic/i) {next;} 

	  if ($kmonth == 1 && $kday == 12 && $dayofweek == 6 && $version !~ /Trident|1960/i) 
         {push(@tfer, sprintf("%02i-%02i=$tempname/Epi1-0", $kmonth, $kday));}

	  if ($dayname[0] =~ /Epi([2-5])/i) {$epi2flag = $1;} 
      if ($dayname[0] =~ /Epi6/i) {$epi2flag = 0;}
	  if ($dayname[0] =~ /Quadp1/i && $epi2flag && $version !~ /1960/) { 
        my %epi = split(';','3;Epi3-3~A;4;Epi4-2~Epi4-4~A;5;Epi5-2~Epi5-4~A');
		$epi2flag++;
		if (exists($epi{$epi2flag})) { 
		  push(@scriptfer, sprintf("%02i-%02i=$epi{$epi2flag}", $kmm1, $kdm1)); 
		}
	    push(@tfer, sprintf("%02i-%02i=Tempora/Epi$epi2flag-0", $kmm1, $kdm1));
		$epi2flag = 0;
      }
      
  		         
	  if ($kmonth == 11 && $dayname[0] =~ /Pent([0-9]+)/i && $1 == 23 && $dayofweek == 0 && $version !~ /1960/) {  
        my $t = date_to_days($kday,$kmonth-1,$kyear);
        @d = days_to_date($t + 35);	   
        if ($d[3] > 24) {
	      push(@tfer, sprintf("%02i-%02i=Tempora/Pent23-0", $kmm1, $kdm1)); 
	      push(@tfer, sprintf("%02i-%02i=Tempora/Pent24-0", $kmonth, $kday));
		  my ($i, $km2, $kd2);
      for ($i = 1; $i < 7; $i++) {   
	      $km2 = $kmonth;
        $kd2 = $kday + $i;
        if ($kd2 > 30) {$kd2 -= 30; $km2++;} 
        push(@tfer, sprintf("%02i-%02i=Tempora/Pent24-$i", $km2, $kd2));
		  } 
        }  
      }

      my $tname = "$dayname[0]-$dayofweek";	 
      if (exists($transfertemp{"Tempora/$tname"})) {
	    $tname =$transfertemp{"Tempora/$tname"};
		$tname =~ s/Tempora\///;
	  }
      if (exists($transfer{"Tempora/$tname"})) {
	     $tname =$transfer{"Tempora/$tname"};
		   $tname =~ s/Tempora\///;
	    }
      %tempora = updaterank(officestring("$datafolder/Latin/Tempora/$tname.txt"));   
      $trank = $tempora{Rank};     
      if ($version =~ /1955|1960/ && exists($tempora{Rank1960})) {$trank = $tempora{Rank1960};}
      if ($version =~ /Trident/i && exists($tempora{RankTrident})) {$w{Rank}=$w{RankTrident};}
      if ($version =~ /1570/i && exists($tempora{Rank1570})) {$w{Rank}=$w{Rank1570};}
      if ($version =~ /newcal/i && exists($tempora{RankNewcal})) {$trank = $tempora{RankNewcal};}
	  @trank = split(";;", $trank);  

      my $sday = get_sday($kmonth, $kday, $kyear);
      if (exists($kalendar{$sday})) {$sday = $kalendar{$sday};}
      if (exists($transfertemp{$sday})) {$sday = $transfertemp{$sday};}
	  if (exists($transfer{$sday}) && $transfer{$sday} !~ /Tempora/i) {$sday = $transfer{$sday}; $transfered = 1;}
      

      %saint = %{setupstring("$datafolder/Latin/Sancti/$sday.txt")};
      $srank = $saint{Rank};      
      if ($version =~ /1955|1960/ && exists($saint{Rank1960})) {$srank = $saint{Rank1960};}
      if ($version =~ /Trident/i && exists($saint{RankTrident})) {$srank=$saint{RankTrident};}
      if ($version =~ /1570/i && exists($saint{Rank1570})) {$srank=$saint{Rank1570};}
      if ($version =~ /newcal/i && exists($saint{RankNewcal})) {$srank = $tempora{RankNewcal};}
      @srank = split(";;", $srank); 

      my $sday1 = nextday($kmonth, $kday, $kyear);
      if (exists($kalendar{$sday1})) {$sday1 = $kalendar{$sday1};}
      if (exists($transfertemp{$sday1})) {$sday1 = $transfertemp{$sday1};}
	    if (exists($transfer{$sday1})) {$sday1 = $transfer{$sday1};}
      
      %saint1 = %{setupstring("$datafolder/Latin/Sancti/$sday1.txt")};
      $srank1 = $saint1{Rank};      
      if ($version =~ /1955|1960/ && exists($saint1{Rank1960})) {$srank1 = $saint1{Rank1960};}
      if ($version =~ /Trident/i && exists($saint1{RankTrident})) {$srank1=$saint1{RankTrident};}
      if ($version =~ /1570/i && exists($saint1{Rank1570})) {$srank1=$saint1{Rank1570};}
      if ($version =~ /newcal/i && exists($saint1{RankNewcal})) {$srank1 = $saint1{RankNewcal};}
      @srank1 = split(";;", $srank1); 
      if ($version =~ /1960/ && $srank1[2] < 6) {$srank1[2] = 0;}



	  #seant for Septuagesima, Sexagesima
	  if ($dayname[0] =~ /Quadp([12])/i) {  
	    my $sw = $1;
		if ($dayofweek == 0) {@seant = splice(@seant, @seant);}
		my $lim = ($dayname[0] =~ /Quadp1/i) ? 5 : 4;
		if ($dayofweek > 0 && $dayofweek < $lim && ($srank[2] >= 2 || $srank1[2] >= 1)) 
		  {push(@seant, "Quadp$sw-$dayofweek");}
		if ($dayofweek >= $lim && $dayofweek < 6 && $srank[2] < 2 && !$srank1[2]) { 
		  my $s = pop(@seant);
		  if ($s) {push(@scriptfer, sprintf("seant%02i-%02i=$s", $kmonth, $kday));}
	    }
      }

 #Hymnus Vespera contracted to hymnus laudes
     my %w = %saint;
	 my $rank = $srank[2];
	 my $tempflag = 0;
	 if ($trank[2] >= $srank[2]) {$rank = $trank[2]; $tempflag = 1;}
	 if ($version !~ /(Monastic|1960)/i && !$tempflag && $oldrank > $rank && exists($w{'Hymnus Vespera'}) && 
	    $w{'Hymnus Vespera'} !~ /\@/ && exists($w{'Hymnus Matutinum'}) && $w{'Hymnus Matutinum'} !~ /\@/) 
	   {push(@tfer, sprintf("Hy%02i-%02i=1", $kmonth, $kday));}
     $oldrank = $rank;

#*** Vigilia on Sunday
     if ($version !~ /1960/ && $dayofweek == 0 && $sday !~ /v$/ && $dayname[0] !~ /(Adv[2-4]|Quad[1-7])/i && 
	   $sday !~ /01\-05/ && ($saint{Rank} =~ /Vigilia/i || exists($saint{'Oratio Vigilia'}) || 
	    $kmonth == 10 && $kday == 31)) { 
        my $km = $kmonth;			  
        my $kd = $kday -1;
        if ($kd == 0) {$km--; $kd = $monthlength[$km];}
        push(@tfer, sprintf("%02i-%02i=%02i-%02iv", $km, $kd, $kmonth, $kday));
     }

#*** Christ the King
      if ($version !~ /Trident/i && $kmonth == 10 && $kday > 24 && $dayofweek == 0) {
	     if ($version =~ /1960/) {push(@tfer, sprintf("%02i-%02i=10-DUr", $kmonth, $kday));}
		 else {
		    push(@tfer, sprintf("%02i-%02i=10-DU", $kmonth, $kday));
			if ($kday == 28) {push(@tfer, "10-29=10-28");}
		}
	  }

     if ($version !~ /(1960|Monastic)/ && $kmonth == 11 && $kday == 29 && ($dayname[0] =~ /Adv/i || $dayofweek == 0) ) {
	    push(@tfer, "11-29=11-29r");
     }


#*** Commemoratio omnium fidelium
    if ($version !~ /(1960|Trident)/i && $month == 11 && $kday == 2 && $dayofweek == 0) 
      {push(@tfer, '11-03=11-02');}

#*** fill dirge
      if ($version !~ /1960/ && !$dirgemonth && $kmonth == 11 && $trank[2] < 5 && $srank[2] < 5) 
        {$dirgemonth = sprintf("%02i-%02i", $kmonth, $kday);}
      elsif ($version =~ /Trid/i && !$dirgemonth && $trank[2] < 5 && $srank[2] < 2) 
        {$dirgemonth = sprintf("%02i-%02i", $kmonth, $kday);}
    
      


      
#*** fill scriptfer  
	  if ($version !~ /1960/) {
      if ($dayofweek == 0) {
        if (@impeded) {
          if (!@free) {push(@scriptfer, "unsolved=@impeded");}
          else {
           my $line = '';
           foreach (@impeded) {$line .= "$_~";}
           $line .= 'A';
           push(@scriptfer, sprintf("%s=%s", pop(@free), $line));
         }
        }
        @qimpeded = splice(@qimpeded, @qimpeded);
        @impeded = splice(@impeded, @impeded);
        @free = splice(@free, @free);
      }

     #** third week of September
 	   if ($kmonth == 9 && $tempora{Rank} =~ /(III\. Septemb|Quat)/i) {
		 if (exists($saint{Lectio1}) && $tempora{Rank} !~ /Quat/i && ($tempora{Rank} !~ /Dominica/i || $srank[2] >= 5)) 
           {push(@qimpeded, monthday(0));}
         elsif (!exists($saint{Lectio1}) && (($tempora{Rank} =~ /Quat/i && $srank[2] >=2) || $tempora{Rank} !~ /Quat/i) 
		   && @qimpeded) {
		  push(@scriptfer, sprintf("%02i-%02i=%s", $kmonth, $kday, shift(@qimpeded)));
	      if ($tempora{Rank} !~ /Quat/i) {push(@qimpeded, monthday(0));}
	    }
      }
     
		 #** initia impeded by feast with proper scriptural lections
     

	 $initia = ($tempora{Lectio1} =~ /!.*? 1\:1\-/) ? 1 : 0; 
	 
	 if ($initia && $trank[2] < $srank[2] &&
         (($version !~ /Trident/i && $saint{Rank} =~ /;;ex C/ ) || 
          ($version =~ /Trident/i && $srank[2] >= 2 && $srank !~ /infra Octav/i) ||
          exists($saint{Lectio1}))) {   
       my $line = monthday(0);   
       if (!$line) {$line = "$dayname[0]-$dayofweek";}      
       if ($dayname[0] && $dayname[0] !~ /not found/i) {push(@impeded, $line);}

	} elsif ($dayofweek != 0 && $saint{Rank} !~ /;;ex C9/i  && !exists($saint{Lectio1}) &&
	         !((($version !~ /Trident/i && $saint{Rank} =~ /;;ex C/ ) || 
             ($version =~ /Trident/i && $srank[2] >= 3)))) { 
	   if (@impeded) {
         my $line = '';
         foreach (@impeded) {$line .= "$_~";}
         $line .= 'B';
         push(@scriptfer, sprintf("%02i-%02i=%s", $kmonth, $kday, $line));
         @impeded = splice(@impeded, @impeded);
       } else {push(@free, sprintf("%02i-%02i", $kmonth, $kday));}
     }     
         
	#** there is no 5th week of September
	if ($kmonth == 9 && $dayofweek == 4 && $kday > 24 && $tempora{Rank} =~ /IV\. Sept/i) {	
       my $d1 = $kday;
	   push(@scriptfer, "09-$d1=095-0");      
       $d1++;
	   if ($d1 < 31) {push(@scriptfer, "09-$d1=095-1");}
       $d1++;
	   if ($d1 < 31) {push(@scriptfer, "09-$d1=095-2");}
     }       
         
	 #*** story of Maccabei martyrs
	 if ($kmonth == 10 && $dayofweek == 4 && $kday > 25 && $tempora{Rank} =~ /IV\. Oct/i) {$macc2flag = 1;}
	 if ($tempora{Rank} =~ / V\. Oct/i) {$macc2flag = 1;}
	 if ($tempora{Rank}	=~ /Nov/i || $macc2num > 2) {$macc2flag = 0;}

	 elsif ($macc2flag) {
	   if ($dayofweek == 0) {if ($version =~ /trident/i && (transfered($sday) || !exists($saint{Lectio1}))) {$macc2num++;}}
 	   elsif (!exists($saint{Lectio1})) {
	     push(@scriptfer, sprintf("%02i-%02i=105-%01i", $kmonth, $kday, $macc2num));      
         $macc2num++; 
	   }	       
	 }   

  }


#*** collect transfered files
      my $lim1 = ($version =~ /1960/) ? 6 :  5; 
	  if (($trank[2] < $lim1 || $srank[2] < $lim1) && $tname !~ /Nat/i) { 
	  	  if (($trank[2] >= $lim1 || $srank[2] >= $lim1) && !$transfered ) {next;}
		    if (!@collect) {next;}	 
		    @collect = sort(@collect);
		    my $line = pop(@collect);  
		    $line =~ s/^[0-9]+\;\;//;	

		    push(@tfer, sprintf("%02i-%02i=$line", $kmonth, $kday));   #****
	  }

	  
#*** set  transfered files to @collect array
	  my $sortnum = sprintf("%02i", $srank[2] * 10); 
      if ($sday =~ /(12\-08|12\-24|01\-05)/ ) {next;}
	  if ($dayofweek == 0 && $sday =~ /11-02/) {push(@tfer, "11-03=11-02"); next;}
	  if ($day == 13 && $tname =~ /Epi1/i && $version !~ /1955|1960/i) 
	      {push(@tfer, "01-12=Tempora/Epi1-0"); next;}
      if ($trank[2] >= 6 && $srank[2] >= 6  && ($saint{Rule} !~ /Festum Domini/i || $tempora{Rule} !~ /Festum Domini/i ||
	     $version !~ /1960/)) {push(@collect, "$sortnum;;$sday"); next; }
	    if ($version =~ /(1955|1960)/) {next;}

      if ($trank[2] > 5.5) {push(@collect, "$sortnum;;$sday");}
	    next; 
   
	if ($dirgemonth) {$dirge .= "$dirgemonth,";}
  }
  }


    #Nat2 assignment
  tfgetweek(1, 1, $kyear);
  if ($version !~ /1570/i) {
    if ($dayofweek > 2) {push(@tfer, sprintf("01-%02i=$tempname/Nat2-0",8 - $dayofweek));}
    else {push(@tfer, "01-02=$tempname/Nat2-0");}
  }
  @tfer = sort(@tfer);

  $dirge =~ s/,$//;
  if ($version !~ /(1960|Monastic)/i) {push(@tfer, "dirge=$dirge");}
  return;
}

sub tfprevnext {
  my $month = shift;
  my $day = shift;
  my $year = shift;
  my $mult = shift;
  
  my $days = date_to_days($day,$month-1,$year);
  
  my @d = days_to_date($days + $mult);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;     
  return ($month, $day, $year);
}
