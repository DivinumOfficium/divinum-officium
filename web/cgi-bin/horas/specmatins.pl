#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office Matins subroutines
use FindBin qw($Bin);
use lib "$Bin/..";
use DivinumOfficium::Directorium qw(get_stransfer hymnmerge hymnshift);

# Defines ScriptFunc and ScriptShortFunc attributes.
use horas::Scripting;
$a = 4;

#*** invitatorium($lang)
# collects and returns psalm 94 with the antipones
sub invitatorium {
	my $lang = shift;
	my %invit = %{setupstring($lang, 'Psalterium/Matutinum Special.txt')};
	my $name =
	($dayname[0] =~ /Adv[12]/i) ? 'Adv'
	: ($dayname[0] =~ /Adv[34]/i) ? 'Adv3'
	: ($month == 12 && $day == 24) ? 'Nat24'
	: ($dayname[0] =~ /(Quad5|Quad6)/i) ? 'Quad5'
	: ($dayname[0] =~ /Quad/i && $dayname[0] !~ /Quadp/i) ? 'Quad'
	: ($dayname[0] =~ /Pasc/i) ? 'Pasch'
	: '';
	
	if (
		$version =~ /Trid|Monastic/i
		&& (!$name
		|| ($name eq 'Quad' && $dayofweek != 0))
		)
	{
		$name = 'Trid';
	}
	
	if ($name) {
		$name = "Invit $name";
		$comment = 1;
	} else {
		$name = 'Invit';
		$comment = 0;
	}
	my $i = ($name =~ /^Invit$/i || $name =~ /Invit Trid/i) ? $dayofweek : 0;
	if ($i == 0 && $name =~ /^Invit$/i && ($month < 4 || ($monthday && $monthday =~ /^1[0-9][0-9]\-/))) { $i = 7; }
	my @invit = split("\n", $invit{$name});
	setbuild('Psalterium/Matutinum Special', $name, 'Invitatorium ord');
	my $ant = chompd($invit[$i]);
	my ($w, $c);
	if ($version =~ /Monastic/i && $dayofweek && $winner =~ /Pasc/ && $winner !~ /Pasc[07]/ && $winner !~ /Pasc5-4/) {
		$ant = $prayers{$lang}{"Alleluia Duplex"};
		$ant =~ s/(\S+), (\S+)\./$1, $2, * $1/;
	} else {
		#look for special from proprium the tempore or sancti
		($w, $c) = getproprium("Invit", $lang, $seasonalflag, 1);
		if ($w) { $ant = chompd($w); $comment = $c; }
		setcomment($label, 'Source', $comment, $lang, translate('Antiphona', $lang));
	}
	$ant =~ s/^.*?\=\s*//;
	$ant = chompd($ant);
	$ant = "Ant. $ant";
	postprocess_ant($ant, $lang);
	my @ant = split('\*', $ant);
	my $ant2 = "Ant. $ant[1]";

	my $invitpath = "Psalterium/Invitatorium.txt";
	$invitpath =~ s/Psalterium/PiusXII/ if ($lang eq 'Latin' && $psalmvar);
	$fname = checkfile($lang, $invitpath);
	
	if (my @a = do_read($fname)) {
    $_ = join("\n", @a);

		if ($rule =~ /Invit2/i) { 
			# old Invitatorium2 = Quadp[123]-0
			s/ \*.*//;
		} elsif ($dayname[0] =~ /Quad[56]/i && $winner =~ /tempora/i && $rule !~ /Gloria responsory/i) {
			# old Invitatorium3
      s/&Gloria/\&Gloria2/;
			s/v\. .* \^ (.)/v. \u\1/m;
			s/\$ant2\s*(?=\$)//s;
		} elsif (!$w && $dayofweek == 1 && $dayname[0] =~ /(Epi|Pent|Quadp)/i && $winner =~ /Tempora/) { 
			# old Invitatorium4
			s/^v\. .* \+ (.)/v. \u\1/m;
		}

		s{[+*^] }{}g; # clean division marks

    s/\$ant2/$ant2/eg;
    s/\$ant/$ant/eg;

    push(@s, $_);
	} else {
		$error .= "$fname cannnot open";
	}
}

#*** hymnus($lang)
# collects and returns the hymn for matutinum
sub hymnusmatutinum {
	my $lang = shift;
	my $hymn = '';
	my $name = 'Hymnus';
	$name .= checkmtv($version, \%winner) unless (exists($winner{'Hymnus Matutinum'}));
	my ($h, $c) = getproprium("$name Matutinum", $lang, $seasonalflag, 1);
	
	if ($h) {
		if (hymnshift($version, $day, $month, $year)) {			# if 1st Vesper hymn has been omitted due to concurrent II. Vespers
			my ($h1, $c1) = getproprium("$name Vespera", $lang, $seasonalflag, 1);
			$h = $h1;
			setbuild2("Hymnus shifted");
    } elsif (hymnmerge($version, $day, $month, $year)) {	# if also 2nd Vesper been omitted
			my ($h1, $c1) = getproprium("$name Vespera", $lang, $seasonalflag, 1);
			$h =~ s/^(v. )//;
			$h1 =~ s/\_(?!.*\_).*/\_\n$h/s;	# find the Doxology as last verse since e.g. Venantius(05-18) has a proper one
			$h = $h1;
			setbuild2("Hymnus merged");
		}
		$hymn = $h;
		$comment = $c;
	}
	else {
		my %hymn = %{setupstring($lang, 'Psalterium/Matutinum Special.txt')};
		$name =
		($dayname[0] =~ /adv/i) ? 'Adv'
		: ($dayname[0] =~ /quad5|quad6/i) ? 'Quad5'
		: ($dayname[0] =~ /quad[0-9]/i) ? 'Quad'
		: ($dayname[0] =~ /pasc/i) ? 'Pasch'
		: '';
		if ($month == 12 && $day == 24) { $name = 'Adv'; }
		$name = ($name) ? "Hymnus $name" : "Day$dayofweek Hymnus";
		$comment = ($name) ? 1 : 5;
		if ($name =~ /^Day0 Hymnus$/i && ($month < 4 || ($monthday && $monthday =~ /^1[0-9][0-9]\-/))) { $name .= '1'; }
		setbuild("Psalterium/Matutinum Special", $name, 'Hymnus ord');
		
	}
	setcomment($label, 'Source', $comment, $lang);
	($hymn, $name);
}

sub nocturn {
	my($num, $lang, $psalmi, @select) = @_;
	our($version);
	my $lastant = '';

	push(@s, '!' . translate('Nocturn', $lang) . ' ' . ('I' x $num) . '.');
	for(my $i=0; $i<(@select - 2); $i++) {
		antetpsalm(@{$psalmi}[$select[$i]], $select[$i], \$lastant, $lang)
	}
	pop(@s);
	push(@s, "Ant. $lastant", "\n");

	# versus cant be text or reference (number)
	my (@vs) = ($select[-1] =~ /^\d+$/ ? (@{$psalmi}[$select[-2]], @{$psalmi}[$select[-1]]) : ($select[-2], $select[-1]));
	process_inline_alleluias($vs[0]);
	process_inline_alleluias($vs[1]);
	push(@s, @vs, "\n");
}

