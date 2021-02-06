#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
use FindBin qw($Bin);
use lib "$Bin/..";

# Defines ScriptFunc and ScriptShortFunc attributes.
use horas::Scripting;
my @lines;
my $precesferiales;
$a = 1;

# REPAIRS ERROR
# --> EofficiumXhtml.pl: Undefined subroutine &horas::ante_post
# --> called at /Users/user/divinum-officium/standalone/tools/epubgen2/../../../web/cgi-bin/horas/horas.pl line 61.
# this error occured when generating an epub for Divino Afflatu
sub ante_post {
  my $title = shift;
  if ($Ck) { return; }
  my $colspan = ($only) ? '' : 'COLSPAN=2';
  print "<TR><TD $background VALIGN=TOP $colspan ALIGN=CENTER>\n";

  # it seems that <input> is not the right thing to have for an ePub. How to fix?
  print "<INPUT TYPE=RADIO NAME=link onclick='linkit(\"\$$title\", 0, \"Latin\");'>\n";
  print "<FONT SIZE=1>$title Divinum officium</FONT></TD></TR>";
}

#*** horas($hora)
# collects and prints the officium for the given $hora
# first let specials to fill the chapters
# then break the text into units (separated by double newline)
# resolves the references (formatting characters, prayers hash references and subs)
#and prints the result
sub horas {
  $command = shift;
  $hora = $command;
  our $canticum = 0;
  our $reciteindex = 0;
  our $recitelimit = 0;
  $tlang = ($lang1 !~ /Latin/) ? $lang1 : $lang2;
  our %translate;
  $translate{$lang1} = setupstring($datafolder, $lang1, "Psalterium/Translate.txt");
  $translate{$lang2} = setupstring($datafolder, $lang2, "Psalterium/Translate.txt");
  cache_prayers();
  %chant = %{setupstring($datafolder, 'Latin', "Psalterium/Chant.txt")};
  $column = 1;
  if ($Ck) { $version = $version1; setmdir($version); precedence(); }
  @script1 = getordinarium($lang1, $command);
  @script1 = specials(\@script1, $lang1);
  $column = 2;
  if ($Ck) { $version = $version2; setmdir($version); precedence(); }
  @script2 = getordinarium($lang2, $command);
  @script2 = specials(\@script2, $lang2);
  $expandind = 0;
  if (!$Tk && !$Hk) { $expandnum = strictparam('expandnum'); }
  table_start();
  $ind1 = $ind2 = 0;
  $searchind = 0;

  if ($version !~ /(Monastic|1570|1955|1960|Newcal|Praedicatorum)/i) {
    ante_post('Ante');
  } else {
    $searchind++;
  }
  my $alleluia_regex = qr/[(]*(?<!&)allel[uú][ij]a[\.\,]*[)]*/i;
  $omit_regexp = 'omit';    # to prevent display omitted Preces|Suffragium in red line 160
  {
    my %comm = %{setupstring($datafolder, $lang2, 'Psalterium/Comment.txt')};
    $omit_regexp .= '|\b' . (split("\n", $comm{'Preces'}))[1] . '\b';
    $omit_regexp .= '|\b' . (split("\n", $comm{'Suffragium'}))[0] . '\b';
  }

  while ($ind1 < @script1 || $ind2 < @script2) {
    $expandind++;
    ($text1, $ind1) = getunit(\@script1, $ind1);
    ($text2, $ind2) = getunit(\@script2, $ind2);
    $column = 1;
    $version = $version1 if $Ck;
    $text1 = resolve_refs($text1, $lang1);

    # Suppress (Alleluia) during Quadrigesima.
    if ($dayname[0] =~ /Quad/i && !Septuagesima_vesp()) {
      $text1 =~ s/$alleluia_regex//g;
    }
    $text1 =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;
    if ($lang1 =~ /Latin/i) { $text1 = spell_var($text1); }
    if ($text1 && $text1 !~ /^\s+$/) { setcell($text1, $lang1); }

    if (!$only) {
      $column = 2;
      if ($Ck) { $version = $version2; }
      $text2 = resolve_refs($text2, $lang2);

      if ($dayname[0] =~ /Quad/i && !Septuagesima_vesp()) {
        $text2 =~ s/$alleluia_regex//ig;
      }
      $text2 =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;
      if ($lang2 =~ /Latin/i) { $text2 = spell_var($text2); }
      if ($text2 && $text2 !~ /^\s+$/) { setcell($text2, $lang2); }
    }
  }

  if ($version !~ /(Monastic|1570|1955|1960|Newcal|Praedicatorum)/) {
    ante_post('Post');
  } else {
    $searchind++;
  }
  table_end();
  if ($column == 1) { $searchind++; }
}

#*** getunits(\@s, $ind)
# break the array into units separated by double newlines
# from $ind  to the returned new $ind
sub getunit {

  my $s = shift;
  my @s = @$s;
  my $ind = shift;
  my $t = '';
  my $plen = 1;

  while ($ind < @s) {
    my $line = chompd($s[$ind]);
    $ind++;
    if ($line && !($line =~ /^\s+$/)) { $t .= "$line\n"; next; }
    if (!$t) { next; }
    last;
  }

  if ($dayname[0] !~ /Pasc/i) {
    $t =~ s/\(Allel[uú][ij]a.*?\)//isg;
  } else {
    $t =~ s/\((Allel[uú][ij]a.*?)\)/$1/isg;
  }
  return ($t, $ind);
}

