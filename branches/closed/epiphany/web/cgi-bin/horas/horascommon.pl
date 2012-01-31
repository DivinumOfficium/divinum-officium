#!/usr/bin/perl

#�����������
# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti also for missa

#use warnings;
#use strict "refs";
#use strict "subs";
my $a = 4;

sub error {
  my $t = shift;    
  $t .= '=';
  if (!$Tk && !$Hk) {$t .= "<BR>";}
  $error .= "=$t";
}

#*** getweek($flag)
# returns $week string list using date1 = mm-dd-yyy string as parameter
# set $dayofweek
# next day if $flag
sub getweek
{
   my $flag = shift;              
                                   
   my $t = date_to_days($date1[1],$date1[0]-1,$year);
   if ($flag) {$t += 1;}  
   @d = days_to_date($t);
   if (!$flag) {$dayofweek = $d[6];}
   else {$nextdayofweek = $d[6];}  
   my $advent1 = getadvent($year);

   my $y = $d[5]+1;
   my $dy = $flag ? $nextdayofweek : $dayofweek;
                      
   #Advent in december
   if ($t >= $advent1) {      
     if ($t < ($advent1 + 28)) {
	     $n = 1 + floor(($t - $advent1) / 7);
       if ($month == 11 || $day < 25) {return getname("Adv$n");}
	   }
     return '';
   }

   if ($month == 1 && $day  < 7) {return '';}

   my $ordtime = date_to_days(6,0,$year);
   @ot = days_to_date($ordtime);     
   $ordtime += (7 - $ot[6]);
                                                 
   my $easter = date_to_days(geteaster($year));   
   
   if ($t < $easter - 63) {
      $n = floor(($t - $ordtime) / 7) + 1;  
	    return getname("Epi$n");
   }
   
   if ($t < $easter - 56) {return getname("Quadp1");}
   if ($t < $easter - 49) {return getname("Quadp2");}
   if ($t < $easter - 42) {return getname("Quadp3");}
   
   if ($t < ($easter)) {
 	    $n = 1 + floor(($t - ($easter - 42)) / 7);
		return getname("Quad$n");
   }

   if ($t < ($easter + 56)) {
     $n = floor(($t - $easter) / 7); 
	   return getname("Pasc$n");
   }
   

   $n = floor(($t - ($easter + 49)) / 7);  

   if ($n < 24) {return getname(sprintf("Pent%02i", $n));}
   my $wdist = floor(($advent1 - $t + 6) / 7);
   if ($wdist < 2) {return "Pent24";}
   if ($missa) {return sprintf("PentEpi%1i", 8 - $wdist);}
   else {return sprintf("Epi%1i", 8 - $wdist);}

}

#*** getname($abr)
# returns the name from the abbreviation
sub getname {
  my $abbr = shift;
  my @days = ('Dominica','Feria II','Feria III','Feria IV','Feria V','Feria VI','Sabbato');

  if (!@sundaytable) {getsundaytable();}
  my $i = 0;
  for ($i = 0; $i < @sundaytable; $i++) {
    my $str = chompd($sundaytable[$i]);
    if ($str && $str =~ /^$abbr\=(.+)/) {
	  $str = $1;
	  if ($str =~ /^\s*\*/) {return "$abbr = $'";}
	  if ($d[6] == 0) {return "$abbr = Dominica $str";}
	  if ($str =~ /infra/i) {return "$abbr = $days[$dayofweek] $str";}
	  return "$abbr=$days[$dayofweek] infra Hebdomodam $str";
	}
  }
  return "$abbr";
}

#*** getsundaytable()
# reads sundaytable.txt into @sundaytable
sub getsundaytable {
   if (open (NI, "$datafolder/sundaytable.txt")) {
     @sundaytable = <NI>;
	 close NI;
   }
}

#*** getadvent($year)
# return time for the first sunday of advent in the given year
sub getadvent {
  my $year = shift;
  my $christmas = date_to_days(25,11,$year);
  my @ch = days_to_date($christmas); 
  my $n = ($ch[6] == 0) ? 7 : $ch[6]; #days between Christmas and 4th Sunday of Advent
  return $christmas - ($n + 21); #1st Sunday of Advent
}

#*** geteaster(year)
# returns easter date (dd,mm,yyyy);
sub geteaster {
  my $year = shift;

  my $c = floor($year / 100);
  my $n = $year - 19 * floor( $year / 19 );
  my $k = floor(( $c - 17 ) / 25);
  my $i = $c - floor($c / 4) - floor(( $c - $k ) / 3) + 19 * $n + 15;
  $i = $i - 30 * floor($i / 30 );
  $i = $i - floor( $i / 28 ) * ( 1 - floor( $i / 28 ) * floor( 29 / ( $i + 1 )) )
        * floor( ( 21 - $n ) / 11 );
  my $j = $year + floor($year / 4) + $i + 2 - $c + floor($c / 4);
  $j = $j - 7 * floor( $j / 7 );     
  my $l = $i - $j;
  my $m = 3 + floor(( $l + 40 ) / 44);
  my $d = $l + 28 - 31 * floor( $m / 4 );
  return ($d, $m-1, $year);
}

#*** checkfile($lang, $filename) 
# substitutes English if no $lang item, Latin if no English
sub checkfile {
  my $lang = shift;
  my $file = shift;  
                             
  if (-e "$datafolder/$lang/$file") {return "$datafolder/$lang/$file";}
  elsif ($lang =~ /english/i) {return "$datafolder/Latin/$file";}
  elsif (-e "$datafolder/English/$file") {return "$datafolder/English/$file";}
  else {return "$datafolder/Latin/$file";}
}