#*** psalmi_matutinum($lang)
# collects and returns psalms and lections for matutinum
sub psalmi_matutinum {
	$lang = shift;
	if ($version =~ /monastic/i && $winner{Rule} !~ /Matutinum Romanum/i) { return psalmi_matutinum_monastic($lang); }
	my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi matutinum.txt')};
	my $d = ($version =~ /trident/i) ? 'Daya' : 'Day';
	my $dw = $dayofweek;
	
	#if ($winner{Rank} =~ /Dominica/i) {$dw = 0;}
	my @psalmi = split("\n", $psalmi{"$d$dw"});
	setbuild("Psalterium/Psalmi matutinum", "$d$dw", 'Psalmi ord');
	$comment = 1;
	my $prefix = translate('Antiphonae', $lang);
	
	if ($dayofweek == 0 && $dayname[0] =~ /Adv/i) {
		if ($version =~ /Trident/i) {
			@psalmi = split("\n", $psalmi{'Adv0'});
		} else {
			@psalmi = split("\n", $psalmi{'Adv 0 Ant Matutinum'});
		}
		setbuild2("Antiphonas Psalmi Dominica special");
	}
	
	#replace Psalm50 with breaking 49 to three parts
	if ($laudes == 2 && $dayofweek == 3 && $version !~ /trident/i) {
		@psalmi = split("\n", $psalmi{"Day31"});
		setbuild2("Psalm #50 replaced by breaking #49");
	}
	
	if (
		$version !~ /Trident/i
		&& (
		($winner =~ /tempora/i && $dayname[0] =~ /(Adv|Quad|Pasc)([0-9])/i)
		|| (
		$month == 1
		&& $version =~ /1960|1955/
		&& $winner =~ /Sancti/i
		&&    # TODO: Temporary condition
		(
		($day < 6 && 'Nat' =~ /(Nat)/) ||    # pending implementation of
		($day <= 13 && 'Epi' =~ /(Epi)/)
		)                                      # Christmas- and Epiphanytide.
		)
		)
	)
	{
		my $name = $1;
		my $i = $2;
		if ($name =~ /Quad/i && $i > 4) { $name = 'Quad5'; }
		
		if ($dayofweek == 0) {
			foreach my $i (1..3) {
				($psalmi[($i-1)*5 + 3], $psalmi[($i-1)*5+4]) = split("\n", $psalmi{"$name $i Versum"}, 2);
			}
			if ($version =~ /1960/) { ($psalmi[13], $psalmi[14]) = ($psalmi[3], $psalmi[4]); }
		} else {
			($psalmi[13], $psalmi[14]) = split("\n", $psalmi{"$name $dayofweek Versum"}, 2);
		}
		setbuild2("Subst Matutitunun Versus $name $dayofweek");
	}
	my ($w, $c) = getproprium('Ant Matutinum', $lang, 0, 1);
	
	if ($w) {
		@psalmi = split("\n", $w);
		$comment = $c;
		$prefix .= ' ' . translate('et Psalmi', $lang);
	}

	if ($dayname[0] =~ /Pasc[1-6]/i && $votive !~ /C9/) {
		@psalmi = ant_matutinum_paschal(\@psalmi, $lang, length($w));
	}
	
	if ($rule =~ /Ant Matutinum ([0-9]+) special/i) {
		my $ind = $1;
		%wa = (columnsel($lang)) ? %winner : %winner2;
		$wa = $wa{"Ant Matutinum $ind"};
		$wa =~ s/\s*$//;
		
		if ($wa) {
			if ($ind == 12 && $dayname[0] =~ /Pasc/i) { 
				$psalmi[10] =~ s/^.*?;;/$wa;;/; 
			} else {
				$psalmi[$ind] =~ s/^.*?;;/$wa;;/;
			}
		}
	}
	
	if ( $version =~ /Trident/i
		&& $testmode =~ /seasonal/i
		&& $winner =~ /Sancti/i
		&& $rank >= 2
		&& $rank < 5
		&& !exists($winner{'Ant Matutinum'}))
	{
		$comment = 0;
	}
	setcomment($label, 'Source', $comment, $lang, $prefix);
	
	my %spec = %{setupstring($lang, 'Psalterium/Psalmi matutinum.txt')};
	my @spec = ();
	my $i = 0;
	my %w = (columnsel($lang)) ? %winner : %winner2;
	my $ltype1960 = gettype1960();
	
	# Trident rubrics: Anticipated Sundays are "Simplex", i.e., 1 nocturn with 3 lessions (of the Gospel Homily!)
	if ($rule =~ /9 lectio/i && !$ltype1960 && $rank >= 2 && !($version =~ /trident/i && $winner{Rank} =~ /Dominica/i && $dayofweek>0)) {
		setbuild2("9 lectiones");
		
		if ($dayname[0] =~ /Pasc/i && !exists($winner{'Ant Matutinum'}) && $rank < 5) {    #??? ex
			my $dname = ($winner{Rank} =~ /Dominica/i) ? 'Dominica' : 'Feria';
			@spec = split("\n", $spec{"Pasc Ant $dname"});
			foreach my $i (3, 4, 8, 9, 13, 14) { $psalmi[$i] = $spec[$i]; }
		} elsif ($winner =~ /tempora/i
		&& $dayname[0] =~ /(Adv|Quad|Pasc)/i
		&& !exists($winner{'Ant Matutinum'}))
		{
			$tmp = $1;
			if ($dayname[0] =~ /(Quad5|Quad6)/) { $tmp = 'Quad5'; }
			@spec = split("\n", $spec{"$tmp 1 Versum"});
			if (@spec) { $psalmi[3] = $spec[0]; $psalmi[4] = $spec[1]; }
			@spec = split("\n", $spec{"$tmp 2 Versum"});
			if (@spec) { $psalmi[8] = $spec[0]; $psalmi[9] = $spec[1]; }
			@spec = split("\n", $spec{"$tmp 3 Versum"});
			if (@spec) { $psalmi[13] = $spec[0]; $psalmi[14] = $spec[1]; }
			setbuild2("$tmp special versums for nocturns");
		}
		
		if ( $version =~ /Trident/i
			&& $testmode =~ /seasonal/i
			&& $winner =~ /Sancti/i
			&& $rank >= 2
			&& $rank < 5
			&& !exists($winner{'Ant Matutinum'}))
		{
			my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi matutinum.txt')};
			@psalmi = split("\n", $psalmi{"Daya$dayofweek"});
			nocturn(1, $lang, \@psalmi, (0,1,6,7));
			lectiones(1, $lang);
			nocturn(2, $lang, \@psalmi, (2,3,6,7));
			lectiones(2, $lang);
			nocturn(3, $lang, \@psalmi, (4,5,6,7));
			lectiones(3, $lang);
			return;
		}

		nocturn(1, $lang, \@psalmi, (0..4));
		lectiones(1, $lang);
		nocturn(2, $lang, \@psalmi, (5..9));
		lectiones(2, $lang);
		nocturn(3, $lang, \@psalmi, (10..14));
		lectiones(3, $lang);
		push(@s, "\n");
		return;
	}
	
	# Here we begin the logic for an office of three lessons. On nine-lesson days
	# we've already returned.
	if ($dayname[0] =~ /Pasc[1-6]/i && $version !~ /Trident/i) {    #??? ex
		my $tde =
		($version =~ /196/ && ($dayname[0] =~ /Pasc6/i || ($dayname[0] =~ /Pasc5/i && $dayofweek > 3))) ? '1' : '';
		my $i;
		
		if ($tde) {
			my %r = %{setupstring($lang, 'Tempora/Pasc5-4.txt')};
			@spec = split("\n", $r{'Ant Matutinum'});
		} else {
			@spec = split("\n", $spec{"Pasc Ant Dominica"});
		}
		foreach my $i (3, 4, 8, 9, 13, 14) { $psalmi[$i] = $spec[$i]; }
		if ($dayofweek == 0 || $dayofweek == 1 || $dayofweek == 4) { $psalmi[13] = $psalmi[3]; $psalmi[14] = $psalmi[4]; }
		if ($dayofweek == 2 || $dayofweek == 5) { $psalmi[13] = $psalmi[8]; $psalmi[14] = $psalmi[9]; }
	}
	if ($rule =~ /votive nocturn/i) { return votivenocturn($lang); }
	
	if (@psalmi > 9 && $rule !~ /1 Nocturn/i) {
		setbuild1("3 lectiones");
	} else {
		setbuild1("One nocturn");
	}
	
	my @psalm_indices = (0, 1, 2); 

	if ($version =~ /trident/i) {
		if ($rule !~ /1 nocturn/i) {
			push(@psalm_indices, 3, 4, 5)
		}
		@spec = ($psalmi[6], $psalmi[7]);
		
		if ($dayofweek == 6 && $rule =~ /ex C10/i) {
			@spec = split("\n", $psalmi{"BMV Versum"});
			# In the office of the BVM on Saturday under the Tridentine rubrics, Psalm 99
			# is replaced by Psalm 91, as the former is said at Lauds.
			$psalm_indices[1] = 8;
		}
		
		if ($dayname[0] =~ /(Adv|Quad|Pasc)([0-9])/i) {
			my $name = $1;
			my $i = $2;
			if ($name =~ /Quad/i && $i > 4) { $name = 'Quad5'; }
			@spec = split("\n", $psalmi{"$name $dayofweek Versum"});
		}
	}
	if (@psalmi > 9) {
		push(@psalm_indices, 5, 6, 7, 10, 11, 12);
		
		# Versum for 3 lectiones is variable
		@spec = ($psalmi[13], $psalmi[14]);
		setbuild2('Ord Versus per annum');
		$comment = 5;
	}
	
	if ($month == 12 && $day == 24) {
		@spec = split("\n", $spec{"Nat24 Versum"});
		setbuild2('Subst Versus Nat24');
		$comment = 1;
	}
	
	if ($dayname[0] =~ /Pasc[07]/i) {
		@spec = ($psalmi[3], $psalmi[4]);
		setbuild2('Subst Versus for de tempore');
		$comment = 2;
	}

	push(@psalm_indices, @spec[0,1]);

	nocturn(1, $lang, \@psalmi, @psalm_indices);
	lectiones(0, $lang);
	return;
}