#*** resolve refs($text_of_block, $lang)
#resolves $name &name references and special characters
#retuns the to be listed text
sub resolve_refs {
  my $t = shift;
  my $lang = shift;
  my @t = split("\n", $t);

  #handles expanding for skeleton
  if ($t[0] =~ /#/) {
    if ($expandind == $expandnum) {
      $expandflag = 1;
    } else {
      $expandflag = 0;
    }
  }

  if ($expand =~ /skeleton/ && !$expandflag) {
    if ($t[0] =~ /\#/) {
      return setlink($t[0], $expandind, $lang);
    } else {
      return "";
    }
  }

  if ($t[0] =~ $omit_regexp) {
    $t[0] =~ s/^\s*\#/\!\!\!/;
  } else {
    $t[0] =~ s/^\s*(\#.*)(\{.*\})?\s*$/'!!' . substr(translate($1, $lang), 1) . $2/e;
  }
  my @resolved_lines;    # Array of blocks expanded from lines.
  my $prelude = '';      # Preceding continued lines.

  #cycle by lines
  for (my $it = 0; $it < @t; $it++) {
    $line = adjust_refs($t[$it], $lang);

    #$ and & references
    if ($line =~ /^\s*[\#\$\&]/) {
      $line =~ s/\.//g;
      $line =~ s/\s+$//;
      $line =~ s/^\s+//;

      #prepares reading the part of common w/ antiphona
      if ($line =~ /psalm/ && $it > 0 && $t[$it - 1] =~ /^\s*Ant\. /i) {
        $line = expand($line, $lang, $t[$it - 1]);

        # If the psalm has a cross, then so should the antiphon.
        @resolved_lines[-1] .= setfont($smallfont, " \x{2021}") if $line =~ /\x{2021}/;
      } else {
        $line = expand($line, $lang);
      }

      if ((!$Tk && $line !~ /\<input/i) || ($Tk && $line !~ /\% .*? \%/)) {
        $line = resolve_refs($line, $lang);
      }    #for special chars
    }

    #cross
    $line = setcross($line);

    # add dot if missing in Antiphona
    $line =~ s/(\w)$/$&./ if ($line =~ /^\s*Ant\./);

    #red prefix
    if ($line =~ /^\s*(R\.br\.|R\.|V\.|Ant\.|Benedictio\.* |Absolutio\.* )(.*)/) {
      my $h = $1;
      my $l = $2;

      if ($h =~ /(Benedictio|Absolutio)/) {
        my $str = $1;
        $str = translate($str, $lang);
        $h =~ s/(Benedictio|Absolutio)/$str/;
      }
      $line = setfont($redfont, $h) . $l;
    }

    #small omitted title
    if ($line =~ /^\s*\!\!\!(.*)/) {
      $l = $1;
      $line = setfont($smallblack, $l);
    }

    #large chapter title
    elsif ($line =~ /^\s*\!\!(.*)/) {
      my $l = $1;
      my $suffix = '';
      if ($l =~ s/(\{[^:].*?\})//) { $suffix = setfont($smallblack, $1); }
      $line = setfont($largefont, $l) . " $suffix\n";
      if ($expand =~ /skeleton/i) { $line .= linkcode1(); }
    }

    #red line
    elsif ($line =~ /^\s*\!(.*)/) {
      $l = $1;
      $line = setfont($redfont, $l);
    }
    $line =~ s{/:(.*?):/}{setfont($smallfont, $1)}e;

    #first letter red
    if ($line =~ /^\s*r\.\s*(.*)/) {
      $line = $1;
      $line = setfont($largefont, substr($line, 0, 1)) . substr($line, 1);
    }

    # first letter initial
    if ($line =~ /^(\s*)v\.\s*(.*)/ || $line =~ /(\{\:.*?\:\}\s*)v\.\s*(.*)/) {
      my $prev = $1;
      $line = $2;
      $line = $prev . setfont($initiale, substr($line, 0, 1)) . substr($line, 1);
    }

    #connect lines marked by tilde, or but linebrak
    if ($line =~ /~\s*$/) {
      $prelude .= substr($line, 0, $-[0]) . ' ';
    } else {
      push @resolved_lines, $prelude . $line;
      $prelude = '';
    }
  }    #line by line cycle ends

  # Concatenate the expansions of the lines with a line break between each.
  push @resolved_lines, $prelude if $prelude;
  push @resolved_lines, '';
  my $resolved_block = join "<BR>\n", @resolved_lines;

  #removes occasional double linebreaks
  $resolved_block =~ s/<BR>\s*<BR>/<BR>/g;
  $resolved_block =~ s/<\/P>\s*<BR>/<\/P>/g;
  return $resolved_block;
}

#*** Pater noster($lang)
# returns the text of the prayer without Amen, setting V. and R. to the last 2 lines
sub pater_noster : ScriptFunc {
  our %prayers;
  return $prayers{shift()}->{'Pater_noster1'};
}

#*** teDeum($lang)
# returns the text of the hymn
sub teDeum : ScriptFunc {
  my $lang = shift;
  our %prayers;
  return "\n_\n!Te Deum\n$prayers{$lang}->{'Te Deum'}";
}

#*** Alleluia($lang)
# return the text Alleluia or Laus tibi
sub Alleluia : ScriptFunc {
  my $lang = shift;
  our %prayers;
  my $text = $prayers{$lang}->{'Alleluia'};
  my @text = split("\n", $text);

  if ($dayname[0] =~ /Quad/i && !Septuagesima_vesp()) {
    $text = $text[1];
  } else {
    $text = $text[0];
  }

  #if ($dayname[0] =~ /Pasc/i) {$text = "Alleluia, alleluia, alleluia";}
  return $text;
}

sub Alleluia_ant {
  my ($lang, $full, $ucase) = @_;
  my $s = translate('Alleluia', $lang);
  if (($full || ($duplex >= 3) || ($version =~ /1960|Newcal|Monastic|Praedicatorum/i))) {
    $s .= ", * $s, $s.";
    $s =~ s/ ./\L$&/g unless $ucase;
  }
  return $s;
}

#*** Septuagesima_vesp
# Determines whether we're saying first Vespers of Septuagesima Sunday.
sub Septuagesima_vesp {
  our ($dayofweek, @dayname, $hora);
  return ($dayofweek == 6 && $dayname[0] =~ /Quadp1/ && $hora =~ /Vespera/i);
}

#*** triduum_gloria_omitted
# Determines whether the Gloria at the end of the psalms should be omitted
# owing to the Triduum.
sub triduum_gloria_omitted() {
  our (@dayname, $dayofweek, $tvesp);

  # TODO: A much more elegant check would be to see what *today's office* is,
  # checking for Quad6-[456], but this information is not reliably available.
  return
       $dayname[0] =~ /Quad6/i
    && $dayofweek > 3
    && $tvesp == 3;
}

#*** Gloria
# returns the text or the omit notice
sub Gloria : ScriptFunc {
  my $lang = shift;
  if (triduum_gloria_omitted()) { return ""; }
  our %prayers;
  if ($rule =~ /Requiem gloria/i) { return $prayers{$lang}->{Requiem}; }
  return $prayers{$lang}->{'Gloria'};
}

sub Gloria1 : ScriptFunc {    #* responsories
  my $lang = shift;
  if ($dayname[0] =~ /(Quad5|Quad6)/i && $winner !~ /Sancti/i && $rule !~ /Gloria responsory/i) { return ""; }
  our %prayers;
  return $prayers{$lang}->{'Gloria1'};
}

sub Gloria2 : ScriptFunc {    #*Invitatorium
  my $lang = shift;
  if ($dayname[0] =~ /(Quad[56])/i) { return ""; }
  our %prayers;
  if ($rule =~ /Requiem gloria/i) { return $prayers{$lang}->{Requiem}; }
  return $prayers{$lang}->{'Gloria'};
}

#*** Dominus_vobiscum
#returns the text of the 'Domine exaudi' for non priests
sub Dominus_vobiscum : ScriptFunc {
  my $lang = shift;
  our %prayers;
  my $text = $prayers{$lang}->{'Dominus'};
  my @text = split("\n", $text);

  if ($priest) {
    $text = "$text[0]\n$text[1]";
  } else {
    if (!$precesferiales) {
      $text = "$text[2]\n$text[3]";
    } else {
      $text = "$text[4]";
    }
    $precesferiales = 0;
  }
  return $text;
}

sub Dominus_vobiscum1 : ScriptFunc {    #* prima after preces
  my $lang = shift;
  if ((!preces('Dominicales et Feriales') || $litaniaflag) && !$priest) { $precesferiales = 1; }
  return Dominus_vobiscum($lang);
}

sub Dominus_vobiscum2 : ScriptFunc {    #* officium defunctorum
  my $lang = shift;
  if (!$priest) { $precesferiales = 1; }
  return Dominus_vobiscum($lang);
}

#*** Benedicamus_Domino
# adds Alleluia, alleluia for Pasc0
sub Benedicamus_Domino : ScriptFunc {
  my $lang = shift;
  our %prayers;
  my $text = $prayers{$lang}->{'Benedicamus Domino'};
  if (Septuagesima_vesp()) { $text = $prayers{$lang}->{'Benedicamus Domino1'}; }
  if ($dayname[0] !~ /Pasc0/i || $hora !~ /(Laudes|Vespera)/i) { return $text; }
  my @text = split("\n", $text);
  return "$text[0] $prayers{$lang}->{'Alleluia Duplex'}\n$text[1] $prayers{$lang}->{'Alleluia Duplex'}\n";
}

#*** antiphona_finalis
#return the text for the appropriate time
sub antiphona_finalis : ScriptFunc {
  my $lang = shift;
  my %ant = %{setupstring($datafolder, $lang, "Psalterium/Mariaant.txt")};
  my $t = '';

  if ($dayname[0] =~ /adv/i && $winner{Rank} !~ /In Nativitate Domini/i) {
    $t = $ant{'Advent'};
  } elsif ($dayname[0] =~ /Nat/i
    || ($month == 12 && $day > 23)
    || $month == 1
    || ($month == 2 && $day < 2)
    || ($month == 2 && $day == 2 && $hora !~ /Completorium/i))
  {
    $t = $ant{'Nativiti'};
  } elsif (($month == 2 || $month == 3 || $dayname[0] =~ /Quad/i) && $dayname[0] !~ /Pasc/i) {
    $t = $ant{'Quadragesimae'};
  } elsif ($dayname[0] =~ /Pasc/) {
    $t = $ant{'Paschalis'};
  } else {
    $t = $ant{'Postpentecost'};
  }
  $t = '#' . translate('Antiphona finalis BMV', $lang) . "\n$t";
  return ($t);
}

#*** psalm($chapter, $lang, $antline)  or
# psalm($chapter, $fromverse, $toverse, $lang, $antline)
# selects the text, attaches the head,
# sets red color for the introductory comments
# returns the visible form
sub psalm : ScriptFunc {
  my @a = @_;
  my ($num, $lang, $antline);

  if (@a < 4) {
    $num = $a[0];
    $lang = $a[1];
    $antline = $a[2];
  } else {
    $num = "$a[0]($a[1]-$a[2])";
    $lang = $a[3];
    $antline = $a[4];
  }

  if ($ck) {
    if ($lang =~ $lang1) {
      $version = $version1;
    } else {
      $version = $version2;
    }
  }
  my $nogloria = 0;

  if ($num =~ /^-(.*)/) {
    $num = $1;

    if ( ($version =~ /Trident/i && $num =~ /(62|148|149)/)
      || ($version =~ /Monastic/i && $num =~ /(115|148|149)/))
    {
      $nogloria = 1;
    }
  }

  #$psalmfolder = ($accented =~ /plain/i) ? 'psalms' : 'psalms1';
  $psalmfolder = 'psalms1';
  $psalmfolder = 'PiusXII' if ($lang eq 'Latin' && $psalmvar);
  my $psnum;

  if ($num =~ /\[(.*?)\]/) {

    # Psalm said only in penitential seasons (intended for psalm
    # transferred from Lauds to Prime).
    $psnum = $1;
    return unless ($dayname[0] =~ /adv|quad/i);
  } elsif ($num =~ /^\s*([0-9]+)/) {
    $psnum = $1;
  } else {
    return;
  }

  # Get the filename of the psalm. Psalm 94, being the psalm used at
  # the invitatory, lives elsewhere, and is loaded here only for its
  # special third-nocturn use on the day of the Epiphany.
  my $fname = ($psnum == 94) ? 'Psalterium/Invitatorium1.txt' : "$psalmfolder/Psalm$psnum.txt";
  if ($version =~ /1960|Newcal/) { $fname =~ s/Psalm226/Psalm226r/; }
  if ($version =~ /1960|Newcal/ && $num !~ /\(/ && $dayname[0] =~ /Nat/i) { $fname =~ s/Psalm88/Psalm88r/; }
  if ($version =~ /1960|Newcal/ && $num !~ /\(/ && $month == 8 && $day == 6) { $fname =~ s/Psalm88/Psalm88a/; }
  $fname = checkfile($lang, $fname);
  # load psalms
  @lines = do_read($fname);
  my $str = 'Psalmus';
  $str = translate($str, $lang);
  my $pnum;

  if ($column == 1) {
    $psalmnum1++;
    $pnum = setfont($smallblack, " [" . $psalmnum1 . "]");
  } else {
    $psalmnum2++;
    $pnum = setfont($smallblack, " [" . $psalmnum2 . "]");
  }
  my $t = '';

  if ($num > 150 && $num < 300 && @lines) {
    $line = $lines[0];

    if ($line =~ /\s*[(]?(.*?)\s+[*]/i) {
      $t = setfont($redfont, $1) . settone(1) . $pnum;
    }
  }
  if (!$t) { $t = setfont($redfont, "$str $num") . settone(1) . $pnum; }
  my $v1 = $v = 0;
  my $v2 = 1000;

  # Extract limits of the division of the psalm.
  if ($num =~ /\((.*?)\)/) {
    my @v = split('-', $1);
    $v1 = $v[0];
    $v2 = $v[1];
  }

  # Flag to signal that dagger should be prepended to current line.
  my $prepend_dagger = 0;
  my $formatted_antline;

  if (@lines) {
    my $first = ($antline) ? 1 : 0;

    foreach $line (@lines) {

      # Interleave antiphon into the psalm "Venite exsultemus".
      if ($psnum == 94 && $line =~ /^\s*\$ant\s*$/) {
        $formatted_antline ||= setfont($redfont, 'Ant.') . " $antline";
        $t .= "\n$formatted_antline";
        next;
      }

      if ($line =~ /^\s*([0-9]+)\:([0-9]+)/) {
        $v = $2;
      } elsif ($line =~ /^\s*([0-9]+)/) {
        $v = $1;
      }
      if ($v < $v1 && $v > 0) { next; }
      if ($v > $v2) { last; }
      $lnum = '';

      if ($line =~ /^([0-9]*[\:]*[0-9]+)(.*)/) {
        $lnum = setfont($smallfont, $1);
        $line = $2;
      }
      my $rest;

      if ($line =~ /(.*?)(\(.*?\))(.*)/) {
        $rest = $3;
        $before = $1;
        $this = $2;
        $this =~ s/:\d+-\d+\)/:$v1-$v2)/ if ($v2 != 1000);
        $before =~ s/^\s*([a-z])/uc($1)/ei;
        $line = $before . setfont($smallfont, ($this));
      } else {
        $rest = $line;
        $line = '';
      }
      $rest =~ s/[ ]*//;

      if ($prepend_dagger) {
        $rest = "\x{2021} $rest";
        $prepend_dagger = 0;
      }

      if ($first && $rest && $rest !~ /^\s*$/) {
        $rest = getantcross($rest, $antline);

        # Put dagger at start of second line if it would otherwise
        # have come at the end of the first.
        $prepend_dagger = ($rest =~ s/\x{2021}\s*$//);
        $first = 0;
      }
      $rest =~ s/\x{2021}/setfont($smallfont, "\x{2021}")/e;
      if ($lang =~ /magyar/i) { $rest = setasterisk($rest); }
      $rest =~ s/^\s*([a-z])/uc($1)/ei;
      $t .= "\n$lnum $line $rest";
    }
    $t .= "\n";
    if ($version eq "Monastic" && $num == 129 && $hora eq 'Prima') { $t .= $prayers{$lang}->{Requiem}; }
    elsif ($num != 210 && !$nogloria) { $t .= "\&Gloria\n"; }
    $t .= settone(0);
    return $t;
  } else {
    return "$t$datafolder/$lang/$psalmfolder/Psalm$psnum.txt not found";
  }
}

#*** getantcross($psalmline, $antline)
# set a	‡ sign if psalmline matches antline
# eliminating accents and pintuation
sub getantcross {

  my $psalmline = shift;
  my $antline = shift;
  my @psalmline = split(' ', $psalmline);
  my @antline = split(' ', $antline);
  my $pind = 0;
  my $aind = 0;

  $psalmline1 = $psalmline;
  $psalmline = '';
  $antline = '';

  while ($aind < @antline && $pind < @psalmline) {
    my $item1 = $psalmline[$pind];
    $pind++;
    $item1 = depunct($item1);
    if (!$item1) { next; }
    my $item2 = $antline[$aind];
    $aind++;
    $item2 = depunct($item2);
    if (!$item2) { $pind--; next; }
    if ($item1 !~ /$item2/i) { return $psalmline1; }
    $psalmline .= " $psalmline[$pind-1]";
  }

  # Don't place a dagger if the antiphon is longer than the verse.
  return $psalmline1 if ($aind < @antline && $pind == @psalmline);

  # Skip over any remaining punctuation.
  $psalmline .= ' ' . $psalmline[$pind++] while ($pind < @psalmline && !depunct($psalmline[$pind]));

  # Output dagger.
  $psalmline .= " \x{2021}";

  # Append rest of the verse.
  $psalmline .= ' ' . $psalmline[$pind++] while ($pind < @psalmline);
  return $psalmline;
}

sub depunct {
  my $item = shift;
  $item =~ s/[.,:?!"';*()]//g;
  $item =~ s/[áÁ]/a/g;
  $item =~ s/[éÉ]/e/g;
  $item =~ s/[íí]/i/g;
  $item =~ tr/Jj/Ii/;
  $item =~ s/[óöõÓÖÔ]/o/g;
  $item =~ s/[úüûÚÜÛ]/u/g;
  $item =~ s/æ/ae/g;
  $item =~ s/œ/oe/g;
  return $item;
}

sub settone {
  if (
    (
      (!$Hk && $Tk < 3) || $voicecolumn !~ /chant/i || ($hora =~ /Matutinum/i
        && !$chantmatins)
    )
    && !$notes
    )
  {
    return '';
  }
  my $flag = shift;
  if (!$flag) { return " {::} "; }
  my $ind = 0;
  my $i = 0;
  my @parray;
  my $tone = '';

  if ($version =~ /Monastic/i) {
    if ($hora =~ /Matutinum/i) { return ''; }

    if ($hora =~ /(Laudes|Vespera)/i) {
      if ($flag != 2 && $psalmnum1 == 0) { return ' {:p9d:} '; }
      @parray = split("\n", $chant{"Monastic $hora"});
      my @a = split(',', $parray[$dayofweek]);
      my $j = ($flag == 2) ? -1 : $psalmnum1 - 1;
      return " {:p$a[$j]:} ";
    } else {
      @parray = split("\n", $chant{"Monastic Horas"});
      my $j =
          ($hora =~ /Prima/i) ? 0
        : ($hora =~ /Tertia/i) ? 1
        : ($hora =~ /Sexta/i) ? 2
        : ($hora =~ /Nona/i) ? 3
        : 4;
      my @a = split(',', $parray[$j]);
      return " {:p$a[$dayofweek]:}";
    }
  } elsif ($hora =~ /matutinum/i) {
    @parray =
        ($dayname[0] =~ /Pasc/i) ? split("\n", $chant{'Matins Pasc'})
      : ($dayname[0] =~ /Adv/i && $winner =~ /tempora/i && $dayofweek == 0) ? split("\n", $chant{'Matins Adv'})
      : split("\n", $chant{'Matins'});
    $i = $dayofweek;

    if ($version =~ /Trident/i && $winner{Rank} =~ /(ex|vide) C([0-9]+)/i) {
      my $n = $2;

      if ($n != 10) {
        if ($dayname[0] =~ /Pasc/i) { $n = 'p'; }
        @parray = split("\n", $chant{"Matins C$n"});
        $i = 0;
      }
    }
    $ind = $psalmnum1 - 1;

    if ($dayname[0] =~ /Pasc/i) {
      $ind = floor($ind / 3);
    } elsif ($version =~ /Trident/i && @parray > 1) {
      my @tridind =
          ($dayofweek == 0)
        ? (0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8)
        : (0, 0, 1, 1, 3, 3, 4, 4, 6, 6, 7, 7);
      $ind = $tridind[$ind];
    }
  } else {
    my $d = ($rule =~ /psalmi dominica/i) ? 0 : $dayofweek;
    @parray = split("\n", $chant{"Day$d"});
    $i = ($hora =~ /laudes/i) ? 0 : ($hora =~ /vespera/i) ? 3 : 2;
    if ($hora =~ /laudes/ && $laudes == 2 && $flag == 1) { $i++; }
    $ind = ($flag == 1) ? $psalmnum1 - 1 : 5;
    my @tridind = (0, 1, 2, 2, 3, 4, 4, 4, 5);
    my @tridind0 = (0, 0, 0, 0, 3, 4, 4, 4, 5);

    if ($version =~ /Trid/i && $hora =~ /Laudes/i) {
      $ind = ($flag > 1) ? 5 : ($d > 0) ? $tridind[$ind] : $tridind0[$ind];
    }
  }
  my @a = split(',', $parray[$i]);
  my $j =
      ($hora =~ /(laudes|vespera|matutinum)/i) ? $ind
    : ($hora =~ /Prima/i) ? 0
    : ($hora =~ /Tertia/i) ? 1
    : ($hora =~ /Sexta/i) ? 2
    : ($hora =~ /Nona/i) ? 3
    : 4;
  $tone = $a[$j];
  return ($flag == 2) ? " {:pc$tone:} " : " {:p$tone:} ";
}

sub adjust_refs {
  use strict;
  my ($name, $lang) = @_;
  our ($rule, @dayname, $winner, $smallfont, $priest);

  if ($name =~ /\&Gloria/ && $rule =~ /Requiem gloria/i) {
    return '$Requiem';
  }

  if (
    ($name =~ /\&Gloria$/i && triduum_gloria_omitted())
    || ( $name =~ /\&Gloria[12]/i
      && $dayname[0] =~ /(Quad[56])/i)
    && $winner !~ /Sancti/i
    && $rule !~ /Gloria responsory/i
    )
  {
    return setfont($smallfont, translate('Gloria omittitur', $lang));
  }

  if (
    !$priest
    && (($name =~ /&Dominus_vobiscum1/i && !preces('Dominicales et Feriales'))
      || $name =~ /&Dominus_vobiscum2/i)
    )
  {
    our %prayers;
    my $text = $prayers{$lang}->{'Dominus'};
    my @text = split("\n", $text);
    return $text[4];
  }

  # No adjustment necessary.
  return $name;
}

#*** setlink($name, $ind, $lang
# sets a link for expand a skeleton chapter line or to call a popup
sub setlink {

  my $name = shift;
  my $ind = shift;
  my $lang = shift;
  my $disabled = ($name =~ /(omit|elmarad)/i) ? 'DISABLED' : '';
  my $smallflag = ($name =~ /(ante|post)/i) ? 1 : 0;

  $name =~ s/\s*$//;
  my $suffix = '';

  if ($name =~ /\{.*?\}/) {
    $name =~ s/(\{.*?\})//;
    $suffix = $1;
    $suffix = setfont($smallblack, $suffix);
  }
  my $t = linkcode($name, $ind, $lang, $disabled);

  if ($name =~ /(Deus in adjutorium|Indulgentiam|Te decet)/i) {
    $suffix = " + $suffix";
  }

  if ($name =~ /Domine labia/i) {
    $suffix = " ++ $suffix";
  }

  # Get index into translation table for the short text.
  $name = get_link_name($name);
  $name = translate($name, $lang) unless ($name =~ /^\#/);
  $name .= $suffix;
  $name =~ s/[\#\$\&]//g;
  my $after = '';

  if (!$Tk && $name =~ /(.*?)(<input.*)/i) {
    $name = $1;
    $after = $2;
  }

  if ($Tk && $name =~ /(.*?)(\{\^.*)/) {
    $name = $1;
    $after = $2;
  }

  if ($disabled || $smallflag) {
    $name = setfont($smallblack, $name);
  } elsif ($expand =~ /skeleton/i) {
    $name = setfont($largefont, substr($name, 0, 1)) . setfont($redfont, substr($name, 1));
  } else {
    $name = setfont($largefont, substr($name, 0, 1)) . substr($name, 1);
  }
  return "$t$name$after";
}

sub get_link_name {
  my $name = shift;
  our $priest;
  our @dayname;
  our $hora;

  if ($name =~ /\&Gloria1/i) {
    $name = "\&gloria";
  } elsif ($name =~ /\&Gloria2/i) {
    $name = "\&Gloria";
  } elsif ($name =~ /&Dominus/i && !$priest) {
    $name = '&Domine exaudi';
  } elsif ($name =~ /&Dominus/) {
    $name =~ s/[12]//;
  } elsif ($name =~ /&Alleluia/i
    && $dayname[0] =~ /Quad/i
    && !Septuagesima_vesp())
  {
    $name = '&Laus tibi';
  } elsif (
    $name =~ /\&Benedicamus[_ ]Domino/i
    && (($dayname[0] =~ /(Pasc0)/i && $hora =~ /(Laudes|Vespera)/i)
      || Septuagesima_vesp())
    )
  {
    $name = '&Benedicamus Domino alleluja';
  }
  return $name;
}

#*** translate($name)
# return the translated name (called only for column2 if necessary)
sub translate {
  my $name = shift;
  my $lang = shift;
  my $n = $name;
  my $prefix = '';
  if ($n =~ s/(\$|\&)//) { $prefix = $1; }
  $n =~ s/^\n*//;
  $n =~ s/\n*$//;
  $n =~ s/\_/ /g;

  if (!exists($translate{$lang}{$n})) {
    $n = $name;
  } else {
    $n = $translate{$lang}{$n};
    if ($name !~ /(omit|elmarad)/i) { $n = $prefix . $n; }
    $n =~ s/\n*$//;
  }
  return "$n";
}

#*** ant_Benedictus($num, $lang)
# returns the antiphona $num=1 = for beginning =2 for end
sub ant_Benedictus : ScriptFunc {

  my $num = shift;
  my $lang = shift;
  our ($version, $winner);
  our ($month, $day);
  our $duplex;

  if (our $ck) {
    if ($lang =~ our $lang1) {
      $version = our $version1;
    } else {
      $version = our $version2;
    }
  }
  my ($ant) = getantvers('Ant', 2, $lang);

  if ($month == 12 && ($day == 21 || $day == 23) && $winner =~ /tempora/i) {
    my %specials = %{setupstring(our $datafolder, $lang, "Psalterium/Major Special.txt")};
    $ant = $specials{"Adv Ant $day" . "L"};
  }
  my @ant_parts = split('\*', $ant);
  if ($num == 1 && $duplex < 3 && $version !~ /1960|Newcal|Praedicatorum/ && $version !~ /monastic/i) { return "Ant. $ant_parts[0]"; }

  if ($num == 1) {
    return "Ant. $ant";
  } else {
    $ant =~ s/\s*\*\s*/ /;
    return "Ant. {::}$ant";
  }
}

#*** ant_Magnificat($num, $lang)
# returns the antiphon for $num=1 the beginning, or =2 for the end
sub ant_Magnificat : ScriptFunc {

  my $num = shift;    #1=before, 2=after
  my $lang = shift;

  our ($version, $winner);
  our ($month, $day);
  our $duplex;
  our $rank;
  our $vespera;

  if (our $ck) {
    if ($lang =~ our $lang1) {
      $version = our $version1;
    } else {
      $version = our $version2;
    }
  }
  my $v = ($version =~ 1960 && $winner =~ /Sancti/i && $rank < 5) ? 3 : $vespera;
  my ($ant) = getantvers('Ant', $v, $lang);

  # Special processing for Common of Supreme Pontiffs. Confessor-Popes
  # have a common Magnificat antiphon at second Vespers.
  if ($version !~ /Trident/i && $v == 3 && (my (undef, $class) = papal_rule($winner{Rule})) && $class =~ /C/i) {
    $ant = papal_antiphon_dum_esset($lang);
  }

  if ($month == 12 && ($day > 16 && $day < 24) && $winner =~ /tempora/i) {
    my %specials = %{setupstring($datafolder, $lang, "Psalterium/Major Special.txt")};
    $ant = $specials{"Adv Ant $day"};
    $num = 2;
  }
  my @ant_parts = split('\*', $ant);
  if ($num == 1 && $duplex < 3 && $version !~ /1960/ && $version !~ /monastic/i) { return "Ant. $ant_parts[0]"; }

  if ($num == 1) {
    return "Ant. $ant";
  } else {
    $ant =~ s/\s*\*\s*/ /;
    return "Ant. {::}$ant";
  }
}

#*** canticum($psnum, $lang)
# returns the formatted text of Benedictus, Magnifificat or Nunc dimittis ($num=1-3)
sub canticum : ScriptFunc {
  my $psnum = shift;
  my $lang = shift;
  $psnum += 230;
  my $w = '';

  #$psalmfolder = ($accented =~ /plain/i) ? 'psalms' : 'psalms1';
  $psalmfolder = 'psalms1';
  $psalmfolder = 'PiusXII' if ($lang eq 'Latin' && $psalmvar);
  my $fname = checkfile($lang, "$psalmfolder/Psalm$psnum.txt");

  if (@w = do_read($fname)) {
    $w[0] =~ s/\!//;
    $w .= setfont($redfont, shift(@w)) . settone(2) . "\n";

    foreach $item (@w) {
      if ($item =~ /^([0-9]+\:)*([0-9]+) (.*)/) {
        my $rest = $3;
        my $num = "$1$2";
        $item = setfont($smallfont, $num) . " $rest";
      }
      $w .= "$item\n";
    }
    return $w;
  } else {
    return "$w $datafolder/$lang/$psalmfolder/Psalm$psnum.txt not found";
  }
}

sub Divinum_auxilium : ScriptFunc {
  my $lang = shift;
  my $text = "V. " . translate("Divinum auxilium", $lang);
  $text =~ s/\n.*\. /\n/ unless ($version =~ /Monastic/i);
  $text =~ s/\n/\nR. /;
  return $text;
}

#*** martyrologium($lang)
#returns the text of the martyrologium for the day
sub martyrologium : ScriptFunc {
  my $lang = shift;
  my $t = setfont($largefont, "Martyrologium ") . setfont($smallblack, "(anticip.)") . "\n_\n";

  #<FONT SIZE=1>(anticipated)</FONT>\n_\n";
  my $a = getweek(1);
  my @a = split('=', $a);
  $a = "$a[0]-$nextdayofweek";
  $a =~ s/\s//g;
  my %a = %{setupstring($datafolder, $lang, "Martyrologium/Mobile.txt")};

  if ($version =~ /1570/ && $lang =~ /Latin/i) {
    %a = %{setupstring($datafolder, $lang, "Martyrologium1570/Mobile.txt")};
  }

  if ($version =~ /1960|Newcal/ && $lang =~ /Latin/i) {
    %a = %{setupstring($datafolder, $lang, "Martyrologium1960/Mobile.txt")};
  }

  if ($version =~ /1955/ && $lang =~ /Latin/i) {
    %a = %{setupstring($datafolder, $lang, "Martyrologium1955R/Mobile.txt")};
  }
  my $mobile = '';
  my $hd = 0;
  if (exists($a{$a})) { $mobile = "$a{$a}\n"; }
  if ($month == 10 && $dayofweek == 6 && $day > 23 && $day < 31 && exists($a{'10-DU'})) { $mobile = $m{'10-DU'}; }
  if ($a =~ /Pasc0\-1/i) { $hd = 1; }
  if ($winner{Rank} =~ /ex C9/i && exists($a{'Defuncti'})) { $mobile = $a{'Defuncti'}; $hd = 1; }
  if ($month == 11 && $day == 14 && $version =~ /Monastic/i) { $mobile = $a{'DefunctiM'}; $hd = 1; }

  #if ($month == 12 && $day == 25 && exists($a{'Nativity'})) {$mobile = $a{'Nativity'}; $hd = 1;}
  if ($hd == 1) { $t = "v. $mobile" . "_\n$t"; $mobile = ''; }
  $fname = nextday($month, $day, $year);
  my ($m, $d) = split('-', $fname);
  my $y = ($m == 1 && $d == 1) ? $year + 1 : $year;

  if ($version =~ /1570/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1570/$fname.txt")) {
    $fname = "$datafolder/Latin/Martyrologium1570/$fname.txt";
  } elsif ($version =~ /1960|Newcal/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1960/$fname.txt")) {
    $fname = "$datafolder/Latin/Martyrologium1960/$fname.txt";
  } elsif ($version =~ /1955/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1955R/$fname.txt")) {
    $fname = "$datafolder/Latin/Martyrologium1955R/$fname.txt";
  } else {
    $fname = checkfile($lang, "Martyrologium/$fname.txt");
  }

  if (my @a = do_read($fname)) {
    my ($luna, $mo) =
      ($year >= 1900 && $year < 2200)
      ? gregor($m, $d, $y, $lang)
      : luna($m, $d, $y, $lang);

    if ($lang =~ /Latin/i) {
      $a[0] .= " $luna";
    } else {
    FINDDATE:
      {
        foreach (@a) {
          last FINDDATE if s/^U[p]+on.*?$mo[, ]*/$luna /i;
        }

        # Put $luna at the start if and only if we didn't find a
        # suitable substitution in the loop above.
        unshift(@a, $luna, "_\n");
      }
    }
    my $prefix = "v. ";

    foreach $line (@a) {
      if (length($line) > 3) {
        $t .= "$prefix$line\n";
      } else {
        $t .= "$line\n";
      }
      $prefix = "r. ";

      if ($mobile && $line =~ /\_/) {
        $t .= "$prefix$mobile";
        $mobile = '';
      }
    }
  }
  our %prayers;
  $t .= $prayers{$lang}->{Conclmart};
  return $t;
}

sub gregor {

  my ($month, $day, $year, $lang) = @_;
  my $golden = $year % 19;
  my @epact = (29, 10, 21, 2, 13, 24, 5, 16, 27, 8, 19, 30, 11, 22, 3, 14, 25, 6, 17);
  my @om = (30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 100);
  my @firstmonth = (2, 21, 10, 29, 18, 7, 26, 15, 4, 23, 12, 1, 20, 9, 28, 17, 6, 25, 14);

  if ($golden == 18) {
    $om[12] = 29;
  } else {
    $om[12] = 30;
  }
  if (leapyear($year) && ($month > 2 || ($month == 2 && $day > 24))) { $om[1] = 30; }
  if ($golden == 0) { unshift(@om, 30); }
  if ($golden == 8 || $golden == 11) { unshift(@om, 30); }

  my $t = date_to_days($day, $month - 1, $year);
  my @d = days_to_date($t);
  my $yday = $d[7];
  my $num = -$epact[$golden] - 1;
  my $i = 0;

  while ($num < $yday) {
    $num += $om[$i];
    $i++;
  }
  my $gday;
  $num -= $om[$i - 1];
  $gday = $yday - $num;
  my @ordinals = (
    'prima', 'secúnda', 'tértia', 'quarta',
    'quinta', 'sexta', 'séptima', 'octáva',
    'nona', 'décima', 'undécima', 'duodécima',
    'tértia décima', 'quarta décima', 'quinta décima', 'sexta décima',
    'décima séptima', 'duodevicésima', 'undevicésima', 'vicésima',
    'vicésima prima', 'vicésima secúnda', 'vicésima tértia', 'vicésima quarta',
    'vicésima quinta', 'vicésima sexta', 'vicésima séptima', 'vicésima octáva',
    'vicésima nona', 'tricésima'
  );
  my @months = (
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  );
  my $sfx1 =
      ($day > 3 && $day < 21) ? 'th'
    : (($day % 10) == 1) ? 'st'
    : (($day % 10) == 2) ? 'nd'
    : (($day % 10) == 3) ? 'rd'
    : 'th';
  my $sfx2 =
      ($gday > 3 && $gday < 21) ? 'th'
    : (($gday % 10) == 1) ? 'st'
    : (($gday % 10) == 2) ? 'nd'
    : (($gday % 10) == 3) ? 'rd'
    : 'th';
  $day = $day + 0;

  if ($lang =~ /Latin/i) {
    return ("Luna $ordinals[$gday-1] Anno Dómini $year\n", ' ');
  } elsif ($lang =~ /Polski/i) {
    return ("Roku Pańskiego $year");
  } else {
    return ("$months[$month - 1] $day$sfx1 $year, the $gday$sfx2 day of the Moon,", $months[$month - 1]);
  }

  #return sprintf("%02i", $gday);
}

sub luna {

  my ($month, $day, $year, $lang) = @_;
  my $epact2008 = 23;
  my $edays = date_to_days(1, 0, 2008);
  my $lunarmonth = 29.53059;
  my @months = (
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  );
  my @ordinals = (
    'prima', 'secúnda', 'tértia', 'quarta',
    'quinta', 'sexta', 'séptima', 'octáva',
    'nona', 'décima', 'undécima', 'duodécima',
    'tértia décima', 'quarta décima', 'quinta décima', 'sexta décima',
    'décima séptima', 'duodevicésima', 'undevicésima', 'vicésima',
    'vicésima prima', 'vicésima secúnda', 'vicésima tértia', 'vicésima quarta',
    'vicésima quinta', 'vicésima sexta', 'vicésima séptima', 'vicésima octáva',
    'vicésima nona', 'tricésima'
  );
  my $sfx1 = (($day % 10) == 1) ? 'st' : (($day % 10) == 2) ? 'nd' : (($day % 10) == 3) ? 'rd' : 'th';
  my $t = (date_to_days($day, $month - 1, $year) - $edays + $epact2008);
  $mult = floor($t / $lunarmonth);
  $dist = floor($t - $mult * $lunarmonth - .25);
  if ($dist <= 0) { $dist = 30 + $dist; }
  my $sfx2 = (($dist % 10) == 1) ? 'st' : (($dist % 10) == 2) ? 'nd' : (($dist % 10) == 3) ? 'rd' : 'th';
  $day = $day + 0;

  if ($lang =~ /Latin/i) {
    return ("Luna $ordinals[$dist-1]. Anno $year\n", ' ');
  } else {
    return ("$months[$month - 1] $day$sfx1 $year. The $dist$sfx2 day of the Moon.", $months[$month - 1]);
  }
}

#*** laudes()
# not used
sub laudes {
  return "skip";
}

#*** special($name, $lang)
# used for 11-02 office
sub special : ScriptFunc {
  my $name = shift;
  my $lang = shift;
  my $r = '';
  %w = (columnsel($lang)) ? %winner : %winner2;

  if (exists($w{$name})) {
    $r = "!Special $name\n_\n" . chompd($w{$name}) . "\n";
  } else {
    $r = "$name is missing";
  }
  return $r;
}

#*** getordinarium($lanf, $command)
# returns the ordinarium for the language and hora
sub getordinarium {
  my $lang = shift;
  my $command = shift;
  my @script = ();
  my $suffix = "";
  if ($command =~ /Matutinum/i && $rule =~ /Special Matutinum Incipit/i) { $suffix .= "e"; }
  if ($version =~ /(1955|1960|Newcal)/) { $suffix .= "1960"; }
  elsif ($version =~ /trident/i && $hora =~ /(laudes|vespera)/i) { $suffix .= "Trid"; }
  elsif ($version =~ /Monastic/i) { $suffix .= "M"; }
  elsif ($version =~ /Ordo Praedicatorum/i) { $suffix .= "OP"; }
  my $fname = checkfile($lang, "Ordinarium/$command$suffix.txt");

  @script = process_conditional_lines(do_read($fname));
  $error = "$fname cannot be opened or gives an empty script." unless @script;

  # Prelude pseudo-item.
  unshift @script, '#Prelude', '';
  return @script;
}

#*** setasterisk($line)
# stets the asterisk to a non pointed psalm verse line by line
sub setasterisk {
  my $line = shift;
  $line =~ s/\s*$//;
  if ($line =~ /\*(.*)/ && length($1) > 9) { return $line; }
  my $lp2 = (length($line) > 64) ? 24 : (length($line) < 24) ? 6 : 12;
  my $t = '';
  my $l = $line;

  if ($line =~ /(.*?)[\.\:\;\?\!](.*)$/ && length($2) > $lp2) {
    while ($l =~ /(.*)([\.\:\;\?\!])(.*?)$/) {
      $breaker = $2;
      $after = $3;
      $l = $1;

      if (length("$after$t") > $lp2) {
        if (length($l) > $lp2) { return "$l$breaker *$after$t"; }
        last;
      }
      $t = "$breaker$after$t";
    }
  }
  $t = '';
  $l = $line;
  my $b = ($line =~ /(.*?),(.*)$/ && length($2) > $lp2) ? ',' : ' ';

  while ($l =~ /(.*)($b)(.*?)$/) {
    $breaker = $2;
    $after = $3;
    $l = $1;
    if (length($l) < $lp2 && $b eq ',') { $b = ' '; $l = $line; $t = ''; next; }

    while ($breaker eq ' ' && length($l) > ($lp2 + 3) && $l =~ /(.*) (.*?)$/ && length($2) < 4) {
      $l = $1;
      $after = "$2 $after";
    }

    if (length("$after$t") > $lp2) {
      if ($after !~ /^ /) { $after = " $after"; }
      return "$l$breaker *$after$t";
    }
    $t = "$breaker$after$t";
  }
  if ($t !~ /^ /) { $t = " $t"; }
  return "$l *$t";
}

sub columnsel {
  my $lang = shift;
  if ($Ck) { return ($column == 1) ? 1 : 0; }
  return ($lang =~ /^$lang1$/i) ? 1 : 0;
}

#*** ensure_single_alleluia($text, $lang)
# Ensures that $text ends in a single 'alleluia' (or rather the
# appropriate translation for $lang).
sub ensure_single_alleluia(\$$) {
  my ($text, $lang) = @_;
  our %prayers;
  my $alleluia = $prayers{$lang}->{'Alleluia Simplex'};
  $alleluia =~ s/\s+$//;
  my $alleluia_depunct = depunct($alleluia);

  # Add a single 'alleluia', unless it's already there.
  $$text =~ s/\W*?(\s*)$/$alleluia$1/ unless depunct($$text) =~ /$alleluia_depunct\s*$/i;
}

#*** ensure_resp_paschal($text, $lang)
# Arranges that $text should end in a double 'alleluia' (or rather the
# appropriate translation for $lang), and that the asterisk should be
# placed correctly, if it appears that the response is not already in
# the Paschal form.
sub ensure_double_alleluia(\$$) {
  my ($text, $lang) = @_;
  our %prayers;
  my $alleluia = $prayers{$lang}->{'Alleluia Duplex'};
  $alleluia =~ s/\s+$//;
  my $alleluia_depunct = depunct($alleluia);

  unless (depunct($$text) =~ /$alleluia_depunct\s*$/i) {

    # Add a double 'alleluia' and move the asterisk.
    $$text =~ s/\s*\*\s*(.)/ \l\1/;
    $$text =~ s/\W*?(\s*)$/, * $alleluia$1/;
  }
}

#*** process_inline_alleluia($text)
# Removes all alleluias after Septuagesima; removes bracketed alleluias
# outside of Paschaltide; unbrackets bracketed alleluias in
# Paschaltide.
sub process_inline_alleluias(\$) {
  my $text = shift;
  our @dayname;

  if ($dayname[0] !~ /Pasc/i) {
    $$text =~ s/\(Allel[uú][ij]a.*?\)//isg;
  } else {
    $$text =~ s/\((Allel[uú][ij]a.*?)\)/$1/isg;
  }
  if ($dayname[0] =~ /Quad/i) { $$text =~ s/[(]*allel[uú][ij]a[\.\,]*[)]*//ig; }
}

#*** postprocess_ant($ant, $lang)
# Performs necessary adjustments to an antiphon.
sub postprocess_ant(\$$) {
  my ($ant, $lang) = @_;
  our @dayname;

  # Don't do anything to null antiphons.
  return unless $$ant;
  process_inline_alleluias($$ant);
  ensure_single_alleluia($$ant, $lang) if ($dayname[0] =~ /Pasc/i && !officium_defunctorum());
}

#*** postprocess_vr($vr, $lang)
# Performs necessary adjustments to a versicle and repsonse.
sub postprocess_vr(\$$) {
  my ($vr, $lang) = @_;
  our @dayname;

  # Don't do anything to null v/r.
  return unless $$vr;
  process_inline_alleluias($$vr);

  if ($dayname[0] =~ /Pasc/i && !officium_defunctorum()) {
    my ($versicle, $response) = split(/(?=^\s*R\.)/m, $$vr);
    ensure_single_alleluia($versicle, $lang);
    ensure_single_alleluia($response, $lang);
    $$vr = $versicle . $response;
  }
}

#*** postprocess_short_resp(@capit, $lang)
# Performs necessary adjustments to a short responsory.
sub postprocess_short_resp(\@$) {
  my ($capit, $lang) = @_;
  s/&Gloria1?/&Gloria1/ for (@$capit);

  if ($dayname[0] =~ /Pasc/i) {
    my $rlines = 0;

    for (@$capit) {
      if (/^R\.br\./ ... (/^R\./ && ++$rlines >= 3)) {

        # Short responsory proper.
        if ((/^V\./ .. /^R\./) && /^R\./) {
          our %prayers;
          $_ = 'R. ' . $prayers{$lang}->{'Alleluia Duplex'};
        } elsif (/^R\./) {
          ensure_double_alleluia($_, $lang);
        }
      } elsif (/^[VR]\./) {

        # V/R following short responsory.
        ensure_single_alleluia($_, $lang);
      }
    }
  }
}

#*** officium_defunctorum()
# Detects whether the office is of the dead. This is checked in lots
# of different ways throughout the program; this function is the
# beginning of an attempt at uniformity.
sub officium_defunctorum() {
  return our $votive =~ /C9|Defunctorum/i;
}
