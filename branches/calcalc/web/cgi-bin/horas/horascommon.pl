#!/usr/bin/perl
use utf8;
# vim: set encoding=utf-8 :

# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti also for missa

#use warnings;
#use strict "refs";
#use strict "subs";

use DivinumOfficium::Scripting qw(dispatch_script_function parse_script_arguments);

my @lines;
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

   if ($n < 23) {return getname(sprintf("Pent%02i", $n));}
   my $wdist = floor(($advent1 - $t + 6) / 7);
   if ($wdist < 2) {return "Pent24";}
   if ($n == 23) {return "Pent23";}
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
    my $str = $sundaytable[$i];
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
sub getsundaytable
{
    @sundaytable = do_read("$datafolder/sundaytable.txt")
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


#*** extract_common($office_desc_ref, $common_field)
# Extracts the type and filename of a common referenced by an
# expression of the form used in rank lines. $common_field is this
# expression, and $office_desc_ref is the descriptor of the corresponding
# office.  Returns respectively the type ('ex' or 'vide') and the filename.
sub extract_common
{
  my ($office_desc_ref, $common_field) = @_;

  # These shadow globals.
  my ($communetype, $commune);

  our ($datafolder, $lang1, $communename, $sanctiname, $temporaname);
  our $version;
  our @dayname;

  if ($common_field =~ /^(ex|vide)\s*(\S.*?)\s*$/i)
  {
    $communetype = $1;
    my $raw_fname = $2;

    $communetype = 'ex' if ($version =~ /Trident/i &&
      ($version !~ /Monastic/i ||
        $office_desc_ref->{cycle} == SANCTORAL_OFFICE));

    my $implicit_dir =
      $raw_fname =~ m'/' ?
        '' :
        $office_desc_ref->{cycle} == SANCTORAL_OFFICE ?
          $sanctiname : $temporaname;

    if ($raw_fname =~ /^C/)
    {
      # Genuine common.
      $commune = $1 if ($common_field =~ /(C[0-9]+[a-z]*)/i);

      my $paschal_fname = "$datafolder/$lang1/$communename/$commune" . 'p.txt';
      $commune .= 'p' if ($dayname[0] =~ /Pasc/i && (-e $paschal_fname));
      
      $commune = "$communename/$commune.txt" if ($commune);
    }
    elsif ($raw_fname =~ /^Sancti\/(.*)$/i)
    {
      $commune = "$sanctiname/$1.txt";
    }
    elsif ($raw_fname =~ /^Tempora\/(.*)$/i)
    {
      $commune = "$temporaname/$1.txt";
    }
    else
    {
      $commune = "${implicit_dir}${raw_fname}.txt";
    }
  }

  return ($communetype, $commune);
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

#*** monthday($forcetomorrow), reading_day($month, $day, $year)
# returns an empty string or mmn-d format 
# e.g. 081-1 for monday after the firs Sunday of August
sub monthday {
  my $forcetomorrow = shift;
  
  our @date1;

  # Use tomorrow's date if the caller requested it or if we're saying first Vespers.
  return reading_day(($forcetomorrow || our $tvesp == 1) ? (nday(@date1[1,0,2]))[1,0,2] : @date1);
}

sub reading_day {
  # $month, $day, $year and $dayofweek shadow globals.
  my ($month, $day, $year) = @_;
  my $date_ordinal = date_to_days($day, $month - 1, $year);
  my $dayofweek = (days_to_date($date_ordinal))[6];
  my $advent = getadvent($year);
  my $m;

  our $version;

  if ($month < 7 || $date_ordinal >= $advent) {return '';} 

  my @ftime;

  for ($m = 8; $m < 13; $m++) { 
    my ($fday, $fmonth);
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

  if ($date_ordinal < $ftime[0]) {return '';}
  for ($m = 9; $m < 13; $m++) {
    if ($date_ordinal < $ftime[$m - 8]) {last;}
  }

  # $m is now *one more* than the current month, which explains the change of
  # offset into @ftime from -8 to -9.
                                 
  my $tdays = $date_ordinal - $ftime[$m - 9];   
  my $weeks = floor($tdays / 7); 

  # Special handling for October with the 1960 rubrics: the III. week vanishes
  # in years when its Sunday would otherwise fall on the 18th-21st (i.e. when
  # the first Sunday in October falls on 4th-7th).
  $weeks++ if ($m == 11 && $version =~ /1960/ && $weeks >= 2 && (days_to_date($ftime[11 - 9]))[3] >= 4);

  # Special handling for November: the II. week vanishes most years (and always
  # with the 1960 rubrics). Achieve this by counting backwards from Advent.
  if ($m == 12 && ($weeks > 0 || $version =~ /1960/)) {
    my $wdist = floor(($advent - $date_ordinal - 1) / 7);    
    $weeks = 4 - $wdist;  
    if ($version =~ /1960/ && $weeks == 1) {$weeks = 0;}
  }

  return sprintf('%02i%01i-%01i', $m - 1, $weeks + 1, $dayofweek);
}

#*** officestring($basedir, $lang, $fname, $flag)
# same as setupstring (in dialogcommon.pl = reads the hash for $fname office)
# with the addition that for the monthly ferias/scriptures (aug-dec)
# it adds that office to the otherwise empty season related one
# if flag is 1 looks for the anticipated office for vespers
# returns the filled hash for the ofiice
sub officestring($$$;$) {
  my ($basedir, $lang, $fname, $flag) = @_;       
  
  my %s;
  if ($fname !~ /tempora[M]*\/(Pent|Epi)/i) {
    %s = updaterank(setupstring($basedir, $lang, $fname));
	if ($version =~ /1960/ && $s{Rank} =~ /Feria.*?(III|IV) Adv/i && $day > 16) {$s{Rank} =~ s/;;2/;;3/;}
	return \%s;
  }
  if ($fname =~ /tempora[M]*\/Pent([0-9]+)/i && $1 < 5) {
    %s = updaterank(setupstring($basedir, $lang, $fname));
	return \%s;
  }
  $monthday = monthday($flag);   #*** was $flag 
  if (!$monthday) {
    %s = updaterank(setupstring($basedir, $lang, $fname));
	return \%s;
  }						   
  %s = %{setupstring($basedir, $lang, $fname)};  
  if (!%s) {return {};}
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
  my %m = %{setupstring($datafolder, $lang, "$temporaname/$monthday.txt")};  

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
  my %w = updaterank(setupstring($datafolder, 'Latin', $winner));
  if ($winner !~ /tempora/i) {return 1;}
  my %c = updaterank(setupstring($datafolder, 'Latin', $c));
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


#*** papal_commem_rule($rule)
#  Determines whether a rule contains a clause for a commemorated Pope.
#  Returns a list ($class, $name), as for papal_rule.
sub papal_commem_rule($)
{
  return papal_rule(shift, (commemoration => 1));
}

#*** papal_rule($rule, %params)
#  Determines whether a rule contains a clause for the office of a
#  Pope. If $params{'commemoration'} is true, a commemorated Pope
#  (only) is checked for; otherwise, only in the office of the day.
#
#  Returns a list ($plural, $class, $name), where $plural is true if
#  the office is of several Popes; $class is 'C', 'M' or 'D' as the
#  Pope is a confessor, doctor or martyr, respectively; and $name is
#  the name(s) of the Pope(s). The empty list is returned if there is
#  no match.
sub papal_rule($%)
{
  my ($rule, %params) = @_;
  my $classchar = $params{'commemoration'} ? 'C' : 'O';
  
  return ($rule =~ /${classchar}Papa(e)?([CMD])=(.*?);/i);
}


#*** papal_prayer($lang, $plural, $class, $name[, $type])
#  Returns the collect, secret or postcommunion from the Common of
#  Supreme Pontiffs, where $lang is the language; $plural, $class and
#  $name are as returned by papal_rule; and $type optionally specifies
#  the key for the template (otherwise, it will be 'Oratio').
sub papal_prayer($$$$;$)
{
  my ($lang, $plural, $class, $name, $type) = @_;
  $type ||= 'Oratio';
  
  # Get the prayer from the common.
  my (%common, $num);
  my $prayer;
  our $missa;
  our ($datafolder, $communename);
  
  if ($missa)
  {
    %common = %{setupstring($datafolder, $lang, "$communename/C4b.txt")};
    $num = $plural && $type eq 'Oratio' ? 91 : '';
  }
  else
  {
    %common = %{setupstring($datafolder, $lang, "$communename/C4.txt")};
    $num = $plural ? 91 : 9;
  }

  $prayer = $common{"$type$num"};
  
  # Fill in the name(s).
  $prayer =~ s/ N\.([a-z ]+N\.)*/ $name/;
  
  # If we're not a martyr, get rid of the bracketed part; if we are,
  # then just get rid of the brackets themselves.
  if ($class !~ /M/i) {$prayer =~ s/\s*\((.|~[\s\n\r]*)*?\)//;}
  else {$prayer =~ tr/()//d;}
  
  return $prayer;
}

#*** papal_antiphon_dum_esset($lang)
#  Returns the Magnificat antiphon "Dum esset" from the Common of
#  Supreme Pontiffs, where $lang is the language.
sub papal_antiphon_dum_esset($)
{
  my $lang = shift;
  our $datafolder, $communename;
  
  my %papalcommon = %{setupstring($datafolder, $lang, "$communename/C4.txt")};
  return $papalcommon{'Ant 3 summi Pontificis'};
}


# Block for conditional-handling routines.
{
  use strict;
  
  my %conditional_values;
  my %stopword_weights;
  my %backscoped_stopwords;
  
  my $stopwords_regex;
  my $scope_regex;
  
  BEGIN
  {
    # Main stopwords. These have implicit backward scope.
    $stopword_weights{'sed'} = $stopword_weights{'vero'} = 1;
    $stopword_weights{'atque'} = 2;
    $stopword_weights{'attamen'} = 3;
    
    %backscoped_stopwords = %stopword_weights;
    
    # Extra stopwords which require explicit backward scoping.
    $stopword_weights{'si'} = 0;
    $stopword_weights{'deinde'} = 1;
    
    my $stopwords_regex_string = join('|', keys(%stopword_weights));
    $stopwords_regex = qr/$stopwords_regex_string/i;
    
    $scope_regex = qr/
      (?:\bloco\s+(?:hu[ij]us\s+versus|horum\s+versuum)\b)?
      \s*
      (?:
        \b
        (?:
            (?:dicitur|dicuntur)(?:\s+semper)?
          |
            (?:hoc\s+versus\s+)?omittitur
          |
            (?:haec\s+versus\s+)?omittuntur
        )
        \b
      )?
      /ix;
  }
  
  # We have four types of scope (in each direction):
  use constant SCOPE_NULL => 0;     # Null scope.
  use constant SCOPE_LINE => 1;     # Single line.
  use constant SCOPE_CHUNK => 2;    # Until the next blank line.
  use constant SCOPE_NEST => 3;     # Until a (weakly) stronger conditional.
    
  
  #*** evaluate_conditional($conditional)
  #  Evaluates a expression from a data-file conditional directive.
  sub evaluate_conditional($)
  {
    my $conditional = shift;
    my $expression = '';
    
    # Pick out tokens.
    while ($conditional =~ /([a-z_\d]+|[><!\(\)]+|==|>=|<=|!=|&&|\|\||\s*)/gi)
    {
      # Look up identifiers in the hash.
      my $token = $1;
      $expression .= ($token =~ /[a-z_]/) ? "$conditional_values{$token}" : $token;
    }
    
    return eval $expression;
  }
  
  #*** conditional_regex()
  #  Returns a regex that matches conditionals, capturing stopwords,
  #  the condition itself and scope keywords, in that order.
  sub conditional_regex()
  {
    return qr/\(\s*($stopwords_regex\b)*(.*?)($scope_regex)?\s*\)/o;
  }
  
  sub parse_conditional($$$)
  {
    my ($stopwords, $condition, $scope) = @_;
    my ($strength, $result, $backscope, $forwardscope);
    
    $strength = 0;
    $strength += $stopword_weights{$_} foreach (split /\s+/, lc($stopwords));
    
    $result = vero($condition);
    
    # The regexes we use to test here are considerably more general
    # than is allowed by the specification, but we're working on the
    # assumption that the input was first matched against the regex
    # returned by &conditional_regex, which is rather stricter.
    
    # Do we have a stopword that gives us implicit backscope?
    my $implicit_backscope = 0;
    $implicit_backscope ||= exists ($backscoped_stopwords{$_}) foreach (split /\s+/, lc($stopwords));
    
    $backscope = 
      $scope =~ /versuum|omittuntur/i             ? SCOPE_NEST  :
      $scope =~ /versus|omittitur/i               ? SCOPE_CHUNK :
      $scope !~ /semper/i && $implicit_backscope  ? SCOPE_LINE  : SCOPE_NULL;

    if ($scope =~ /omittitur|omittuntur/i)
    {
      $forwardscope = SCOPE_NULL;
    }
    elsif ($scope =~ /dicuntur/i)
    {
      $forwardscope = ($backscope == SCOPE_CHUNK) ? SCOPE_CHUNK : SCOPE_NEST;
    }
    else
    {
      $forwardscope = ($backscope == SCOPE_CHUNK || $backscope == SCOPE_NEST) ? SCOPE_CHUNK : SCOPE_LINE;
    }
    
    return ($strength, $result, $backscope, $forwardscope);
  }
}

#*** build_comment_line()
#  Sets $comment to the HTML for the comment line.
sub build_comment_line()
{
  our @dayname;
  our ($comment, $marian_commem);
  
  my $commentcolor = ($dayname[2] =~ /(Feria)/i) ? 'black' : ($marian_commem && $dayname[2] =~ /^Commem/) ? 'blue' : 'maroon';
  $comment = ($dayname[2]) ? "<SPAN STYLE=\"font-size:82%; color:$commentcolor;\"><I>$dayname[2]</I></SPAN>" : "";
}

#*** cache_prayers()
#  Loads Prayers.txt for each language into global hash.
sub cache_prayers()
{
  our %prayers;
  our ($lang1, $lang2);
  our $datafolder;
  my $dir = our $missa ? 'Ordo' : 'Psalterium';
  $prayers{$lang1} = setupstring($datafolder, $lang1, "$dir/Prayers.txt");
  $prayers{$lang2} = setupstring($datafolder, $lang2, "$dir/Prayers.txt");
}



#*** sub expand($line, $lang, $antline)
# for & references calls the sub
# $ references are filled from Psalterium/Prayers file
# antline to handle redding the beginning of psalm is same as antiphona
# returns the expanded text or the link
sub expand
{
  use strict;

  my ($line, $lang, $antline) = @_;

  $line =~ s/^\s+//;
  $line =~ s/\s+$//;

  # Extract and remove the sigil indicating the required expansion type.
  # TODO: Fail more drastically when the sigil is invalid.
  $line =~ s/^([&\$])// or return $line;
  my $sigil = $1;

  our ($expand, $missa);
  local $expand = $missa ? 'all' : $expand;

  #returns the link or text for & references
  if ($sigil eq '&')
  {  
    # Make popup link if we shouldn't expand.
    if (
      $expand =~ /nothing/i ||
      ($expand !~ /all/i && ($line =~ /^(?:[A-Z]|pater_noster)/))
    )
    {
      return setlink($sigil . $line, 0, $lang);
    }

    # Actual expansion for & references.

    # Get function name and any parameters.
    my ($function_name, $arg_string) = ($line =~ /(.*?)(?:[(](.*)[)])?$/);
    my @args = (parse_script_arguments($arg_string), $lang);

    # If we have an antiphon, pass it on to the script function.
    if ($antline)
    {
        $antline =~ s/^\s*Ant\. //i;
        push @args, $antline;
    }

    return dispatch_script_function($function_name, @args);
  }
  else  # Sigil is $, so simply look up the prayer.
  {
    if ($expand =~ /all/i)
    {
      #actual expansion for $ references
      our %prayers;
      return $prayers{$lang}->{$line};
    }
    else
    {
      return setlink($sigil . $line, 0, $lang);
    }
  }
}

1;

