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

#*** Deus_in_adjutorium($lang)
# Called from Ordinarium of the Major Hours
# returns Ferial, Festal, or Solemn chant for Incipit
# and stores is for usage by &Alleluja
sub Deus_in_adjutorium : ScriptFunc {

  my $lang = shift;

  our ($winner, @dayname);
  my %latwinner = %{setupstring('Latin', $winner)};
  my @latrank = split(';;', $latwinner{Rank});
  my $latname = $latrank[0];
  my $latrank = $latrank[2];

  # Ferial chant for all Little hours and Ferials and Simples
  if ( $lang !~ /gabc/
    || $hora !~ /matutinum|laudes|vespera/i
    || $rank < 2
    || $latname =~ /Feria|Sabbato|Vigilia(?! Epi)/i
    || $latrank < 2)
  {
    our $incipitTone = 'ferial';
    return prayer('Deus in adjutorium', $lang);
  }

  our $chantTone;    # has been filled by setChantTone() @horascommon.pl

  if ($hora !~ /vespera/i || $chantTone !~ /solemnis|resurrectionis/i) {
    our $incipitTone = 'festal';
    return prayer('Deus in adjutorium festivus', $lang);    # Festal tone
  } else {    # Solemn Vespers only
    our $incipitTone = 'solemn';
    return prayer('Deus in adjutorium solemnis', $lang);    # Solemn tone
  }
}

#*** Alleluia($lang)
# return the text Alleluia or Laus tibi
sub Alleluia : ScriptFunc {
  my $lang = shift;
  our (%prayers, $incipitTone);
  my $text = prayer('Alleluia', $lang);

  if ($lang =~ /gabc/i && $incipitTone) {
    $text =
        ($incipitTone =~ /festal/i) ? prayer('Alleluia festivus', $lang)
      : ($incipitTone =~ /solemn/i) ? prayer('Alleluia solemnis', $lang)
      : $text;
  }
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
  if ($lang eq 'Latin-gabc' && $hora =~ /Prima/) { return prayer('Gloria in directum', $lang); }
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
  return $lang !~ /gabc/i ? "\$Kyrie\n\$pater secreto" : "\$mLitany2";
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
  our (@dayname, $hora, $vespera);
  our $chantTone;    # filled by setChantTone() @horascommon.pl

  my $text = prayer('Benedicamus Domino', $lang);

  if (
    $hora =~ /(Laudes|Vespera)/i
    && ( ($dayname[0] =~ /Pasc0/i && ($lang !~ /gabc/i || $chantTone !~ /resurrectionis/i))
      || ($dayname[0] =~ /Pasc/ && $version =~ /Praedicatorum/ && ($rank > 3 || $winner eq 'C10'))
      || Septuagesima_vesp())
  ) {

    if ($lang !~ /gabc/i) {

      # Standard: Paschal octave and ante Septuagesima
      return $text =~ s/\.\s*\n/", " . lc(prayer('Alleluia Duplex', $lang)) . "\n"/egr;
    } else {

      # GABC: Paschal octave (Feria IV - Sabbato only) and ante Septuagesima
      return prayer('Benedicamus Domino1', $lang);
    }

    return $text;
  } elsif ($lang !~ /gabc/i || $hora !~ /(Matutinum|Laudes|Vespera)/i) {
    return $text;    # Standard or GABC ad minores
  }

  # GABC: Benedicamus depending on the solemnity of the day (ChantTone)
  my %benedicamus = %{setupstring($lang, 'Psalterium/Benedicamus.txt')};
  return ($benedicamus{"$chantTone$vespera"}) || ($benedicamus{"$chantTone"}) || prayer('Benedicamus Domino', 'Latin');
}