#*** votivenocturn($lang)
# 3 psalm 3 lectiones for votive
sub votivenocturn {
	my $lang = shift;
	setbuild1("3 psalms 3 lectiones");
	my %w = (columnsel($lang)) ? %winner : %winner2;
	my @psalms = split('\n', $w{'Ant Matutinum'});
	my $i0;
	
	if ($dayofweek == 2 || $dayofweek == 5) {
		nocturn(1, $lang, \@psalms, (5..9));
		$i0 = 4;
	} elsif ($dayofweek == 3 || $dayofweek == 6) {
		nocturn(1, $lang, \@psalms, (10..14));
		$i0 = 7;
	} else {
		nocturn(1, $lang, \@psalms, (0..4));
	  $i0 = 1;
	}
	
	if ($rule !~ /Limit.*?Benedictio/i) {
		push(@s, "\&pater_noster");
	} else {
		push(@s, "\$Pater noster");
	}
	
	if ($winner !~ /C12/i) {
		for ($i = $i0; $i < $i0 + 3; $i++) {
			push(@s, "\&lectio($i)");
			push(@s, "\n");
		}
	} else {
		%mariae = %{setupstring($lang, subdirname('Commune', $version) . "C10.txt")};
		@a = split("\n", $mariae{Benedictio});
		setbuild2('Special benedictio');
		push(@s, "Absolutio. $a[0]");
		push(@s, "\n");
		
		for ($i = 1; $i < 4; $i++) {
			push(@s, "V. $a[1]");
			push(@s, "Benedictio. $a[1+$i]");
			push(@s, "\&lectio($i)");
			push(@s, "\n");
		}
	}
	return;
}

#*** lectiones($number, $language)
#input: the index number for the nocturn, 0 for 3 lectiones only and the language
#collects and prints the the Benedictio, and set the call for the lectiones/responsory
sub lectiones {
	my $num = shift;
	my $lang = shift;
	my $evan_regexp = translate('Evangelist', $lang);
	
	# some vernaculars have no translated parts, so add English and Latin
	# cannot use translate('Evangelist', 'English') as it is anavailable
	$evan_regexp .= '|Matt|Marc|Luc|Joannes' if ($lang !~ /Latin/);
	$evan_regexp .= '|Matt|Mark|Luke|John' if ($lang !~ /English/);
	$evan_regexp = '!(?:' . $evan_regexp . ')\s+\d+';
	$evan_regexp = qr/$evan_regexp/;
	push(@s, "\n");
	
	if ($rule !~ /Limit.*?Benedictio/i) {
		push(@s, "\&pater_noster");
	} else {
		push(@s, "\$Pater noster");
	}
	my %benedictio = %{setupstring($lang, 'Psalterium/Benedictions.txt')};
	my $i = $num;
	
	my $j0 = 0;
	my $j1 = 1 + (($num == 0) ? 0 : 2 * ($rule =~ /12 lectio/ ? 4 : 3));    # for 3 lect: 1; for 9: 7; for 12: 9 (used to look for homily)
	
	if ($num == 0 && $winner{Rank} =~ /Dominica/i) {
		$j0 = ($dayofweek == 1 || $dayofweek == 4) ? 1        # Monday, Thursday
		: ($dayofweek == 2 || $dayofweek == 5) ? 2      # Tuesday, Friday
		: ($dayofweek == 3 || $dayofweek == 6) ? 3      # Wednesday, Saturday
		: 1;                                            # Sunday (as a default in error)
		$j1 = 7;
		$i = 3;
	} elsif ($num == 0) {                                  # in the case of a single nocturn of 3 lessons
		$i =
		($dayofweek == 1 || $dayofweek == 4) ? 1        # Monday, Thursday
		: ($dayofweek == 2 || $dayofweek == 5) ? 2      # Tuesday, Friday
		: ($dayofweek == 3 || $dayofweek == 6) ? 3      # Wednesday, Saturday
		: 1;                                            # Sunday (as a default in error)
		my $w = lectio(1, $lang);                       # get first lectio
		
		if ($w =~ $evan_regexp) {                       # if first lectio is homily
			$j0 = $i;                                     # update j0 depending on dayofweek (used for Absolutio)
			$i = 3;                                       # Benedictions itself are taken from Noct. 3
		}
	} else {                                          # in the case of a regular nocturn
		$i = $num;                                      # take the Benedictions from that nocturn
	}
	my @a = split("\n", $benedictio{"Nocturn $i"});     # benedictions for nocturn / homily at single, then from 3rd
	
	if ($j0) {                                          # if homily at single nocturn only
		my @a1 = split("\n", $benedictio{"Nocturn $j0"}); # get benedictios from nocturn of the weekday as well
		$a[0] = $a1[0];                                   # and update absolutio
	}
	
	if ($rule =~ /Special Benedictio/) {
		%mariae = %{setupstring($lang, subdirname('Commune', $version) . "C10.txt")};
		@a = split("\n", $mariae{Benedictio});
		setbuild2('Special benedictio');
	}
	
	if ($rule =~ /Special Evangelii Benedictio/i && $num == 3) {
		my %w = (columnsel($lang)) ? %winner : %winner2;
		@a = split("\n", $w{Benedictio3});
		setbuild2('Special Evangelii Benedictio');
	}
	
	#absolutiones
	if ($rule !~ /Limit.*?Benedictio/i) {
		push(@s, "Absolutio. $a[0]");
		push(@s, "\n");
	}
	
	# if 1960 or monastic of ferial type diverge to sub routine
	my $ltype1960 = gettype1960();
	if ($ltype1960) { return lect1960($lang, $evan_regexp); }
	
	if ($winner =~ /sancti/i && $rule !~ /ex C1[02]/ && $rule !~ /Special Evangelii Benedictio/i) { # if winner is sanctoral
		$i = ($num > 0) ? $num : 3;
		@a = split("\n", $benedictio{"Nocturn $i"});
	}
	my $divaux = ($rule =~ /Divinum auxilium/i || $commune{Rule} =~ /Divinum auxilium/i) ? 1 : 0;
	if ($i == 3 && $winner{Rank} =~ /Mari.* Virgin/i && !$divaux) { $a[3] = $a[10]; }   # Special B.M.V. benedictio '… ipsa Virgo'
	
	#benedictiones for nocturn III
	if ($i == 3 && $rule !~ /ex C1[02]/ && $rule !~ /Special Evangelii Benedictio/i) {
		($a[3], $a[4], $a[5]) = ($a[5], $a[3], $a[4]) if ($version =~ /Monastic/i);       # Monastic requires different order for 3rd nocturn
		
		my $w = lectio($j1, $lang);             # get lectio at the spot, where we expect a homily
		
		if ($w =~ $evan_regexp) {
			$a[2] = $benedictio{Evangelica};      # if it is indeed a homily, ensure "Evangélica lectio…"
		} elsif ($a[2] =~ /(evang|Gospel)/i) {
			$a[2] = $a[5];                        # if there is no homily, replace "Evangélica lectio…"
		}
		setbuild2("B$j1. : " . beginwith($a[2]));
		
		if ($winner =~ /sancti/i && ($winner{Rank} =~ /(s\.|ss\.)/i && $winner{Rank} !~ /vigil/i) && !$divaux) {
			my $j = 6;                                                                          # "Cujus …, ipse"
			if ($winner{Rank} =~ /(virgin|vidua|poenitentis|pœnitentis|C6|C7)/i) { $j += 2; }   # "Cujus …, ipsa"
			if ($winner{Rank} =~ /ss\./i) { $j++; }                                             # "Quorum / Quarum"
			$a[($version =~ /Monastic/) ? 4 : 3] = $a[$j];                                      # Replace Benediction 8 (or 11)
		}
		if ($rule =~ /Ipsa Virgo Virginum/i && !$divaux) { $a[3] = $a[10]; }                  # Special B.M.V. benedictio '… ipsa Virgo'
		if ($rule =~ /Quorum Festum/i && !$divaux) { $a[3] = $a[7]; }                         # Feast of several saints in tempora
		setbuild2("B" . ($j1+1) . ". : " . beginwith($a[3]));
		$w = lectio($j1+2, $lang);                                                            # check if final Lectio is a commemorated Homily
		if ($w =~ $evan_regexp) { $a[4] = $benedictio{Evangelica9}; }                         # "Per evangélica dicta, …"
		setbuild2("B" . ($j1+2) . ". : " . beginwith($a[4]));
	}
	if ($version =~ /1960/ && $lang =~ /Latin/i) { $a[1] = 'Jube, Dómine, benedícere.'; }
	
	push(@s, "_");
	
	my $read_per_noct = ($rule =~ /12 lectio/) ? 4 : 3;
	
	$num = 1 if ($num < 1);
	
	for my $i (1..$read_per_noct) {                 # push all the lectios
		my $l = ($num - 1) * $read_per_noct + $i;
		if ($rule !~ /Limit.*?Benedictio/i) {
			push(@s, "V. $a[1]");                       # push "Jube, …"
			push(@s, "Benedictio. $a[$i+1]");           # push Benedictio
		}
		push(@s, "\&lectio($l)");                     # the lesson is going to be added by the subroutine below at a later time
		push(@s, "\n");
	}
}

