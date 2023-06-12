#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti also for missa
# use warnings;
# use strict;
use FindBin qw($Bin);
use lib "$Bin/..";
use horas::Scripting qw(dispatch_script_function parse_script_arguments);
use DivinumOfficium::Date qw(getweek leapyear geteaster get_sday nextday day_of_week monthday);
use DivinumOfficium::Directorium qw(get_kalendar get_transfer get_tempora transfered);

sub error {
	my $t = shift;
	our $error .= "= $t =<br>";
}

#*** checkfile($lang, $filename)
# substitutes English if no $lang item, Latin if no English
# if $lang contains dash, the part before the last dash is taken as a fallback recursively (till something exists)
sub checkfile {
	my $lang = shift;
	my $file = shift;
	our $datafolder;
	
	if (-e "$datafolder/$lang/$file") {
		return "$datafolder/$lang/$file";
	} elsif ($lang =~ /-/) {
		my $temp = $lang;
		$temp =~ s/-[^-]+$//;
		return checkfile($temp, $file);
	} elsif ($lang =~ /english/i) {
		return "$datafolder/Latin/$file";
	} elsif (-e "$datafolder/English/$file") {
		return "$datafolder/English/$file";
	} else {
		return "$datafolder/Latin/$file";
	}
}

#*** getrank() loads files from tempora and sancti
sub getrank {
	my($day, $month, $year, $version) = @_;
	
	# globals readonly
	our($testmode, $hora, $missa, $caller, $datafolder, $lang2);
	
	# globals set/mod here
	our($winner, $rank, $commemoratio, $comrank, $commemoratio1, $commune, $communetype);
	our($initia, $hymncontract, $scriptura, $laudesonly, $commemorated, $seasonalflag);
	our($antecapitulum, $antecapitulum2, $transfervigil) = ('') x 3;
	our($vespera, $cvespera, $tvesp, $svesp, $dayofweek);
	our($C10, $marian_commem);
	our(%winner);
	our(@dayname);
	
	my %tempora;
	my %tn1;
	my %saint;
	my $trank = '';
	my $tname = '';
	my $srank = '';
	my $sname = '';
	my $cname = '';
	my @trank = ();
	my @srank = ();
	
	# Search for relevant Sanctoral office of the day (if any)
	my $sday = get_sday($month, $day, $year); # get office string mm-dd for Sanctoral office
	my $transfertemp = get_tempora($version, $sday); # look for permanent Transfers assigned to the day of the year (as of 2023-5-22 only 12-12n in Newcal version)
	if ($transfertemp && $transfertemp !~ /tempora/i) { $transfertemp = subdirname('Sancti', $version) . "$transfertemp"; }	# add path to Sancti folder if necessary
	my $transfer = get_transfer($year, $version, $sday);				# get annual transfers if applicable depending on the day of Easter
	$hymncontract = get_transfer($year, $version, "Hy$sday");		# check if Hymns need to be contracted on this day
	
	# handle the case of a transferred vigil which does not have its file "mm-ddv"
	if ($transfer =~ /v$/ && !(-e "$datafolder/Latin/" . subdirname('Sancti', $version) . "$transfer.txt")) {
		$transfervigil = $transfer;
		$transfervigil =~ s/v$//;
		$transfer = '';
	}
	
	if ($transfer) {
		if ($transfer !~ /tempora/i) {
			$transfer = subdirname('Sancti', $version) . "$transfer"; }	# add path to Sancti folder if necessary
		elsif ($version =~ /monastic/i) {
			$transfer =~ s/TemporaM?/TemporaM/; 	# modify path to Monastic Tempora folder if necessary
		}
	}
	
	# to begin with, assume 2nd vespers for Winner, Sanctoral and Temporal and no concurrent Sanctoral office
	$vespera = 3;
	$svesp = 3;
	$tvesp = 3;
	$cvespera = 0;
	$dayofweek = day_of_week($day, $month, $year);	# 0 = Sunday, 1 = Mpnday, etc.
	my $tn = '';
	
	if ($dayname[0]) {			# outside Nativity tide where we do not have any Temporal
		$tn = subdirname('Tempora', $version) . "$dayname[0]-$dayofweek";
		my $t = get_tempora($version, $tn);		# look for permanent Transfers assigned to the Temporal, most prominently the Ferias in the Octaves of S. Joseph, Corpus Christi, Ssmi Cordis
		$tn = $t || $tn;
	}
	if ($transfertemp && $transfertemp =~ /tempora/i) { $tn = $transfertemp; }	# in case a Temporal office has been transfered by means of assigning it to a specific day of the year
	if ($transfer =~ /tempora/i) { $tn = $transfer; }	# also if in that specific year depending on the day of Easter
	my $tn1 = '';
	my $tn1rank = '';
	my $nday = nextday($month, $day, $year);
	
	#if ($hora =~ /(vespera|Completorium)/i) {
	#  if ($transfer{$nday} =~ /tempora/i) {$tn1 = $transfer{$nday};}
	#}
	if ($testmode =~ /(Saint|Common)/i) { $tn = 'none'; }
	
	#Vespera anticipation  concurrence
	my $tnday = get_transfer($year, $version, $nday);
	if (-e "$datafolder/Latin/$tn.txt" || $dayname[0] =~ /Epi0/i || ($tnday && $tnday =~ /tempora/i)) {
		
		if ($hora =~ /(vespera|completorium)/i && $testmode !~ /(Saint|Common)/i) {	# retrieve potential Temporal office with 1st Vespers
			my $weekname = getweek($day, $month, $year, 1);
			$tn1 = sprintf("%s%s-%d", subdirname('Tempora', $version), $weekname, ($dayofweek + 1) % 7);
			
			if (my $t = get_tempora($version, $tn1)) {
				$tn1 = $t;
			} elsif ($t = get_transfer($year, $version, $tn1)) {
				$tn1 = $t;
			} elsif ($tnday && $tnday =~ subdirname('Tempora', $version)) {
				$tn1 = $tnday;
			}
			
			#$tvesp = 1;
			%tn1 = %{officestring('Latin', "$tn1.txt", 1)};
			# Sort out all cases where there cannot be any 1st Vespers of a Temporal office
			if ($tn1{Rank} =~ /(Feria|Vigilia|infra octavam|Quat[t]*uor)/i && $tn1{Rank} !~ /in octava/i && $tn1{Rank} !~ /Dominica/i) {$tn1rank = '';}
			if ($tn1{Rank} =~ /(Feria|Sabbato|infra octavam)/i && $tn1{Rank} !~ /in octava/i && $tn1{Rank} !~ /Dominica/i) { $tn1rank = ''; }
			elsif ($dayname[0] =~ /Pasc[07]/i && $dayofweek != 6) { $tn1rank = ''; }
			elsif ($version =~ /1955|1960/ && $tn1{Rank} =~ /Dominica Resurrectionis/i) { $tn1rank = ''; }
			elsif ($version =~ /(1955|1960|Newcal)/ && $tn1{Rank} =~ /Patrocinii S. Joseph/i) { $tn1rank = ''; }
			else { $tn1rank = $tn1{Rank}; }
			
			#if ($version =~ /1960/ && $tn =~ /Nat1/i && $day =~ /(25|26|27|28)/) {$tn = '';}
		}
		
		if ($tn) {
			$tname = "$tn.txt";
			$tvesp = 3;
			%tempora = %{officestring('Latin', $tname)};
			$trank = $tempora{Rank};
			
			if ($hora =~ /(Vespera|Completorium)/i && $tempora{Rule} =~ /No secunda Vespera/i && $version !~ /1960|Monastic/i) {
				$trank = '';
				%tempora = undef;
				$tname = '';
			}
		}
	} else { #if there is no Temporal file and we're not in Epiphany tide and there is no transfered temporal for the following day by day of Easter
		$trank = '';
		$tname = '';
	}
	if (transfered($tname, $year, $version)) { $trank = ''; }			### this seems to come way too late in the algorithm and should never be evaluated as true ???
	
	#if (transfered($tn1)) {$tn1 = '';}     #???????????
	if ($hora =~ /Vespera/i && $dayname[0] =~ /Quadp3/ && $dayofweek == 3 && $version !~ /1960|1955/) {
		# before 1955, Ash Wednesday gave way at 2nd Vespers in concurrence to a Duplex
		$trank =~ s/;;6/;;2/;
	}
	elsif ($hora =~ /Vespera/i && $dayname[0] =~ /(Quad[0-5]|Quadp)/ && $dayofweek == 0 && $version =~ /1570|1910/) {
		# before Divino Afflatu, the Sundays from Septuag to Judica gave way at 2nd Vespers in concurrence to a Duplex
		$trank =~ s/;;5.6/;;2/;
	}
	@trank = split(";;", $trank);
	my @tn1 = split(';;', $tn1rank);
	
	# sort out Concurrence in the Temporal
	if ($tn1[2] >= $trank[2]) {
		# if the following day is of higher rank than the current day, we have 1st Vespers of the following day and discard today's temporal completely
		$tname = "$tn1.txt";
		%tempora = %tn1;
		$trank = $tempora{Rank};
		# Rubrics 1960: the Sunday within the Octave of the Nativity does not beat the Comites in concurrence at 1st Vespers:
		if ($version =~ /1960/ && $tn1 =~ /Nat1/i && $day =~ /(25|26|27|28)/) { $trank =~ s/;;5/;;4/; }
		@trank = split(";;", $trank);
		$dayname[0] = getweek($day, $month, $year, 1, $missa);
		$tvesp = 1;
	} elsif (!$trank) {
		$tname = '';
		%tempora = {};
	}
	$initia = ($tempora{Lectio1} =~ /!.*? 1\:1\-/) ? $initia = 1 : 0;
	
	#handle sancti
	my $sn = subdirname('Sancti', $version) . get_kalendar($version, $sday);	# get the filename for the Sanctoral office from the Kalendarium
	
	# prevent duplicate vigil of St. Mathias in leap years
	$sn = '' if $sn =~ /02-23o/ && $day == 23 && leapyear($year) && day_of_week(25, $month, $year);
	
	if ($transfertemp =~ /Sancti/) {
		$sn = $transfertemp;
	} elsif ($transfer =~ /Sancti/) {
		$sn = $transfer;
	} elsif (transfered($sn, $year, $version)) {
		$sn = '';
	}
	# the variable $snd seems to be completely superflous as of 2023-5-22:
	# my $snd = $sn;
	# if (!$snd || $snd !~ /([0-9]+\-[0-9]+)/) { $snd = $sday; }
	# $snd = ($snd =~ /([0-9]+\-[0-9]+)/) ? $1 : '';
	if ($testmode =~ /^Season$/i) { $sn = 'none'; }
	
	if (-e "$datafolder/Latin/$sn.txt") {
		$sname = "$sn.txt";
		if ($caller && $hora =~ /(Matutinum|Laudes)/i) { $sname =~ s/11-02t/11-02/; }
		%saint = updaterank(setupstring('Latin', $sname));
		$srank = $saint{Rank};
		
		if ($hora =~ /(Vespera|Completorium)/i && $saint{Rule} =~ /No secunda Vespera/i && $version !~ /1960/) {
			$srank = '';
			%saint = undef;
			$sname = '';
		}
	} else {
		$srank = '';
	}
	
	if ($version =~ /(1955|1960|Newcal)/) {
		if ($srank =~ /vigil/i && $sday !~ /(06\-23|06\-28|08\-09|08\-14|12\-24)/) { $srank = ''; }
		if ($srank =~ /(infra octavam|in octava)/i && nooctnat()) { $srank = ''; }
	}    #else {if ($srank =~ /Simplex/i) {$srank = '';}}
	@srank = split(";;", $srank);
	
	if ($srank[2] < 2 && $hora =~ /(vespera|completorium)/i && $trank && !($month == 1 && $day > 6 && $day < 13)) {
		$srank = '';
		@srank = undef;
	}
	if ($trank[2] == 7 && $srank[2] < 6) { $srank = ''; @srank = undef; }
	if ($version =~ /(1955|1960|Monastic)/i && $trank[2] >= 6 && $srank[2] < 6) { $srank = ''; @srank = undef; }
	
	if ($version =~ /1955/ && $srank[2] == 2 && $srank[1] =~ /Semiduplex/i) {
		$srank[2] = 1.5;	#1955: semiduplex reduced to simplex
	}
	
	if ( $version =~ /1960|Monastic/i
		&& $srank[2] < 2
		&& $srank[1] =~ /Simplex/i
		&& $testmode =~ /seasonal/i
		&& ($month > 1 || $day > 13))
	{
		$srank[2] = 1;
	}
	
	#if ( transfered($sday) && $srank !~ /Christi Regis/i) {$srank[2] = 0;}
	#check for concurrence
	my $cday = '';
	my @crank = ();
	my %csaint = ();
	my $crank = '';
	my $vflag = 0;
	$cday = $nday;
	my $tcday = $tnday;		# the transfered office-file from the next day given the annual transfer tables depending on the date of Easter
	if ($tcday !~ /tempora/i && transfered($cday, $year, $version)) { $cday = 'none'; }
	if ($tcday && $tcday !~ /Tempora/i) { $cday = $tcday; }
	if ($tname =~ /Nat/ && $cday =~ /Nat/) { $cday = 'none'; }
	my $BMVSabbato = ($cday =~ /v/) ? 0 : 1;
	if ($hora =~ /(vespera|completorium)/i) {
		#if ($cday !~ /(tempora|DU)/i ) { $cday = get_kalendar($version, $cday); } # here it breaks if the transferred string is not known in the calendar (e.g. mm-dd-anticip...)
		if ($cday !~ /(tempora|DU)/i && !$tcday || $tcday =~ /tempora/i) { $cday = get_kalendar($version, $cday); } # potential solution
		# same weird code as with $sday which has not been used anywhere else
		#my $cdayd = $cday;
		#if (!$cdayd || $cdayd !~ /([0-9]+\-[0-9]+)/) { $cdayd = nextday($month, $day, $year); }
		#$cdayd = ($cdayd =~ /([0-9]+\-[0-9]+)/) ? $1 : '';
		
		if ($cday && $cday !~ /tempora/i) { $cday = subdirname('Sancti', $version) . "$cday"; }
		if ($testmode =~ /^Season$/i) { $cday = 'none'; }
		
		if (-e "$datafolder/Latin/$cday.txt") {
			$cname = "$cday.txt";
			%csaint = updaterank(setupstring('Latin', "$cname"));
			@crank = split(";;", $csaint{Rank});
			$BMVSabbato = $csaint{Rank} !~ /Vigilia/ && $crank[2] < 2;
			$crank = ($csaint{Rank} =~ /vigilia/i && $csaint{Rank} !~ /(;;[56]|Epi)/i) ? '' : $csaint{Rank};
			if ($crank =~ /(Feria|Vigilia)/i && $csaint{Rank} !~ /in Vigilia Epi/i) { $crank = ''; }
		}
		@crank = split(";;", $crank);
		
		if ($version =~ /(1955|1960|Newcal)/) {
			if ($crank =~ /vigil/i && $sday !~ /(06\-23|06\-28|08\-09|08\-14|08\-24)/) { $crank = ''; }
			if ($crank =~ /octav/i && $crank !~ /cum Octav/i && $crank[2] < 6) { $crank = ''; }
		}
		if ($csaint{Rule} =~ /No prima vespera/i) { $crank = ''; $cname = ''; }
		if ($tname =~ /Tempora\/Quad6\-3/i) { $crank = ''; $cname = ''; }
		
		@crank = split(";;", $crank);
		
		if ($version !~ /1960|Newcal/ && $srank && $crank && ($tname =~ /Quadp3\-3/i || $tname =~ /Quad6\-[1-3]/i)) {
			$srank[2] = 1;
		}
		if ($version !~ /1960|Newcal/ && $crank && ($tname =~ /Quadp3\-2/i || $tname =~ /Quad6\-[1-3]/i)) { $crank[2] = 1; }
		
		if ($crank =~ /infra octav/i && $srank =~ /infra octav/i) { #infra octav concurrent with infra octav = crank deleted
			$crank = '';
			$cname = '';
			@crank = undef;
		}    #exception for nov 2
		if ($srank =~ /vigilia/i && ($version !~ /(1960|Newcal)/ || $sname !~ /08\-09/)) { $srank[2] = 0; $srank = ''; }
		
		# Restrict I. Vespers in 1955/1960. In particular, in 1960, II. cl.
		# feasts have I. Vespers if and only if they're feasts of the Lord.
		if ( ($version =~ /1955/ && $crank[2] < 5)
			|| ($version =~ /1960|Newcal|Monastic/i && $crank[2] < (($csaint{Rule} =~ /Festum Domini/i && $dayofweek == 6) ? 5 : 6)))
		{
			$crank = '';
			@crank = ();
		}
		if ($trank[2] >= (($version =~ /(1955|1960|Newcal)/) ? 6 : 7) && $crank[2] < 6) { $crank = ''; @crank = undef; }
		
		if ($version !~ /1960|Trident/ && $hora =~ /Completorium/i && $month == 11 && $day == 1 && $dayofweek != 6) {
			$crank[2] = 7;
			$crank =~ s/;;[0-9]/;;7/;
			$srank = '';
		} elsif (($version !~ /1960|Newcal|Monastic/ || $dayofweek == 6)
		&& $hora =~ /(Vespera|Completorium)/i
		&& $month == 11
		&& $srank =~ /Omnium Fidelium defunctorum/i
		&& !$caller)
		{
			# Office of All Souls' day ends after None.
			$srank[2] = 1;
			$srank = '';
		} elsif ($version =~ /1960/ && $hora =~ /(Vespera|Completorium)/i && $month == 11 && $day == 1) {
			$crank[2] = 1;
			$crank = '';
		}
		our $anterule = ''; # TODO: check this as it only here set
		
		if ($crank[2] >= $srank[2]) {
			if ($hora =~ /Vespera/i && $srank[2] == $crank[2] && $crank[2] >= 2) {
				$antecapitulum =
				(exists($saint{'Ant Vespera 3'})) ? $saint{'Ant Vespera 3'}
				: (exists($saint{'Ant Vespera'})) ? $saint{'Ant Vespera'}
				: '';
				
				if ($antecapitulum) {
					my %saint2 = %{setupstring($lang2, $sname)};
					$antecapitulum2 =
					(exists($saint2{'Ant Vespera 3'})) ? $saint2{'Ant Vespera 3'}
					: (exists($saint2{'Ant Vespera'})) ? $saint2{'Ant Vespera'}
					: '';
				}
			}
			($cname, $sname) = ($sname, $cname);
			($crank, $srank) = ($srank, $crank);
			$svesp = 1;
			
			#switched
			my %tempsaint = %saint;
			%saint = %csaint;
			%csaint = %tempsaint;
			@srank = split(";;", $srank);
			$srank[2] = 1 if ($version =~ /trident|divino/i && $tname =~ /Quadp3\-2/i);
			@crank = split(";;", $crank);
			$vflag = 1;
			
			if ((($srank[2] >= 6 && $crank[2] < 5) || ($srank[2] >= 5 && $crank[2] < 3))
				&& $crank[0] !~ /Octav.*?(Epiph|Nativ|Corporis|Cordis|Ascensionis)/i)
			{
				$crank = '';
				$cname = '';
				@crank = '';
				%csaint = undef;
			} elsif ($srank[2] >= 5 && $crank =~ /infra octav/i) {
				$crank = '';
				$cname = '';
				%csaint = undef;
				@crank = '';
			}
		}
		
		if ($tvesp == 1 && $version =~ /(1955|1960|Newcal)/) {
			if ((($trank[2] >= 6 && $srank[2] < 5) || ($trank[2] >= 5 && $srank[2] < 3))
				&& $srank[0] !~ /Octav.*?(Epiph|Nativ|Corporis|Cordis|Ascensionis)/i)
			{
				$srank = '';
				$sname = '';
				@srank = '';
				%saint = undef;
			} elsif ($trank[2] >= 5 && $srank =~ /infra octav/i && $srank[0] !~ /Epiph/) {
				$srank = '';
				$sname = '';
				%saint = undef;
				@srank = '';
			}
		}
	}
	
	#Newcal optional
	#  if (
	#       $version =~ /newcal/i
	#   && $testmode =~ /seasonal/i
	#   && ($srank[2] < 3
	#      || ($dayname[0] =~ /Quad[1-6]/i && $srank[2] < 5))
	#    )
	#  {
	#    $srank = $sname = $crank = $cname = '';
	#    %saint = %csaint = undef;
	#    @srank = @crank = '';
	#  }
	#  $commemoratio = $commemoratio1 = $communetype = $commune = $commemorated = $dayname[2] = $scriptura = '';
	#  $comrank = 0;
	if ($version =~ /Trid/i && $trank[2] < 5.1 && $trank[0] =~ /Dominica/i) { $trank[2] = 2.9; }
	
	if ($version =~ /1960/ && $dayofweek == 0) {
		if (($trank[2] >= 6 && $srank[2] < 6) || ($trank[2] >= 5 && $srank[2] < 5)) { $srank = ''; @srank = undef; }
	}
	
	#if ($svesp == 3 && $srank[2] >= 5 && $dayofweek == 6) {$srank[2] += 5;}  ?????????
	
	# In Festo Sanctae Mariae Sabbato according to the rubrics.
	if ( $dayname[0] !~ /(Adv|Quad[0-6])/i
		&& $dayname[0] !~ /Quadp3/i
		&& $testmode !~ /^season$/i)
	{
		if ($dayofweek == 6 && $srank !~ /(Vigil|in Octav)/i && $trank[2] < 2 && $srank[2] < 2 && !$transfervigil) {
			$tempora{Rank} = $trank = "Sanctae Mariae Sabbato;;Feria;;2;;vide $C10";
			$scriptura = $tname;
			if ($scriptura =~ /^\.txt/i) { $scriptura = $sname; }
			$tname = subdirname('Commune', $version) . "$C10.txt";
			@trank = split(";;", $trank);
		}
		
		if ( $hora =~ /(Vespera|Completorium)/i
			&& $dayofweek == 5
			&& $crank !~ /;;[2-7]/
		&& $srank !~ /;;[5-7]/
		&& $BMVSabbato == 1
		&& $version !~ /(1960|Newcal)/
		&& $saint{Rule} !~ /BMV/i
		&& $trank !~ /;;[2-7]/
		&& $srank !~ /in Octav/i)
		{
			$tempora{Rank} = $trank = "Sanctae Mariae Sabbato;;Feria;;1.9;;vide $C10";
			$tname = subdirname('Commune', $version) . "$C10.txt";
			@trank = split(";;", $trank);
		}
	}
	if ($trank[2] == 2 && $trank[0] =~ /infra octav/i) { $srank[2] += .1; }
	if ($testmode =~ /seasonal/i && $version =~ /1960|Newcal/ && $srank[2] < 5 && $dayname[0] =~ /Adv/i) { $srank[2] = 1; }
	
	# Flag to indicate whether office is sanctoral or temporal. Assume the
	# latter unless we find otherwise.
	my $sanctoraloffice = 0;
	
	# Sort out occurrence and concurrence between the sanctoral and
	# temporal cycles.
	# Dispose of some cases in which the office can't be sanctoral:
	# if we have no sanctoral office, or it was reduced to a
	# commemoration by Cum nostra.
	if (!$srank[2] || ($version =~ /(1955|1960|Monastic|Newcal)/i && $srank[2] <= 1.1)) {
		
		# Office is temporal; flag is correct.
	}
	
	# Simple feasts give way to the office of our Lady on a Saturday.
	elsif (($dayofweek == 6 || ($dayofweek == 5 && $hora =~ /(Vespera|Completorium)/i))
	&& $trank[2]
	&& $srank[2] < 2
	&& $srank !~ /Vigil/i)
	{
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
			
			# RG 15: As an exception to the general rule, the Immaculate Conception
			# is preferred to the Second Sunday of Advent in occurrence (but not in
			# concurrence).
			elsif ($srank[0] =~ /Conceptione Immaculata/ && $svesp == 3) {
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
		%winner = updaterank(setupstring('Latin', $winner));
		$vespera = $svesp;
		
		if (my ($new_ct, $new_c) = extract_common($srank[3], $rank, $version, $dayname[0] =~ /Pasc/)) {
			($communetype, $commune) = ($new_ct, $new_c);
		}
		
		if ($srank[3] =~ /^(ex|vide)\s*(C[0-9]+[a-z]*)/i) {
			my $c = getdialog('communes');
			$c =~ s/\n//sg;
			my %communesname = split(',', $c);
			$dayname[1] .= " $communetype $communesname{$commune} [$commune]";
		}
		if ($hora =~ /vespera/i && $trank[2] =~ /Feria/i) { $trank = ''; @trank = undef; }
		
		#if ($version =~ /1960/ && $srank[2] >= 6 && $trank[2] < 6) {$tname = $trank = ''; @trank = undef;}
		# Is the commemoration Marian?
		$marian_commem = 0;
		
		if (transfered($tname, $year, $version)) {    #&& !$vflag)
			if ($hora !~ /Vespera|Completorium/i) { $dayname[2] = "Transfer $trank[0]"; }
			$commemoratio = '';
		} elsif ($version =~ /1960|Newcal|Monastic/i && $winner{Rule} =~ /Festum Domini/i && $trank =~ /Dominica/i) {
			$trank = '';
			@trank = undef;
			
			if ($crank[2] >= 6) {
				$dayname[2] = "Commemoratio: $crank[0]";
				$commemoratio = $cname;
				$marian_commem = ($crank[3] =~ /C1[0-9]/);
			}
		} elsif ($winner =~ /sancti/i && $trank[2] && $trank[2] > 1 && $trank[2] >= $crank[2] && $rank < 7
		&& !($version =~ /divino/i && $winner =~ /07-01/ && $tname =~ /Pent03-5/) # github #2950
		) {
			if ($hora !~ /Completorium/i && $trank[0] && $winner{Rule} !~ /no commemoratio/i) {
				$dayname[2] = "Commemoratio: $trank[0]";
			}
			$commemoratio = $tname;
			
			if ($cname && $version !~ /1960|Newcal|Monastic/) {
				{ $commemoratio1 = $cname; }    #{$commemoratio = $cname; $commemoratio1 = $tname;}
			}
			$comrank = $trank[2];
			$cvespera = $tvesp;
			$marian_commem = ($trank[3] =~ /C1[0-9]/);
		} elsif ($crank[2] && ($srank[2] <= 5 || $crank[2] >= 2)) {
			if ($hora !~ /Completorium/i && $crank[0] && $winner{Rule} !~ /no commemoratio/i) {
				$dayname[2] = "Commemoratio: $crank[0]";
			}
			$commemoratio1 = ($trank[2] > 1) ? $tname : '';
			$commemoratio = $cname;
			$comrank = $crank[2];
			$cvespera = 4 - $svesp;
			$marian_commem = ($crank[3] =~ /C1[0-9]/);
		} elsif ($crank[2] < 6) {
			$dayname[2] = '';
			$commemoratio = '';
		}
		
		if (!$dayname[2] && ($winner{'Commemoratio 2'} || $winner{'Commemoratio'})) {
			($_) = split(/\n/, $winner{'Commemoratio 2'} || $winner{'Commemoratio'});
			$dayname[2] = "Commemoratio: $_" if (s/^!Commemoratio //);
		}
		
		if (($hora =~ /matutinum/i || (!$dayname[2] && $hora !~ /Vespera|Completorium/i)) && $rank < 7 && $trank[0]) {
			my %scrip = %{officestring('Latin', $tname)};
			
			if (!exists($winner{"Lectio1"})
			&& exists($scrip{Lectio1})
			&& $scrip{Lectio1} !~ /evangelii/i
			&& ($winner{Rank} !~ /\;\;ex / || ($version =~ /trident/i && $winner{Rank} !~ /\;\;(vide|ex) /i)))
			{
				$dayname[2] = "Scriptura: $trank[0]";
			} else {
				$dayname[2] = "Tempora: $trank[0]";
			}
			$scriptura = $tname;
		}
	} else {    #winner is de tempora
		if (
			$version !~ /Monastic/i
			&& $dayname[0] !~ /(Adv|Quad[0-6])/i
			&& $srank[2] < 2
			&& $trank[2] < 2
			&& $testmode !~ /^season$/i
			&& (
			($dayofweek == 6 && $srank !~ /Vigil/i && $trank[2] < 2 && !$transfervigil)
			|| ( $hora =~ /Vespera|Completorium/i
			&& $dayofweek == 5
			&& $trank[2] < 2
			&& $srank[0] !~ /Vigil/i
			&& $BMVSabbato == 1
			&& $version !~ /(1960|Newcal)/)
			)
			)
		{
			$tempora{Rank} = $trank = "Sanctae Mariae Sabbato;;Feria;;2;;vide $C10";
			$scriptura = $tname;
			$tname = subdirname('Commune', $version) . "$C10.txt";
			@trank = split(";;", $trank);
		}
		
		if ($hora !~ /Vespera/i && $rank < 1.5 && $transfervigil) {
			my $t = "Sancti/$transfervigil.txt";
			my %w = setupstring('Latin', $t);
			
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
			if ($name =~ /^C[0-9]/i) { $name = subdirname('Commune', $version) . "$name"; }
			if ($name !~ /(Sancti|Commune|Tempora)/i) { $name = subdirname('Tempora', $version) . "$name"; }
			$commune = "$name.txt";
			if ($version =~ /trident/i && $version !~ /monastic/i) { $communetype = 'ex'; }
		}
		if ($version =~ /1960/ && $vespera == 1 && $rank >= 6 && $comrank < 5) { $commemoratio = ''; $srank[2] = 0; }
		
		if (transfered($vflag ? $nday : $sday, $year, $version) && $crank !~ /$srank/) {
			$dayname[2] = "Transfer $srank[0]";
			$commemoratio = '';
		} elsif ($srank[2]) {
			my %w = %{officestring('Latin', $winner)};
			my $climit1960 = climit1960($sname);
			
			if (
				$w{Rule} !~ /omit.*? commemoratio/i
			&& $climit1960
			&& ($w{Rule} !~ /No commemoratio/i
			|| ($svesp == 1 && $hora =~ /vespera/i))
			&& $sname !~ /12-20o/
			)
			{
				$laudesonly = ($missa) ? '' : ($climit1960 > 1) ? ' ad Laudes tantum' : '';
				
				#(nomatinscomm(\%w)) ? ' Laudes, Vesperas' : '';
				if ($srank[0] =~ /vigil/i && $srank[0] !~ /Epiph/i) {
					$laudesonly = ($dayname[0] =~ /(Adv|Quad[0-6])/i) ? ' ad Missam tantum' : ' ad Laudes tantum';
				}
				
				# Don't say "Commemoratio in Commemoratione"
				my $comm = $srank[0] =~ /^In Commemoratione/ ? '' : 'Commemoratio';
				
				if ($srank[0]) {
					$dayname[2] = "$comm$laudesonly: $srank[0]";
					$marian_commem = ($srank[3] =~ /C1[0-9]/);
				}
				if ($version =~ /(monastic|1960)/i && $dayname[2] =~ /Januarii/i) { $dayname[2] = ''; }
				
				if (($climit1960 > 1 && ($hora =~ /laudes/i || $missa)) || $climit1960 < 2) {
					$commemoratio = $sname;
					$cvespera = $svesp;
					$comrank = $srank[2];
					
					if (($version !~ /1960/ && $crank[2]) || ($crank[2] >= 3 || ($trank[2] == 5 && $crank[2] >= 2))) {
						$commemoratio1 = $cname;
					}
					if ($winner =~ /Epi1-0a/ && ($hora =~ /laudes/i || $vespera == 3 )) { $commemoratio = 'Sancti/01-06.txt' }
				}
			} else {
				$dayname[2] = '';
				$commemoratio = '';
			}
		}
		
		if (!$commemoratio && !$commemoratio1 && $sname) {
			$sname =~ s/v\././;
			my %s = %{setupstring('Latin', $sname)};
			if ($s{Rank} =~ /Vigil/i && exists($s{Commemoratio})) { $commemorated = $sname; }
			if ($s{Rank} =~ /Vigil/i && exists($s{"Commemoratio 2"})) { $commemorated = $sname; }
		}
	}
	if ($version =~ /trident/i && $communetype =~ /ex/i && $rank < 1.5) { $communetype = 'vide'; }
	if ($winner =~ /tempora/i) { $antecapitulum = ''; }
	
	#Newcal commemoratio handling
	#  if ($version =~ /Newcal/i && ($month != 12 || $day < 17 || $day > 24)) {
	#    $commemoratio = $commemoratio1 = '';
	#    %commemoratio = %commemoratio2 = undef;
	#  }
	
	#Commemoratio for litaniis majores
	#  if ($month == 4 && $day == 25 && $version =~ /(1955|1960|Newcal)/ && $dayofweek == 0) {
	#    $commemoratio = '';
	#    $dayname[2] = '';
	#  }
	$comrank =~ s/\s*//g;
	$seasonalflag = ($testmode =~ /Seasonal/i && $winner =~ /Sancti/ && $rank < 5) ? 0 : 1;
	if (($month == 12 && $day > 24) || ($month == 1 && $day < 14 && $dayname[0] !~ /Epi/i)) { $dayname[0] = "Nat$day"; }
}

#*** extract_common($common_field, $office_rank)
# Extracts the type and filename of a common referenced by an
# expression of the form used in rank lines. $common_field is this
# expression, and $office_rank is the rank of the corresponding office.
# Returns respectively the type ('ex' or 'vide') and the filename.
sub extract_common($$) {
	my ($common_field, $office_rank, $version, $paschal_tide) = @_;
	
	# These shadow globals.
	my ($communetype, $commune);
	our ($datafolder);
	
	if ($common_field =~ /^(ex|vide)\s*(C[0-9]+[a-z]*)/i) {
		
		# Genuine common.
		$communetype = $1;
		$commune = $2;
		$communetype = 'ex' if ($version =~ /Trident/i && $office_rank >= 2);
		if ($paschal_tide) {
			my $paschal_fname = "$datafolder/Latin/" . subdirname('Commune', $version) . "$commune" . 'p.txt';
			$commune .= 'p' if -e $paschal_fname;
		}
		$commune = subdirname('Commune', $version) . "$commune.txt" if ($commune);
	} elsif ($common_field =~ /(ex|vide)\s*Sancti\/(.*)\s*$/i) {
		
		# Another sanctoral office used as a pseudo-common.
		$communetype = $1;
		$commune = subdirname('Sancti', $version) . "$2.txt";
		$communetype = 'ex' if ($version =~ /Trident/i);
	}
	return ($communetype, $commune);
}


#*** emberday
# return 1 if emberday, 0 otherwise
# used $dayofweek, $dayname[0] season and week,
# for September the weekday office
sub emberday {
	# globals readonly
	our ($day, $month, $year, @dayname, %winner, %commemoratio, %scriptura);
	
	my $dayofweek = day_of_week($day, $month, $year);
	if ($dayofweek < 3 || $dayofweek == 4) { return 0; }
	if ($dayname[0] =~ /Adv3/i) { return 1; }
	if ($dayname[0] =~ /Quad1/i) { return 1; }
	if ($dayname[0] =~ /Pasc7/i) { return 1; }
	if ($month != 9) { return 0; }
	if ($winner{Rank} =~ /Quatuor/i || $commemoratio{Rank} =~ /Quatuor/i || $scriptura{Rank} =~ /Quatuor/i) { return 1; }
	
	if ( $winner{Rank} =~ /Quattuor/i
	|| $commemoratio{Rank} =~ /Quattuor/i
	|| $scriptura{Rank} =~ /Quattuor/i)
	{
		return 1;
	}
	return 0;
}

#*** gettoday($flag)
#get the currend date in mm-dd-yyy format
# flag is set only for primary call for the standalone version
# for the web version javascrip function obtains the user's date
sub gettoday {
	my $flag = shift;
	if (our $browsertime && !$flag) { return $browsertime; }
	my @date = localtime(time());
	my $month = $date[4] + 1;
	my $day = $date[3];
	my $year = $date[5] + 1900;
	return "$month-$day-$year";
}

sub setsecondcol {
	our($winner, $commemoratio, $commune, $scriptura);
	our($lang2, $tvesp, $testmode);
	
	our(%winner2, %commemoratio2, %commune2, %scriptura2) = () x 4;
	
	%winner2 = %{officestring($lang2, $winner, $winner =~ /tempora/i && $tvesp == 1)} if $winner;
	%commemoratio2 = %{officestring($lang2, $commemoratio)} if $commemoratio;
	%commune2 = %{officestring($lang2, $commune)} if $commune;
	%scriptura2 = %{officestring($lang2, $scriptura)} if $scriptura;
	
	if ($testmode =~ /Commune/i) {
		foreach my $key (keys %winner2) {
			next if $key =~ /Rank/i;
			
			if (exists($commune2{$key})) {
				$winner2{$key} = $commune2{$key};
			} else {
				delete($winner2{$key});
			}
		}
	}
}

#*** precedence()
# get date, rank, winner, preloads hashes
sub precedence {
	
	# globals sets here
	our($winner, $commemoratio, $commune, $scriptura, $commemoratio1) = ('') x 5;
	our(%winner, %commemoratio, %commemoratio1, %commune, %scriptura) = () x 5;
	our(@dayname) = ();
	our($month, $day, $year) = ('') x 3;
	our($rule, $communerule, $communetype, $laudes, $transfervigil) = ('') x 5;
	our($C10, $duplex) = ('') x 2;
	
	# globals read only
	our($hora, $version, $missa, $missanumber, $votive, $lang1, $lang2, $testmode);
	our($vespera, $cvespera, $tvesp, $svesp, $rank);
	our $datafolder;
	
	# set global date
	our($date1) = shift || strictparam('date');
	if (!$date1 || $votive =~ /hodie/) { $date1 = gettoday(); }
	$date1 =~ s/\//\-/g;
	($month, $day, $year) = split('-', $date1);
	
	my $dayofweek = day_of_week($day, $month, $year);
	
	if ($month < 1 || $month > 12 || $day < 1 || $day > 31) {
		error("Wrong date $date1 using today");
		$date1 = '';
	} elsif (sprintf("%04d%02d%02d", $year, $month, $day) < '15821015') {
		error("Date $date1 is before Gregorian calendar using today.");
		$date1 = '';
	}
	
	if (!$date1) { ($month, $day, $year) = split('-', gettoday()); }
	
	@dayname = (getweek($day, $month, $year, 0, $missa), '', '');
	
	my $vtv;
	
	if (!$missa) {
		$vtv =
		($votive =~ /(Dedication|C8)/i) ? 'C8'
		: ($votive =~ /(Defunctorum|C9)/i) ? 'C9'
		: ($votive =~ /(Parvum|C12)/i) ? 'C12'
		: '';
		if ($vtv !~ /(C8|C9|C12)/) { $votive = ''; }
	} else {
		$vtv = $votive unless ($votive eq 'Hodie');
	}
	
	$C10 = 'C10';
	if ($missa) {
		$C10 .= ($dayname[0] =~ /Adv/i) ? 'a'
		: ($month == 1 || ($month == 2 && $day == 1)) ? 'b'
		: ($dayname[0] =~ /(Epi|Quad)/i) ? 'c'
		: ($dayname[0] =~ /Pasc/i) ? 'Pasc'
		: '';
	}
	else {
		$C10 .= ($month == 1 || ($month == 2 && $day == 1)) ? 'n'
		: ($dayname[0] =~ /Pasc/i) ? 'p'
		: '';
	}
	getrank($day, $month, $year, $version);    #fills $winner, $commemoratio, $commune, $communetype, $rank);
	$duplex = 0;
	
	if ($dayname[1] && $dayname[1] !~ /duplex/i) {
		$duplex = 1;
	} elsif ($dayname[1] =~ /semiduplex/i) {
		$duplex = 2;
	} else {
		$duplex = 3;
	}
	$rule = $communerule = '';
	
	if ($winner) {
		if ($missa && $missanumber) {
			my $wm = $winner;
			$wm =~ s/\.txt/m$missanumber\.txt/i;
			if ($missanumber && (-e "$datafolder/Latin/$wm")) { $winner = $wm; }
		}
		my $flag = ($winner =~ /tempora/i && $tvesp == 1) ? 1 : 0;
		%winner = %{officestring($lang1, $winner, $flag)};
		
		# In the feriae where the octave of the Epiphany used to be, the
		# Mass is of the Epiphany ('Ecce advenit') before the Sunday, and
		# of I. Sunday after the Epiphany ('In excelso throno') afterwards.
		if ( $version =~ /1955|1960|Newcal/
			&& $missa
			&& $dayname[0] =~ /Epi1/i
			&& $winner =~ /01\-([0-9]+)/
			&& $1 < 13
			&& $dayofweek != 0)
		{
			$communetype = 'ex';
			$commune = 'Tempora/Epi1-0a.txt';
		}
		$rule = $winner{Rule};
	}
	
	if ( $version !~ /(1960|Newcal|monastic)/i
		&& exists($winner{'Oratio Vigilia'})
	&& $dayofweek != 0
	&& $hora =~ /Laudes/i)
	{
		$transfervigil = $winner;
	}
	if ($winner =~ /Sancti/ && $rule =~ /Tempora none/i) { $commemoratio = $scriptura = $dayname[2] = ''; }
	
	if ($version !~ /1960/ && $hora =~ /Vespera/ && $month == 12 && $day == 28 && $dayofweek == 6) {
		$commemoratio1 = $commemoratio;
		$commemoratio = 'Sancti/12-29.txt';
	}
	
	if ($version !~ /1960/ && $hora =~ /Vespera/ && $month == 1 && $day == 3 && $dayofweek == 6) {
		$commemoratio1 = 'Sancti/01-04.txt';
	}
	
	if ($version =~ /1960|Newcal/ && $winner{Rule} =~ /No Sunday commemoratio/i && $dayofweek == 0) {
		$commemoratio = $commemoratio1 = $dayname[2] = '';
	}
	
	if ($commemoratio) {
		my $flag = ($commemoratio =~ /tempora/i && $tvesp == 1) ? 1 : 0;
		%commemoratio = %{officestring($lang1, $commemoratio, $flag)};
		
		if ($version =~ /1960|Newcal/ && $winner{Rule} =~ /Festum Domini/ && $commemoratio{Rule} =~ /Festum Domini/i) {
			$commemoratio = '';
			%commemoratio = undef;
			$dayname[2] = '';
		}
		if ($version =~ /Monastic|1960|Newcal/ && $commemoratio =~ /06-28r?/i && $dayofweek == 0) {
			$commemoratio = '';
			%commemoratio = undef;
			$dayname[2] = '';
		}
		if ($vespera == $svesp && $vespera == 1 && $cvespera == 3 && $commemoratio{Rule} =~ /No second Vespera/i) {
			$commemoratio = '';
			%commemoratio = undef;
			$dayname[2] = '';
		}
	}
	
	if ($commemoratio1) {
		my $flag = ($commemoratio1 =~ /tempora/i && $tvesp == 1) ? 1 : 0;
		%commemoratio1 = %{officestring($lang1, $commemoratio1, $flag)};
		
		if ($version =~ /1960/ && $winner{Rule} =~ /Festum Domini/ && $commemoratio1{Rule} =~ /Festum Domini/) {
			$commemoratio1 = '';
			%commemoratio1 = undef;
			$dayname[2] = '';
		}
	}
	
	if ($scriptura) {
		%scriptura = %{officestring($lang1, $scriptura)};
	}
	
	#Epiphany days for 1955|1960
	#if ($version =~ /(1955|1960)/ && $month == 1 && $day > 6 && $day < 13 && $winner{Rank} =~ /Die/i  &&
	#    exists($scriptura{Rank}))
	#  {$winner{Rank} = $scriptura{Rank}; $winner2{Rank} = $scriptura2{Rank};}
	#no transfervigil if emberday
	if ( $winner{Rank} =~ /Quat[t]*uor/i
	|| $commemoratio{Rank} =~ /Quat[t]*uor/i
	|| $scriptura{Rank} =~ /Quat[t]*uor/i)
	{
		$transfervigil = '';
	}
	
	if ($commune) {
		%commune = %{officestring($lang1, $commune)};
		
		# XXX: this should moved where Responsories are in use
		if (exists($commune{Responsory7c})) {
			my @a = split("\n", $commune{Responsory7});
			my @b = split("\n", $scriptura{Responsory1});
			
			if ($a[0] =~ /$b[0]/i) {
				$commune{Responsory7} = $commune{Responsory7c};
				# $commune2{Responsory7} = $commune2{Responsory7c};
			}
		}
		
		if ($commune =~ /C10/) {
			$rule .= "ex $C10";
			$rule =~ s/Oratio Dominica//gi;
			$winner{Rank} = "Sanctae Mariae Sabbato;;Feria;;1;;ex $C10";
		}
		
		if ($winner{Rank} =~ /\;\;ex\s/
		|| ($version =~ /Trident/i && $rank =~ /\;\;(ex|vide)/i && $duplex > 1))
		{
			$communerule = $commune{Rule};
		}
		
		if ($testmode =~ /Commune/i) {
			foreach my $key (keys %winner) {
				next if $key =~ /Rank/i;
				
				if (exists($commune{$key})) {
					$winner{$key} = $commune{$key};
				} else {
					delete($winner{$key});
				}
			}
		}
	}
	
	if ($vtv && !$missa) {
		if ($vtv =~ /C12/i) {
			if ( ($month == 12 && ($day == 24 && $hora =~ /Vespera|Completorium/ || ($day > 24)))
				|| $month == 1
				|| ($month == 2 && $day < 3))
			{
				$vtv = 'C12N';
			} elsif ($dayname[0] =~ /adv/i) {
				$vtv = 'C12A';
			} elsif ($dayname[0] =~ /Pasc/i) {
				$vtv = 'C12P';
			} elsif (
			$month == 3
			&& (($day == 24 && $hora =~ /(Vespera|Completorium)/i)
			|| $day == 25)
			)
			{
				$vtv = 'C12';
			} elsif ($dayname[0] =~ /(Quadp|Quad)/i) {
				$vtv = 'C12Q';
			}
		}
		$winner = subdirname('Commune', $version) . "$vtv.txt";
		$commemoratio = $commemoratio1 = $scriptura = $commune = '';
		%winner = updaterank(setupstring($lang1, $winner));
		%commemoratio = %commemoratio1 = %scriptura = %commune = {};
		$rule = $winner{Rule};
		
		if ($vtv =~ /C12/i) {
			$commune = subdirname('Commune', $version) . "C11.txt";
			$communetype = 'ex';
			%commune = updaterank(setupstring($lang1, $commune));
		}
		$dayname[1] = $winner{Name};
		$dayname[2] = '';
	}
	
	if ($vtv && $missa) {
		$winner = "Votive/$vtv.txt";
		$commemoratio = $commemoratio1 = $scriptura = $commune = '';
		%winner = updaterank(setupstring($lang1, $winner));
		%commemoratio = %scriptura = %commune = {};
		$rule = $winner{Rule};
		
		if ($vtv =~ /Maria/i) {
			$commune = "Commune/C11.txt";
			$communetype = 'ex';
			%commune = updaterank(setupstring($lang1, $commune));
			# %commune2 = updaterank(setupstring($lang2, $commune));
		}
		$dayname[1] = $winner{Name};
		$dayname[2] = '';
	}
	
	# Choose the appropriate scheme for Lauds. Roughly speaking, penitential days
	# have Lauds II and others have Lauds I, although for the Tridentine rubrics
	# only the Sundays of Septuagesima and Lent have a sort of "Lauds II", with
	# all other days being unambiguous.
	if ($version =~ /Trident/i) {
		$laudes =
		($dayname[0] =~ /Quad/i && $dayofweek == 0 && $winner =~ /Tempora/i)
		? 2
		: '';
	} else {
		$laudes = (
		(
		(($dayname[0] =~ /Adv/i && $dayofweek != 0) || $dayname[0] =~ /Quad/i || emberday())
		&& $winner =~ /tempora/i
		&& $winner{Rank} !~ /(Beatae|Sanctae) Mariae/i
		)
		|| $rule =~ /Laudes 2/i
		|| ($winner{Rank} =~ /vigil/i && $version !~ /(1955|1960|Newcal)/)
		)
		? 2
		: 1;
	}
	if ($missa && $winner{Rank} =~ /Defunctorum/) { $votive = 'Defunct'; }
}

#*** officestring($lang, $fname, $flag)
# same as setupstring (in dialogcommon.pl = reads the hash for $fname office)
# with the addition that for the monthly ferias/scriptures (aug-dec)
# it adds that office to the otherwise empty season related one
# if flag is 1 looks for the anticipated office for vespers
# returns the filled hash for the ofiice
sub officestring($$;$) {
	my ($lang, $fname, $flag) = @_;
	
	my $basedir = our $datafolder;
	my %s;
	
	# read only globals
	our ($version, $day, $month, $year);
	
	# set this global here
	our $monthday;
	
	if ($fname !~ /tempora[M]*\/(Pent|Epi)/i) {
		%s = updaterank(setupstring($lang, $fname));
		if ($version =~ /1960|Monastic/ && $s{Rank} =~ /Feria.*?(III|IV) Adv/i && $day > 16) { $s{Rank} =~ s/;;2/;;3/; }
		return \%s;
	}
	
	if ($fname =~ /tempora[M]*\/Pent([0-9]+)/i && $1 < 5) {
		%s = updaterank(setupstring($lang, $fname));
		return \%s;
	}
	$monthday = monthday($day, $month, $year, ($version =~ /1960|Monastic/) + 0, $flag);
	
	if (!$monthday) {
		%s = updaterank(setupstring($lang, $fname));
		return \%s;
	}
	%s = %{setupstring($lang, $fname)};
	if (!%s) { return ''; }
	my @rank = split(';;', $s{Rank});
	my $m = 0;
	my $w = 0;
	if ($monthday =~ /([0-9][0-9])([0-9])\-[0-9]/) { $m = $1; $w = $2; }
	my @months = ('Augusti', 'Septembris', 'Octobris', 'Novembris', 'Decembris');
	my @weeks = ('I.', 'II.', 'III.', 'IV.', 'V.');
	if ($m) { $m = $months[$m - 8]; }
	if ($w) { $w = $weeks[$w - 1]; }
	$rank[0] .= " $w $m";
	$s{Rank} = join(';;', @rank);
	my %m = %{setupstring($lang, subdirname('Tempora', $version) . "$monthday.txt")};
	
	foreach my $key (keys %m) {
		if (($version =~ //i && $key =~ /Rank/i)) {
			;
		} else {
			$s{$key} = $m{$key};
		}
	}
	%s = updaterank(\%s);
	return \%s;
}

#*** climit1960($commemoratio)
# returns 1 if commemoratio is allowed for 1960 rules
sub climit1960 {
	my $c = shift;
	if (!$c) { return 0; }
	
	# read only globals
	our ($version, $datafolder, $winner, $hora, $rank);
	
	if ($version !~ /1960|Monastic/i || $c !~ /sancti/i) { return 1; }
	
	# Subsume commemoration in special case 7-16 with Common 10 (BVM in Sabbato)
	return 0 if $c =~ /7-16/ && $winner =~ /C10/;
	my %w = updaterank(setupstring('Latin', $winner));
	if ($winner !~ /tempora|C10/i) { return 1; }
	my %c = updaterank(setupstring('Latin', $c));
	my @r = split(';;', $c{Rank});
	
	if ($w{Rank} =~ /Dominica/i) {
		if (($hora !~ /(Vespera|Completorium)/i && $r[2] >= 5) || $r[2] >= 6) { return 1; }
		if ($hora =~ /Laudes/i && $r[2] >= 5 && $rank < 6) { return 1; }
	} elsif ($r[2] >= 6) {
		return 1;
	} elsif ($r[2] > 1) {
		return 2;
	}
	return 0;
}

#*** setheadline();
# returns the winner name and rank, different for 1960
sub setheadline {
	my $name = shift;
	my $rank = shift;
	
	# read only globals
	our(%winner, $winner, @dayname, $version, $day, $month, $year, $dayofweek, $hora, $rule);
	
	if ((!$name || !$rank) && exists($winner{Rank}) && $winner !~ /Epi1\-0a/i) {
		my @rank = split(';;', $winner{Rank});
		$name = $rank[0];
		$rank = $rank[2];
	}
	if ($name && $rank) {
		my $rankname = '';
		
		if ($name !~ /(Die|Feria|Sabbato)/i && ($dayname[0] !~ /Pasc[07]/i || $dayofweek == 0)) {
			my @tradtable = (
			'none', 'Simplex', 'Semiduplex', 'Duplex',
			'Duplex majus', 'Duplex II. classis', 'Duplex I. classis', 'Duplex I. classis'
			);
			my @newtable = (
			'none',
			'Commemoratio',
			'III. classis',
			'III. classis',
			'III. classis',
			'II. classis',
			'I. classis',
			'I. classis'
			);
			$rankname = ($version !~ /1960|Monastic/i) ? $tradtable[$rank] : $newtable[$rank];
			if ($version =~ /(1955|1960|Newcal)/ && $winner !~ /Pasc5-3/i && $dayname[1] =~ /feria/i) { $rankname = 'Feria'; }
			
			if ($name =~ /Dominica/i && $version !~ /1960|Monastic/i) {
				local $_ = getweek($day, $month, $year, $dayofweek == 6 && $hora =~ /(Vespera|Completorium)/i);
				$rankname =
				(/Pasc[017]/i || /Pent01/i) ? 'Duplex I. classis'
				: (/(Adv1|Quad[1-6])/i) ? 'Semiduplex I. classis'
				: (/(Adv[2-4]|Quadp)/i) ? 'Semiduplex II. classis'
				: (/(Epi[3-6])/i && $dayofweek > 0) ? 'Simplex'
				: 'Semiduplex Dominica minor';
			}
		} elsif ($version =~ /1960|Newcal|Monastic/i && $dayname[0] =~ /Pasc[07]/i && $dayofweek > 0 && $winner !~ /Pasc7-0/) {
			$rankname = 'Dies Octavæ I. classis';
		} elsif ($version =~ /(1570|1910|Divino|1955)/ && $rule =~ /C10/) {
			$rankname = 'Simplex';
		} elsif ($version =~ /(1570|1910|Divino|1955)/ && $winner =~ /Quadp3-3/) {
			$rankname = 'Feria privilegiata';
		} elsif ($version =~ /(1570|1910|Divino|1955)/ && $winner =~ /Pasc6-5/) {
			$rankname = 'Semiduplex';
		} elsif ($version =~ /1960|Newcal|Monastic/i && $winner =~ /Pasc6-6/) {
			$rankname = 'I. classis';
		} elsif ($version =~ /1960|Newcal/i && $winner =~ /Pasc5-3/) {
			$rankname = 'II. classis';
		} elsif ($version =~ /1960|Newcal|Monastic/ && $month == 12 && $day > 16 && $day < 25 && $dayofweek > 0) {
			$rankname = 'II. classis';
		} elsif ($version =~ /(1570|1910|Divino|1955)/ && $dayname[0] =~ /Pasc[07]/i && $dayofweek > 0) {
			$rankname = ($rank =~ 7) ? 'Duplex I. classis' : 'Semiduplex';
		} elsif ($version =~ /(1570|1910|Divino|1955)/ && $dayname[0] =~ /Quad/i && $dayname[0] !~ /Quad6-4|5|6/i && $dayofweek > 0) {
			$rankname = 'Simplex';
		} elsif ($version =~ /(1570|1910|Divino|1955)/ && $dayname[0] =~ /07-04/i && $dayofweek > 0) {
			$rankname = ($rank =~ 7) ? 'Duplex I. classis' : 'Semiduplex';
		} else {
			if ($version !~ /1960|Monastic/i) {
				$rankname = ($rank <= 2) ? 'Ferial' : ($rank < 3) ? 'Feria major' : 'Feria privilegiata';
			} else {
				my @ranktable = (
				'',
				'IV. classis',
				'III. classis',
				'III. classis',
				'II. classis',
				'II. classis',
				'II. classis',
				'I. classis',
				'I. classis'
				);
				$rankname = $ranktable[$rank];
			}
		}
		return "$name ~ $rankname";
	} else {
		return $dayname[1];
	}
}

#*** updaterank \%office
#updates $office{Rank} for 1960 Trid versions if any
sub updaterank {
	my $w = shift;
	my %w = %$w;
	if (!exists($w{Rank})) { return %w; }
	
	our $version;
	
	if ($version =~ /Newcal/i && exists($w{RankNewcal})) {
		$w{Rank} = $w{RankNewcal};
	} elsif ($version =~ /(1955|1960|Newcal)/ && exists($w{Rank1960})) {
		$w{Rank} = $w{Rank1960};
	}
	
	if ($version =~ /1570/i && exists($w{Rank1570})) {
		$w{Rank} = $w{Rank1570};
	} elsif ($version =~ /(Trident|1570)/i && exists($w{RankTrident})) {
		$w{Rank} = $w{RankTrident};
	}
	return %w;
}

sub subdirname {
	my($subdir, $version) = @_;
	$subdir .= 'M' if $version =~ /monastic/i;
	"$subdir/"
}

sub nomatinscomm {
	my $w = shift;
	my %w = %$w;
	if ($w{Rule} =~ /9 lectiones/i && exists($w{Responsory9})) { return 1; }
	if ($w{Rule} !~ /9 lectiones/i && exists($w{Responsory3})) { return 1; }
	return 0;
}

#*** days_to_date($days)
# returns the ($sec, $min, $hour, $day, $month-1, $year-1900, $wday, $yday, 0) array from the number of days from 01-01-1970
sub days_to_date {
	my $days = shift;
	if ($days > 0 && $days < 24837) { return localtime($days * 60 * 60 * 24 + 12 * 60 * 60); }
	if ($days < -141427) { error("Date before the Gregorian Calendar!"); }
	my @d = ();
	$d[0] = 0;
	$d[1] = 0;
	$d[2] = 6;
	$d[6] = (($days % 7) + 4) % 7;
	$d[8] = 0;
	my $count = 10957;
	my $yc = 20;
	my $add;
	my $oldadd;
	my $oldcount = $count;
	my $oldyc = $yc;
	
	if ($days < $count) {
		while ($days < $count) { $yc--; $add = (($yc % 4) == 0) ? 36525 : 36524; $count -= $add; }
	} else {
		while ($days >= $count) {
			$oldcount = $count;
			$oldyc = $yc;
			$add = (($yc % 4) == 0) ? 36525 : 36524;
			$count += $add;
			$yc++;
		}
		$count = $oldcount;
		$yc = $oldyc;
	}
	$add = 4 * 365;
	if (($yc % 4) == 0) { $add += 1; }
	$yc *= 100;
	$oldcount = $count;
	$oldyc = $yc;
	while ($count <= $days) { $oldcount = $count; $oldyc = $yc; $count += $add; $add = 4 * 365 + 1; $yc += 4; }
	$count = $oldcount;
	$yc = $oldyc;
	$add = 366;
	if (($yc % 100) == 0 && ($yc % 400) > 0) { $add = 365; }
	$oldyc = $yc;
	while ($count <= $days) { $oldadd = $add; $oldyc = $yc; $count += $add; $add = 365; $yc++; }
	$count -= $oldadd;
	$yc = $oldyc;
	$d[5] = $yc - 1900;
	$d[7] = $days - $count + 1;
	my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	
	if (($yc % 4) == 0) {
		$months[1] = 29;
	} else {
		$months[1] = 28;
	}
	if (($yc % 100) == 0 && ($yc % 400) > 0) { $months[1] = 28; }
	my $c = 0;
	while ($count <= $days) { $count += $months[$c]; $c++; }
	$c--;
	$count -= $months[$c];
	$d[4] = $c;
	$d[3] = $days - $count + 1;
	return @d;
}

#*** date_to_days($day, $month-1, $year)
# returns the number of days from the epoch 01-01-1070
sub date_to_days {
	my ($d, $m, $y) = @_;
	if ($y > 1970 && $y < 2038) { floor(timelocal(0, 0, 12, $d, $m, $y) / 60 * 60 * 24); }
	my $yc = floor($y / 100);
	my $c = 20;
	my $ret = 10957;
	my $add;
	
	if ($y < 2000) {
		while ($c > $yc) { $c--; $add = (($c % 4) == 0) ? 36525 : 36524; $ret -= $add; }
	} else {
		while ($c < $yc) { $add = (($c % 4) == 0) ? 36525 : 36524; $ret += $add; $c++; }
	}
	$add = 4 * 365;
	if (($yc % 4) == 0) { $add += 1; }
	$yc *= 100;
	while ($yc < ($y - ($y % 4))) { $ret += $add; $add = 4 * 365 + 1; $yc += 4; }
	$add = 366;
	if (($yc % 100) == 0 && ($yc % 400) > 0) { $add = 365; }
	while ($yc < $y) { $ret += $add; $add = 365; $yc++; }
	my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	
	if (($y % 4) == 0) {
		$months[1] = 29;
	} else {
		$months[1] = 28;
	}
	if (($y % 100) == 0 && ($y % 400) > 0) { $months[1] = 28; }
	$c = 0;
	while ($c < $m) { $ret += $months[$c]; $c++; }
	$ret += ($d - 1);
	if ($ret < -141427) { error("Date before the Gregorian Calendar!"); }
	return $ret;
}
#*** nooctnat()
# returns 1 for 1960 not Christmas Octave days
sub nooctnat {
	our $version =~ /1960|Monastic/i && (our $month < 12 || our $day < 25)
}

# Latin spelling variety in versions
sub spell_var {
	my $t = shift;
	
	if (our $version =~ /1960|Praedicatorum|Newcalendar|Monastic/) {
		# substitute i for j
		# but not in html tags!
		my @parts = split(/(<[^<>]*>)/, $t);
		
		foreach (@parts) {
			next if /^</;
			tr/Jj/Ii/;
			s/H\-Iesu/H-Jesu/g;
			s/er eúmdem/er eúndem/g;
		}
		$t = join('', @parts);
	} else {
		$t =~ s/Génetrix/Génitrix/g;
		$t =~ s/\bco(t[ií]d[ií])/quo$1/g;
	}
	return $t;
}

#*** papal_commem_rule($rule)
#  Determines whether a rule contains a clause for a commemorated Pope.
#  Returns a list ($class, $name), as for papal_rule.
sub papal_commem_rule($) {
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
sub papal_rule($%) {
	my ($rule, %params) = @_;
	my $classchar = $params{'commemoration'} ? 'C' : 'O';
	return ($rule =~ /${classchar}Papa(e)?([CMD])=(.*?);/i);
}

#*** papal_prayer($lang, $plural, $class, $name[, $type])
#  Returns the collect, secret or postcommunion from the Common of
#  Supreme Pontiffs, where $lang is the language; $plural, $class and
#  $name are as returned by papal_rule; and $type optionally specifies
#  the key for the template (otherwise, it will be 'Oratio').
sub papal_prayer($$$$;$) {
	my ($lang, $plural, $class, $name, $type) = @_;
	$type ||= 'Oratio';
	
	# Get the prayer from the common.
	my (%common, $num);
	our ($missa, $version);
	
	if ($missa) {
		%common = %{setupstring($lang, subdirname('Commune', $version) . "C4b.txt")};
		$num = $plural && $type eq 'Oratio' ? 91 : '';
	} else {
		%common = %{setupstring($lang, subdirname('Commune', $version) . "C4.txt")};
		$num = $plural ? 91 : 9;
	}
	my $prayer = $common{"$type$num"};
	
	# Fill in the name(s).
	$prayer =~ s/ N\.([a-z ]+N\.)*/ $name/;
	
	# If we're not a martyr, get rid of the bracketed part; if we are,
	# then just get rid of the brackets themselves.
	if ($class !~ /M/i) {
		$prayer =~ s/\s*\((.|~[\s\n\r]*)*?\)//;
	} else {
		$prayer =~ tr/()//d;
	}
	return $prayer;
}

#*** papal_antiphon_dum_esset($lang)
#  Returns the Magnificat antiphon "Dum esset" from the Common of
#  Supreme Pontiffs, where $lang is the language.
sub papal_antiphon_dum_esset($) {
	my $lang = shift;
	our $version;
	my %papalcommon = %{setupstring($lang, subdirname('Commune', $version) . "C4.txt")};
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
	
	BEGIN {
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
		(?:hic\s+versus\s+)?omittitur
		|
		(?:hoc\s+versus\s+)?omittitur
		|
		(?:hæc\s+versus\s+)?omittuntur
		|
		(?:hi\s+versus\s+)?omittuntur
		|
		(?:haec\s+versus\s+)?omittuntur
		)
		\b
		)?
		/ix;
	}
	
	# We have four types of scope (in each direction):
	use constant SCOPE_NULL => 0;    # Null scope.
	use constant SCOPE_LINE => 1;    # Single line.
	use constant SCOPE_CHUNK => 2;   # Until the next blank line.
	use constant SCOPE_NEST => 3;    # Until a (weakly) stronger conditional.
	
	#*** evaluate_conditional($conditional)
	#  Evaluates a expression from a data-file conditional directive.
	sub evaluate_conditional($) {
		my $conditional = shift;
		my $expression = '';
		
		# Pick out tokens.
		while ($conditional =~ /([a-z_\d]+|[><!\(\)]+|==|>=|<=|!=|&&|\|\||\s*)/gi) {
			
			# Look up identifiers in the hash.
			my $token = $1;
			$expression .= ($token =~ /[a-z_]/) ? "$conditional_values{$token}" : $token;
		}
		return eval $expression;
	}
	
	#*** conditional_regex()
	#  Returns a regex that matches conditionals, capturing stopwords,
	#  the condition itself and scope keywords, in that order.
	sub conditional_regex() {
		return qr/\(\s*($stopwords_regex\b)*(.*?)($scope_regex)?\s*\)/o;
	}
	
	sub parse_conditional($$$) {
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
		$implicit_backscope ||= exists($backscoped_stopwords{$_}) foreach (split /\s+/, lc($stopwords));
		$backscope =
		$scope =~ /versuum|omittuntur/i ? SCOPE_NEST
		: $scope =~ /versus|omittitur/i ? SCOPE_CHUNK
		: $scope !~ /semper/i && $implicit_backscope ? SCOPE_LINE
		: SCOPE_NULL;
		
		if ($scope =~ /omittitur|omittuntur/i) {
			$forwardscope = SCOPE_NULL;
		} elsif ($scope =~ /dicuntur/i) {
			$forwardscope = ($backscope == SCOPE_CHUNK) ? SCOPE_CHUNK : SCOPE_NEST;
		} else {
			$forwardscope = ($backscope == SCOPE_CHUNK || $backscope == SCOPE_NEST) ? SCOPE_CHUNK : SCOPE_LINE;
		}
		return ($strength, $result, $backscope, $forwardscope);
	}
}

#*** build_comment_line()
#  Sets $comment to the HTML for the comment line.
sub build_comment_line() {
	our @dayname;
	our ($comment, $marian_commem);
	my $commentcolor =
	($dayname[2] =~ /(Feria)/i) ? 'black' : ($marian_commem && $dayname[2] =~ /^Commem/) ? 'blue' : 'maroon';
	$comment = ($dayname[2]) ? "<SPAN STYLE=\"font-size:82%; color:$commentcolor;\"><I>$dayname[2]</I></SPAN>" : "";
}

#*** cache_prayers()
#  Loads Prayers.txt for each language into global hash.
sub cache_prayers() {
	our %prayers;
	our ($lang1, $lang2);
	our $datafolder;
	my $dir = our $missa ? 'Ordo' : 'Psalterium';
	$prayers{$lang1} = setupstring($lang1, "$dir/Prayers.txt");
	$prayers{$lang2} = setupstring($lang2, "$dir/Prayers.txt");
}

#*** sub expand($line, $lang, $antline)
# for & references calls the sub
# $ references are filled from Psalterium/Prayers file
# antline to handle redding the beginning of psalm is same as antiphona
# returns the expanded text or the link
sub expand {
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
	if ($sigil eq '&') {
		
		# Make popup link if we shouldn't expand.
		if ($expand =~ /nothing/i
			|| ($expand !~ /all/i && ($line =~ /^(?:[A-Z]|pater_noster)/)))
		{
			return setlink($sigil . $line, 0, $lang);
		}
		
		# Actual expansion for & references.
		# Get function name and any parameters.
		my ($function_name, $arg_string) = ($line =~ /(.*?)(?:[(](.*)[)])?$/);
		my @args = (parse_script_arguments($arg_string), $lang);
		
		# If we have an antiphon, pass it on to the script function.
		if ($antline) {
			$antline =~ s/^\s*Ant\. //i;
			push @args, $antline;
		}
		return dispatch_script_function($function_name, @args);
	} else    # Sigil is $, so simply look up the prayer.
	{
		if ($expand =~ /all/i) {
			
			#actual expansion for $ references
			our %prayers;
			return $prayers{$lang}->{$line};
		} else {
			return setlink($sigil . $line, 0, $lang);
		}
	}
}
1;
