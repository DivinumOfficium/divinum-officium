#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
use FindBin qw($Bin);
use lib "$Bin/..";

use DivinumOfficium::LanguageTextTools
  qw(prayer translate omit_regexp suppress_alleluia process_inline_alleluias alleluia_ant ensure_single_alleluia ensure_double_alleluia);
use DivinumOfficium::Date qw(date_to_days days_to_date);

# Defines ScriptFunc and ScriptShortFunc attributes.
use DivinumOfficium::Scripting;
my $precesferiales;
$a = 1;

sub adhoram {
  my $hora = shift;
  my $head = "Ad $hora";
  $head =~ s/a$/am/;
  $head = 'Ad Vesperas' if $hora =~ /vesper/i;
  $head;
}

#*** horas($hora)
# collects and prints the officium for the given $hora
sub horas {
  my $command = shift;
  $hora = $command;
  $hora = 'Vespera' if $hora =~ /vesper/i;
  print "<H2 ID='${hora}top'>" . adhoram($hora) . "</H2>\n";
  my (@script1, @script2);
  our ($lang1, $lang2, $column);
  $column = 1;    # The 'setbuild' functions in specials.pl check for this to set the Building Script

  if ($Ck) {
    $version = $version1;
    precedence();
  }

  @script1 = getordinarium($lang1, $command);
  @script1 = specials(\@script1, $lang1);
  $column = 2;    # This prevents the duplications in the Building Script

  if ($Ck) {
    $version = $version2;
    load_languages_data($lang1, $lang2, $version, $missa);
    precedence();
  }

  if (!$only) {
    @script2 = getordinarium($lang2, $command);
    @script2 = specials(\@script2, $lang2);
  }

  print_content($lang1, \@script1, $lang2, \@script2, $version !~ /(1570|1955|196)/);
}