sub matins_lectio_responsory_alleluia(\$$) {
	my ($r, $lang) = @_;
	
	my @resp = split("\n", $$r);
	ensure_single_alleluia($resp[1], $lang);
	ensure_single_alleluia($resp[3], $lang);
	ensure_single_alleluia($resp[-1], $lang);
	$$r = join("\n", @resp);
}
#
#*** getC10readingname
sub getC10readingname {
	return "Lectio M101" if ($version !~ /196/ && $month == 9 && $day > 8 && $day < 15);
	my $satnum = floor(($day - 1) / 7 + 1);
	$satnum = 4 if ($satnum == 5);
	return sprintf("Lectio M%02i%s", $month, ($version =~ /Monastic/i) ? $satnum : '');
}

#*** lectio($num, $lang)
# input $num=index number for the lectio(1-9 or 1-3) and language
# print the appropriate lectio collected from the winner or commune
# handles the commemoratio as last
sub lectio : ScriptFunc {
	my $num = shift;
	my $lang = shift;
	$ltype1960 = gettype1960();
	if ($winner =~ /C12/i) { $ltype1960 = 0; }  # Officium parvum B.M.V.
	
	if ($ltype1960 == 2 && $num == 3) {     # 3rd reading in a Sunday office
		$num = 7;       # diverge to Gospel / Homily
	} elsif (
	($ltype1960 == 3 && $num == 3 && $votive !~ /(C9|Defunctorum)/i) # 3rd reading in sanctoral office of 3 readings
	|| (
	$version !~ /1960/
	&& $rule !~ /1 et 2 lectiones/i
	&& $num == 3
	&& $winner =~ /Sancti/i
	&& $rank < 2
	&& $winner{Rank} !~ /vigil/i
	&& ( $version !~ /monastic/i
	|| $dayname[0] !~ /Nat|Epi1/i)
	)      # sanctoral simplex feast (unless monastic in Nativitytide and Epiphany => prevent the former Octave days of Stephanus, Joannes, Innocents)
	)
	{
		$num = 4;   # diverge to legend
	}
	my %w = (columnsel($lang)) ? %winner : %winner2;
	

	if ($num < 4 && $version =~ /trident/i && $winner{Rank} =~ /Dominica/i && $dayofweek > 0) {
		my $inum = $num + 6;
		$w{"Lectio$num"} = $w{"Lectio$inum"};
		if ($num==1) {
			setbuild2("Lectio de Homilia Dominicæ anticipiata")
		}
	}
	
	#Nat1-0 special rule
	# TODO: Get rid of this special case by separating the temporal and sanctoral
	# parts of Christmas, thus allowing occurring Scripture to be defined.
	if ($num <= 3 && $rule =~ /Lectio1 OctNat/i) {
		my $c;
		
		if ($day < 29) {
			$c = officestring($lang, "Sancti/12-25.txt"); # GitHub3539: in 1960 rubrics, Scripture on Sunday (26-28) comes from Nativity
		} else {
			my $tfile = "Tempora/Nat$day" . ($version =~ /trident/i ? "o.txt" : ".txt");
			$c = officestring($lang, $tfile);
		}
		$c->{'Lectio2'} .= $c->{'Lectio3'} if (contract_scripture(2));
		
		$w{"Lectio$num"} = $c->{"Lectio$num"};
		$w{"Responsory$num"} = $c->{"Responsory$num"};
	}
	
	# special rule for not having "Ss. Nominis" and missing readings on 01-13 for Monastic
	# add first nocturn lessons from the actual tempora // as TempraM/Epi1-….txt is still incomplete it leads to issues on 01-13
	# TODO: get TemporaM folder updated and completed
	if ((($winner eq 'TemporaM/Nat2-0.txt') || ($winner eq 'SanctiM/01-13.txt')) && $num <= 4) {
		$c = officestring($lang,
		$winner =~ /Tempora/ ? sprintf("SanctiM/01-%02d.txt",$day) : "TemporaM/Epi1-$dayofweek.txt");
		$w{"Lectio$num"} = $c->{"LectioM$num"} || $c->{"Lectio$num"};
	}
	
	#Lectio1 tempora
	if ($num <= 3 && $rule =~ /Lectio1 tempora/i && exists($scriptura{"Lectio$num"})) {
		my %c = (columnsel($lang)) ? %scriptura : %scriptura2;
		$w{"Lectio$num"} = $c{"Lectio$num"};
		
		if ($version =~ /Trident/i && exists($w{"ResponsoryT$num"})) {
			$w{"Responsory$num"} = $c{"Responsory$num"};
		} else {
			$w{"Responsory$num"} = $c{"Responsory$num"};
		}
	}
	
	# TODO: There seems to be a mismatch between taking care of a conflict of Die VII infra 8vam Immaculata Conceptio. and Q.T. in Adventum
	# The lessons are repeated from the feast day 12-08 unless it is Feria IV Q.T.?
	if($version =~ /(Trident|Divino)/i && $month == 12 && $day == 14 && $dayofweek !~ 3){ $w{"Lectio$num"} = $c{"Lectio$num"};}
	
	#scriptura1960
	if ( $num < 3
		&& $version =~ /1960/
		&& $rule =~ /scriptura1960/i
		&& exists($scriptura{"Lectio$num"}))
	{
		my %c = (columnsel($lang)) ? %scriptura : %scriptura2;
		$w{"Lectio$num"} = $c{"Lectio$num"};
		
		if ($num == 2 && $votive !~ /(C9|Defunctorum)/i && ($dayname[1] !~ /feria/i || $commemoratio)) {
			if ($w{Lectio2} =~ /(.*?)\_/s) { $w{Lectio2} = $1; }
			my $w1 = $c{"Lectio3"};
			$w{Lectio2} .= $w1;
		}
	}
	
	#** handle initia table (Str$ver$year)
	if ($num < 4 && $version !~ /monastic/i) {
		my $file = initiarule($month, $day, $year);
		if ($file) { %w = resolveitable(\%w, $file, $lang); }
	}
	
	#StJamesRule
	if ($num < 4 && $rule =~ /StJamesRule=([a-z,]+)\s/i)    #was also: && $version !~ /1961/
	{
		%w = StJamesRule(\%w, $lang, $num, $1);
	}
	
	#Sancta Maria Sabbato special rule
	if ($winner =~ /C12/i) {
		if (($version =~ /1960/ || ($winner =~ /Sancti/i && $rank < 2)) && $num == 4) { $num = 3; }
		$num = $num % 3;
		if ($num == 0) { $num = 3; }
	}
	my $w = $w{"Lectio$num"};
	if (($num < 4 || ($num == 4 && $rule =~ /12 lectiones/i)) && $rule =~ /Lectio1 Quad/i && $dayname[0] !~ /Quad/i) { $w = ''; } # some saints in April when after easter
	if (($num < 4 || ($num == 4 && $rule =~ /12 lectiones/i)) && $commemoratio{Rank} =~ /Quattuor/i && $month == 9) { $w = ''; } # Q.T. Septembris...
	
	if ($w && $num % 3 == 1) {
		my @n = split('/', $winner);
		setbuild2("Lectio$num ex $n[0]");
	}
	
	#prepares for case of homily instead of scripture
	my $homilyflag = (exists($commemoratio{Lectio1})
		&& $commemoratio{Lectio1} =~ /\!(Matt|Mark|Marc|Luke|Luc|Joannes|John)\s+[0-9]+\:[0-9]+\-[0-9]+/i) ? 1 : 0;
	if (!$w         # we don't have a lectio yet
		&& (($communetype =~ /^ex/i && $commune !~ /Sancti/i && $rank > 3)      # either we have 'ex C.' on Duplex majus or higher
		|| ( ($num < 4 || ($num == 4 && $rule =~ /12 lectiones/i))              # or we are in the first nocturn
		&& $homilyflag                                                          # and there is a homily to be commemorated
		&& exists($commune{"Lectio$num"})                                     # which has not been superseded by the sanctoral
	)
	)
	) {
		%w = (columnsel($lang)) ? %commune : %commune2;
		$w = $w{"Lectio$num"};
		if ($w && $num == 1) { setbuild2("Lectio1-3 from Tempora/$file replacing homily"); }
	}
	
	# fill with Scriptura for 1st nocturn if possible
	if (!$w                                                     # we still don't have a lectio yet as there is no homily
		&& ($num < 4 || ($num == 4 && $rule =~ /12 lectiones/i))  # for the first nocturn
		&& exists($scriptura{"Lectio$num"})                       # there is scripture available
	&& ($version !~ /trident/i || $rank < 5)                  # but not in Tridentinum Duplex II. vel I. classis
	)   {
		%w = (columnsel($lang)) ? %scriptura : %scriptura2;
		$w = $w{"Lectio$num"};
		if ($w && $num == 1) { setbuild2("Lectio1 ex scriptura"); }
	} elsif (!$w && $num == 4 && exists($commemoratio{"Lectio$num"}) && ($version =~ /1960/i)) { # handle diverged 3rd lesson in 1960
		%w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
		$w = $w{"Lectio$num"};
		if ($w && $num == 4) { setbuild2("Lectio3 ex commemoratio"); }
	}
	
	if (contract_scripture($num)) {
		if ($w =~ /(.*?)\_/s) { $w = $1; }
		my $w1 = $w{'Lectio3'};
		
		#$w1 =~ s/^\!.*?\n//;
		$w .= $w1;
	}
	if ($version =~ /monastic/i && $num == 3) { $w = monastic_lectio3($w, $lang); }
	
	#look for commune if sancti and 'ex' or 'vide'
	if (!$w && $winner =~ /sancti/i && $rule =~ /(ex\s*C|vide\s*C)/i) {
		my %com = (columnsel($lang)) ? %commune : %commune2;
		
		if (exists($com{"Lectio$num"})) {
			$w = $com{"Lectio$num"};
			if ($w && $num % 3 == 1) { setbuild2("Lectio$num ex $commune{Name}"); }
		}
	}
	
	if (!$w && exists($commune{"Lectio$num"})) {
		my %c = (columnsel($lang)) ? %commune : %commune2;
		$w = $c{"Lectio$num"};
		
		if ($num == 2 && $version =~ /1960/) {
			my $w1 = $c{'Lectio3'};
			$w .= $w1;
		}
	}
	
	if ($commune{Rule} =~ /Special Lectio $num/) {
		%mariae = %{setupstring($lang, subdirname('Commune', $version) . "C10.txt")};
		my $name = getC10readingname();
		$w = $mariae{$name};
		setbuild2("Mariae $name");
	}
	
	# Combine lessons 8 and 9 if there's a commemoration to be read in place of
	# lesson 9, and if the office of the day requires it. In fact the rubrics
	# always *permit* such a contraction, but we don't support that yet.
	if ( $version !~ /1960/
		&& $num == 8
		&& $rule =~ /Contract8/i
		&& (exists($winner{Lectio93}) || exists($commemoratio{Lectio7})))
	{
		%w = (columnsel($lang)) ? %winner : %winner2;
		$w = $w{Lectio8} . $w{Lectio9};
		$w =~ s/\&teDeum//;
	}
	my $wo = $w;
	
	#look for commemoratio 9
	#if ($rule =~ /9 lectio/i && $rank < 2) {$rule =~ s/9 lectio//i;}
	if ( $version !~ /196/
		&& $commune !~ /C10/
		&& $rule !~ /no93/i
		&& $winner{Rank} !~ /Octav.*(Epi|Corp)/i
		#&& ($dayofweek != 0 || $winner =~ /Sancti/i || $winner =~ /Nat2/i)
		&& (($rule =~ /9 lectio/i && $num == 9 && !exists($winner{Responsory9})) || ($rule !~ /9 lectio/i && $num == 3 && $winner !~ /Tempora/i && !exists($winner{Responsory3})))
			|| ($rank < 2 && $winner =~ /Sancti/i && $num == 4))
	{
		%w = (columnsel($lang)) ? %winner : %winner2;
		
		if (($w{Rank} =~ /Simplex/i || ($version =~ /1955/ && $rank == 1.5)) && exists($w{'Lectio94'})) {
			setbuild2("Last lectio Commemoratio ex Legenda historica (#94)");
			$w = $w{'Lectio94'};
		} elsif (exists($w{'Lectio93'})) {
			setbuild2("Last lectio Commemoratio ex Sanctorum (#93)");
			$w = $w{'Lectio93'};
		}
		
		if (
			($commemoratio =~ /tempora/i && $commemoratio !~ /Nat30/i || $commemoratio =~ /01\-05/)
			&& ($homilyflag || exists($commemoratio{Lectio7}))
		&& $comrank > 1
		&& ( $rank > 4
		|| ($rank >= 3 && $version =~ /Trident/i)
		|| $homilyflag
		|| exists($winner{Lectio1}))
		)
		{
			%w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
			$wc = $w{"Lectio7"};
			$wc ||= $w{"Lectio1"};
			
			if ($wc) {
				setbuild2("Last lectio Commemoratio ex Tempore #1");
				my %comm = %{setupstring($lang, 'Psalterium/Comment.txt')};
				my @comm = split("\n", $comm{'Lectio'});
				$comment = ($commemoratio{Rank} =~ /Feria/) ? $comm[0] : ($commemoratio =~ /01\-05/) ? $comm[3] : $comm[1];
				$w = setfont($redfont, $comment) . "\n$wc";
			}
		}
		
		if ($transfervigil) {
			if (!(-e "$datafolder/$lang/$transfervigil")) { $transfervigil =~ s/v\.txt/\.txt/; }
			my %tro = %{setupstring($lang, $transfervigil)};
			if (exists($tro{'Lectio Vigilia'})) { $w = $tro{'Lectio Vigilia'}; }
		}
		my $cflag = 1;    #*************  03-30-10
		#if ($winner{Rule} =~ /9 lectiones/i && exists($winner{Responsory9})) { $cflag = 0; }
		#if ($winner{Rule} !~ /9 lectiones/i && exists($winner{Responsory3})) { $cflag = 0; }
		
		if ( $commemoratio =~ /sancti/i
			&& $commemoratio{Rank} =~ /S\. /i
		&& ($winner !~ /tempora/i || $winner{Rank} < 5)
		&& ($version !~ /1955/ || $comrank > 4)
		&& $cflag)
		{
			%w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
			my $ji = 94;
			$wc = $w{"Lectio$ji"};
			
			if (!$wc && $w{Rank} !~ /infra octav/i) {
				$wc = '';
				
				for ($ji = 4; $ji < 7; $ji++) {
					my $w1 = $w{"Lectio$ji"};
					if (!$w1 || ($ji > 4 && $w1 =~ /\!/)) { last; }
					if ($wc =~ /(.*?)\_/s) { $wc = $1; }
					$wc .= $w1;
				}
			}
			$wc ||= $w{"Lectio93"};
			
			if ($wc) {
				setbuild2("Last lectio: Commemoratio from Sancti #$ji");
				if($wc !~ /\!/) {	# add Commemoratio comment if not there already
					my %comm = %{setupstring($lang, 'Psalterium/Comment.txt')};
					my @comm = split("\n", $comm{'Lectio'});
					$comment = $comm[2];
					$w = setfont($redfont, $comment) . "\n$wc";
				} else {
					$w = $wc;
				}
				
			}
		}
		if ($winner{Rank} =~ /Octav.*(Epi|Corp)/i && $w !~ /!.*Vigil/i) { $w = $wo; }
		;    #*** if removed from top
		if (exists($w{'Lectio Vigilia'})) { $w = $w{'Lectio Vigilia'}; }
		#if ($w =~ /!.*?Octav/i || $w{Rank} =~ /Octav/i) { $w = $wo; setbuild2("transfervigil deleted");}
		$w = addtedeum($w);
	}
	
	if ($ltype1960 == 3 && $num == 4) {
		if (exists($w{'Lectio94'})) {
			$w = $w{'Lectio94'};
		}    #contracted legend for commemoratio
		else {
			my $w1 = %w;
			if ($version =~ /newcal/i && !exists($w{Lectio5})) { %w = (columnsel($lang)) ? %commune : %commune2; }
			my $i = 5;
			
			while ($i < 7) {
				my $w1 = $w{"Lectio$i"};
				if (!$w1 || $w1 =~ /\!/) { last; }
				if ($w =~ /(.*?)\_/s) { $w = $1; }
				$w .= $w1;
				$i++;
			}
			%w = %w1;
		}
	}
	if (($ltype1960 || ($winner =~ /Sancti/i && $rank < 2)) && $num > 2) { $num = 3; $w = addtedeum($w); }
	if ($num == 3 && $winner =~ /Tempora/ && $rule !~ /9 lectiones/i && $rule =~ /Feria Te Deum/i) { $w = addtedeum($w); }
	if ($version =~ /monastic/i) { $w =~ s/\&teDeum//g; } # remove te deum from ninth/twelve lesson as it comes only after the last response
	
	#get item from [Responsory$num] if no responsory
	if ($w && $w !~ /\nR\./ && $w !~ /\&teDeum/i) {
		my $s = '';
		$na = $num;
		
		if ($version =~ /1960/ && $winner =~ /tempora/i && $dayofweek == 0 && $dayname[0] =~ /(Adv|Quad)/i && $na == 3) {
			$na = 9;
		}
		if (contract_scripture($num) && $version !~ /Monastic/i) { $na = 3; }
		
		if ($version =~ /1955|1960/ && exists($w{"Responsory$na 1960"})) {
			$s = $w{"Responsory$na 1960"};
		} elsif ($rule =~ /Responsory Feria/i) {
			if (exists($scriptura{"Responsory$na"})) {
				$s = (columnsel($lang)) ? $scriptura{"Responsory$na"} : $scriptura2{"Responsory$na"};
			} else {
				$s = (columnsel($lang)) ? $scriptura{"Lectio$na"} : $scriptura2{"Lectio$na"};
				
				if ($s =~ /\n\_(.*?)/s) {
					$s = "_$1";
				} else {
					$s = '';
				}
			}
			
			if (!$s && $version =~ /1960/ && exists($scriptura{"Responsory$na 1960"})) {
				$s = (columnsel($lang)) ? $scriptura{"Responsory$na 1960"} : $scriptura2{"Responsory$na 1960"};
			}
		} else {
			if ($version =~ /monastic/i && $dayofweek != 0 && $month == 1 && $day > 6 && $day < 13) {
				$na += 4 if ($dayofweek == 2 || $dayofweek == 5) ;
				if ($dayofweek == 3) { # Saturday dont work due C10 || $dayofweek == 6 ) {
					$na += 1 if ($na > 1);
					$na += 8;
				}
			}
			if (exists($w{"Responsory$na"})) {
				$s = $w{"Responsory$na"};
			} elsif ($version =~ /1960/ && exists($commune{"Responsory$na"})) {
				my %c = (columnsel($lang)) ? %commune : %commune2;
				$s = $c{"Responsory$na"};
			}
			if (exists($winner{"Responsory$na"})) { $s = ''; }
			
			#$$$ watch initia rule
		}
		
		if (!$s) {
			my %w = (columnsel($lang)) ? %winner : %winner2;
			if ($winner =~ /C9/ && $na == 9) { $na = 91; }
			if (exists($w{"Responsory$na"})) { $s = $w{"Responsory$na"}; }
			
			if (!$s) {
				%w = (columnsel($lang)) ? %commune : %commune2;
				if (exists($w{"Responsory$na"})) { $s = $w{"Responsory$na"}; }
			}
		}
		matins_lectio_responsory_alleluia($s, $lang) if alleluia_required($dayname[0], $votive);
		$w =~ s/\s*$/\n\_\n$s/;
	}
	$w = responsory_gloria($w, $num);
	
	#add Tu autem before responsory
	if ($expand =~ /all/) {
		our %prayers;
		$tuautem = $prayers{$lang}->{'Tu autem'};
	} else {
		$tuautem = '$Tu autem';
	}
	$w =~ s/^\_//;
	
	if ($rule !~ /Limit.*?Benedictio/i) {
		my $before = '';
		my $rest = $w;
		$rest =~ s/[\n\_ ]*$//gs;
		while ($rest =~ /(.*?)_(.*)/s) { $before .= "$1_"; $rest = $2; }
		if (!$before) { $before = $w; $rest = ''; }
		$before =~ s/[\n\_ ~]*$//gs;
		
		if ($before =~ /(.*?)\&teDeum/s) {
			$before = $1;
			$rest = "&teDeum\n";
		} elsif ($rest =~ /(.*?)\&teDeum/s) {
			$before .= "\n_\n$1";
			$rest = "&teDeum\n";
		}
		$w = "$before" . "\n$tuautem\n_\n$rest";
	}
	
	# add initial to text
	if ($w !~ /^!/m) {
		$w =~ s/^(?=\p{Letter})/v. /;
	} elsif ($w !~ /^\d/m) {
		$w =~ s/^!.*?\n(?=\p{Letter})/$&v. /gm;
	}
	
	#handle verse numbers for passages
	my $item = translate('Lectio', $lang);
	$item .= " %s" unless ($item =~ /%s/);
	$w = "_\n" . setfont($largefont, sprintf($item,$num)) . "\n$w";
	my @w = split("\n", $w);
	$w = "";
	
	my $initial = $nonumbers;
	foreach (@w) {
		if (/^([0-9]+)\s+(.*)/s) {
			my $rest = $2;
			my $num = "\n" . setfont($smallfont, $1);
			$rest =~ s/^./\u$&/ unless ($nonumbers);
			if ($initial) {
				$num = "\nv. ";
				$initial = 0;
			} elsif ($nonumbers) {
				$num = '';
			}
			$_ = "$num $rest";
		} else {
			$initial = 1 if (/^!/ && $nonumbers);
			$_ = "\n$_";
		}
		$w .= "$_";
	}

	process_inline_alleluias($w);
	
	#handle parentheses in non Latin
	if ($lang !~ /Latin/i) {
		$w =~ s/\((.*?[.,\d].*?)\)/parenthesised_text($1)/eg;
	}
	$w = replaceNdot($w, $lang);
	return $w;
}

sub parenthesised_text {
	my $text = shift;
	return setfont(our $smallfont, $text)
	if (length($text) < 20 || $text =~ /[0-9][.,]/);
	return "($text)";
}

#Te Deum instead of responsory
sub addtedeum {
	my $w = shift;
	
	if ($rule =~ /no Te Deum/i
		|| ($winner =~ /(Tempora|C12A|C12Q)/i && $dayname[0] =~ /(Adv|Quad)/i) && $winner{Rank} !~ /Septem dolorum/i)
	{
		$w =~ s/\&teDeum//;
	}
	
	if ($w =~ /teDeum/i || $winner =~ /C12/i || ($rule =~ /no Te Deum/i && ($winner !~ /12-28/ || $dayofweek > 0))) {
		return $w;
	}
	if ($votive =~ /(C9|Defunctorum)/i) { return ($w); }
	if ($winner =~ /Tempora/i && $dayname[0] =~ /(Adv|Quad)/i && $winner !~ /C10/i) { return $w; }
	if ($month == 12 && $day == 24) { return $w; }
	
	if ( ($rank >= 2 && $dayname[1] !~ /(feria|vigilia)/i && $rule !~ /Responsory9/i)
		|| ($rule =~ /Feria Te Deum/i || $winner =~ /Sancti/i || $winner =~ /C10/i))
	{
		my $before = ($w =~ /(.*?)(\nR. |\n\@)/s) ? $1 : $w;
		$before =~ s/\_$//;
		$before =~ s/\n*$//;
		$w = "$before" . "\n\&teDeum\n";
	}
	return $w;
}

#*** beginwith($str)
# formats the benediction for building script output
sub beginwith {
	my $str = shift;
	my @str = split(" ", $str);
	$str = "$str[0] $str[1]";
	$str =~ s/\n/ /g;
	return $str;
}

#*** lect1960($lang)
# sets the benedictiones and sub calls for the 1960 version 3 lection
sub lect1960 {
	
	my $lang = shift;
	my $evan_regexp = shift;
	my %w = (columnsel($lang)) ? %winner : %winner2;
	my %s = (columnsel($lang)) ? %scriptura : %scriptura2;
	my %benedictio = %{setupstring($lang, 'Psalterium/Benedictions.txt')};
	my $i = 3;
	
	if ($rank < 2 || $winner{Rank} =~ /Feria/) {
		$i = ($dayofweek % 3);
		if ($i == 0) { $i = 3; }
	}
	my $w = lectio(1, $lang);
	if ($w =~ $evan_regexp) { $i = 3; }
	my @a = split("\n", $benedictio{"Nocturn $i"});
	
	if ($rule =~ /ex C10/) {
		my %m = (columnsel($lang)) ? %commune : %commune2;
		@a = split("\n", $m{Benedictio});
		setbuild2('Special benedictio');
	}
	my $divaux = ($rule =~ /Divinum auxilium/i || $commune{Rule} =~ /Divinum auxilium/i) ? 1 : 0;
	
	if ($winner =~ /sancti/i && $rank >= 2 && ($winner{Rank} =~ /(s\.|ss\.)/i && $winner{Rank} !~ /vigil/i) && !$divaux) {
		my $j = 6;
		if ($winner{Rank} =~ /(virgin|vidu|víduæ|poenitentis|pœnitentis)/i) { $j += 2; }
		if ($winner{Rank} =~ /ss\./i) { $j++; }
		$a[3] = $a[$j];
	}
	if ($rule =~ /Ipsa Virgo Virginum/i || $winner{Rank} =~ /Mari\w*\b\s*Virgin/i) { $a[3] = $a[10]; }
	if ($rule =~ /Quorum Festum/i && !$divaux) { $a[3] = $a[7]; }
	if ($rule =~ /Quarum Festum/i && !$divaux) { $a[3] = $a[9]; }
	$w = $w{'Lectio1'};
	if (!$w) { $w = $s{'Lectio1'}; }
	
	if ($w =~ $evan_regexp) {
		$a[2] = $benedictio{Evangelica};
	} else {
		if (exists($a[6])) { $a[2] = $a[5]; }
		if ($winner{Rank} =~ /dominica/i) { $a[4] = $benedictio{Evangelica9}; }
	}
	setbuild2("B3 : " . beginwith($a[4]));
	if ($version =~ /1960/ && $lang =~ /Latin/i) { $a[1] = 'Jube, Dómine, benedícere.'; }
	push(@s, "_");
	
	if ($rule !~ /Limit.*?Benedictio/i) {
		push(@s, "V. $a[1]");
		push(@s, "Benedictio. $a[2]");
	}
	push(@s, "\&lectio(1)");
	push(@s, "\n");
	
	if ($rule !~ /Limit.*?Benedictio/i) {
		push(@s, "V. $a[1]");
		push(@s, "Benedictio. $a[3]");
	}
	push(@s, "\&lectio(2)");
	push(@s, "\n");
	
	if ($rule !~ /Limit.*?Benedictio/i) {
		push(@s, "V. $a[1]");
		push(@s, "Benedictio. $a[4]");
	}
	push(@s, "\&lectio(3)");
	push(@s, "\n");
}
use constant {
	LT1960_DEFAULT => 0,
	LT1960_FERIAL => 1,
	LT1960_SUNDAY => 2,
	LT1960_SANCTORAL => 3,
	LT1960_OCTAVEII => 4
};

#*** gettype1960
#returns for 1960 version
#  1 for ferial office
#  2 for Sunday office
#  3 for saint's office
#  4 for office within II. cl. octave
# 0 for the other versions or if there are 9 lectiones
sub gettype1960 {
	my $type = LT1960_DEFAULT;
	
	if ($version =~ /196/ && $votive !~ /(C9|Defunctorum)/i) {
		if ($dayname[1] =~ /post Nativitatem/i) {
			$type = LT1960_OCTAVEII;
		} elsif ($rank < 2 || $dayname[1] =~ /(feria|vigilia|die)/i) {
			$type = LT1960_FERIAL;
		} elsif ($version !~ /Monastic/i && ($dayname[1] =~ /dominica.*?semiduplex/i || $winner =~ /Pasc1\-0/i)) {
			$type = LT1960_SUNDAY;
		} elsif ($rank < 5) {
			$type = LT1960_SANCTORAL;
		}
		if ($rule =~ /9 lectiones 1960|12 lectiones/i) { $type = LT1960_DEFAULT; }
	}
	return $type;
}

#*** responsory_gloria($lectio_text, $num)
# adds or removes \&gloria to lection
# return the modified lectio text
#
sub responsory_gloria {
	my $w = shift;
	my $num = shift;
	$w =~ s/\&Gloria1?/\&Gloria1/g;
	$prev = $w;
	if ($w =~ /(.*?)\&Gloria/is) { $prev = $1; }
	$prev =~ s/\s*$//gm;
	
	if ($w =~ /\&teDeum/i || ($num == 1 && $dayname[0] =~ /Adv1|Pasc0/i && $dayofweek == 0) || $rule =~ /requiem Gloria/i)
	{
		return $w;
	}
	if ($num == 2 && $version =~ /1960/ && $dayname[0] =~ /(Adv|Quad)/i && $winner =~ /Tempora/i) { return $prev; }
	
	if ($num == 8 && $winner =~ /12-28/ && $dayofweek == 0) {
		delete($winner{Responsory9});
		delete($winner2{Responsory9});
	}
	if ($num == 8 && exists($winner{Responsory9}) && ($rule !~ /12 lectio/)) { return $w; }
	if ($version =~ /Monastic/i && $num == 2) { return $prev; }
	my $flag = 0;
	
	my $read_per_noct = ($rule =~ /12 lectio/) ? 4 : 3;
	if (
		($num % $read_per_noct == 0)
		|| ($rule =~ /9 lectiones/i && ($winner !~ /tempora/i || $dayname[0] !~ /(Adv|Quad)/i) && $num == 8)
		|| ( $version =~ /1960/
		&& $rule =~ /9 lectiones/i
		&& $rule =~ /Feria Te Deum/i
		&& $num == 2
		&& ($dayname[0] !~ /quad/i))
		|| (gettype1960() > 1 && $num == 2 && $winner !~ /C12/)
		|| ($rank < 2 && $num == 2 && $winner =~ /(Sancti)/)
		|| ($num == 2 && $winner =~ /C10/)
		|| ($num == 2 && ($rule =~ /Feria Te Deum/i || $dayname[0] =~ /Pasc[07]/i) && $rule !~ /9 lectiones/i)
		)
	{
		if ($w !~ /\&Gloria/i) {
			$w =~ s/[\s_]*$//gs;
			$line = ($w =~ /(R\..*?$)/) ? $1 : '';
			$w .= "\n\&Gloria1\n$line";
		}
		return $w;
	}
	return $prev;
}

#*** ant matutinum_paschal(@_ref, $lang)
# sets matutinum antiphonas in pascal tide
sub ant_matutinum_paschal {
	my ($psalmi_ref, $lang, $proper) = @_;
	my @psalmi = @$psalmi_ref;
	our(@dayname, $version, $winner);

	if ($dayofweek || ($dayname[0] =~ /Pasc6/ && $version =~ /196/)) {
		if (!$proper || $winner =~ /\/C10/) {
			@psalmi = map { s/.*?;/;/r } @psalmi;
			$psalmi[0] = Alleluia_ant($lang) . $psalmi[0];
			if ($dayofweek && $rule =~ /9 lectio/i && ($version !~ /196/ || $rank > 3) && $rank >= 2) { #3 nocturns
				$psalmi[5] = Alleluia_ant($lang) . $psalmi[5];
				$psalmi[10] = Alleluia_ant($lang) . $psalmi[10];
			}
		}	elsif ($winner !~ /tempora/i) { # each nocturn under single antiphonas apart Ascension
			foreach my $i (0..3) {
				$psalmi[$i*5+1] =~ s/.*;;/;;/;
				$psalmi[$i*5+2] =~ s/.*;;/;;/;
			}
		}
	} else {
		if ($dayname[0] =~ /Pasc[1-5]/i && $dayname[1] =~ /Dominica/) {
			my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi matutinum.txt')};
			my @a = split("\n", $psalmi{Pasc0});
			for (my $i=0; $i<@psalmi; $i++) {
				$psalmi[$i] =~ s/.*;;/$a[$i]/;
			}
			if ($version =~ /196/) { # one nocturn under single antiophona
				for (my $i=1; $i<@psalmi; $i++) {
					$psalmi[$i] =~ s/.*;;/;;/;
				}
			}
		}
	}
	@psalmi;
}

#*** initiarule($month, $day, $year)
# returns the key from the proper Str$ver$year table for the date
sub initiarule {
	my $month = shift;
	my $day = shift;
	my $year = shift;
	
	my $key = sprintf("%02i-%02i", $month, $day);
	
	return get_stransfer($year, $version, $key);
}

#*** resolveitable(\%w, $file, $lang)
# input %w = winner hash; $file = Str$ver$year table actual line
# returns the winner hash
sub resolveitable {
	
	my $w = shift;
	my $file = shift;
	my $lang = shift;
	my %w = %$w;
	my (%winit, @file, $lim, $start, $i);
	
	if ($file !~ /\~B$/ || !$initia) {  # ==> !( ~B && $initia ); unless there is a conflict between a B rule and a initia
		$file =~ s/~[AB]$//;            # remove ~A or ~B from the end of the string
		@file = split('~', $file);      # gather the transfered intias
		$lim = 3;                       # in general, allow up to 3 transferals
		$start = 1;                     # in general, start at 1
		
		if ($initia) {                  # if we have a inita on the day already (so we put the transferred afterwards)
			$start = (@file < 2) ? 3 : 2;   # if we have one transferred place it no. at 3; otherwise at 2&3
			if ($rule !~ /(9|12) lectiones/i && $winner =~ /Sancti/i) { $lim = 1; $start = 1; } # in a sanctoral of 3 lessons, only one transfer is allowed; and placed at the beginning
		}
		$i = 1;
		
		while (@file && $i <= $lim) {   # while we have more transferals and stay in the limit
			$file = shift(@file);
			%winit = %{setupstring($lang, subdirname('Tempora', $version) . "$file.txt")};
			
			#$w{"Lectio$start"} = $winit{"Lectio$i"};
			#if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
			%w = tferifile(\%w, \%winit, $start, 1, $lang);
			$i++;
			$start++;
		}
		
		while ($start <= 3) { # only in case we put transfers "before", also transfer the remaining parts of the last initia (apparently this can only happen with a single transfer as well, so we can use $i equal to $start ???)
			
			#$w{"Lectio$start"} = $winit{"Lectio$i"};
			#if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
			%w = tferifile(\%w, \%winit, $start, $i, $lang);
			$i++;
			$start++;
		}
	} else {        # when there is a conflict of a ~B transfer and an inita itself
		$file =~ s/~[AB]$//;
		@file = split('~', $file);
		$lim = 1;       # in general allow 1 transfer and
		$start = 2;     # put the actual days in second place
		if (@file > 1 && !($rule !~ /(9|12) lectiones/i && $winner =~ /Sancti/i)) { $lim = 2; $start = 3; } # if there is more than 1 transferal which is not impeded by a Sanctoral office of 3 lections, allow 2 and put the actual day inita at 3
		
		if (exists($w{'Lectio2'})) {
			%winit = %w;
		} else {
			%winit = (columnsel($lang)) ? %scriptura : %scriptura2;
		}
		$i = 1;
		
		while ($start < 4) {    # first fill the actual day's inita at their appropriate place
			
			#$w{"Lectio$start"} = $winit{"Lectio$i"};
			#if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
			%w = tferifile(\%w, \%winit, $start, $i, $lang);
			$i++;
			$start++;
		}
		$i = 1;
		$start = 1;
		
		while (@file && $i <= $lim) {   # second, fill the transfers beforehand
			$file = shift(@file);
			%winit = %{setupstring($lang, subdirname('Tempora', $version) . "$file.txt")};
			
			#$w{"Lectio$start"} = $winit{"Lectio$i"};
			#if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
			%w = tferifile(\%w, \%winit, $start, 1, $lang);
			$i++;
			$start++;
		}
	}
	return %w;
}

#*** sub tferifile(/$w, /$winit, $start, $i, $lang)
# fill $w{Lectio$start} and conditionally $w{Responsory$start} from %winit office
sub tferifile {
	my ($w, $winit, $start, $i, $lang) = @_;
	my %w = %$w;
	my %winit = %$winit;
	$w{"Lectio$start"} = $winit{"Lectio$i"};
	
	if (($winit{Rule} =~ /Initia cum Responsory/i || $winit{Rank} =~ /Dominica/i) && exists($winit{"Responsory$i"})) {
		$w{"Responsory$start"} = $winit{"Responsory$i"};
	} elsif (!exists($w{"Responsory$start"})) {
		my %s = (columnsel($lang)) ? %scriptura : %scriptura2;
		$w{"Responsory$start"} = $s{"Responsory$i"};
	}
	return %w;
}

#*** STJamesRule(\%w, $lang, $num, $book);
# returns the modified hash
sub StJamesRule {
	
	my $w = shift;
	my $lang = shift;
	my $num = shift;
	my $s = shift;
	my %w = %$w;
	my %w1 = undef;
	my $key;
	
	if ($w{Rank} =~ /Dominica/i && prevdayl1($s)) {
		my $kd = "$dayname[0]-1";
		if ($ordostatus =~ /Ordo/i) { return $kd; }
		%w1 = %{setupstring($lang, subdirname('Tempora', $version) . "$kd.txt");};
	}
	
	if ($w{Rank} =~ /Jacobi/ && $scriptura{Lectio1} =~ /!.*?($s) /i) {
		if ($ordostatus =~ /Ordo/) { $s = $scriptura; $s =~ s/(Tempora\/|\.txt)//gi; return $s; }
		%w1 = columnsel($lang) ? %scriptura : %scriptura2;
	}
	if (!exists($w1{"Lectio$num"})) { return %w; }
	$w{"Lectio$num"} = $w1{"Lectio$num"};
	return %w;
}

sub prevdayl1 {
	my @monthtab = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31.30, 31);
	if (leapyear($year)) { $month[1] = 29; }
	my $s = shift;
	my @s = split(',', $s);
	$s = $s[0];
	my $d = $day - 1;
	my $m = $month;
	if ($day = 0) { $m--; $d = $monthtab[$m - 1]; }
	my $kd = sprintf("%02i-%02i", $m, $d);
	my %w1 = %{setupstring($lang, subdirname('Sancti', $version) . "$kd.txt")};
	my $l = $w1{Lectio1};
	if ($l =~ /!.*?$s 1:/i) { return 1; }
	return 0;
}

#*** contract_scripture($num)
# returns 1 if lesson 2 and 3 is to be contracted
sub contract_scripture {
	my $num = shift;
	if ($num != 2 || $votive =~ /(C9|Defunctorum)/i) { return 0; }
	if ($version !~ /196/) { return 0; }
	if ($commune =~ /C10/i) { return 1; }
	
	if ( ($ltype1960 == LT1960_SANCTORAL || $ltype1960 == LT1960_SUNDAY)
		&& $rule !~ /scriptura1960/i
		&& ($dayname[1] !~ /feria/i || $commemoratio))
	{
		return 1;
	}
	return 0;
}