#*** getrank() loads files from tempora and sancti
sub getrank {
  my $c = $dialog{'communes'};
  $c =~ s/\n//sg;
  %communesname = split(',', $c);
  $dayname[0] =~ s/\s*$//g;
  $dayname[0] =~ s /^\s*//g;

  my %tempora = {};
  my %saint = {};
  my $trank = '';
  my $tname = '';
  my $srank = '';
  my $sname = '';
  my $cname = '';

  my @trank = ();
  my @srank = ();
  our $transfervigil = '';
  our %transfer = {};
  our $hymncontract = 0;

  my $kalendarname = ($version =~ /Monastic/i) ? '500' 
    : ($version =~ /1570/) ? 1570 : ($version =~ /Trident/i) ? 1888 
    : ($version =~ /newcal/i) ? '2009' : ($version =~ /1960/) ? 1960 : 1942;     
  our %kalendar = undef;
  our $kalendarkey = ''; 
  if (open(INP, "$datafolder/../horas/Latin/Tabulae/K$kalendarname.txt")) {
    my @a = <INP>;
    close INP;
    foreach (@a) {
      my @item = split('=', $_); 
      $kalendar{$item[0]} = $item[1];
    }
  } else {error("$datafolder/../horas/Latin/Tabulae/K$kalendarname.txt cannot open");}


  my $sday = get_sday($month, $day, $year);   

  # Handle transfers
  my $vtrans = ($version =~ /newcal/i) ? 'newcal' : ($version =~ /(1955|1960)/) ? '1960' : 
   ($version =~ /monastic/i) ? 'M' : ($version =~ /1570/) ? '1570' : ($version =~ /1910/) ? 1910 : 'DA';  
  if ($vtrans && open(INP, "$datafolder/../horas/Latin/Tabulae/Tr$vtrans.txt")) {
     my $tr = '';
     while ($line = <INP>) {$tr .= chompd($line);}
     $tr =~ s/\=/\;\;/g;
     close(INP);
     %transfertemp = split(';;', $tr);      
     $transfertemp = $transfertemp{$sday}; 	
  } else {%transfertemp = undef; $transfertemp = '';} 
  if ($transfertemp && $transfertemp !~ /tempora/i) {$transfertemp = "$sanctiname/$transfertemp";} 
 
                        
  $dirgeline = '';	 
  $dirge = 0;		 	 
  if (($tk || $Hk || $savesetup ) && !(-e "$datafolder/../horas/Latin/Tabulae/Tr$vtrans$year.txt")) {tfertable($version, $year, $datafolder);}
  if (open(INP, "$datafolder/../horas/Latin/Tabulae/Tr$vtrans$year.txt")) {   
     my $tr = ''; 
     while ($line = <INP>) {$tr .= chompd($line);}
     close(INP);
     $tr =~ s/\=/\;\;/g;  	   
     %transfer = split(';;', $tr);	 
     if (exists($transfer{dirge})) {$dirgeline = $transfer{dirge};}  #&& !$caller
  } else {%transfer = {}; }

  $transfer = $transfer{$sday};   
  
  if ($transfer =~ /v$/ && !(-e "$datafolder/Latin/$sanctiname/$transfer.txt")) {
    $transfervigil = $transfer;
	$transfervigil =~ s/v$//;
    $transfer = ''; 
 } 

 if (exists($transfer{"Hy$sday"})) {$hymncontract = 1;}
   
  if ($transfer && $transfer !~ /tempora/i) {$transfer = "$sanctiname/$transfer";}

  $vespera = 3;
  $svesp = 3;
  $tvesp = 3;
  $cvespera = 0;
  my $tn = '';
  if ($dayname[0]) {
    $tn = "$temporaname/$dayname[0]-$dayofweek";  
    if (exists($transfertemp{$tn})) {$tn =$transfertemp{$tn};} 
  } 

  if (exists($transfertemp{$sday}) &&
    $transfertemp{$sday} =~ /tempora/i) {$tn = $transfertemp{$sday};}
  if (exists($transfer{$sday}) && $transfer{$sday} =~ /tempora/i) {$tn = $transfer{$sday};}

  $tn1 = '';
  $tn1rank = '';

              			   
  my $nday = nextday($month, $day, $year);   
  #if ($hora =~ /(vespera|Completorium)/i) {
  #  if ($transfer{$nday} =~ /tempora/i) {$tn1 = $transfer{$nday};} 
  #}
				  	 
  if ($testmode =~ /(Saint|Common)/i) {$tn = 'none';} 

                      
  #Vespera anticipation  concurrence
  if (-e "$datafolder/$lang1/$tn.txt" || $dayname[0] =~ /Epi0/i || ($transfer{$nday}) =~ /tempora/i) {  
     $dofw = $dayofweek;
     if ($hora =~ /(vespera|completorium)/i && $testmode !~ /(Saint|Common)/i) {      
       my $a = getweek(1);            
       my @a = split('=', $a); 
       $dn[0] = $a[0];
       $dn[0] =~ s/\s*$//g;
       $dn[0] =~ s/^\s*//g;
       $dofw = ($dayofweek + 1) % 7;
       $tn1 = "$temporaname/$dn[0]-$dofw";    
       
	   if (exists($transfertemp{$tn1})) {$tn1 =$transfertemp{$tn1};}
	   elsif (exists($transfer{$tn1})) {$tn1 =$transfer{$tn1};}
       elsif(exists($transfer{$nday}) && $transfer{$nday} =~ /tempora/i ) {$tn1 = $transfer{$nday};} 

       #$tvesp = 1;
	   %tn1 = %{officestring("$datafolder/$lang1/$tn1.txt", 1)};  
       #if ($tn1{Rank} =~ /(Feria|Vigilia|infra octavam|Quat[t]*uor)/i && $tn1{Rank} !~ /in octava/i
       #  && $tn1{Rank} !~ /Dominica/i) {$tn1rank = '';}
       if ($tn1{Rank} =~ /(Feria|Sabbato|infra octavam)/i && $tn1{Rank} !~ /in octava/i
         && $tn1{Rank} !~ /Dominica/i) {$tn1rank = '';}
       elsif ($dayname[0] =~ /Pasc[07]/i && $dayofweek != 6) {$tn1rank = '';}
	   elsif ($version =~ /1960/ && $tn1{Rank} =~ /Dominica Resurrectionis/i) 
	       {$tn1rank = '';}
       elsif ($version =~ /1960/ && $tn1{Rank} =~ /Patrocinii St. Joseph/i) 
  	     {$tn1rank = '';}

	   else {$tn1rank = $tn1{Rank};} 
       #if ($version =~ /1960/ && $tn =~ /Nat1/i && $day =~ /(25|26|27|28)/) {$tn = '';} 

     }

     $tname = "$tn.txt";                    
                       
     $tvesp = 3;
	 %tempora = %{officestring("$datafolder/$lang1/$tname")};   
     $trank = $tempora{Rank};     
     if ($hora =~ /(Vespera|Completorium)/i && $tempora{Rule} =~ /No secunda Vespera/i && $version !~ /1960/) 
	   {$trank = ''; %tempora = undef; $tname=''}
   
  } else {$trank = ''; $tname = '';}     


  if (transfered($tname)) {$trank = '';} 
  #if (transfered($tn1)) {$tn1 = '';}     #???????????
		
  if ($hora =~ /Vespera/i && $dayname[0] =~ /Quadp3/ && $dayofweek == 3) {$trank =~ s/;;6/;;2/;}
  @trank = split(";;", $trank);  
  @tn1 = split(';;', $tn1rank);  
  if ($tn1[2] >= $trank[2]) {  
    $tname = "$tn1.txt";
    %tempora = %tn1; 
    $trank = $tempora{Rank}; 
 	if ($version =~ /1960/ && $tn1 =~ /Nat1/i && $day =~ /(25|26|27|28)/) {$trank =~ s/;;5/;;4/;} 
    @trank = split(";;", $trank);  	
    $dayname[0] = $dn[0];
	$tvesp = 1;  
  } elsif (!$trank) {
    $tname = '';
    %tempora = {};
  }

  $initia = ($tempora{Lectio1} =~ /!.*? 1\:1\-/) ? $initia = 1 : 0;
                            
  #handle sancti
  $sn = "$sanctiname/$kalendar{$sday}";  
  if ($transfertemp =~ /Sancti/) {$sn = $transfertemp;}   
  elsif ($transfer =~ /Sancti/) {$sn = $transfer;;}
  elsif (transfered($sn)){$sn = '';}    

  my $snd = $sn;
  if (!$snd || $snd !~ /([0-9]+\-[0-9]+)/) {$snd = $sday;}
  $snd = ($snd =~ /([0-9]+\-[0-9]+)/) ? $1 : '';   
  if ($dirgeline && $hora =~ /Laudes/i && $version =~ /Trident/i && $snd && $dirgeline =~ /$snd/) 
    {$dirge = 2;}
                   
  if ($testmode =~ /^Season$/i) {$sn = 'none';}    
  if (-e "$datafolder/$lang1/$sn.txt") { 
   $sname = "$sn.txt";   	 
   if ($caller && $hora =~ /(Matutinum|Laudes)/i) {$sname =~ s/11-02t/11-02/;}          

   %saint = updaterank(setupstring("$datafolder/$lang1/$sname")); 
   $srank = $saint{Rank};          
   if ($hora =~ /(Vespera|Completorium)/i && $saint{Rule} =~ /No secunda Vespera/i && $version !~ /1960/) 
     {$srank = ''; %saint = undef; $sname = '';}
  } else {$srank = '';}                 

  if ($version =~ /(1955|1960)/) { 
    if ($srank =~ /vigil/i && $sday !~ /(06\-23|06\-28|08\-09|08\-14|12\-24)/) {$srank = '';}
    if ($srank =~ /(infra octavam|in octava)/i && nooctnat()) {$srank = '';}  
  } #else {if ($srank =~ /Simplex/i) {$srank = '';}}
  @srank = split(";;", $srank);     

  if ($srank[2] < 2 && $hora =~ /(vespera|completorium)/i && $trank  && !($month == 1 && $day > 6 && $day < 13)) 
     {$srank = ''; @srank = undef;}
  if ($trank[2] == 7 && $srank[2] < 6) {$srank = ''; @srank = undef;}
  if ($version =~ /(1955|1960)/ && $trank[2] >= 6 && $srank[2] < 6)  {$srank = ''; @srank = undef;}

  if ($version =~ /1955/ && $srank[2] == 2 && $srank[1] =~ /Semiduplex/i) 
    {$srank[2] = 1.5;}  #1955: semiduplex reduced to simplex
  if ($version =~ /1960/ && $srank[2] < 2 && $srank[1] =~ /Simplex/i && $testmode =~ /seasonal/i &&
    ($month > 1 || $day > 13)) 
    {$srank[2] = 1;}      

  #if ( transfered($sday) && $srank !~ /Christi Regis/i) {$srank[2] = 0;}  

  #check for concurrence
  my $cday = $crank = '';
  my %csaint = {};
  my $crank = '';
  my $vflag = 0; 
  $cday = nextday($month, $day, $year); 
  if ($transfer{$cday} !~ /tempora/i && transfered($cday)) {$cday = 'none';} 
  if (exists($transfer{$cday}) && $transfer{$cday} !~ /Tempora/i) {$cday = $transfer{$cday};}
  if ($tname =~ /Nat/ && $cday =~ /Nat/) {$cday = 'none';} 

  if ($hora =~ /(vespera|completorium)/i) {     
    if ($cday !~ /(tempora|DU)/i) {$cday = "$kalendar{$cday}"; } 

    my $cdayd = $cday;
    if (!$cdayd || $cdayd !~ /([0-9]+\-[0-9]+)/) {$cdayd = nextday($month, $day, $year);}
    $cdayd = ($cdayd =~ /([0-9]+\-[0-9]+)/) ? $1 : '';
	if ($dirgeline && $cdayd && $dirgeline =~ /$cdayd/) {$dirge = 1;}  

    if ($cday && $cday !~ /tempora/i) {$cday = "$sanctiname/$cday";} 
    if ($testmode =~ /^Season$/i) {$cday = 'none';} 	   
    $cday =~ s/11-03$/11-02t/;

	if (-e "$datafolder/$lang1/$cday.txt") { 
      $cname = "$cday.txt";      
      %csaint = updaterank(setupstring("$datafolder/$lang1/$cname")); 
      $BMVSabbato = ($csaint{Rank} =~ /Vigilia/) ? 0 : 1;
      $crank = ($csaint{Rank} =~ /vigilia/i && $csaint{Rank} !~ /(;;[56]|Epi)/i ) ? '' : $csaint{Rank};
	  if ($crank =~ /(Feria|Vigilia)/i  && $csaint{Rank} !~ /in Vigilia Epi/i ) {$crank = '';}
	} 
    @crank = split(";;", $crank);    
  
  if ($version =~ /(1955|1960)/) { 
      if ($crank =~ /vigil/i && $sday !~ /(06\-23|06\-28|08\-09|08\-14|08\-24)/) {$crank = '';}
      if ($crank =~ /octav/i && $crank !~ /cum Octav/i && $crank[2] < 6) {$crank = '';}
    }
  if ($csaint{Rule} =~ /No prima vespera/i) {$crank = ''; $cname= '';}
  if ($tname =~ /Tempora\/Quad6\-3/i) {$crank = ''; $cname = '';}  

  #infra octav concurrent with infra octav = crank deleted
  @crank = split(";;", $crank);   
  if ($version !~ /1960/ && $srank && $crank && ($tname =~ /Quadp3\-3/i || $tname =~ /Quad6\-[1-3]/i)) 
    {$srank[2] = 1;}      
  if ($version !~ /1960/ && $crank && ($tname =~ /Quadp3\-2/i || $tname =~ /Quad6\-[1-3]/i)) 
    {$crank[2] = 1;}      

  if ($crank =~ /infra octav/i  && $srank =~ /infra octav/i) 
    {$crank = ''; $cname = ''; @crank = undef;} #exception for nov 2

  if ($srank =~ /vigilia/i && ($version !~ /1960/ || $sname !~ /08\-09/)) {$srank[2] = 0; $srank = '';}
                                         
  if (($version =~ /1955/ && $crank[2] < 5) || ($version =~ /1960/ && $crank[2] < 6) ) 
	  {$crank = ''; @crank = splice(@crank, @crank);}    


  if ($version !~ /1960/ && $hora =~ /Completorium/i && $month == 11 && $day == 1 && $dayofweek != 6) {
    $crank[2] = 7;
    $crank =~ s/;;[0-9]/;;7/;
    $srank = '';
  } elsif ($version !~ /1960/ && $hora =~ /(Vespera|Completorium)/i && $month == 11 && 
      $srank =~ /Omnium Fidelium defunctorum/i && !$caller) {	 
      $srank[2] = 1;
      $srank = '';
  } elsif ($version =~ /1960/ && $hora =~ /(Vespera|Completorium)/i && $month == 11 && $day == 1) {
     $crank[2] = 1;    
     $crank = '';
  } 
  our $antecapitulum = '';
  our $antecapitulum2 = '';
  our $anterule = '';

  if ($crank[2] >= $srank[2]) {     
	   if ($hora =~ /Vespera/i && $srank[2] ==  $crank[2]  && $crank[2] >= 2) {
	     $antecapitulum = (exists($saint{'Ant Vespera 3'})) ? $saint{'Ant Vespera 3'} :
		   (exists($saint{'Ant Vespera'})) ? $saint{'Ant Vespera'} : '';
	     if ($antecapitulum) {
	       %saint2 = %{setupstring("$datafolder/$lang2/$sname")};
           $antecapitulum2 = (exists($saint2{'Ant Vespera 3'})) ? $saint2{'Ant Vespera 3'} :
		   (exists($saint2{'Ant Vespera'})) ? $saint2{'Ant Vespera'} : '';
	    } 
	   }
	  ($cname, $sname) = ($sname, $cname);
	  ($crank, $srank) = ($srank, $crank);	  
	   $svesp = 1;
      #switched
	  (%saint, %csaint) = (%csaint, %saint);
      @srank = split(";;", $srank);
      @crank = split(";;", $crank); 
	  $vflag = 1; 
	  
	  if ((($srank[2] >= 6 && $crank[2] < 5) || ($srank[2] >= 5 && $crank[2] < 3)) 
	    && $crank[0] !~ /Octav.*?(Epiph|Nativ|Corporis|Cordis|Ascensionis)/i )  
	    {$crank = ''; $cname = ''; @crank =''; %csaint= undef;}
	  elsif ($srank[2] >= 5 && $crank =~ /infra octav/i) {$crank = ''; $cname = ''; %csaint = undef; @crank = '';} 
    }

	if ($tvesp == 1 && $version =~ /1960/) {
	  if ((($trank[2] >= 6 && $srank[2] < 5) || ($trank[2] >= 5 && $srank[2] < 3)) 
	    && $srank[0] !~ /Octav.*?(Epiph|Nativ|Corporis|Cordis|Ascensionis)/i )  
	    {$srank = ''; $sname = ''; @srank =''; %saint= undef;}
	  elsif ($trank[2] >= 5 && $srank =~ /infra octav/i  && $srank[0] !~ /Epiph/) 
	    {$srank = ''; $sname = ''; %saint = undef; @srank = '';} 
    }
  } 


   #Newcal optional
  if ($version =~ /newcal/i && $testmode =~ /seasonal/i && ($srank[2] < 3  
      || ($dayname[0] =~ /Quad[1-6]/i && $srank[2] < 5))) {
    $srank = $sname = $crank = $cname = ''; %saint = %csaint = undef; 
    @srank = @crank = ''; 
  }  

  $commemoratio = $commemoratio1 =  $communetype = $commune = $commemorated = 
    $dayname[2] = $scriptura = '';
  $comrank = 0;			 

  if ($version =~ /Trid/i && $trank[2] < 5.1 && $trank[0] =~ /Dominica/i) 
    {$trank[2] = 2.9;}   
  if ($version =~ /Monastic/i && $trank[2] < 5.1 && $trank[0] =~ /Dominica/i) 
    {$trank[2] = 4.9;}   
  if ($version =~ /1960/ && (floor($trank[2]) == 3 || $dayname[0] =~ /Quad[0-9]/i || 
    ($dayname[0] =~ /quadp3/i && $dayofweek >= 3)) && $srank[2] < 5) {$trank[2] = 4.9;}
  if ($version =~ /1960/ && $dayofweek == 0) {
    if (($trank[2] >= 6 && $srank[2] < 6) || ($trank[2] >= 5 && $srank[2] < 5)) 
	  {$srank = ''; @srank = undef;}
  }


  #if ($svesp == 3 && $srank[2] >= 5 && $dayofweek == 6) {$srank[2] += 5;}  ?????????

  my @cr = split(';;', $csaint{Rank});         

  # In Festo Sanctae Mariae Sabbato according to the rubrics.
  if ($version !~ /monastic/i && $dayname[0] !~ /(Adv|Quad[0-6])/i && $dayname[0] !~ /Quadp3/i && 
      $testmode !~ /^season$/i && $saint{Rule} !~ /Infra octavam Epiphaniae Domini/i) { 
    if ($dayofweek == 6 && $srank !~ /(Vigil|in Octav)/i && $trank[2] < 2 && $srank[2] < 2 && !$transfervigil) { 
      $tempora{Rank} = $trank = "Sanctae Mariae Sabbato;;Feria;;2;;vide $C10";
      $scriptura = $tname;  
      if ($scriptura =~ /^\.txt/i) {$scriptura = $sname;} 
	    $tname = "Tempora/$C10.txt";
      if ($version =~ /Trident/i) {
	    $tempora{Rank} =~ s/C10/C10t/;
		$trank =~ s/C10/C10t/;
		$tname =~ s/C10/C10t/;
	  } 
	  @trank = split(";;", $trank);  
    } 

	if ($hora =~ /(Vespera|Completorium)/i && $dayofweek == 5 &&  $crank !~ /;;[2-7]/ && $srank !~ /;;[5-7]/ &&
        $crank !~ /Vigil/i && $version !~ /1960/  && $saint{Rule} !~ /BMV/i && $trank !~ /;;[2-7]/ &&
        $srank !~ /in Octav/i && $saint{Rule} !~ /Infra octavam Epiphaniae Domini/i) { 
      $tempora{Rank} = $trank = 'Sanctae Mariae Sabbato;;Feria;;1.9;;vide C10';  
	  $tname = "Tempora/C10.txt";  
      if ($version =~ /Trident/i) {
	    $tempora{Rank} =~ s/C10/C10t/;
		$trank =~ s/C10/C10t/;
		$tname =~ s/C10/C10t/;
	  } 
	  @trank = split(";;", $trank);  
    }
  }
  if ($trank[2] == 2 && $trank[0] =~ /infra octav/i) {$srank[2] += .1;}

  if ($testmode =~ /seasonal/i && $version =~ /1960/ && $srank[2] < 5 && $dayname[0] =~ /Adv/i) 
    {$srank[2] = 1;}   
    
  # Flag to indicate whether office is sanctoral or temporal. Assume the
  # latter unless we find otherwise.
  my $sanctoraloffice = 0;
  
  # Sort out occurrence and concurrence between the sanctoral and
  # temporal cycles.
  
  # Dispose of some cases in which the office can't be sanctoral:
  # if we have no sanctoral office, or it was reduced to a
  # commemoration by Cum nostra.
  if (!$srank[2] || ($version =~ /(1955|1960)/ && $srank[2] <= 1.1)) {
    # Office is temporal; flag is correct.
  }
  # Simple feasts give way to the office of our Lady on a Saturday.
  elsif (($dayofweek == 6 || ($dayofweek == 5 && $hora =~ /(Vespera|Completorium)/i)) &&
    $trank[2] && $srank[2] < 2 && $srank !~ /Vigil/i) {
   # Office is temporal; flag is correct.
  }
  # Main case: If the sanctoral office outranks the temporal, the
  # former takes precedence.
  elsif ($srank[2] > $trank[2]) {
    $sanctoraloffice = 1;
  }
  # On some Sundays, the sanctoral office can still win in certain
  # circumstances, even if it doesn't outrank the Sunday numerically.
  elsif ($trank[0] =~ /Dominica/i && $dayname[0] !~ /Nat1/i) {
    if ($version =~ /1960/) {
      # With the 1960 rubrics, II. cl. feasts of the Lord and all I. cl.
      # feasts beat II. cl. Sundays.
      if ($trank[2] <= 5 && ($srank[2] >= 6 || ($srank[2] >= 5 && $saint{Rule} =~ /Festum Domini/i))) {
        $sanctoraloffice = 1;
      }
      # Still in 1960, in concurrence of days of equal rank, the
      # preceding office takes precedence.
      elsif ($hora =~ /(Vespera|Completorium)/i && $tvesp == 1 && $svesp == 3 && $srank[2] == $trank[2]) {
        $sanctoraloffice = 1;
      }
    }
    # Pre-1960, feasts of the Lord of nine lessons take precedence over
    # a lesser Sunday.
    elsif ($saint{Rule} =~ /Festum Domini/i && $srank[2] >= 2 && $trank[2] <= 5) {
      $sanctoraloffice = 1;
    }
    # Again pre-1960, doubles of at least the II. cl. (and privileged
    # octave days) beat all Sundays in concurrence.
    elsif ($hora =~ /(Vespera|Completorium)/i && ($tvesp != $svesp) && $srank[2] >= 5) {
      $sanctoraloffice = 1;
    }
  }

  # Office is sanctoral.
  if ($sanctoraloffice) {   
    $rank = $srank[2];     
	  $dayname[1] = "$srank[0] $srank[1]"; 
    $winner = $sname;  
    %winner = updaterank(setupstring("$datafolder/$lang1/$winner"));
    $vespera = $svesp;      
    if ($srank[3] =~ /^(ex|vide)\s*C/i) {  
      $communetype = $1;    
      if ($version =~ /trident/i && $version !~ /monastic/i && $rank >= 2) {$communetype = 'ex';}
      if ($srank[3] =~ /(C[0-9]+[a-z]*)/i) {
	      $commune = $1;
	 	  $dayname[1] .= " $communetype $communesname{$commune} [$commune]";
      } 
      my $fname="$datafolder/$lang1/$communename/$commune" . "p.txt";     
      if ($dayname[0] =~ /Pasc/i && (-e $fname)) 
      {$commune .= 'p';}
 		  if ($commune) {$commune = "$communename/$commune.txt";}

   } elsif ($srank[3] =~ /(ex|vide)\s*Sancti\/(.*)\s*$/i) {
    $communetype = $1;       
    $commune = "$sanctiname/$2.txt";  
    if ($version =~ /trident/i && $version !~ /monastic/i) {$communetype = 'ex';}
   }  

   if ($hora =~ /vespera/i && $trank[2] =~ /Feria/i) {$trank = ''; @trank = undef;}
   #if ($version =~ /1960/ && $srank[2] >= 6 && $trank[2] < 6) {$tname = $trank = ''; @trank = undef;}

   if (transfered($tname)) { #&& !$vflag) 
     if ($hora !~ /Completorium/i) {$dayname[2] = "Transfer $trank[0]";}
     $commemoratio = ''; 
      
  } elsif ($version =~ /1960/ && $winner{Rule} =~ /Festum Domini/i && $trank =~ /Dominica/i) { 
        $trank = ''; @trank = undef; 
		if ($crank[2] >= 6) {$dayname[2] = "Commemoratio: $crank[0]"; $commemoratio = $cname;} 	 
  } elsif ($winner =~ /sancti/i && $trank[2] && $trank[2] > 1 && $trank[2] >= $crank[2] && $rank < 7) { 
      if ($hora !~ /Completorium/i && $trank[0] && $winner{Rule} !~ /no commemoratio/i)
	    {$dayname[2] = "Commemoratio: $trank[0]";  } 
      $commemoratio = $tname; 
	  if ($cname && $version !~ /1960/) {{$commemoratio1 = $cname;}#{$commemoratio = $cname; $commemoratio1 = $tname;}
      } 
	  $comrank = $trank[2];
      $cvespera = $tvesp;

  } elsif ($crank[2] && ($srank[2] <= 5 || $crank[2] >= 2)) { 
      if ($hora !~ /Completorium/i && $crank[0] && $winner{Rule} !~ /no commemoratio/i) 
	    {$dayname[2] = "Commemoratio: $crank[0]";}  
      $commemoratio1 = ($trank[2] > 1) ? $tname : '';
      $commemoratio = $cname; 
      $comrank = $crank[2]; 
      $cvespera = 4 - $svesp;    
    							 
  } elsif ($crank[2] < 6) {$dayname[2] = ''; $commemoratio = '';}  

  %w = %{officestring("$datafolder/$lang1/$winner")};      
  if (($hora =~ /matutinum/i || (!$dayname[2] && $hora !~ /Vespera|Completorium/i)) && $rank < 7) { 
    my %scrip = %{officestring("$datafolder/$lang1/$tname")};  
    if (!exists($w{"Lectio1"}) && exists($scrip{Lectio1}) && $scrip{Lectio1} !~ /evangelii/i && 
      ($w{Rank} !~ /\;\;ex / || ($version =~ /trident/i && $w{Rank} !~ /\;\;(vide|ex) /i) ) ) 
    {$dayname[2] = "Scriptura: $trank[0]";}
    else {$dayname[2] = "Tempora: $trank[0]" }
   $scriptura = $tname;
   }

  } else {    #winner is de tempora


  if ($version !~ /Monastic/i && $dayname[0] !~ /(Adv|Quad[0-6])/i && $srank[2] < 2 && $trank[2] < 2 && 
    $testmode !~ /^season$/i && $saint{Rule} !~ /Infra octavam Epiphaniae Domini/i &&
    (($dayofweek == 6 && $srank !~ /Vigil/i && $trank[2] < 2 && !$transfervigil) || 
       ($hora =~ /Vespera|Completorium/i && $dayofweek ==5 &&  $trank[2] < 2 && $srank[0] !~ /Vigil/i &&
        $csaint{Rank} !~ /Vigil/i && $version !~ /1960/))) {  
      $tempora{Rank} = $trank = "Sanctae Mariae Sabbato;;Feria;;2;;vide $C10";
      $scriptura = $tname;
	    $tname = "Tempora/$C10.txt";
      if ($version =~ /Trident/i) {
	      $tempora{Rank} =~ s/C10/C10t/;
		    $trank =~ s/C10/C10t/;
		    $tname =~ s/C10/C10t/;
	    } 
	  @trank = split(";;", $trank);    
  } 
  
   if ($hora !~ /Vespera/i && $rank < 1.5 && $transfervigil) {
     my $t = "Sancti/$transfervigil.txt";
	 my %w = setupstring("$datafolder/$lang1/$t"); 
	 if (%w) {
	   $tname = $t;
	   $trank = $w{Rank};
	   @trank = split(';;', $trank);
     }
   }

  
    $rank = $trank[2];  
	$dayname[1] = "$trank[0]  $trank[1]"; 
    $winner = $tname;            
    $vespera = $tvesp; 
                        			
    if ($trank[3] =~ /(ex|vide)\s*(.*)\s*$/i) {
      $communetype = $1;  
      my $name = $2;
      if ($name =~ /^C[0-9]/i) {$name = "$communename/$name";}
      if ($name !~ /(Sancti|Commune|Tempora)/i) {$name = "$temporaname/$name";}
      $commune = "$name.txt";  
      if ($version =~ /trident/i && $version !~ /monastic/i) {$communetype = 'ex';}    
    }  
     

	if ($version =~ /1960/ && $vespera == 1 && $rank >= 6 && $comrank < 5) 
    {$commemoratio = ''; $srank[2] = 0;}

  if (transfered($sday) && $crank !~ /$srank/) {  
     $dayname[2] = "Transfer $srank[0]";  
     $commemoratio = '';
    
  } elsif ($srank[2]) {   
     %w = %{officestring("$datafolder/$lang1/$winner")};  
	 my $climit1960 = climit1960($sname);  
	 if ($w{Rule} !~ /omit.*? commemoratio/i && $climit1960  && ($w{Rule} !~ /No commemoratio/i || 
	   ($svesp == 1 && $hora =~ /vespera/i))) { 
	   $laudesonly = ($missa) ? '' : ($climit1960 > 1) ? ' ad Laudes tantum' : '';
	     #(nomatinscomm(\%w)) ? ' Laudes, Vesperas' : '';  
	   if ($srank[0] =~ /vigil/i && $srank[0] !~ /Epiph/i) {
	     $laudesonly = ($dayname[0] =~ /(Adv|Quad[0-6])/i) ? ' ad Missam tantum' : ' ad Laudes tantum';
       } 
       # Don't say "Commemoratio in Commemoratione"
       my $comm = $srank[0] =~ /^In Commemoratione/ ? '' : 'Commemoratio';
	   if ($srank[0]) {$dayname[2] = "$comm$laudesonly: $srank[0]";}
       if ($version =~ /(monastic|1960)/i && $dayname[2] =~ /Januarii/i) {$dayname[2] = '';}
	   if (($climit1960 > 1 && ($hora =~ /laudes/i || $missa)) || $climit1960 < 2) {
         $commemoratio = $sname;    
         $cvespera = $svesp;
         $comrank = $srank[2]; 
         if (($version !~ /1960/ && $crank[2]) || ($crank[2] >= 3 || ($trank[2] == 5 && $crank[2] >= 2)))
		   {$commemoratio1 = $cname;} 
       } 

	 } else {
        $dayname[2] = '';
        $commemoratio = '';
      }
    } 
   if (!$commemoratio && !$commemoratio1  && $sname) {
     $sname =~ s/v\././;
     my %s = %{setupstring("$datafolder/Latin/$sname")};
     if ($s{Rank} =~ /Vigil/i && exists($s{Commemoratio})) {$commemorated = $sname;}
     if ($s{Rank} =~ /Vigil/i && exists($s{"Commemoratio 2"})) {$commemorated = $sname;}
   }
  } 
  if ($version =~ /trident/i && $communetype =~ /ex/i && $rank < 1.5) {$communetype = 'vide';}

  if ($winner =~ /tempora/i) {$antecapitulum = '';}

  #Newcal commemoratio handling
  if ($version =~ /Newcal/i && ($month != 12 || $day < 17 || $day > 24)) {
    $commemoratio = $commemoratio1 = '';
    %commemoratio = %commemoratio2 = undef;
  }

 #Commemoratio for litaniis majores
 if ($month == 4 && $day == 25 && $version =~ /(1955|1960)/ && $dayofweek == 0) 
   {$commemoratio = ''; $dayname[2] = '';}


  $comrank=~ s/\s*//g;
  $seasonalflag = ($testmode =~ /Seasonal/i && $winner =~ /Sancti/ && $rank < 5  &&
    $version !~ /newcal/i) ? 0 : 1;   
  if (($month == 12 && $day > 24) || ($month == 1 && $day < 14 && $dayname[0] !~ /Epi/i)) {$dayname[0] = "Nat$day";}   

}

