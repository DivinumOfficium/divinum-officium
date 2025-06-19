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
  return "\$Kyrie\n\$pater secreto";
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

  if (
    $hora =~ /(Laudes|Vespera)/i
    && ( $dayname[0] =~ /Pasc0/i
      || ($dayname[0] =~ /Pasc/ && $version =~ /Praedicatorum/ && ($rank > 3 || $winner eq 'C10'))
      || Septuagesima_vesp())
  ) {
    $text =~ s/\.\s*\n/". " . prayer('Alleluia Duplex', $lang) . "\n"/egr;
  } else {
    $text;
  }
}

#*** handleverses($ref)
# remove or colorize verse numbers
# parentheses text as rubrics
sub handleverses {
  map {
    if ($nonumbers) {    # remove numbering
      s/^(?:\d+:)?\d+[a-z]?\s*//;
      s/\s*\(\d+[a-z]?\)//;
    } elsif ($noinnumbers) {    # remove subverse letter & inline numbering
      s/\d\K[a-z]//;
      s/\(\d+[a-z]?\)//;
    }

    unless ($nonumbers) {       # put numbers as rubrics
      s{^(?:\d+:)?\d+[a-z]?}{/:$&:/};
      s{\(\d+[a-z]?\)}{/:$&:/};
    }

    s{(\(.*?\))}{/:$&:/};       # text in () as rubrics

    # Discussion #4504: For Breviarum Romanum style
    # ‡ marks mediant for Breviarum Romanum but flexa for Antiphonale
    # Following space to safeguard against /:‡:/ which needs to remain unchanged
    # flexa removed for Breviarum Romanum display
    s/‡\s+(.*?)\*\s*/* $1/g if $noflexa;
    s/†\s*//g if $noflexa;

    # Discussion #4504: For Antiphonale style
    # Surrounding space to safeguard against /:‡:/ which needs to remain unchanged
    s/\s‡\s/ † /g unless $noflexa;

    s/\s\+\s/ / if $version =~ /cist/i;    # no sign-of the cross in Cistercian

    $_
  } @{$_[0]};
}

#*** psalm($chapter, $lang, $antline)  or
# psalm($chapter, $fromverse, $toverse, $lang, $antline)
# if second arg is 1 omit gloria
# selects the text, attaches the head,
# sets red color for the introductory comments
# returns the visible form
sub psalm : ScriptFunc {
  my $psnum = shift;
  my ($lang, $antline, $nogloria);

  #  limits of the division of the psalm.
  my $v1 = 0;       # first line
  my $v2 = 1000;    # last line
  my $c1;           # subverse in first line if any
  my $c2;           # subverse in last line if any

  if (@_ < 3) {
    $nogloria = shift if $_[0] =~ /^1$/;
    $lang = $_[0];
    $antline = $_[1];
  } else {
    ($v1, $c1) = ($1, $2) if $_[0] =~ /^(\d+)([a-z])?/;
    ($v2, $c2) = ($1, $2) if $_[1] =~ /^(\d+)([a-z])?/;
    $lang = $_[2];
    $antline = $_[3];
  }

  # Tridentine Romanum Laudes: Pss. 62/66 & 148/149/150 under 1 gloria
  # Monastic Vespers: Pss. 115/116 & 148/149/150 under 1 gloria
  if ($psnum =~ s/^-(.*)/$1/ && $version =~ /Trident|Monastic/) {
    $nogloria =
         $psnum == 148
      || $psnum == 149
      || ($psnum == 62 && $version !~ /Monastic/)
      || ($psnum == 115 && $version =~ /Monastic/);
  }

  my @lines = do_read(checkfile($lang, "Psalterium/Psalmorum/Psalm$psnum.txt"));
  return "Psalm$psnum not found" unless @lines;

  # Prepare title and source if canticle
  my $title = translate('Psalmus', $lang) . " $psnum";
  $title .= "($v1$c1-$v2$c2)" if $v1;
  my $source;

  if ($psnum > 150 && $psnum < 300 && @lines) {
    shift(@lines) =~ /\(?(?<title>.*?) \* (?<source>.*?)\)?\s*$/;
    ($title, $source) = ($+{title}, $+{source});
    if ($v1) { $source =~ s/:\K.*/"$v1-$v2"/e; }
  } elsif ($lang eq 'Latin-Bea') {    # special handling for Bea's psalter

    # remove Title if Psalm section does not start in the beginning
    shift(@lines) if $lines[0] =~ /^\(.*\)\s*$/ && $lines[1] =~ /^\d+\:(\d+)[a-z]?\s/ && $v1 > $1;

    if ($psnum == 9) {
      splice(@lines, 20, 20) if $v2 < 22;    # remove Hebr. Ps 10
      splice(@lines, 0, 20) if $v1 > 21;     # remove Hebr. Ps 9
      shift(@lines) if $v1 > 22;             # remove Title B
    }

    if ($lines[0] =~ /^\(.*\)$/) {
      shift(@lines) =~ /\((?<title>.*?)\)\s*$/;
      $title .= " — $1";
    }
  }

  @lines = grep {    # take only needed lines if boundary given
    (
      /^(?:\d+:)?(?<v>\d+)(?<c>[a-z])?/                # line has numbering
        && ($+{v} == $v1 && (!$c1 || $+{c} ge $c1))    # first line
        || ($+{v} == $v2 && (!$c2 || $+{c} le $c2))    # last line
        || ($+{v} > $v1 && $+{v} < $v2)                # betwean
    )
  } @lines if $v1;

  if ($antline && $psnum != 232) {                     # put dagger if needed
    $lines[0] =~ s/^\d+:\d+[a-z]? \K(.*)/ getantcross($1, $antline) /e;
    if ($lines[0] =~ s{/:\x{2021}:/$}{}) { $lines[1] =~ s{^\d+:\d+[a-z]? \K}{/:\x{2021}:/ }; }
  }

  handleverses(\@lines);

  # put initial at begin
  $lines[0] =~ s/^(?=\p{Letter})/v. / if ($nonumbers || $psnum == 234);    # 234 - quiqumque has no numbers

  my $output = "!$title";
  $output .= " [" . ($column == 1 ? ++$psalmnum1 : ++$psalmnum2) . "]"
    unless 230 < $psnum && $psnum < 234;                                   # add psalm counter
  $output .= "\n!$source" if $source;                                      # add source
  $output .= "\n" . join("\n", @lines) . "\n";
  $output .= "\&Gloria\n" unless $psnum == 210 || $nogloria;
  $output =~ s/\$ant/Ant. $antline/g if $psnum == 94;
  $output =~ s/94C/94/ if $psnum == "94C";
  $output;
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

    #$r = "#$name specialis\n" . chompd($w{$name}) . "\n";
    $r = chompd($w{$name}) . "\n";
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
