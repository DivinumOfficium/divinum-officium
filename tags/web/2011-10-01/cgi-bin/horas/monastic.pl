#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti

#use warnings;
#use strict "refs";
#use strict "subs";
my $a = 4;

#*** makeferia()
# generates a name and office for feria
# if there is none
sub makeferia {
 my @nametab = ('Sunday', 'II.', 'III.', 'IV.', 'V.', 'VI.', 'Sabbato');
 my $name = $nametab[$dayofweek];
 if ($dayofweek > 0 && $dayofweek < 6) {$name = "Feria $name";}
 return $name;
}

#*** psalmi_matutinum_monastic($lang)
# generates the appropriate psalm and lessons
# for the monastic version
sub psalmi_matutinum_monastic {
  $lang = shift;

  $psalmnum1 = $psalmnum2 = -1;
  
  #** reads the set of antiphons-psalms from the psalterium
  my %psalmi = %{setupstring("$datafolder/$lang/Psalterium/Psalmi matutinum.txt")};  
  my $dw = $dayofweek;
  if ($winner{Rank} =~ /Dominica/i) {$dw = 0;}	   
  my @psalmi = split("\n", $psalmi{"Daym$dw"});
  setbuild("Psalterium/Psalmi matutinum monastic", "dayM$dw", 'Psalmi ord');
  $comment = 1;
  my $prefix = ($lang =~ /English/i) ? 'Antiphons' : 'Antiphonae';
           

  #** special Adv - Pasc antiphons for Sundays
  if ($dayofweek == 0 && $dayname[0] =~ /(Adv|Pasc)/i) {
    @psalmi = split("\n", $psalmi{$1 . 'm0'});   
  	setbuild2("Antiphonas Psalmi Dominica special for Adv Pasc");
  }
  
  
  #** special antiphons for not Quad weekdays
  if ($dayofweek > 0 && $dayname[0] !~ /Quad/i) {
    my $start = ($dayname[0] =~ /Pasc/i) ? 0 : 8;
    my @p = split("\n", $psalmi{'Daym Pasc'}); 
    my $i;
    for ($i = $start; $i < 14; $i++) {
      my $p = $p[$i];
	  if ($psalmi[$i] =~ /;;/) {$p = ";;$'";}
	  if ($i == 0 || $i == 8) {$p = "Alleluia, * alleluia, alleluia$p";}
    $psalmi[$i] = $p;
    }
  	setbuild2("Antiphonas Psalmi weekday special no Quad"); 
  }

  #** change of versicle for Adv, Quad, Quad5, Pasc
  if ($dayofweek > 0 && $winner =~ /tempora/i && $dayname[0] =~ /(Adv|Quad|Pasc)([0-9])/i) {
    my $name = $1;
    my $i = $2;
    if ($name =~ /Quad/i && $i > 4) {$name = 'Quad5';}
    $i = $dayofweek;
    my @a = split("\n",$psalmi{"$name $i Versum"});
    $psalmi[6] = $a[0];
    $psalmi[7] = $a[1];
    setbuild2("Subst Matutitunun Versus $name $dayofweek");
   }

  #** Feria VI psalm change if winner has proper antiphons
  # for Lauds, so the Sunday psalm set is in effect
  if ($dayofweek == 5 && $psalmi[4] =~ /92!75/) {
    if (exists($winner{'Ant Laudes'})) {
	  $psalmi[4] =~ s/92!75/75/;
	  if ($psalmi[12] =~ /!/) {$psalmi[12] = $';}
	} else {
	  $psalmi[4] =~ s/92!75/92/;
	  if ($psalmi[12] =~ /!/) {$psalmi[12] = $`;}
    }
  }

  #** special cantica for quad time
  if (exists($winner{'Cantica'})) {
    my $c = split("\n", $winner{Cantica});
	my $i;
	for ($i = 0; $i < 3; $i++) {$psalmi[$i + 16] = $c[$i];}
  }

  #** get proper Ant Matutinum
  if (!($dayname[0] =~ /(Pasc[1-6]|Pent)/i && $month < 11) || $winner !~ /Sancti/i) {
    my ($w, $c) = getproprium('Ant Matutinum', $lang, 0, 1); 
    if ($w) {  
      @psalmi = split("\n", $w);
      $comment = $c;
      $prefix .= ' et Psalmi'; 
    }
  }									  

  setcomment($label, 'Source', $comment, $lang, $prefix);

  my $i = 0;
  my %w = (columnsel($lang)) ? %winner : %winner2;
  
  antetpsalm_mm('',-1);  #initialization for multiple psalms under one antiphon
  push (@s, '!Nocturn I.');	  
  foreach $i (0,1,2,3,4,5) {antetpsalm_mm($psalmi[$i], $i);}
  antetpsalm_mm('',-2); # set antiphon for multiple psalms under one antiphon situation
  push (@s, $psalmi[6]);
  push (@s, $psalmi[7]);
  push (@s, "\n");		

  if ($rule =~ /(9|12) lectio/i) {lectiones(1, $lang);}
  elsif ($dayname[0] =~ /(Pasc[1-6]|Pent)/i && $month < 11) { 
    if ($winner =~ /Tempora/i || 
     !(exists($winner{Lectio94}) || exists($winner{Lectio4}))) 
	 {brevis_monastic($lang);}
    elsif (exists($winner{Lectio94}) || exists($winner{Lectio4})) 
     {legend_monastic($lang)}
  } else {lectiones(1, $lang);}
   
  push (@s, "\n");   
  push (@s, '!Nocturn II.');
  foreach $i (8,9,10,11,12,13) {antetpsalm_mm($psalmi[$i], $i);}
  antetpsalm_mm('',-2); #draw out antiphon if any
                           
  if ($dayofweek == 0 || $winner{Rule} =~ /(12|9) lectiones/i) {
    push (@s, $psalmi[14]);
    push (@s, $psalmi[15]);                
    push (@s, "\n");
    lectiones(2, $lang);
    push (@s, "\n");   
    
	push (@s, '!Nocturn III.');	
	if ($psalmi[16] =~ /;;/) {
	  my $ant = $`;
	  my @c = split(';', $');
	  push (@s, "Ant. $ant");
	  push (@s, "\&psalm($c[0])\n");
	  push (@s, "\n");
	  push (@s, "\&psalm($c[1])\n");
	  push (@s, "\n");
	  push (@s, "\&psalm($c[2])");
	  push (@s, "Ant. $ant");
	  push (@s, "\n");
	  push (@s, $psalmi[17]);
	  push (@s, $psalmi[18]);
	  push (@s, "\n");
    lectiones(3, $lang);      
    push (@s, '&teDeum');
    push (@s, "\n");
    if (exists($winner{LectioE})) {   #** set evangelium
      my %w = (columnsel($lang)) ? %winner : %winner2; 
      my @w = split("\n", getreference($w{LectioE}, $lang));
      $w = '';
      foreach $item (@w) {
        if ($item =~ /^([0-9:]+)\s+/) {
        my $rest = $';
        my $num = $1;
        if ($rest =~ /^\s*([a-z])/i) {$rest = uc($1) . $';}
          $item = setfont($smallfont, $num) . " $rest";   
        }
        $w .= "$item\n";	
      }                                      
      push(@s, $w);
    }
    push (@s, "\n");   
	}
	return;
  } 

  my ($w, $c) = getproprium('MM Capitulum', $lang, 0, 1); 
  my %s = %{setupstring("$datafolder/$lang/Psalterium/Matutinum Special.txt")};  
	if (!$w) {
    if ($dayname[0] =~ /(Adv|Quad|Pasc)/i) {
	    my $name = $1;
	    if ($dayname[0] =~ /Quad[56]/i) {$name .= '5';}
	    $w = $s{"MM Capitulum $name"};  
	  }
  }
  if (!$w) {$w = $s{'MM Capitulum'};}
  push(@s, "!!Capitulum");
  push(@s, $w);
  push (@s, "\n");
}

#*** antetpsal_mmm($line, $i) 
# format of line is antiphona;;psalm number
# sets the antiphon and psalm call into the output flow
# handles the multiple psalms under one antiphon situation
sub antetpsalm_mm {
  my $line = shift;
  my $ind = shift;   	  		  
  my @line = split(';;', $line);   
  								  
  our $lastantiphon;

  if ($ind == -1) {$lastantiphon = ''; return;}
  if ($ind == -2) {
    if ($lastantiphon) {push(@s, "Ant. $lastantiphon"); push(@s, "\n"); $lastantiphon = '';}
	return;
  }

   if ($dayname[0]  =~ /Pasc/i  && $hora =~ /Vespera/i && 
      !exists($winner{"Ant $hora"}) && $rule !~ /ex /i) {
    if ($ind == 0) {$line[0] = ($duplex < 3 ) ? 'Alleluia' : 'Alleluia. * Alleluia, alleluia'; $lastantiphon = ''}
    else {$line[0] = ''; $lastantiphon = 'Alleluia. * Alleluia, alleluia'; }	  
  }
  if ($dayname[0]  =~ /Pasc/i  && $hora =~ /Laudes/i && $winner{Rank} !~ /Dominica/i &&
      !exists($winner{"Ant $hora"}) && $rule !~ /ex /i) {
    if ($ind == 0) {$line[0] = ($duplex < 3 ) ? 'Alleluia' : 'Alleluia. * Alleluia, alleluia'; $lastantiphon = '';}
    if ($ind == 1) {$line[0] = ''; $lastantiphon = '';}
	if ($ind == 2) {$line[0] = ''; $lastantiphon = 'Alleluia * Alleluia, alleluia';}
  }

  if ($line[0] && $lastantiphon) {push(@s, "Ant. $lastantiphon"); push(@s, "\n");}
  if ($line[0]) {push(@s, "Ant. $line[0]"); $lastantiphon = $line[0];}
  my $p = $line[1];
  my @p = split(';', $p);
  my $i = 0;
  foreach $p (@p) {
    if (!$p || $p =~ /^\s*$/) {next;};
    $p =~ s/[\(\-]/\,/g;
    $p =~ s/\)//;
    if (!$line[0]) {push(@s, "\n");}
    if ($i < (@p -1)) {$p = '-' . $p;}
    push(@s, "\&psalm($p)");
    push (@s, "\_");
	$i++;
  }
}

#*** monstic_lectio3($w, $lang)
# return the legend if appropriate
sub monastic_lectio3 {
  my $w = shift;  
  my $lang = shift;
  if ($winner !~ /Sancti/i || exists($winner{Lectio3}) || $rank >= 4 ||
    $rule =~ /(9|12) lectio/i) {return $w;}
  my %w = (columnsel($lang)) ? %winner : %winner2; 
  if (exists($w{Lectio94})) {return $w{Lectio94};}
  if (exists($w{Lectio4})) {return $w{Lectio4};}
  return $w;
}

#*** legend_monastic($lang)
sub legend_monastic {
  my $lang = shift;

  #absolutio-benedictio
  push (@s, "\n");
  push (@s, '&pater_noster');
  my %benedictio = %{setupstring("$datafolder/$lang/Psalterium/Benedictions.txt")};  
  my $i = ($dayofweek == 1 || $dayofweek == 4) ? 1 :
    ($dayofweek == 2 || $dayofweek == 5) ? 2 : 
    ($dayofweek == 3 || $dayofweek == 6) ? 3 : 1;
  my @a = split("\n", $benedictio{"Nocturn $i"});
  push (@s, "Absolutio. $a[0]");
  push(@s, "\n");
  push (@s, "V. $a[1]");
  push (@s, "Benedictio. $a[4]");
  push(@s, "_");

  #1 lesson
  my %w = (columnsel($lang)) ? %winner : %winner2; 
  my $str == '';
  if (exists($w{Lectio94})) {
    push(@s, $w{Lectio94});
  } else {
    $str = $w{Lectio4};
    if (exists($w{Lectio5}) && $w{Lectio5} !~ /!/) {$str .= $w{Lectio5} . $w{Lectio6};}
	push(@s, $str);
  }
  push(@s, "\_");
  if (exists($w{Responsory6})) {push(@s, $w{Responsory6});}
  else {
    my %c = (columnsel($lang)) ? %commune : %commune2;
    if (exists($c{Responsory6})) {push(@s, $c{Responsory6});}
	else {push(@s, "Responsory for ne lesson not found!");}
  }
}

#*** brevis_monstic($lang)
sub brevis_monastic {
  my $lang = shift; 

  my %b = %{setupstring("$datafolder/$lang/Psalterium/Matutinum special.txt")};
  push(@s, $b{"MM LB$dayofweek"});
}

#*** regula($lang)
#returns the text of the Regula for the day
sub regula {
  my $lang = shift;        

  my $t = setfont($largefont, "Regula") . "\n_\n";
  my $d = $day;
  my $l = leapyear($year);
  if ($month == 2 && $day >= 24 && !$l) {$d++;}  

  $fname = sprintf("%02i-%02i", $month, $d);
  if (!-e "$datafolder/Latin/Regula/$fname.txt") {	  
    if (open (INP, "$datafolder/Latin/Regula/Regulatable.txt")) {
	    my @a = <INP>;
	    close INP;
	    my $a;
	    my %a = undef;
	    foreach $a (@a) {	 
	      my @a1 = split(';', $a);
		    $a{$a1[1]} = $a1[0];  
		    $a{$a1[2]} = $a1[0];
	    }
	    $fname = $a{$fname};     

	  } else {return $t;}
  }
  $fname = checkfile($lang, "Regula/$fname.txt");   
  if (open (INP, "$fname")) {
    my @a = <INP>;	  
    close INP;
    foreach $line (@a) {
      if ($line =~ /^.*?\#/) {$line = $';}
      if ($line =~ /^\s*$/) {$line = "_$line";}
	    $t .= $line;
    }
  }

  if (!$l && $fname =~ /02\-23/ ) {
    $fname = checkfile($lang, "Regula/02-24.txt");  
    if (open (INP, "$fname")) {
      my @a = <INP>;	  
      close INP;
      foreach $line (@a) {
        if ($line =~ /^.*?\#/) {$line = $';}
        if ($line =~ /^\s*$/) {$line = "_$line";}
	      $t .= $line;
      }
    }
  }

  $t .= '$Tu autem';
  return $t;
}