#*** next day for vespera
# input month, day, year
# returns the name for saint folder
sub nextday {
  my $month = shift;
  my $day = shift;
  my $year = shift;
  
  my $time = date_to_days($day,$month-1,$year);
  
  my @d = days_to_date($time + 1);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;     
  return get_sday($month, $day, $year);
}

#*** leapyear($year)
# returns 1 if leapyear, otherwise 0
sub leapyear {
  my $year = shift;  
  if (($year % 400) == 0) {return 1;}
  if (($year % 100) == 0) {return 0;}
  if (($year % 4) == 0) {return 1;}
  return 0;
}

#*** get_sday($month, $day, $year)
# get a name (mm-dd) for sancti folder
sub get_sday {
  my $month = shift;
  my $day = shift;
  my $year = shift;

  if (leapyear($year) && $month == 2 && $day == 24) {$day = 29;} 
  if (leapyear($year) && $month == 2 && $day > 24) {$day -= 1;}
   
  $kalendarkey = sprintf("%02i-%02i", $month, $day);   
  return $kalendarkey;
}

#*** emberday 
# return 1 if emberday, 0 otherwise
# used $dayofweek, $dayname[0] season and week,
# for September the weekday office 
sub emberday {    
  if ($dayofweek < 3 || $dayofweek == 4) {return 0;}
  if ($dayname[0] =~ /Adv3/i) {return 1;}
  if ($dayname[0] =~ /Quad1/i) {return 1;}  
  if ($dayname[0] =~ /Pasc7/i) {return 1;}
  if ($month != 9) {return 0;}

  if ($winner{Rank} =~ /Quatuor/i || $commemoratio{Rank} =~ /Quatuor/i ||
    $scriptura{Rank} =~ /Quatuor/i) {return 1;}
  if ($winner{Rank} =~ /Quattuor/i || $commemoratio{Rank} =~ /Quattuor/i ||
    $scriptura{Rank} =~ /Quattuor/i) {return 1;}
  return 0;
}      

