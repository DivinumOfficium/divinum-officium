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

sub mLitany : ScriptFunc {
  my $lang = shift;
  if (preces('Dominicales')) { return ''; }
  return "\$Kyrie\n\$Pater secreto";
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

  if ($num =~ /\((?<v1>\d+)(?<c1>[a-z]?)-(?<v2>\d+)(?<c2>[a-z]?)\)/) {
    ($v1, $v2, $c1, $c2) = ($+{v1}, $+{v2}, $+{c1}, $+{c2});
  }

  # Prepare title and source if canticle
  my $title = translate('Psalmus', $lang) . " $num";
  my $source;

  if ($num > 150 && $num < 300 && @lines) {
    shift(@lines) =~ /\(?(?<title>.*?) \* (?<source>.*?)\)?\s*$/;
    ($title, $source) = ($+{title}, $+{source});
    if ($v1) { $source =~ s/:\K.*/"$v1-$v2"/e; }
  } elsif ($lang =~ /bea/i || $psalmfolder =~ /PiusXII/) {

    # remove Title if Psalm section does not start in the beginning
    shift(@lines) if $lines[0] =~ /^\(.*\)\s*$/ && $lines[1] =~ /^\d+\:(\d+)[a-z]?\s/ && $v1 > $1;

    if ($psnum eq 9) {
      splice(@lines, 20, 20) if $v2 < 22;    # remove Hebr. Ps 10
      splice(@lines, 0, 20) if $v1 > 21;     # remove Hebr. Ps 9
      shift(@lines) if $v1 > 22;             # remove Title B
    }

    if ($lines[0] =~ /^\(.*\)$/) {
      shift(@lines) =~ /\((?<title>.*?)\)\s*$/;
      $title .= " — $1";
    }
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

    if ($line =~ /^\s*([0-9]+)\:([0-9]+)([a-z]?)/) {
      $v = $2;
      $cc = $3;
    } elsif ($line =~ /^\s*([0-9]+)([a-z]?)/) {
      $v = $1;
      $cc = $2;
    }
    if ($v < $v1 && $v > 0) { next; }
    if ($cc && $v == $v1 && $cc lt $c1) { next; }    # breaking within a Psalm Verse
    if ($v > $v2) { last; }
    if ($cc && $v == $v2 && $cc gt $c2) { last; }    # breaking within a Psalm Verse
    my $lnum = '';

    if ($line =~ /^([0-9]*[\:]*[0-9]+[a-z]?)(.*)/) {
      $lnum = setfont($smallfont, $1) unless ($nonumbers);
      $line = $2;
    }

    if ($noinnumbers) {
      $lnum =~ s/(\d)[a-z]/$1/;      # Remove sub-verse letter if inline numbers hidden
      $line =~ s/\(\d+[a-z]?\)//;    # Remove inline verse numbers
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

    if ($first && $rest && $rest !~ /^\s*$/ && $num != 232) {
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

#*** special($name, $lang)
# used for 11-02 office
sub special : ScriptFunc {
  my $name = shift;
  my $lang = shift;
  my $r = '';
  %w = (columnsel($lang)) ? %winner : %winner2;

  if (exists($w{$name})) {
    $r = "!Special $name\n_\n" . chompd($w{$name}) . "\n";
  } elsif ($name =~ /^\#/) {
    my @scriptum = ();
    push(@scriptum, $name);

    @scriptum = specials(\@scriptum, $lang, 1);
    $r = join("\n", @scriptum);
  } else {
    $r = "$name is missing";
  }
  return $r;
}