#*** handleverses($ref)
# remove or colorize verse numbers
# parentheses text as rubrics
sub handleverses {
  my $gabc = 0;

  map {
    if ($_[1] && !$gabc && /^(name:|\([cf][1-4]\))/) {

      # GABC: Chant has to start with '{' s.t. gabc is recognized by webdia.pl
      $gabc = 1;    # prevent further opening braces
      s/^/{/;       # append brace once
    }

    if ($_[1]) {

      # ensure red digits for chant
      s/(\s)_([\^\s*]+)_(\(\))?(\s)/$1\^_$2_\^$3$4/g;
      s/(\([cf][1-4]\)|\s?)(\d+\.)(\s\S)/$1\^$2\^$3/g;
    }

    # GABC: Change PsalmTones as requested
    if ($_[2] =~ /^[s56]/) {
      if ($_[3] =~ /^5g/) {

        # 5:    hr 'i gr 'h fr f.
        # 5g:   hr 'i gr 'h fr fe..     (Ant. Monast.)
        s/\(f\.\) \(\:\:\)/(fe..) (::)/;
      } elsif ($_[3] =~ /6\-alt/) {

        # 6:      f gh hr 'ixi hr 'g hr h. *
        # 6-alt:  f gh hr       g 'h fr f. *
        s/(\>[\,\.\:\;]?)\(g(.*?)hr\)(.*?)\(h\.\)/$1(h$2fr)$3(f.)/;
        s/<b>(.*?)<\/b>([\,\.\:\;]?)\(ixi hr\)(.*?)\(h\)/$1$2(h)<i>$3<\/i>(g)/;
        s/<b>(.*?)<\/b>([\,\.\:\;]?)\(ixi\)(.*?)\(hr\)(.*?)\(h\)/$1$2(h)$3(h)<i>$4<\/i>(g)/;
      }
    } elsif ($_[2] =~ /[12]/) {
      if ($_[3] =~ /^\dD?$/) {

        # 1D:     hr g f 'gh gr gvFED.  (Ant. Monast. '1D*')
        # 2D:     hr g   'e  fr f.
      } elsif ($_[3] =~ /^2/) {

        # 2Dm:    hr g   er 'ef f.
        s/\(e fr\)/(ef)/;
        s/(<b>.*?<\/b>[\,\.\:\;]?)\(e\)(.*?)\(fr\)/$1(er[ocb:1{])<b>$2<\/b>(ef[ocb:0}])/;
      } elsif ($_[3] =~ /1D\-/) {

        # 1D-:    hr g f 'g  gr gvFED.   (Ant. Monast. '1D')
        s/(\>[\,\.\:\;]?)\(gh(.*?)gr\)/$1(g$2gr)/g;
      } elsif ($_[3] =~ /1D2/) {

        # 1D2:    hr g f gr 'gf d.
        s/\(gh gr\)(.*?)\(gvFED\.\)/(gf)$1(d.)/;
        s/(<b>.*?<\/b>[\,\.\:\;]?)\(gh\)(.*?)\(gr\)(.*?)\(gvFED\.\)/$1(gr[ocb:1{])<b>$2<\/b>(gf[ocb:0}])$3(d.)/;
      } else {

        # 1f:     hr g f 'gh gr gf..
        # 1g:     hr g f 'gh gr g.
        # 1g2:    hr g f 'g  gr ghg.
        # 1g3:    hr g f 'g  gr g.      (Ant. Monast. '1g4')
        # 1g3m:   hr g f 'h  gr g.      (Ant. Monast. '1g3')
        # 1g5:    hr   g 'h  gr g.      (Ant. Monast.)
        # 1a:     hr g f 'g  hr h.
        # 1a2:    hr g f 'g  gr gh..
        # 1a3:    hr g f 'gh gr gh..
        my $prep = $_[3] =~ /m|5/ ? 'h' : $_[3] =~ /g[23]|a$|a2/ ? 'g' : 'gh';
        my $sup = $_[3] eq '1a' ? 'hr' : 'gr';
        my $fin =
            $_[3] =~ /g(?!2)/ ? 'g.'
          : $_[3] =~ /a$/ ? 'h.'
          : $_[3] =~ /a\d/ ? 'gh..'
          : $_[3] =~ /f/ ? 'gf..'
          : 'ghg.';
        s/(\>[\,\.\:\;]?)\(gh(.*?)gr\)(.*?)\(gvFED\.\)/$1($prep$2$sup)$3($fin)/g;

        if ($_[3] =~ /5/) {
          s/<i>(.*?)<\/i>([\,\.\:\;]?)\(g\)/$1$2(h)/;
          s/(<i>.*?<\/i>[\,\.\:]?)\(f\)/$1(g)/;
        }
      }
    } elsif ($_[2] =~ /[78]/) {
      if ($_[3] =~ /7a|8G$/) {

        # 7a:   ir 'j ir 'h hr gf..
        # 8G:   jr i j 'h gr g.
        if ($_[3] =~ /transposeF3/) {
          s/\(c3\)/(f3)/;
          s/\(k/(kxk/;
        }
      } elsif ($_[3] =~ /^7(.*)/) {

        # 7b:   ir 'j ir 'h hr g.
        # 7c:   ir 'j ir 'h hr gh..
        # 7c2:  ir 'j ir 'h hr ih..
        # 7d:   ir 'j ir 'h hr gi..
        my $fin = $1;
        my %fin = (
          'b' => 'g.',
          'c' => 'gh..',
          'c2' => 'ih..',
          'd' => 'gi..',
        );
        s/\(gf\.\.\)/($fin{"$fin"})/;
      } elsif ($_[3] =~ /8c/) {

        # 8c:   jr h j 'k jr j.
        s/(<i>.*?<\/i>[\,\.\:\;]?)\(i\)(.*?)\(h([.\s]*?)gr\)(.*?)\(g\.\)/$1(h)$2(k$3jr)$4(j.)/;
      } else {

        # 8G*:  jr i j 'h gr gh..     (Ant. Monast.: '8a')
        # 8G2:  jr i j 'h gr ghg.     (Ant. Monast.)
        my $fin = $_[3] =~ /2/ ? 'ghg.' : 'gh..';
        s/\(g\.\)/($fin)/;
      }
    } elsif ($_[2] =~ /4/) {
      if ($_[3] !~ /alt/) {

        # 4E: e|h gh hr g h 'i hr h. * hr g  h ih  gr 'gf e.
        # 4E*:                       * hr g  h ih  gr 'gf ef..  (Ant. Monast.)
        # 4d:                        * hr g  h ih  gr 'gf ed..  (Ant. Monast.)
        # 4E2:                       * hr hg h hih gr 'gf e.    (Ant. Monast.)
        # 4E2*:                      * hr hg h hih gr 'gf ef..  (Ant. Monast.)
        # 4d2:                       * hr hg h hih gr 'gf ed..  (Ant. Monast.)
        # 4a:                        * hr g  h i   'g  hr h.    (Ant. Monast.)
        # 4g:                        * hr          'h  gr g.
        s/\(e\)(.*?)\(gh\)/(h)$1(gh)/ unless $_[3] =~ /antiquo/;

        if ($_[3] =~ /star|2|d/) {
          my $fin = $_[3] =~ /star/ ? 'ef..' : $_[3] =~ /d/ ? 'ed..' : 'e.';
          s/\(e\.\)/($fin)/;

          if ($_[3] =~ /2/) {
            s/(.*<i>(.*?)<\/i>[\,\.\,\:]?)\(ih/$1(hih/;
            s/(.*<i>(.*?)<\/i>[\,\.\,\:]?)\(g\)/$1(hg)/;
          }
        } elsif ($_[3] =~ /[ag]$/) {
          my ($fin, $sup, $prep) =
            $_[3] =~ /g/ ? ('g.', 'gr', 'h') : ('h.', 'hr', 'g');
          s/(<b>.*?<\/b>[\,\.\,\:]?)\(gr.*?\)<b>(.*?)<\/b>([\,\.\,\:]?)\(gf.*?\)(.*?)\(e\.\)/$1($prep)$2$3($sup)$4($fin)/;
          s/(<b>.*?<\/b>[\,\.\,\:]?)\(gf.*?\)(.*?)\(e\.\)/$1($prep $sup)$2($fin)/;
          s/(.*<i>(.*?)<\/i>[\,\.\,\:]?)\(ih.*?\)/$1(i)/;

          if ($_[3] =~ /g/) {
            while (s/(\:.*?)<i>(.*?)<\/i>([\,\.\,\:]?)\((?:[ghi])\)/$1$2$3(h)/) { }
          }
        }
      } else {

        # ivA:  f|i hi ir h i 'j ir i. * ir h i j 'h fr f.
        # ivA*: f|i hi ir h i 'j ir i. * ir h i j 'h fr fg..
        # ivd:  f|i hi ir h i 'j ir i. * ir h i j 'h ir i.
        # ivc:  f|i hi ir h i 'j ir i. * ir       'i hr h.
        s/\(f\)(.*?)\(hi\)/(i)$1(hi)/ unless $_[3] =~ /antiquo/;

        unless ($_[3] =~ /A$/) {
          my ($fin, $sup, $prep) =
              $_[3] =~ /star/ ? ('fg..', 'fr', 'h')
            : $_[3] =~ /d/ ? ('i.', 'ir', 'h')
            : ('h.', 'hr', 'i');
          s/(\(\:\).*?b\>[\,\.\:\;]?)\(h(.*?)fr\)(.*?)\(f\.\)/$1($prep$2$sup)$3($fin)/g;

          if ($_[3] =~ /c/) {
            while (s/(\:\).*?)<i>(.*?)<\/i>([\,\.\,\:]?)\((?:[hij])\)/$1$2$3(i)/) { }
          }
        }
      }
    } else {
      if ($_[3] =~ /[ab]$/) {

        # 3b:     g hj jr 'k jr jr 'ih j. * jr       h  'j jr i.
        # 3a:                             * jr       h  'j jr ih..
        # iiib:   g hi ir 'k jr jr 'ih j. * ir 'j hr hr 'j jr i.
        # iiia:                           * ir 'j hr hr 'j jr ih..
        s/\(i\.\)/(ih..)/ if $_[3] =~ /a$/;
      } else {

        my $fin = $_[3] =~ /a/ ? 'gh..' : 'g.';
        s/(.*)\(j(.*?)jr\)(.*?)\(i\.\)/$1(h$2gr)$3($fin)/;

        if ($_[3] =~ /antiquo/) {

          # iiia2:    * ir 'j  hr hi 'h gr gh..
          # iiia3:    * ir 'ji hr hi 'h gr gh..
          # iiig:     * ir 'j  hr hi 'h gr g.
          # iiig2:    * ir 'ji hr hi 'h gr g.
          s/hr\)(.*?)\(h\)/hr)$1(hi)/;
          s/(.*)\(j(.*?)hr\)/$1(ji$2hr)/g if $_[3] =~ /a3|g2/;
        } elsif ($_[3] !~ /g2/) {

          # 3a2:    * jr   ji hi 'h gr gh..
          # 3g:     * jr   ji hi 'h gr g.
          s/(<\/i>[\,\.\:\;]?)\(h\)/$1(hi)/;
          s/(.*\))(.*?)\(j\)(\s*<i>)/$1<i>$2<\/i>(ji)$3/;
        } else {

          # 3g2:    * jr h j  i  'h gr g.
          s/(<\/i>[\,\.\:\;]?)\(h\)/$1(i)/;
          s/(.*\))(.*?)\(j\)(.*?)\(j\)(\s*<i>)/$1<i>$2<\/i>(h)<i>$3<\/i>(j)$4/;
        }
      }
    }

    if ($nonumbers) {    # remove numbering
      s/^(?:\d+:)?\d+[a-z]?\s*//;
      s/\s*\(\d+[a-z]?\)//;
    } elsif ($noinnumbers) {    # remove subverse letter & inline numbering
      s/\d\K[a-z]//;
      s/\(\d+[a-z]?\)//;
    }

    unless ($nonumbers || $gabc) {    # put numbers as rubrics
      s{^(?:\d+:)?\d+[a-z]?}{/:$&:/};
      s{\(\d+[a-z]?\)}{/:$&:/};
    }

    s/\(fit reverentia\)// if $version =~ /cist/i;    # no (fit reverentia) in Cistercian

    s{(\(.*?\))}{/:$&:/} unless $gabc;                # text in () as rubrics

    # Discussion #4504: For Breviarum Romanum style
    # ‡ marks mediant for Breviarum Romanum but flexa for Antiphonale
    # Following space to safeguard against /:‡:/ which needs to remain unchanged
    # flexa removed for Breviarum Romanum display
    s/‡\s+(.*?)\*\s*/* $1/g if $noflexa;
    s/†\s*//g if $noflexa;

    # Discussion #4504: For Antiphonale style
    # Surrounding space to safeguard against /:‡:/ which needs to remain unchanged
    s/\s‡\s/ † /g unless $noflexa;

    s/\s(\+|\^✠\^\(\))\s/ / if $version =~ /cist/i;    # no sign-of the cross in Cistercian

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
      || ($psnum == 62 && $version !~ /Monastic/ || ($votive =~ /C9/ && $version =~ /Trident/))
      || ($psnum == 115 && $version =~ /Monastic/);
  }

  my $bea = $lang eq 'Latin' && $psalmvar || $lang eq 'Latin-Bea';

  # select right Psalm file
  my $fname = "Psalm$psnum.txt";
  my ($ftone, $ffolder);

  if ($lang =~ /gabc/i) {

    # Redirect certain tones for Monastic and Tridentine
    $psnum =~ s/(,|solemn)(1g3|2|in,dir)$/$1$2-monasticus/ if $version =~ /monastic/i;
    $psnum =~ s/(,|solemn)([34])\,?(?!antiquo)/$1$2,antiquo,$3/ if $version =~ /monastic|1570/i;

    # Distingiush between chant and text
    if ($psnum !~ /,/) {
      $fname = "Psalm$psnum.txt";
    } else {

      # Deal with formatting specifics necessary for perl scripting
      $fname = ($psnum =~ /,/) ? "$psnum.gabc" : "Psalm$psnum.txt";

      $fname =~ s/\,/-/g;          # file name with dash not comma
      $psnum =~ s/,/; Tonus: /;    # name Tone in Psalm headline

      # Extract Tone and folder (also to be used for Doxology)
      $ftone = ($psnum =~ /Tonus: (.*)/) ? $1 : '';
      $ftone =~ s/\,/-/g;          # Tone name with en-dash not comma
      $ffolder = ($ftone =~ /^(solemn|\d)/) ? $1 : 'specialis';
      $ffolder .= '-alt' if $ftone =~ /4.alt/;
      $ffolder .= '-antiquo' if $ftone =~ /3\-antiquo/;
      $ffolder = 'solemn' if $ftone =~ /solemn/;

      if ($ffolder =~ /([18]|solemn)/ && $version =~ /monastic/i) {

        # redirect Monastic tones to the correct files acc. to Roman
        map {
          s/8a/8Gstar/;
          s/1D$/1D-/;
          s/1Dstar/1D/;
          s/1g4/1g3/;
          s/1g3\-monasticus/1g3m/;
        } ($ftone, $fname);
      }

      if ($ffolder =~ /^\d/) {
        my %standardtone = (
          '1' => '1D',
          '2' => '2',
          '3' => '3b',
          '3-antiquo' => '3-antiquo-b',
          '4' => '4-antiquo-E',
          '4-alt' => '4-antiquo-alt-A',
          '5' => '5',
          '6' => '6',
          '7' => '7a',
          '8' => '8G',
        );
        $fname =~ s/^(\d+\-).*/$1$standardtone{$ffolder}.gabc/;
      }

      # Format and edit the Psalm headline
      $psnum =~ s/in[,-]dir[,-]monasticus|in[,-]dir/in Directum/;
      $psnum =~ s/[,-]monasticus//;
      $psnum =~ s/(irregularis).*/$1/;
      $psnum =~ s/per$/Peregrinus/;
      $psnum =~ s/,antiquo,alt,(.*)/$1 alteratus usu antiqui/;
      $psnum =~ s/,alt,(.*)/$1 alteratus/;
      $psnum =~ s/,alt$/ alteratus/;
      $psnum =~ s/3,antiquo,(.*)/3$1 in tenore antiquo/;
      $psnum =~ s/4,antiquo,(.*)/4$1 usu antiqui/;
      $psnum =~ s/solemn(.*)/$1; Mediatio solemnis/;
      $psnum =~ s/([a-gA-G1-5])star/$1*/;
      $psnum =~ s/,transposeF3/; transpositus/;
      $psnum =~ s/transpose(\d\w+)/$1; transpositus/;
      $psnum =~ s/\,/–/g;    # Tone name with en-dash not comma

      if (!(-e "$datafolder/$lang/Psalterium/Psalmorum/$ffolder/$fname")) {
        $psnum =~ s/;.*//;
        $fname = "Psalm$psnum.txt";
        $ffolder = '';
        $ftone = '';
      }
    }
  }

  my @lines = do_read(
    checkfile(
      $bea ? 'Latin-Bea' : $lang,
      $ffolder ? "Psalterium/Psalmorum/$ffolder/$fname" : "Psalterium/Psalmorum/$fname",
    )
  );
  return "Psalm$psnum not found" unless @lines;

  # Prepare title and source if canticle
  my $title = translate('Psalmus', $lang) . " $psnum";
  $title =~ s/(; Tonus:.*)?$/($v1$c1-$v2$c2)$1/ if $v1;
  my $source;

  if ($psnum > 150 && $psnum < 300 && @lines) {

    # GABC: Retrieve Headlines for Cantica from Latin folder
    if ($fname =~ /\.gabc/) {
      map { s/[\(\)]//g; } @lines[0 .. 5];
      $psnum =~ s/(;.*)//;
      my $tonus = $1;
      my $latFile = "$datafolder/Latin/Psalterium/Psalmorum/Psalm$psnum.txt";
      my (@latlines) = do_read($latFile);
      $latlines[0] =~ s/ \*/$tonus */;
      unshift(@lines, $latlines[0]);
    }

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

  # take only needed lines if boundary given
  if ($lines[6] =~ /^\(([cf][1-4]b?)\)[\s\w\,\.\:]+\((.*?)\)[\s\w\,\.\:]+\((.*?)\)/ && $v1) {
    my ($clef, $int1, $int2) = ($1, $2, $3);

    # There are 6 GABC header lines to be considered:
    splice(@lines, $v2 + 6, 1000);    # Remove rest of the psalm
    splice(@lines, 6, $v1 - 1);       # Remove inital part of the psalm
                                      # Insert intonation
    $lines[6] =~ s/^\d+\./($clef)/;
    $lines[6] =~ s/^(\([cf][1-4]b?\)[\s\w\,\.\:]+)\(.*?\)([\s\w\,\.\:]+)\(.*?\)/$1($int1)$2($int2)/;
  } elsif ($v1) {
    @lines = grep {
      (
        /^(?:\d+:)?(?<v>\d+)(?<c>[a-z])?/                # line has numbering
          && ($+{v} == $v1 && (!$c1 || $+{c} ge $c1))    # first line
          || ($+{v} == $v2 && (!$c2 || $+{c} le $c2))    # last line
          || ($+{v} > $v1 && $+{v} < $v2)                # between
      )
    } @lines;
  }

  if ($antline && $psnum != 232) {    # put dagger if needed
    $lines[0] =~ s/^\d+:\d+[a-z]? \K(.*)/ getantcross($1, $antline) /e;
    if ($lines[0] =~ s{/:\x{2021}:/$}{}) { $lines[1] =~ s{^\d+:\d+[a-z]? \K}{/:\x{2021}:/ }; }
  } elsif (!$antline && $lang =~ /gabc/i && $psnum !~ /in Directum/) {

    # GABC: Remove consecutive Intonation if two or more Psalms are sung under the same Antiphone
    $title .= ' sine intonatio';
    $lines[7] =~ /\((.*?)\)/;
    my $tenor = $1;
    $lines[6] =~ s/\)([\w\s\,\.\:]+\(.*?\)[\w\s\,\.\:]+)\(.*?\)/\)$1($tenor)/;
    $lines[6] =~ s/\)([\w\s\,\.\:]+)\(.*?\)/\)$1($tenor)/;
  }

  handleverses(\@lines, $lang =~ /gabc/i, $ffolder, $ftone);

  # put initial at begin
  $lines[0] =~ s/^(?=\p{Letter})/v. / if ($nonumbers || $psnum == 234);    # 234 - quiqumque has no numbers

  my $output = "!$title";
  $output .= " [" . ($column == 1 ? ++$psalmnum1 : ++$psalmnum2) . "]"
    unless 230 < $psnum && $psnum < 234;                                   # add psalm counter
  $output .= "\n!$source" if $source;                                            # add source
  $output .= "\n" . join("\n", @lines) . ($lines[0] =~ /^\{/ ? "}\n" : "\n");    # end chant with brace for recognition

  if ($psnum != 210 && !$nogloria) {
    if ($lines[0] =~ /^\{/ && !triduum_gloria_omitted()) {

      # GABC: Add Gloria/Requiem Chant
      my $doxology = 'gloria';
      $doxology = 'requiem' if $commune =~ /C9/ || ($version =~ /monastic/i && $psnum == 129 && $hora eq 'Prima');
      $fname = "Psalterium/Psalmorum/$ffolder/$doxology-$ftone.gabc";
      $fname =~ s/,/-/g;    # file name with dash not comma
      $fname = checkfile($lang, $fname);
      my (@lines) = do_read($fname);

      foreach my $line (@lines) {
        $output =~ s/\}\n$/ \n$line\}\n/;
      }
    } else {

      # Standard: Add Gloria/Requiem Chant
      $output .= "\&Gloria\n";
    }
  }

  $output =~ s/\$ant/Ant. $antline/g if $psnum == 94;
  $output =~ s/94C/94/ if $psnum == "94C";
  $output;
}

sub Divinum_auxilium : ScriptFunc {
  my $lang = shift;
  if ($lang =~ /gabc/i) { return prayer("Divinum auxilium", $lang); }
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