#*** gettoday($flag) 
#get the currend date in mm-dd-yyy format
# flag is set only for primary call for the standalone version
# for the web version javascrip function obtains the user's date
sub gettoday {
  my $flag = shift;
  if ($browsertime && !$flag) {return $browsertime;}

  
  my @date = localtime(time());
  my $month = @date[4]+1;
  my $day = @date[3];
  my $year = @date[5]+1900;
  return "$month-$day-$year";
}  

#*** precedence() 
# get date, rank, winner, preloads hashes
sub precedence {	  
                
  $winner = $commemoratio = $commune = $striptura = $commemoratio1 = '';
  %winner = %commemoratio = %commune = %scriptura = {};
  
  #get date
  $dat1 = shift;   
  if (!$dat1) {$dat1 = ($Tk || $Hk) ? $date1 : strictparam('date');}
  $date1 = $dat1;     
  if ($votive =~ /hodie/ && !$Hk) {$date1 = gettoday();}  
  
  if (!$missa) {
    $vtv = ($votive =~ /(Dedication|C8)/i) ? 'C8' : ($votive =~ /(Defunctorum|C9)/i) ? 'C9' :
      ($votive =~ /(Parvum|C12)/i) ? 'C12' : '';
    if ($vtv !~ /(C8|C9|C12)/) {$votive = '';}
  } 
  else {$vtv = $votive;}
     
  if ($date1) {
    $date1 =~ s/\//\-/g;   
    @date1 = split('-', $date1);
    $month = $date1[0];
    $day = $date1[1];
    $year = $date1[2];      
    if ($month < 1 || $month > 12 || $day < 1 || $day > 31){ $date1 = '';}
  }
  if (!$date1) {($month, $day, $year) = split('-', gettoday());}  
                                  
  if ($month) {$date1 = "$month-$day-$year";}  
  else {$date1 = '';} 
                      

  @date1 = split('-', $date1);    
  $dayname = getweek(0);  
  @dayname=split('=', $dayname);
  our $C10 = ($dayname[0] =~ /Adv/i) ? 'a' : ($month == 1 || ($month == 2 && $day ==1)) ? 'b' :
    ($dayname[0] =~ /(Epi|Quad)/i) ? 'c' : ($dayname[0] =~ /Pasc/i) ? 'Pasc' : '';
  $C10 = ($missa) ? "C10$C10" : 'C10';  


  getrank(); #fills @dayname, $winner, $commemoratio, $commune, $communetype, $rank);

  $duplex = 0;    
  if ($dayname[1] && $dayname[1] !~ /duplex/i) {$duplex = 1;}
  elsif ($dayname[1] =~ /semiduplex/i) {$duplex = 2;}
  else {$duplex = 3;}
                      
  $rule = $communerule = '';    
    
  if ($winner) {   
    if ($missa && $missanumber) {
      my $wm = $winner;
	  $wm =~ s/\.txt/m$missanumber\.txt/i; 
	  if ($missanumber && (-e "$datafolder/Latin/$wm")) {$winner = $wm; } 
    } 

    my $flag = ($winner =~ /tempora/i && $tvesp == 1) ? 1 : 0;  
    %winner = %{officestring("$datafolder/$lang1/$winner", $flag)};  
    %winner2 = %{officestring("$datafolder/$lang2/$winner", $flag)};

    # In the feriae where the octave of the Epiphany used to be, the
    # Mass is of the Epiphany ('Ecce advenit') before the Sunday, and
    # of I. Sunday after the Epiphany ('In excelso throno') afterwards.
    if ($version =~ /1955|1960/ && $missa && $dayname[0] =~ /Epi1/i && $winner =~ /01\-([0-9]+)/ && $1 < 13 && $dayofweek != 0) {
      $communetype = 'ex';
      $commune = 'Tempora/Epi1-0a.txt';
    } 

    $rule = $winner{Rule};  
  }
 
 
 
  if ($version !~ /(1960|monastic)/i && exists($winner{'Oratio Vigilia'}) 
    && $dayofweek != 0 && $hora =~ /Laudes/i) {$transfervigil = $winner;}  

  if ($winner =~ /Sancti/ && $rule =~ /Tempora none/i) {$commemoratio = $scriptura = $dayname[2] = ''; }

  
  if ($version !~ /1960/ && $hora =~ /Vespera/ && $month == 12 && $day == 28 && $dayofweek == 6) {
     $commemoratio1 = $commemoratio;
	 $commemoratio = 'Sancti/12-29.txt';
  }
  if ($version !~ /1960/ && $hora =~ /Vespera/ && $month == 1 && $day == 3 && $dayofweek == 6) 
    {$commemoratio1 = 'Sancti/01-04.txt';}

  if ($version =~ /1960/ && $winner{Rule} =~ /No Sunday commemoratio/i && $dayofweek == 0) 
    {$commemoratio = $commemoratio1 = $dayname[2] = '';}

  
  if ($commemoratio) {   
    my $flag = ($commemoratio =~ /tempora/i && $tvesp == 1) ? 1 : 0;  
    %commemoratio = %{officestring("$datafolder/$lang1/$commemoratio", $flag)};
    if ($version =~ /1960/ && $winner{Rule} =~ /Festum Domini/ && $commemoratio{Rule} =~ /Festum Domini/i) 
	  {$commemoratio = ''; %commemoratio = undef; $dayname[2] = '';}
    if ($vespera == $svesp && $vespera == 1 && $cvespera == 3 && $commemoratio{Rule} =~ /No second Vespera/i)
	  {$commemoratio = ''; %commemoratio = undef; $dayname[2] = '';}
	else {%commemoratio2 = %{officestring("$datafolder/$lang2/$commemoratio")};}
	
  }

  if ($commemoratio1) {   
    my $flag = ($commemoratio1 =~ /tempora/i && $tvesp == 1) ? 1 : 0;  
    %commemoratio1 = %{officestring("$datafolder/$lang1/$commemoratio1", $flag)};
    if ($version =~ /1960/ && $winner{Rule} =~ /Festum Domini/ && $commemoratio1{Rule} =~ /Festum Domini/) 
	  {$commemoratio1 = ''; %commemoratio1 = undef; $dayname[2] = '';}
  }

  if ($scriptura) {     
    %scriptura = %{officestring("$datafolder/$lang1/$scriptura")};
    %scriptura2 = %{officestring("$datafolder/$lang2/$scriptura")};
  }  

  #Epiphany days for 1955|1960
  #if ($version =~ /(1955|1960)/ && $month == 1 && $day > 6 && $day < 13 && $winner{Rank} =~ /Die/i  && 
  #    exists($scriptura{Rank})) 
  #  {$winner{Rank} = $scriptura{Rank}; $winner2{Rank} = $scriptura2{Rank};}

  #no transfervigil if emberday
  if ($winner{Rank} =~ /Quat[t]*uor/i || $commemoratio{Rank} =~ /Quat[t]*uor/i 
     || $scriptura{Rank} =~ /Quat[t]*uor/i) {$transfervigil = '';}

  if ($commune) {     
    %commune = %{officestring("$datafolder/$lang1/$commune")}; 
    %commune2 = %{officestring("$datafolder/$lang2/$commune")};
    if (exists($commune{Responsory7c})) {
	  my @a = split("\n", $commune{Responsory7});
	  my @b = split("\n", getreference($scriptura{Responsory1}, Latin)); 
	  if ($a[0] =~ /$b[0]/i) {
	    $commune{Responsory7} = $commune{Responsory7c};
		$commune2{Responsory7} = $commune2{Responsory7c};
      }
    }
	
	if ($commune =~ /C10/) {
      $rule .= "ex $C10";
      $rule =~ s/Oratio Dominica//gi; 
      $winner{Rank} = "Sanctae Mariae Sabbato;;Feria;;1;;ex $C10";
    }
    if ($winner{Rank} =~ /\;\;ex\s/ || 
	  ($version =~ /Trident/i && $rank =~ /\;\;(ex|vide)/i && $duplex > 1)) 
      {$communerule = $commune{Rule};}

    if ($testmode =~ /Commune/i) {
      my $key;
      foreach $key (keys %winner) {
        if ($key =~ /Rank/i) {next;}
        if (exists($commune{$key})) {$winner{$key} = $commune{$key}}
        else {delete($winner{$key});}
      }
      foreach $key (keys %winner2) {
        if ($key =~ /Rank/i) {next;}
        if (exists($commune2{$key})) {$winner2{$key} = $commune2{$key}}
        else {delete($winner2{$key});}
      }
    }
  }
  
  if ($vtv && !$missa) { 
    if ($vtv =~ /C12/i) {  
      if ($dayname[0] =~ /adv/i) {$vtv = 'C12A';}
      elsif ($dayname[0] =~ /Nat/i || ($month == 12 && $day > 24) || 
        $month == 1 || ($month == 2 && $day < 3)) {$vtv = 'C12N';}
      elsif ($dayname[0] =~ /Pasc/i) {$vtv = 'C12P';}
      elsif ($month == 3 && (($day == 24 && $hora =~ /(Vespera|Completorium)/i) ||
        $day == 25)) {$vtv = 'C12An';}
    }  
	
	$winner = "Commune/$vtv.txt";
    $commemoratio = $commemoratio1 = $scriptura = $commune = '';
    %winner = updaterank(setupstring("$datafolder/$lang1/$winner"));
	  %winner2 = updaterank(setupstring("$datafolder/$lang2/$winner"));
    %commemoratio = %commemoratio1 = %scriptura = %commune = %commemoratio2 = %scriptura2 = %commune2 = {};
    $rule = $winner{Rule};
    if ($vtv =~ /C12/i) {
      @rank = split(';;', $winner{Rank});
      $commune = "Commune/C11.txt";
      $communetype = 'ex';
      %commune = updaterank(setupstring("$datafolder/$lang1/$commune"));
      %commune2 = updaterank(setupstring("$datafolder/$lang2/$commune"));
    }
    $dayname[1] = $winner{Name}; $dayname[2] = ''; 
  }	  
    if (!$missa && $winner =~ /C10/)
    {
        if ($month < 2 || ($month == 2 && $day < 3))
        {    
            $winner{'Ant 1'} = $winner{'Ant 11'};
            $winner{'Ant 2'} = $winner{'Ant 21'};
            $winner2{'Ant 1'} = $winner2{'Ant 11'};
            $winner2{'Ant 2'} = $winner2{'Ant 21'};
            $winner{'Oratio'} = $winner{'Oratio 21'};
        }
        elsif ($dayname[0] =~ /Pasc/i)
        {
            $winner{'Ant 1'} = $winner{'Ant 13'};
            $winner{'Ant 2'} = $winner{'Ant 23'};
            $winner2{'Ant 1'} = $winner2{'Ant 13'};
            $winner2{'Ant 2'} = $winner2{'Ant 23'};
        }
        elsif ( $version !~ /1960/ && $month == 9 && $day > 8 && $day < 15 )
        {
            my %s = %{setupstring("$datafolder/$lang1/Sancti/09-08.txt")};
            my %s2 = %{setupstring("$datafolder/$lang2/Sancti/09-08.txt")};
            my $key;
            foreach $key (%s)
            {
            if ($key =~ /(Rank|Name|Rule|Lectio|Benedictio|Ant Matutinum)/i) {next;}
            $winner{$key} = $s{$key};
            $winner2{$key} = $s2{$key};
            }
        }

        # 7/16 version=1960 : partially excepted by BVM de Monte Carmelo   (#5)
        elsif ( $version =~ /1960/ && $month == 7 && $day == 16 )
        {
            my %s = %{setupstring("$datafolder/$lang1/Sancti/07-16.txt")};
            my %s2 = %{setupstring("$datafolder/$lang2/Sancti/07-16.txt")};
            my %sc = %{setupstring("$datafolder/$lang1/Commune/C11.txt")};
            my %sc2 = %{setupstring("$datafolder/$lang2/Commune/C11.txt")};

            $winner{'Oratio'} = $s{'Oratio'};
            $winner2{'Oratio'} = $s2{'Oratio'};

            $winner{'Versum 2'} = $sc{'Versum 2'};
            $winner2{'Versum 2'} = $sc2{'Versum 2'};

            $winner{'Ant 2'} = $s{'Ant 2'};
            $winner2{'Ant 2'} = $s2{'Ant 2'};
        }
    }
 
  if ($vtv && $missa) { 
	
	$winner = "Votive/$vtv.txt";
    $commemoratio = $commemoratio1 = $scriptura = $commune = '';
    %winner = updaterank(setupstring("$datafolder/$lang1/$winner"));
	  %winner2 = updaterank(setupstring("$datafolder/$lang2/$winner"));
    %commemoratio = %scriptura = %commune = %commemoratio2 = %scriptura2 = %commune2 = {};
    $rule = $winner{Rule};
    if ($vtv =~ /Maria/i) {
      @rank = split(';;', $winner{Rank});
      $commune = "Commune/C11.txt";
      $communetype = 'ex';
      %commune = updaterank(setupstring("$datafolder/$lang1/$commune"));
      %commune2 = updaterank(setupstring("$datafolder/$lang2/$commune"));
    }
    $dayname[1] = $winner{Name}; $dayname[2] = ''; 
  }	  


  if ($dayofweek == 0 && $month == 12 && $day == 24 && !$missa) {
    if ($hora !~ /(Vespera|Completorium)/i) {
      %winner = %{officestring("$datafolder/$lang1/Sancti/12-24s.txt", $flag)};  
      %winner2 = %{officestring("$datafolder/$lang2/Sancti/12-24s.txt", $flag)}; 
	  $rule = $winner{Rule};
    } else {$dayname[2] = '';}
  }



  $laudes = 1;	      
  if ((($dayname[0] =~ /Adv|Quad/i || emberday()) && $winner =~ /tempora/i &&
     $winner{Rank} !~ /(Beatae|Sanctae) Mariae/i) ||  $rule =~ /Laudes 2/i ||
    ($winner{Rank} =~ /vigil/i && $version !~ /(1955|1960)/))  {$laudes = 2;}
  if ($version =~ /trident/i) {$laudes = '';}
  if ($dayname[0] =~ /Adv/ && $dayofweek == 0) {$laudes = 1;}

  if ($missa && $winner{Rank} =~ /Defunctorum/) {$votive = 'Defunct';}

}