#*** resolve refs($text_of_block, $lang)
#resolves $name &name references and special characters
#retuns the to be listed text
sub resolve_refs {
  my $t = shift;
  my $lang = shift;
  my @t = split("\n", $t);

  #handles expanding for skeleton
  if ($expand =~ /skeleton/ && $expandind != $expandnum) {
    if ($t[0] =~ /\#/) {
      return setlink($t[0], $expandind, $lang);
    } else {
      return "";
    }
  }

  if ($t[0] =~ omit_regexp()) {
    $t[0] =~ s/^\s*\#/\!\!\!/;
  } else {
    $t[0] =~ s/^\s*(\#.*)(\{.*\})?\s*$/'!!' . substr(translate($1, $lang), 1) . $2/e;
  }
  my @resolved_lines;    # Array of blocks expanded from lines.
  my $merged_lines;      # Preceding continued lines.

  #cycle by lines
  for (my $it = 0; $it < @t; $it++) {
    $line = adjust_refs($t[$it], $lang);
    $line =~ s/\s+$//;
    $line =~ s/^\s+//;

    my $merge_with_next = ($line =~ s/~$//);

    #$ and & references
    if ($line =~ /^[\#\$\&]/) {
      $line =~ s/\.//g;

      #prepares reading the part of common w/ antiphona
      if ($line =~ /psalm/ && $it > 0 && $t[$it - 1] =~ /^\s*Ant\. /i) {
        $line = expand($line, $lang, $t[$it - 1]);

        # If the psalm has a cross, then so should the antiphon.
        @resolved_lines[-1] .= setfont($smallfont, " \x{2021}") if $line =~ /\x{2021}/;
      } else {
        $line = expand($line, $lang);
      }

      if ($line !~ /\<input/i) {
        $line = resolve_refs($line, $lang);
      }    #for special chars
    }

    # add dot if missing in Antiphona
    $line =~ s/(\w)$/$&./ if ($line =~ /^Ant\./);

    #red prefix
    if ($line =~ /^(R\.br\.|R\.|V\.|Ant\.|Benedictio\.|Absolutio\.)(.*)/) {
      my $h = setvrbar($1);
      my $l = $2;

      $h =~ s/(Benedictio|Absolutio)/ translate($1, $lang) /e;
      $line = setfont($redfont, $h) . $l;
    }

    #cross
    $line = setcross($line);

    #small omitted title
    if ($line =~ /^\!\!\!(.*)/) {
      $l = $1;
      $line = setfont($smallblack, $l);
    }

    #large chapter title
    elsif ($line =~ /^\!\!(.*)/) {
      my $l = $1;
      my $suffix = '';
      if ($l =~ s/(\{[^:].*?\})//) { $suffix = setfont($smallblack, $1); }
      $line = setfont($largefont, $l) . " $suffix\n";
      if ($expand =~ /skeleton/i) { $line .= linkcode1(); }
    }

    #red line
    elsif ($line =~ /^\!(.*)/) {
      $l = $1;
      my $suffix = '';
      if ($l =~ s/(\{[^:].*?\})//) { $suffix = setfont($smallblack, $1); }
      $line = setfont($redfont, $l) . " $suffix\n";
    }

    #first letter red
    elsif ($line =~ /^r\.\s*(.\.?)(.*)/) {
      $line = setfont($largefont, $1) . $2;
    }

    # first letter initial
    elsif ($line =~ /^v\.\s*(.*)/ || $line =~ /\{\:.*?\:\}\s*v\.\s*(.*)/) {
      $line = $1;
      $line = setfont($initiale, substr($line, 0, 1)) . substr($line, 1);
    }

    # rubrics - small red
    $line =~ s{/:(.*?):/}{setfont($smallfont, $1)}eg;

    # italic for mute vovels in hymns
    $line =~ s/\[([aeiou])\]/setfont('italic', $1)/eg;

    if ($merge_with_next) {
      $merged_lines .= $line . ' ';
    } else {
      push @resolved_lines, $merged_lines . $line;
      $merged_lines = '';
    }

  }    #line by line cycle ends

  # Concatenate the expansions of the lines with a line break between each.
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
  return prayer('Pater_noster1', shift());
}

#*** teDeum($lang)
# returns the text of the hymn
sub teDeum : ScriptFunc {
  my $lang = shift;
  return "\n!Te Deum\n" . prayer('Te Deum', $lang);
}

#*** Alleluia($lang)
# return the text Alleluia or Laus tibi
sub Alleluia : ScriptFunc {
  my $lang = shift;
  my $text = prayer('Alleluia', $lang);
  my @text = split("\n", $text);

  if ($dayname[0] =~ /Quad/i && !Septuagesima_vesp()) {
    $text = $text[1];
  } else {
    $text = $text[0];
  }

  #if ($dayname[0] =~ /Pasc/i) {$text = "Alleluia, alleluia, alleluia";}
  return $text;
}

#*** Septuagesima_vesp
# Determines whether we're saying first Vespers of Septuagesima Sunday.
sub Septuagesima_vesp {
  our ($dayofweek, @dayname, $hora, $vespera, $cwinner);
  return ($dayofweek == 6
      && $hora =~ /Vespera/i
      && (($vespera == 1 && $dayname[0] =~ /Quadp1/) || ($vespera == 3 && $cwinner =~ /Quadp1\-0/)));
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
    && $tvesp != 1;
}

#*** Gloria
# returns the text or the omit notice
sub Gloria : ScriptFunc {
  my $lang = shift;
  if (triduum_gloria_omitted()) { return ""; }
  if ($rule =~ /Requiem gloria/i) { return prayer('Requiem', $lang); }
  return prayer('Gloria', $lang);
}

sub Gloria1 : ScriptFunc {    #* responsories
  my $lang = shift;
  if ($dayname[0] =~ /(Quad5|Quad6)/i && $winner !~ /Sancti/i && $rule !~ /Gloria responsory/i) { return ""; }
  return prayer('Gloria1', $lang);
}

sub Gloria2 : ScriptFunc {    #*Invitatorium
  my $lang = shift;
  if ($dayname[0] =~ /(Quad[56])/i) { return ""; }
  if ($rule =~ /Requiem gloria/i) { return prayer('Requiem', $lang); }
  return prayer('Gloria', $lang);
}

#*** Dominus_vobiscum
#returns the text of the 'Domine exaudi' for non priests
sub Dominus_vobiscum : ScriptFunc {
  my $lang = shift;
  my $text = prayer('Dominus', $lang);
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
  if ((preces('Dominicales et Feriales') || $litaniaflag) && !$priest) { $precesferiales = 1; }
  return Dominus_vobiscum($lang);
}

sub Dominus_vobiscum2 : ScriptFunc {    #* officium defunctorum
  my $lang = shift;
  if (!$priest) { $precesferiales = 1; }
  return Dominus_vobiscum($lang);
}

sub MLitany2 : ScriptFunc {
  my $lang = shift;
  if (preces('Dominicales')) { return; }
  return prayer('MLitany2', $lang);
}

#*** versiculum_ante_laudes($lang)
# return versiculum ante Laudes used in Ordo Praedicatorum only
sub versiculum_ante_laudes : ScriptFunc {
  my $lang = shift;

  my ($v, $c) = getantvers('Versum', 0, $lang);

  $v;
}

#*** Benedicamus_Domino
# adds Alleluia, alleluia for Pasc0
sub Benedicamus_Domino : ScriptFunc {
  my $lang = shift;
  my $text = prayer('Benedicamus Domino', $lang);

  if (($dayname[0] =~ /Pasc0/i && $hora =~ /(Laudes|Vespera)/i)
    || Septuagesima_vesp())
  {
    $text =~ s/\.\s*\n/". " . prayer('Alleluia Duplex', $lang) . "\n"/egr;
  } else {
    $text;
  }
}

#*** antiphona_finalis
#return the text for the appropriate time
sub antiphona_finalis : ScriptFunc {
  my $lang = shift;
  my $name;

  if ($version =~ /^Ordo Praedicatorum/) {
    $name = 'Ant Finalis OP';
  } elsif ($dayname[0] =~ /adv/i && $winner{Rank} !~ /In Nativitate Domini/i) {
    $name = 'Advent';
  } elsif ($dayname[0] =~ /Nat/i
    || ($month == 12 && $day > 23)
    || $month == 1
    || ($month == 2 && $day < 2)
    || ($month == 2 && $day == 2 && $hora !~ /Completorium/i))
  {
    $name = 'Nativiti';
  } elsif (($month == 2 || $month == 3 || $dayname[0] =~ /Quad/i) && $dayname[0] !~ /Pasc/i) {
    $name = 'Quadragesimae';
  } elsif ($dayname[0] =~ /Pasc/) {
    $name = 'Paschalis';
  } else {
    $name = 'Postpentecost';
  }
  my %ant = %{setupstring($lang, "Psalterium/Mariaant.txt")};
  my $t = $ant{$name};
  $t = '#' . translate($name eq 'Ant Finalis OP' ? 'Antiphonae finalis' : 'Antiphona finalis BMV', $lang) . "\n$t";
  return ($t);
}

#*** psalm($chapter, $lang, $antline)  or
# psalm($chapter, $fromverse, $toverse, $lang, $antline)
# if second arg is 1 omit gloria
# selects the text, attaches the head,
# sets red color for the introductory comments
# returns the visible form
sub psalm : ScriptFunc {
  my @a = @_;
  my ($num, $lang, $antline, $nogloria);

  if (@a < 4) {
    $num = shift @a;

    if ($a[0] =~ /^1$/) {
      $nogloria = shift @a;
    }
    $lang = $a[0];
    $antline = $a[1];
  } else {
    $num = "$a[0]($a[1]-$a[2])";
    $lang = $a[3];
    $antline = $a[4];
  }

  my $canticlef = 230 < $num && $num < 234;

  if ($num =~ /^-(.*)/) {
    $num = $1;

    if (
      (    $version =~ /Trident/i
        && $version !~ /Monastic/i
        && $num =~ /(62|148|149)/)    # Tridentine Romanum Laudes: Pss. 62/66 & 148/149/150 under 1 gloria
      || ($version =~ /Monastic/i && $num =~ /(115|148|149)/)
      )                               # Monastic Vespers: Pss. 115/116 & 148/149/150 under 1 gloria
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

  # load psalm
  my (@lines) = do_read($fname);

  unless (@lines > 0) {
    return "$t$datafolder/$lang/$psalmfolder/Psalm$psnum.txt not found";
  }

  # Extract limits of the division of the psalm. (potentially within a psalm verse)
  my $v1 = $v = 0;
  my $v2 = 1000;
  my $c1 = $cc = '';
  my $c2 = '';

  if ($num =~ /\((?<v1>\d+)(?<c1>[abc]?)-(?<v2>\d+)(?<c2>[abc]?)\)/) {
    ($v1, $v2, $c1, $c2) = ($+{v1}, $+{v2}, $+{c1}, $+{c2});
  }

  # Prepare title and source if canticle
  my $title = translate('Psalmus', $lang) . " $num";
  my $source;

  if ($num > 150 && $num < 300 && @lines) {
    shift(@lines) =~ /\(?(?<title>.*?) \* (?<source>.*?)\)?\s*$/;
    ($title, $source) = ($+{title}, $+{source});
    if ($v1) { $source =~ s/:\K.*/"$v1-$v2"/e; }
  }

  my $t = setfont($redfont, $title) . settone(1);
  if (!$canticlef) { $t .= setfont($smallblack, " [" . (($column == 1) ? ++$psalmnum1 : ++$psalmnum2) . "]"); }
  if ($source) { $t .= "\n!$source"; }

  # Flag to signal that dagger should be prepended to current line.
  my $prepend_dagger = 0;
  my $formatted_antline;
  my $first = $antline;
  my $initial = $nonumbers;

  foreach my $line (@lines) {

    # Interleave antiphon into the psalm "Venite exsultemus".
    if ($psnum == 94 && $line =~ /^\s*\$ant\s*$/) {
      $formatted_antline ||= setfont($redfont, 'Ant.') . " $antline";
      $t .= "\n$formatted_antline";
      next;
    }

    if ($line =~ /^\s*([0-9]+)\:([0-9]+)([abc]?)/) {
      $v = $2;
      $cc = $3;
    } elsif ($line =~ /^\s*([0-9]+)([abc]?)/) {
      $v = $1;
      $cc = $2;
    }
    if ($v < $v1 && $v > 0) { next; }
    if ($cc && $v == $v1 && $cc lt $c1) { next; }    # breaking within a Psalm Verse
    if ($v > $v2) { last; }
    if ($cc && $v == $v2 && $cc gt $c2) { last; }    # breaking within a Psalm Verse
    my $lnum = '';

    if ($line =~ /^([0-9]*[\:]*[0-9]+[abc]?)(.*)/) {
      $lnum = setfont($smallfont, $1) unless ($nonumbers);
      $line = $2;
    }

    if ($noinnumbers) {
      $lnum =~ s/[abc]//;            # Remove sub-verse letter if inline numbers hidden
      $line =~ s/\(\d+[abc]?\)//;    # Remove inline verse numbers
    }
    $line =~ s/†// if ($noflexa);
    my $rest;

    if ($line =~ /(.*?)(\(.*?\))(.*)/) {
      $rest = $3;
      $before = $1;
      $this = $2;
      $before =~ s/^\s*([a-z])/uc($1)/ei;
      $line = $before . setfont($smallfont, ($this));
      $initial = 0 if ($rest);
    } else {
      $rest = $line;
      $line = '';

      if ($initial) {
        $lnum = "v. ";
        $initial = 0;
      }
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

  if ($version =~ /Monastic/ && $num == 129 && $hora eq 'Prima') {
    $t .= prayer('Requiem', $lang);
  } elsif ($num != 210 && !$nogloria) {
    $t .= "\&Gloria\n";
  }
  $t .= settone(0);
  return $t;
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
      $voicecolumn !~ /chant/i || ($hora =~ /Matutinum/i
        && !$chantmatins)
    )
    && !$notes
  ) {
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
  ) {
    return setfont($smallfont, translate('Gloria omittitur', $lang));
  }

  if (
    !$priest
    && (($name =~ /&Dominus_vobiscum1/i && preces('Dominicales et Feriales'))
      || $name =~ /&Dominus_vobiscum2/i)
  ) {
    my $text = prayer('Dominus', $lang);
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
  my $disabled = ($name =~ omit_regexp()) ? 'DISABLED' : '';
  my $smallflag = ($name =~ /(ante|post)/i) ? 1 : 0;

  $name =~ s/\s*$//;
  my $item = $name;
  my $suffix = '';

  if ($name =~ /\{.*?\}/) {
    $name =~ s/(\{.*?\})//;
    $suffix = $1;
    $suffix = setfont($smallblack, $suffix);
  }
  my $t = linkcode($name, $ind, $lang, $disabled);

  if ($name =~ /Alleluia|Oremus|Deo gratias/i) {
    $t = '';
  }

  if ($name =~ /(Deus in adjutorium$|Indulgentiam|Te decet|Benedictio Prima2)/i) {
    $suffix = " + $suffix";
  }

  if ($name =~ /Domine[ _]labia/i) {
    $suffix = " ++ $suffix";
  }

  # Get index into translation table for the short text.
  $name = get_link_name($name);
  $name = translate($name, $lang) unless ($name =~ /^\#/);
  $name .= $suffix;
  $name =~ s/[\#\$\&]//g;
  my $after = '';

  if ($name =~ /(.*?)(<input.*)/i) {
    $name = $1;
    $after = $2;
  }

  if ($item =~ /Deo gratias/) {
    return $name;
  } elsif ($disabled || $smallflag) {
    $name = setfont($smallblack, $name);
  } elsif ($expand =~ /skeleton/i) {
    $name = setfont($largefont, substr($name, 0, 1)) . setfont($redfont, substr($name, 1));
  } else {
    $name = setfont($largefont, uc(substr($name, 0, 1))) . substr($name, 1);
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
  ) {
    $name = '&Benedicamus Domino alleluja';
  }
  return $name;
}

#*** ant_Benedictus($num, $lang)
# returns the antiphona $num=1 = for beginning =2 for end
sub ant_Benedictus : ScriptFunc {

  my $num = shift;
  my $lang = shift;
  our ($version, $winner);
  our ($month, $day);
  our $duplex;

  my ($ant) = getantvers('Ant', 2, $lang);

  if ($month == 12 && ($day == 21 || $day == 23) && $winner =~ /tempora/i) {
    my %specials = %{setupstring($lang, "Psalterium/Major Special.txt")};
    $ant = $specials{"Adv Ant $day" . "L"};
  }
  my @ant_parts = split('\*', $ant);
  if ($num == 1 && $duplex < 3 && $version !~ /196/) { return "Ant. $ant_parts[0]"; }

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

  my $v = ($version =~ 1960 && $winner =~ /Sancti/i && $rank < 5) ? 3 : $vespera;
  my ($ant) = getantvers('Ant', $v, $lang);

  # Special processing for Common of Supreme Pontiffs. Confessor-Popes
  # have a common Magnificat antiphon at second Vespers.
  my $popeclass = '';

  if ( $version !~ /Trident/i
    && $v == 3
    && ((undef, $popeclass, undef) = papal_rule($winner{Rule}))
    && $popeclass =~ /C/i)
  {
    $ant = papal_antiphon_dum_esset($lang);
    setbuild2("subst: Special Magnificat Ant. Dum esset");
  }

  if ($month == 12 && ($day > 16 && $day < 24) && $winner =~ /tempora/i) {
    my %specials = %{setupstring($lang, "Psalterium/Major Special.txt")};
    $ant = $specials{"Adv Ant $day"};
    $num = 2;
  }
  my @ant_parts = split('\*', $ant);
  if ($num == 1 && $duplex < 3 && $version !~ /196/) { return "Ant. $ant_parts[0]"; }

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
  psalm($psnum, $lang);
}

sub Nunc_dimittis {
  my $lang = shift;
  my $ant, $ant2;
  my ($w, $c) = getproprium("Ant 4$vespera", $lang, 1);

  if ($w) {
    setbuild1($ite, 'special');
    ($ant, $ant2) = split("\n", $w);
  } else {
    my %a = %{setupstring($lang, "Psalterium/Minor Special.txt")};
    my $name;
    $name = gettempora('Nunc dimittis') if $version =~ /^Ordo Praedicatorum/;
    $ant = $a{"Ant 4$name"};

    if ($version =~ /^Ordo Praedicatorum/ && $name eq ' Quad3') {
      ($ant, $ant2) = split("\n", $ant);
      $ant2 = "$ant\n$ant2";
    }
  }

  if (alleluia_required($dayname[0], $votive)) {
    ensure_single_alleluia(\$ant, $lang);
  }

  my @psalmi = ("$ant;;233");
  my $duplexf = $version =~ /196/;
  push(@s, translate('#Canticum Nunc dimittis', $lang));
  antetpsalm(\@psalmi, $duplexf, $lang);
  $s[-1] = "Ant. $ant2" if $ant2;
}

sub Divinum_auxilium : ScriptFunc {
  my $lang = shift;
  my @text = split(/\n/, prayer("Divinum auxilium", $lang));
  $text[-2] = "V. $text[-2]";
  $text[-1] =~ s/.*\. // unless ($version =~ /Monastic/i);    # contract resp. "Et cum fratribus… " to "Amen." for Roman
  $text[-1] = "R. $text[-1]";
  join("\n", @text);
}

sub Domine_labia : ScriptFunc {
  my $lang = shift;
  my $text = prayer("Domine labia", $lang);

  if ($version =~ /monastic/i) {                              # triple times with one cross sign
    $text .= "\n$text\n$text";
    $text =~ s/\+\+/$&++/;
    $text =~ s/\+\+ / /g;
  }
  $text;
}

#*** martyrologium($lang)
#returns the text of the martyrologium for the day
sub martyrologium : ScriptFunc {
  my $lang = shift;
  my $t = '';    # Title and Comment is now set in specials.pl for #Martyrolgium

  my $a = getweek($day, $month, $year, 1) . "-" . (($dayofweek + 1) % 7);
  my %a = %{setupstring($lang, "Martyrologium/Mobile.txt")};

  if ($version =~ /1570/ && $lang =~ /Latin/i) {
    %a = %{setupstring($lang, "Martyrologium1570/Mobile.txt")};
  }

  if ($version =~ /1960|Newcal/ && $lang =~ /Latin/i) {
    %a = %{setupstring($lang, "Martyrologium1960/Mobile.txt")};
  }

  if ($version =~ /1955/ && $lang =~ /Latin/i) {
    %a = %{setupstring($lang, "Martyrologium1955R/Mobile.txt")};
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
      if (length($line) > 3 && $line !~ /^\/\:/) {    # allowing /:rubrics:/ in Martyrology
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
  my $conclmart = prayer('Conclmart', $lang);
  $conclmart =~ s/\_.*/ /si if $rule =~ /ex C9/;
  $t .= $conclmart;
  return $t;
}

sub gregor {

  my ($month, $day, $year, $lang) = @_;
  my $golden = $year % 19;
  my @epact = (29, 10, 21, 2, 13, 24, 5, 16, 27, 8, 19, 30, 11, 22, 3, 14, 25, 6, 17);
  my @om = (30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 100);
  my @firstmonth = (2, 21, 10, 29, 18, 7, 26, 15, 4, 23, 12, 1, 20, 9, 28, 17, 6, 25, 14);
  my $leapday;    # only set in the last days of February in a leap year

  if ($golden == 18) {
    $om[12] = 29;
  } else {
    $om[12] = 30;
  }
  if (leapyear($year) && ($month > 2)) { $om[1] = 30; }    # || ($month == 2 && $day > 24)
  if ($golden == 0) { unshift(@om, 30); }
  if ($golden == 8 || $golden == 11) { unshift(@om, 30); }

  if (leapyear($year) && $month == 2 && $day >= 24) {
    $leapday = ($day + 1) % 30;                            #  24->25, 25->26, "29"->0
    if ($day == 29) { $day = 24; }
  }

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
    'vicésima nona', 'tricésima',
  );
  my @months = (
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  );
  my @months_it = (
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
  );
  $day = $leapday || $day;    # recover English date in Leap Years
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
  } elsif ($lang =~ /Francais/i) {
    return ("L'année du Seigneur $year, le $gday$sfx2 jour de la Lune");
  } elsif ($lang =~ /Italiano/i) {
    return ("Anno del Signore $year, $day $months_it[$month - 1], Luna $gday");
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
    'July', 'August', 'September', 'October', 'November', 'December',
  );
  my @months_it = (
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
  );
  my @ordinals = (
    'prima', 'secúnda', 'tértia', 'quarta',
    'quinta', 'sexta', 'séptima', 'octáva',
    'nona', 'décima', 'undécima', 'duodécima',
    'tértia décima', 'quarta décima', 'quinta décima', 'sexta décima',
    'décima séptima', 'duodevicésima', 'undevicésima', 'vicésima',
    'vicésima prima', 'vicésima secúnda', 'vicésima tértia', 'vicésima quarta',
    'vicésima quinta', 'vicésima sexta', 'vicésima séptima', 'vicésima octáva',
    'vicésima nona', 'tricésima',
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
  } elsif ($lang =~ /Italiano/i) {
    return ("$day $months_it[$month - 1] $year, Luna $gday");
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

#*** getordinarium($lang, $command)
# returns the ordinarium for the language and hora
sub getordinarium {
  my $lang = shift;
  my $command = shift;

  $command =~ s/Vesperae/Vespera/;
  if ($command =~ /Tertia|Sexta|Nona/i) { $command = 'Minor'; }    # identical for Terz/Sext/Non

  our $datafolder;
  my $fname = "$datafolder/Ordinarium/$command.txt";

  my @script = process_conditional_lines(do_read($fname));
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

#*** postprocess_ant($ant, $lang)
# Performs necessary adjustments to an antiphon.
sub postprocess_ant(\$$) {
  my ($ant, $lang) = @_;
  our (@dayname, $votive);

  # Don't do anything to null antiphons.
  return unless $$ant;
  ensure_single_alleluia($ant, $lang) if alleluia_required($dayname[0], $votive);
}

#*** postprocess_vr($vr, $lang)
# Performs necessary adjustments to a versicle and repsonse.
sub postprocess_vr(\$$) {
  my ($vr, $lang) = @_;
  our (@dayname, $votive);

  # Don't do anything to null v/r.
  return unless $$vr;

  if (alleluia_required($dayname[0], $votive)) {
    my ($versicle, $response) = split(/(?=^\s*R\.)/m, $$vr);
    ensure_single_alleluia(\$versicle, $lang);
    ensure_single_alleluia(\$response, $lang);
    $$vr = $versicle . "\n" . $response;
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
          $_ = 'R. ' . prayer('Alleluia Duplex', $lang);
        } elsif (/^R\./) {
          ensure_double_alleluia(\$_, $lang);
        }
      } elsif (/^[VR]\./) {

        # V/R following short responsory.
        ensure_single_alleluia(\$_, $lang);
      }
    }
  }
}

#*** alleluia_required
# check if alleluia addition is required
# it is Paschaltide and not officium defunctorum or BMV Parv.
sub alleluia_required {
  my ($dayname, $votive) = @_;

  $dayname =~ /Pasc/i && $votive !~ /C(?:9|12)/;
}
