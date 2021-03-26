#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti
#use warnings;
#use strict "refs";
#use strict "subs";
use FindBin qw($Bin);
use lib "$Bin/..";

# Defines ScriptFunc and ScriptShortFunc attributes.
use horas::Scripting;
my $a = 4;

#*** makeferia()
# generates a name and office for feria
# if there is none
sub makeferia {
  my @nametab = ('Sunday', 'II.', 'III.', 'IV.', 'V.', 'VI.', 'Sabbato');
  my $name = $nametab[$dayofweek];
  if ($dayofweek > 0 && $dayofweek < 6) { $name = "Feria $name"; }
  return $name;
}

#*** psalmi_matutinum_monastic($lang)
# generates the appropriate psalm and lessons
# for the monastic version
sub psalmi_matutinum_monastic {
  $lang = shift;
  $psalmnum1 = $psalmnum2 = -1;
  $psalmnum1 = $psalmnum2 = 0 if (($dayname[0] eq "Quad6") && ($dayofweek > 3));

  #** reads the set of antiphons-psalms from the psalterium
  my %psalmi = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi matutinum.txt')};
  my $dw = $dayofweek;
  if ($winner{Rank} =~ /Dominica/i) { $dw = 0; }
  my @psalmi = split("\n", $psalmi{"Daym$dw"});
  setbuild("Psalterium/Psalmi matutinum monastic", "dayM$dw", 'Psalmi ord');
  $comment = 1;
  my $prefix = translate('Antiphonae', $lang);

  #** special Adv - Pasc antiphons for Sundays
  if ($dayofweek == 0 && $dayname[0] =~ /(Adv|Pasc)/i) {
    @psalmi = split("\n", $psalmi{$1 . 'm0'});
    setbuild2("Antiphonas Psalmi Dominica special for Adv Pasc");
  }

  #** special antiphons for not Quad weekdays
  if ($dayofweek > 0 && $dayname[0] !~ /Quad/i) {
    my $start = ($dayname[0] =~ /Pasc|Nat[23]\d/i) ? 0 : 8;
    my @p;
    if ($dayname[0] =~ /Pasc/) { @p = split("\n", $psalmi{'Daym Pasc'}); }
    elsif ($dayname[0] =~ /Nat[23]\d/) {
      @p = split("\n", $psalmi{'Daym Nat'});
    }
    my $i;

    for ($i = $start; $i < 14; $i++) {
      my $p = $p[$i];
      if ($psalmi[$i] =~ /;;(.*)/s) { $p = ";;$1"; }
      if ($i == 0 || $i == 8) {
        if ($dayname[0] !~ /Nat[23]\d|Pasc0/) {
          my $ant = $prayers{$lang}{"Alleluia Duplex"};
          $ant =~ s/ / * /;
          $ant =~ s/\./$prayers{$lang}{"Alleluia Simplex"}/;
          $p = "$ant$p";
        }
        else {
          $p = "$p[$i]$p";
        }
      }
      $psalmi[$i] = $p;
    }
    setbuild2("Antiphonas Psalmi weekday special no Quad");
  }

  #** change of versicle for Adv, Quad, Quad5, Pasc
  if ( ($winner =~ /tempora/i && $dayname[0] =~ /(Adv|Quad|Pasc)([0-9])/i)
    || $dayname[0] =~ /(Nat)((?:0?[2-9])|(?:1[0-2]))$/ ) {
    my $name = $1;
    my $i = $2;
    if ($name =~ /Nat/ && $i > 6 && $i < 13) { $name = 'Epi'; }
    if ($name =~ /Quad/i && $i > 4) { $name = 'Quad5'; }
    $i = $dayofweek || 1;
    if ($name =~ /Nat|Epi/ && $i > 3) { $i -= 3; }
    ($psalmi[6],$psalmi[7]) = split("\n", $psalmi{"$name $i Versum"});
    if ($dayofweek == 0) {
      ($psalmi[14],$psalmi[15]) = split("\n", $psalmi{"$name 2 Versum"});
      ($psalmi[17],$psalmi[18]) = split("\n", $psalmi{"$name 3 Versum"});
    }
    setbuild2("Subst Matutitunum Versus $name $dayofweek");
  }

  #** special cantica for quad time
  if (exists($winner{'Cantica'})) {
    my $c = split("\n", $winner{Cantica});
    my $i;
    for ($i = 0; $i < 3; $i++) { $psalmi[$i + 16] = $c[$i]; }
  }

  if (($rank > 4.9) && !(($dayname[0] =~ /Pasc0/) && ($dayofweek > 2))) {
    #** get proper Ant Matutinum
    my ($w, $c) = getproprium('Ant Matutinum', $lang, 0, 1);
    if ($w) {
      @psalmi = split("\n", $w);
      $comment = $c;
      $prefix .= ' ' . translate('et Psalmi', $lang);
    }
  }
  setcomment($label, 'Source', $comment, $lang, $prefix);
  my $i = 0;
  my %w = (columnsel($lang)) ? %winner : %winner2;
  antetpsalm_mm('', -1);    #initialization for multiple psalms under one antiphon
  push(@s, '!Nocturn I.', '_');
  for (0..5) { antetpsalm_mm($psalmi[$_], $_); }
  antetpsalm_mm('', -2);    # set antiphon for multiple psalms under one antiphon situation
  push(@s, $psalmi[6], $psalmi[7], "\n");

  if ($rule =~ /(9|12) lectio/i && $rank > 4.9) {
    lectiones(1, $lang);
  } elsif ($dayname[0] =~ /(Pasc[1-6]|Pent)/i && $month < 11 && $winner{Rank} !~ /vigil|quattuor/i) {
    if ($winner =~ /Tempora/i
      || !(exists($winner{Lectio94}) || exists($winner{Lectio4})))
    {
      brevis_monastic($lang);
    } elsif (exists($winner{Lectio94}) || exists($winner{Lectio4})) {
      legend_monastic($lang);
    }
  } else {
    lectiones($winner{Rank} !~ /vigil/i, $lang);
  }
  push(@s, "\n", '!Nocturn II.', '_');
  for (8..13) { antetpsalm_mm($psalmi[$_], $_); }
  antetpsalm_mm('', -2);    #draw out antiphon if any

  if ($winner{Rule} =~ /(12|9) lectiones/i && $rank > 4.9) {
    push(@s, $psalmi[14], $psalmi[15], "\n");
    lectiones(2, $lang);
    push(@s, "\n", '!Nocturn III.', '_');

    if (($dayname[0] eq "Quad6") && ($dayofweek > 3))  {
      for (16..18) { antetpsalm_mm($psalmi[$_], $_); }
      antetpsalm_mm('', -2);
      push(@s, $psalmi[19], $psalmi[20], "\n");
      lectiones(3, $lang);
      return;
    }

    my $ant;
    my $p;
    if ($psalmi[16] =~ /(.*?);;(.*)/s) {
      $ant = $1;
      $p = $2;
    }
    my %w = (columnsel($lang)) ? %winner : %winner2;
    if (exists($w{"Ant Matutinum 3N"})) {
      my @t = split("\n",$w{"Ant Matutinum 3N"});
      for(my $i=0; $i <= $#t; $i++) { $psalmi[16+$i] = $t[$i]; }
    }
    if ($psalmi[16] =~ /(.*?);;(.*)/s) {
      $ant = $1;
      $p = $2;
    }
    else {
      $ant = $psalmi[16];
    }
    $p =~ s/[\(\-]/\,/g;
    $p =~ s/\)//g;

    push(@s, "Ant. $ant");
    for (split(';', $p)) { push(@s, "\&psalm($_)", "\n"); } pop(@s);
    push(@s, "Ant. $ant");
    push(@s, "\n", $psalmi[17], $psalmi[18], "\n");
    lectiones(3, $lang);
    push(@s, '&teDeum', "\n");

    my @e;
    if (exists($w{LectioE})) {    #** set evangelium
      @e = split("\n", $w{LectioE}); }
    else {
      my $dt = $datafolder; $dt =~ s/horas/missa/g; 
      my $w = $winner; $w =~ s/M//g;
      my %missa = %{setupstring($dt, $lang, $w)};
      @e = split("\n", $missa{Evangelium});
    }

    my $firstline = shift @e;
    $firstline =~ s/^(v. )?/v./;
    $firstline =~ s/\++/++/;
    push(@s, $firstline, shift @e, "R. " . translate("Gloria tibi Domine", $lang));

    @e = grep { !/^!/ } @e;
    $e[0] =~ s/^(v. )?/v./;
    for($i=0; $i<$#e-1; $i++) { $e[$i] =~ s/~$/~/ }

    push(@s, @e, "R. " . translate("Amen", $lang), "_", "\$Te decet");
    return;
  }
  my ($w, $c) = getproprium('MM Capitulum', $lang, 0, 1);
  my %s = %{setupstring($datafolder, $lang, 'Psalterium/Matutinum Special.txt')};

  if ((!$w || $commune =~ /M\/C10/) && $commune) {
    my $name = $commune;
    $name =~ s/.*M.//;
    $name =~ s/\D?\.txt//;
    $w = $s{"MM Capitulum $name"};
  }
  if (!$w) {
    if ($dayname[0] =~ /(Adv|Nat|Quad|Pasc)/i) {
      my $name = $1;
      if ($dayname[0] =~ /Quad[56]/i) { $name .= '5'; }
      if ($name eq 'Nat' && $day > 6 && $day < 13) { $name = 'Epi'; }
      $w = $s{"MM Capitulum $name"};
    }
  }
  if (!$w) { $w = $s{'MM Capitulum'}; }
  push(@s, "!!Capitulum", $w, "\n");
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
  $lastantiphon =~ s/\s+\*//;

  if ($ind == -1) { $lastantiphon = ''; return; }

  if ($ind == -2) {
    if ($lastantiphon) { push(@s, "Ant. $lastantiphon"); push(@s, "\n"); $lastantiphon = ''; }
    return;
  }

  if ( $dayname[0] =~ /Pasc/i
    && $hora =~ /Vespera/i
    && !exists($winner{"Ant $hora"})
    && $rule !~ /ex /i)
  {
    if ($ind == 0) {
      $line[0] = Alleluia_ant($lang, 0, 0);
      $lastantiphon = '';
    } else {
      $line[0] = '';
      $lastantiphon = Alleluia_ant($lang, 0, 0);
    }
  }

  if ( $dayname[0] =~ /Pasc/i
    && $hora =~ /Laudes/i
    && $winner{Rank} !~ /Dominica/i
    && !exists($winner{"Ant $hora"})
    && $rule !~ /ex /i)
  {

    if ($ind == 0) { $line[0] = Alleluia_ant($lang, 0, 0); $lastantiphon = ''; }
    if ($ind == 1) { $line[0] = ''; $lastantiphon = ''; }
    if ($ind == 2) { $line[0] = ''; $lastantiphon = Alleluia_ant($lang, 0, 0); }
    if ($ind == 3) { ensure_single_alleluia($line[0], $lang); }
    if ($ind == 4) { $line[0] = Alleluia_ant($lang, 0, 0); }
  }
  if ($line[0] && $lastantiphon) { push(@s, "Ant. $lastantiphon"); push(@s, "\n"); }
  if ($line[0]) { push(@s, "Ant. $line[0]"); $lastantiphon = $line[0]; }
  my $p = $line[1];
  my @p = split(';', $p);
  my $i = 0;

  foreach $p (@p) {
    if (!$p || $p =~ /^\s*$/) { next; }
    $p =~ s/[\(\-]/\,/g;
    $p =~ s/\)//;
    if (!$line[0]) { push(@s, "\n"); }
    if ($i < (@p - 1)) { $p = '-' . $p; }
    push(@s, "\&psalm($p)");
    push(@s, "\_");
    $i++;
  }
}

#*** monstic_lectio3($w, $lang)
# return the legend if appropriate
sub monastic_lectio3 {
  my $w = shift;
  my $lang = shift;
  if ($winner !~ /Sancti/i || exists($winner{Lectio3}) || $rank >= 4 || $rule =~ /(9|12) lectio/i) { return $w; }
  my %w = (columnsel($lang)) ? %winner : %winner2;
  if (exists($w{Lectio94})) { return $w{Lectio94}; }
  if (exists($w{Lectio4})) { return $w{Lectio4}; }
  return $w;
}

#*** absolutio_benedictio($lang)
sub absolutio_benedictio {
  my $lang = shift;

  push(@s, "\n");
  push(@s, '&pater_noster');
  my @a;
  if ($commune =~ /C10/) {
    my %m = (columnsel($lang)) ? %commune : %commune2;
    @a = split("\n", $m{Benedictio});
    setbuild2('Special benedictio');
  } else {
    my %benedictio = %{setupstring($datafolder, $lang, 'Psalterium/Benedictions.txt')};
    my $i =
        ($dayofweek == 1 || $dayofweek == 4) ? 1
      : ($dayofweek == 2 || $dayofweek == 5) ? 2
      : ($dayofweek == 3 || $dayofweek == 6) ? 3
      : 1;
    @a = split("\n", $benedictio{"Nocturn $i"});
    $a[4] = $a[5] if ($i != 3);
  }
  push(@s, "Absolutio. $a[0]");
  push(@s, "\n");
  push(@s, "V. $a[1]");
  push(@s, "Benedictio. $a[4]");
  push(@s, "_");
}

#*** legend_monastic($lang)
sub legend_monastic {
  my $lang = shift;
  #1 lesson
  absolutio_benedictio($lang);
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my $str == '';

  if (exists($w{Lectio94})) {
    $str = $w{Lectio94};
  } else {
    $str = $w{Lectio4};
    if (exists($w{Lectio5}) && $w{Lectio5} !~ /!/) { $str .= $w{Lectio5} . $w{Lectio6}; }
  }

  $str =~ s/&teDeum\s*//;
  push(@s, $str, '$Tu autem', '_');

  my $resp = '';

  if (exists($w{Responsory1})) {
    $resp = $w{Responsory1};
  } else {
    my %c = (columnsel($lang)) ? %commune : %commune2;

    if (exists($c{Responsory1})) {
      $resp = $c{Responsory1};
    } else {
      $resp = "Responsory for ne lesson not found!";
    }
  }
  push(@s, responsory_gloria($resp, 3));
}

#*** brevis_monstic($lang)
sub brevis_monastic {
  my $lang = shift;
  absolutio_benedictio($lang);
  my $lectio;
  if ($commune =~ /C10/) {
    my %c = (columnsel($lang)) ? %commune : %commune2;
    $lectio = $c{getC10readingname()} ."\n_\n" . $c{'Responsory3'};
    setbuild2("Mariae $name");
  }
  else {
    my %b = %{setupstring($datafolder, $lang, 'Psalterium/Matutinum Special.txt')};
    $lectio  = $b{"MM LB" . (($dayname[0] =~ /Pasc/) ? " Pasc" : $dayofweek)};
  }
  $lectio =~ s/&Gloria1?/&Gloria1/;
  push(@s, $lectio);
}

#*** regula($lang)
#returns the text of the Regula for the day
sub regula : ScriptFunc {

  my $lang = shift;
  my @a;
  my $t = setfont($largefont, translate("Regula", $lang)) . "\n_\n";
  my $d = $day;
  my $l = leapyear($year);

  if ($month == 2 && $day >= 24 && !$l) { $d++; }
  $fname = sprintf("%02i-%02i", $month, $d);

  if (!-e "$datafolder/Latin/Regula/$fname.txt") {
    if (@a = do_read("$datafolder/Latin/Regula/Regulatable.txt")) {
      my $a;
      my %a = undef;

      foreach $a (@a) {
        my @a1 = split(';', $a);
        $a{$a1[1]} = $a1[0];
        $a{$a1[2]} = $a1[0];
      }
      $fname = $a{$fname};
    } else {
      return $t;
    }
  }
  $fname = checkfile($lang, "Regula/$fname.txt");

  if (@a = do_read($fname)) {
    foreach $line (@a) {
      $line =~ s/^.*?\#//;
      $line =~ s/^(\s*)$/_$1/;
      $t .= "$line\n";
    }
  }

  if (!$l && $fname =~ /02\-23/) {
    $fname = checkfile($lang, "Regula/02-24.txt");

    if (@a = do_read($fname)) {
      foreach $line (@a) {
        $line =~ s/^.*?\#//;
        $line =~ s/^(\s*)$/_$1/;
        $t .= "$line\n";
      }
    }
  }
  $t .= '$Tu autem';
  return $t;
}