#*** monthday($forcetomorrow)
# returns an empty string or mmn-d format 
# e.g. 081-1 for monday after the firs Sunday of August
sub monthday {
  my $forcetomorrow = shift;
  my $tomorrow;
  
  # Get tomorrow's date if the caller requested it or if we're saying first Vespers.
  $tomorrow = ($forcetomorrow || $tvesp == 1);

  if ($month < 7 || $dayname[0] =~ /Adv/i) {return '';} 

  my @ftime = splice(@ftime, @ftime);
  my ($fday, $fmonth);
  for ($m = 8; $m < 13; $m++) { 
    my $t = date_to_days( 1, $m - 1, $year);  #time for the first day of month
    my @d = days_to_date($t);
    my $dofweek = $d[6];  
    if ($version =~ /1960/) {$fday = ($dofweek == 0) ? 1 : 8 - $dofweek; $fmonth = $m;}
    else {
      my @ldays = (31,31,30,31,30);
      if ($dofweek == 0) {$fday = 1; $fmonth = $m;}
      elsif ($dofweek < 4) {$fday = $ldays[$m - 8] - $dofweek + 1; $fmonth = $m - 1;}
      else {$fday = 8 - $dofweek; $fmonth = $m;}
    }
 
    $ftime[$m - 8] = date_to_days( $fday, $fmonth - 1, $year);  
  }

  my ($d1, $m1, $y1, $dow) = ($day, $month, $year, $dayofweek);
  if ($tomorrow) {($d1, $m1, $y1) = nday($day, $month, $year); $dow = ($dayofweek + 1) % 7;}
      
  my $ta = date_to_days( $d1, $m1 - 1, $y1); 
  if ($ta < $ftime[0]) {return '';}
  for ($m = 9; $m < 13; $m++) {
    if ($ta < $ftime[$m - 8]) {last;}
  }						 
                                 
  my $tdays = $ta - $ftime[$m - 9];   
  my $weeks = floor($tdays / 7); 
  if ($m == 12 && ($weeks > 0 || $version =~ /1960/)) {
    my $t = date_to_days($date1[1],$date1[0]-1,$date1[2]);
    if ($tomorrow) {$t += 1;}
    my $advent1 = getadvent($year);
    my $wdist = floor(($advent1 - $t - 1) / 7);    
    $weeks = 4 - $wdist;  
	if ($version =~ /1960/ && $weeks == 1) {$weeks = 0;}
  }								
  my $monthday = sprintf('%02i%01i-%01i', $m - 1, $weeks + 1, $dow);  
  return $monthday;
}

#*** officestring($fname, $flag)
# same as setupstring (in dialogcommon.pl = reads the hash for $fname office)
# with the addition that for the monthly ferias/scriptures (aug-dec)
# it adds that office to the otherwise empty season related one
# if flag is 1 looks for the anticipated office for vespers
# returns the filled hash for the ofiice
sub officestring {
  my ($fname, $flag) = @_;       
  
  my %s;
  if ($fname !~ /tempora[M]*\/(Pent|Epi)/i) {
    %s = updaterank(setupstring($fname));
	if ($version =~ /1960/ && $s{Rank} =~ /Feria.*?(III|IV) Adv/i && $day > 16) {$s{Rank} =~ s/;;2/;;3/;}
	return \%s;
  }
  if ($fname =~ /tempora[M]*\/Pent([0-9]+)/i && $1 < 5) {
    %s = updaterank(setupstring($fname));
	return \%s;
  }
  $monthday = monthday($flag);   #*** was $flag 
  if (!$monthday) {
    %s = updaterank(setupstring($fname));
	return \%s;
  }						   
  %s = %{setupstring($fname)};  
  if (!%s) {return '';}
  my @rank = split(';;', $s{Rank});
  my $m = 0;
  my $w = 0;
  if ($monthday =~ /([0-9][0-9])([0-9])\-[0-9]/) {$m = $1; $w = $2;}
  my @months = ('Augusti', 'Septembris', 'Octobris', 'Novembris', 'Decembris');
  my @weeks = ('I.', 'II.', 'III.', 'IV.', 'V.');
  if ($m) {$m = $months[$m - 8];}
  if ($w) {$w = $weeks[$w - 1];}
  $rank[0] .= " $w $m";
  $str = "$rank[0];;$rank[1];;$rank[2]";
  if ($rank[3]) {$str .= ";;$rank[3]";}
  $s{Rank} = $str;
  my $lang = 'Latin';
  if ($fname =~ /.*\/(.*?)\/Tempora/i) {$lang = $1;}	 
  my %m = %{setupstring("$datafolder/$lang/$temporaname/$monthday.txt")};  

  foreach $key (keys %m) {	
    if (($version =~ /newcal/i && $key =~ /Rank/i)) {;}
	  else {$s{$key} = $m{$key}; } 
  }	  
    
  %s = updaterank(\%s);
  return \%s;
}

#*** nday($day, $month, $year)
# returns ($day, $month, $year) values for the following day
sub nday {
  my ($day, $month, $year) = @_;
  my $time = date_to_days($day,$month-1,$year);
  my @d = days_to_date($time + 1);
  
  $month = $d[4]+1;
  $day = $d[3];         
  $year = $d[5]+1900;     
  return ($day, $month, $year);
}

#*** transfered($tname | $sday)
# returns true if the day for season or saint is transfered
# otherwise false
sub transfered { 
  my $str = shift;	  
  if ($transfertemp && $str =~ /$transfertemp/i) {return 0;}  
  if ($transfer && $str =~ /$transfer/i) {return 0;}
  my $key;	
  foreach $key (keys %transfer) { 
	if ($transfer{$key} =~ /Tempora/i && $transfer{$key} !~ /Epi1\-0/i ) {next;} 
	if ($key !~ /(dirge|Hy)/i && $transfer{$key} !~ /$key/ && ($str =~ /$transfer{$key}/i || $transfer{$key} =~ /$str/i ) ) {
	  return 1;
	}
  }		 
  if (%transfertemp) {
    foreach $key (keys %transfertemp) 
      {if ($key !~ /dirge/i && $transfertemp{$key} =~ /$str/i  && $transfer{$key} !~ /v\s*$/i) {return 1;}}
  }		
  return 0;
}

#*** climit1960($commemoratio)
# returns 1 if commemoratio is allowed for 1960 rules
sub climit1960 {
  my $c = shift;            
  if (!$c) {return 0;}
  if ($version !~ /1960/ || $c !~ /sancti/i) {return 1;}
  # Subsume commemoration in special case 7-16 with Common 10 (BVM in Sabbato)
  return 0 if $c =~ /7-16/ && $winner =~ /C10/;
  my %w = updaterank(setupstring("$datafolder/Latin/$winner"));
  if ($winner !~ /tempora/i) {return 1;}
  my %c = updaterank(setupstring("$datafolder/Latin/$c"));
  my @r = split(';;', $c{Rank});   
  if ($w{Rank} =~ /Dominica/i) {
    if (($hora !~ /(Vespera|Completorium)/i && $r[2] >= 5) || $r[2] >= 6) {return 1;}
    if ($hora =~ /Laudes/i && $r[2] >= 5 && $rank < 6) {return 1;}
  } elsif ($r[2] >= 6) {return 1;}
  elsif ($r[2] > 1) {return 2;}
  return 0;
}

#*** setheadline();
# returns the winner name and rank, different for 1960
sub setheadline { 
  my $name = shift;
  my $rank = shift;     

  if ((!$name || !$rank) && exists($winner{Rank}) && $winner !~ /Epi1\-0a/i) {  
    my @rank = split(';;', $winner{Rank});
 	$name = $rank[0];
	$rank = $rank[2];
  }

  if ($name && $rank) {
	  my $rankname = '';

    if ($name !~ /(Die|Feria|Sabbato)/i && ($dayname[0] !~ /Pasc[07]/i || $dayofweek == 0)) {
	    my @tradtable = ('none', 'Simplex', 'Semiduplex', 'Duplex', 'Duplex majus', 
        'Duplex II. classis', 'Duplex I. classis', 'Duplex I. clasis');
        my @newtable = ('none', 'Commemoratio', 'III. classis', 'III. classis', 'III. classis',
        'II. classis', 'I. classis', 'I. classis');
    
 	    $rankname = ($version !~ /1960/) ? $tradtable[$rank] : $newtable[$rank];
	    if ($version =~ /1960/ && $dayname[1] =~ /feria/i) {$rankname = 'Feria';}
		if ($name =~ /Dominica/i && $version !~ /1960/) {
          my $a = ($dayofweek == 6 && $hora =~ /(Vespera|Completorium)/i) 
            ? getweek(1) : getweek(0);  
          my @a = split('=', $a);  
          $rankname = ($a[0] =~ /Pasc[017]/i || $a[0] =~ /Pent01/i) ? 'Duplex  1st class' :
            ($a[0] =~ /(Adv1|Quad[1-6])/i) ? 'Semiduplex 1st class' :
            ($a[0] =~ /(Adv[2-4]|Quadp)/i) ? 'Semiduplex 2nd class' : 'Semiduplex Dominica minor';
        }

	  } elsif ($dayname[0] =~ /Pasc[07]/i && $dayofweek > 0) {
	    $rankname = 'Dies Octavae I classis';
	  
	  } else {
	     if ($version !~ /1960/) {
		     $rankname = ($rank < 2) ? 'Ferial' : ($rank < 3) ? 'Feria major' : 'Feria privilegiata';
         } else {
	       my @ranktable = ('', 'IV. classis', 'III. classis', 'II. classis', 'II. classis',
		      'II. classis', 'I. classis', 'I. classis'); 
		     $rankname = $ranktable[$rank]; 
	     }
	} 
    return "$name ~ $rankname";
  } else {return $dayname[1];}
}

#*** updaterank \%office
#updates $office{Rank} for 1960 Trid versions if any
sub updaterank {  
  my $w = shift;  
  my %w = %$w;   
  if (!exists($w{Rank})) {return %w;}  
  if ($version =~ /Newcal/i && exists($w{RankNewcal})) {$w{Rank}=$w{RankNewcal};}
  elsif ($version =~ /(1955|1960|Newcal)/ && exists($w{Rank1960})) {$w{Rank}=$w{Rank1960};}
  if ($version =~ /1570/i && exists($w{Rank1570})) {$w{Rank}=$w{Rank1570};}
  elsif ($version =~ /(Trident|1570)/i && exists($w{RankTrident})) {$w{Rank}=$w{RankTrident};}
  return %w;
}

#*** setmdir($version)
# set $anctiname, $temporaname $commonname
sub setmdir {
  my $version = shift;
  if ($version =~ /Monastic/i) {
    $sanctiname = 'SanctiM';
    $temporaname = 'TemporaM';
    $communename = 'CommuneM';
    $votive = '';
  } else {
    $sanctiname = 'Sancti';
    $temporaname = 'Tempora';
    $communename = 'Commune';
  }
}

sub nomatinscomm {
  my $w = shift;
  my %w = %$w;
  if ($w{Rule} =~ /9 lectiones/i && exists($w{Responsory9})) {return 1;}  
  if ($w{Rule} !~ /9 lectiones/i && exists($w{Responsory3})) {return 1;}
  return 0;
}

#*** getreference($str, $lang)
# checks for @... reference
# returns the expanded text
sub getreference {
  my $str = shift;  
  my $lang = shift;      
  if ($str =~ /\@([a-z0-9 \/\-\:]+)/i) {
    my $key = $1;        
    my @key = split(':', $key);
	if ($dayname[0] =~ /Pasc/i) {$key[0] =~ s/(C[23])/$1p/;}
	$key[1] =~ s/\s*$//;   
    my %v = %{setupstring("$datafolder/$lang/$key[0].txt")}; 
    $str=~ s/\@([a-z0-9 \/\-\:]+)/$v{$key[1]}/i; 
  }
  return $str;
}


#*** days_to_date($days)
# returns the ($sec, $min, $hour, $day, $month-1, $year-1900, $wday, $yday, 0) array from the number of days from 01-01-1970 
sub days_to_date {
  my $days = shift;
  if ($days > 0 && $days  < 24837) {return localtime($days * 60*60*24 + 12*60*60);}
  if ($days < -141427) { error("Date before the Gregorian Calendar!");}

  my @d = splice(@d,@d);
  $d[0] = 0;
  $d[1] = 0;
  $d[2] = 6;
  $d[6] = (($days % 7) + 4) % 7;
  $d[8] = 0;
  
  my $count = 10957;
  my $yc = 20;
  my $add;
 
  $oldcount = $count; 
  $oldyc = $yc; 
  if ($days < $count) {
     while ($days < $count) {$yc--; $add = (($yc % 4) == 0) ? 36525 : 36524; $count -= $add;}
   } else {
     while ($days >= $count) {$oldcount = $count; $oldyc = $yc; $add = (($yc % 4) == 0) ? 36525 : 36524; $count += $add; $yc++;}
     $count = $oldcount; $yc = $oldyc;
  }

   $add = 4 * 365;
   if (($yc % 4) == 0) {$add += 1;}
   $yc *= 100;
   $oldcount = $count;
   $oldyc = $yc;
   while ($count <= $days) {$oldcount = $count; $oldyc = $yc; $count += $add; $add = 4 * 365 + 1; $yc += 4;}
   $count = $oldcount; $yc = $oldyc;
   $add = 366;
   if (($yc % 100) == 0 && ($yc % 400) > 0) {$add = 365;} 
   $oldyc = $yc;
   while ($count <= $days) {$oldadd = $add; $oldyc = $yc; $count += $add; $add = 365; $yc++;}
   $count -= $oldadd; $yc = $oldyc;

   $d[5] = $yc - 1900;
   $d[7] = $days - $count + 1; 
   my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   if (($yc % 4) == 0) {$months[1] = 29;} else {$months[1] = 28;} 
   if (($yc % 100) == 0 && ($yc % 400) > 0) {$months[1] = 28;} 
   $c = 0;
   while ($count <= $days) {$count += $months[$c]; $c++;}  
   $c--; $count -= $months[$c];
   $d[4] = $c;
   $d[3] = $days - $count + 1;
   return @d;
}

#*** date_to_days($day, $month-1, $year)
# returns the number of days from the epoch 01-01-1070
sub date_to_days {
  my ($d, $m, $y) = @_;  
  if ($y > 1970 && $y < 2038) {floor(timelocal(0,0,12,$d,$m,$y) / 60*60*24);}

  my $yc = floor($y / 100);
  my $c =20;
  my $ret = 10957;
  my $add;
  if ($y < 2000) {
    while ($c > $yc) {$c--; $add = (($c % 4) == 0) ? 36525 : 36524; $ret -= $add;}
 } else { 
   while ($c < $yc) {$add = (($c % 4) == 0) ? 36525 : 36524; $ret += $add; $c++;}
 } 
 $add = 4 * 365;
 if (($yc % 4) == 0) {$add += 1;}
 $yc *= 100;

 while ($yc < ($y - ($y % 4))) {$ret += $add; $add = 4 * 365 + 1; $yc += 4;}   
 $add = 366; 
 if (($yc % 100) == 0 && ($yc % 400) > 0) {$add = 365;} 
 while ($yc < $y) {$ret += $add; $add = 365; $yc++;}

 my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
 if (($y % 4) == 0) {$months[1] = 29;} else {$months[1] = 28;}
 if (($y % 100) == 0 && ($y % 400) > 0) {$months[1] = 28;}
 $c = 0;
 while ($c < $m) {$ret += $months[$c]; $c++;}
 $ret += ($d -1); 
 if ($ret < -141427) { error("Date before the Gregorian Calendar!");}
 return $ret
}

#*** date_to_days1($day, $month-1, $year)
# returns the number of days from the epoch 01-01-1070
sub date_to_days1 {
  my ($d, $m, $y) = @_; 
  if ($y > 1970 && $y < 2038) {floor(timelocal(0,0,12,$d,$m,$y) / 60*60*24);}
  
  #my $dt = DateTime->new(year=>$y, month=>$m+1, day=>$d, hour=>6);
  #my $days = $dt->delta_days(DateTime->new(year=>1970, month=>1, day=>1))->in_units('days');
  #if ($dt->year() < 1970) {$days = -$days;}
  return $days;
}

#*** days_to_date1($days)
# returns the ($sec, $min, $hour, $day, $month-1, $year-1900, $wday, $yday, 0) array from the number of days from 01-01-1970 
sub days_to_date1 {
  my $days = shift;
  if ($days > 0 && $days  < 24837) {return localtime($days * 60*60*24 + 12*60*60);}


  #my $dt = DateTime->new(year=>1970, month=>1, day=>1)->add(days=>$days);
  #my @d = ($dt->sec(), $dt->min(), $dt->hour(), $dt->day(), $dt->month()-1,$dt->year()-1900, 
  #  ($dt->wday() % 7), $dt->doy(), 0);
  return @d;
}

#*** nooctnat()
# returns 1 for 1960 not Christmas Octave days
sub nooctnat {
  if ($version =~ /1960/ && ($month < 12 || $day <25)) {return 1;}
  return 0;
}

# substitute i for j (in Latin text)
sub jtoi
{
    my $t = shift;
    # but not in html tags!
    my @parts = split(/(<[^<>]*>)/,$t);
    foreach ( @parts )
    {
        next if /^</;
        s/([aeiou])u([aeiou])/$1v$2/g;
        s/V([bcdfghklmnpqrstvwxyz])/U$1/g;
        s/Qv/Qu/g;
        s/qv/qu/g;
        next if $version !~ /1960/;
        s/j/i/g;
        s/J/I/g;
        s/H\-Iesu/H-Jesu/g;
    }
    $t = join('', @parts);
    return $t;
}
