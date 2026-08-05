# use warnings;
# use strict;
use utf8;

sub lectio_brevis_prima {

  my $lang = shift;

  our ($version, %winner, %winner2, %commune, %commune2, $winner, $commune);

  my %brevis = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};
  my $name = gettempora("Lectio brevis Prima");
  my $brevis = $brevis{$name};
  my $comment = $name =~ /per annum/i ? 5 : 1;

  setbuild('Psalterium/Special/Prima Special', $name, 'Lectio brevis ord');

  #look for [Lectio Prima]
  if ($version !~ /1955|196|cist/i) {
    my $b;

    if (exists($winner{'Lectio Prima'})) {
      $b = columnsel($lang) ? $winner{'Lectio Prima'} : $winner2{'Lectio Prima'};
      setbuild2("Subst Lectio Prima $winner");
      $comment = 3;
    } elsif (exists($commune{'Lectio Prima'})) {
      $b = columnsel($lang) ? $commune{'Lectio Prima'} : $commune2{'Lectio Prima'};
      setbuild2("Subst Lectio Prima $commune");
      $comment = 4;
    }

    $brevis = $b || $brevis;
  }

  if ($brevis =~ /\(ef\.\.\)/) {

    # GABC: All Lectio Prima are either input in Tonus Capitulum or links to Capitulum Nona
    # Therefore: Transform Tonus Capitulum (Nona) into Tonus Lectio brevis here
    map {
      s/(.*)\(f/$1(h./g;
      s/er\)/dr\)/g;
      s/\(ef\.\.\)/(d.)/g;
    } $brevis;

    # Shorter pause at Flexa in Ant. Monasticum compared to Ant. Romanum
    $brevis =~ s/†\(\;\)/†(,)/g if $version =~ /monastic/i;
  }

  $brevis = "\$benedictio Prima\n$brevis" unless $version =~ /^Monastic/;
  $brevis .= "\n\$Tu autem";

  ($brevis, $comment);
}

sub capitulum_prima {

  my $lang = shift;
  my $withresponsory = shift;

  our ($dayofweek, $version, %winner, $commune, $rank, @dayname, $label, %winner2);

  my %brevis = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};

  my $key =
    (    $dayofweek > 0
      && $version !~ /196[03]/
      && $winner{Rank} =~ /Feria|Vigilia/i
      && $winner{Rank} !~ /Vigilia Epi/i
      && !($winner{Rank} =~ /in.*Oct/i && $version =~ /Cist/i)
      && (!$commune || $commune !~ /C10/)
      && ($rank < 3 || $dayname[0] =~ /Quad6/ || $winner =~ /Quadp3-3/)
      && $dayname[0] !~ /Pasc/i) ? 'Feria' : 'Dominica';

  my $capit = $brevis{$key} . "\n\$Deo gratias\n_\n";
  setbuild1('Capitulum', "Psalterium $key");

  # Shorter pause at Flexa in Ant. Monasticum compared to Ant. Romanum
  $capit =~ s/†\(\;\)/†(,)/g if $lang eq 'Latin-gabc' && $version =~ /monastic/i;

  if ($version =~ /1963/) {
    $capit = "$label\n" . $capit;
  } else {
    setcomment($label, 'Source', $key eq 'Feria', $lang);
  }

  my @resp;

  if ($withresponsory) {
    @resp = split("\n", $brevis{'Responsory'});
    my $primaresponsory = get_prima_responsory($lang);
    my %wpr = columnsel($lang) ? %winner : %winner2;
    if (exists($wpr{'Versum Prima'})) { $primaresponsory = $wpr{'Versum Prima'}; }

    if ($primaresponsory) {
      if ($lang =~ /gabc/i) {
        $resp[0] = $primaresponsory;    # GABC: Take whole Responsorium from [Versum Prima]
      } else {
        $resp[2] = "V. $primaresponsory";
      }
    }
    push(@resp, "_");
  }

  push(@resp, split("\n", $brevis{Versum}));

  postprocess_short_resp(@resp, $lang);

  $capit . join("\n", @resp);
}

sub get_prima_responsory {
  my $lang = shift;

  our ($version, $month, $day, %commemoratio, $rule);

  my $key = gettempora('Prima responsory');

  if ( $rule =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i
    || $commemoratio{Rule} =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i)
  {
    $key = $1;
  } elsif ($version !~ /196/ && $month == 8 && $day > 15 && $day < 23) {
    $key = 'Nat';
  }

  if ($version =~ /196/ && $month == 12 && $day > 8 && $day < 16 && $version !~ /Newcal/ && $day !~ 12) {
    $key = 'Adv';
  }

  if ($version =~ /196/ && $key =~ /Corp|Heart/) { $key = ''; }
  return '' unless $key;

  my %t = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};
  return $t{"Responsory $key"};
}

#*** martyrologium($lang)
#returns the text of the martyrologium for the day
sub martyrologium {

  my $lang = shift;

  our ($version, $year, $month, $day, $dayofweek);

  my $dir = 'Martyrologium';
  $dir .= '1570' if $version =~ /1570/;
  $dir .= '1960' if $version =~ /1960|Newcal/;
  $dir .= '1955R' if $version =~ /1955/;
  $dir = substr($dir, 0, 13) unless -e "$datafolder/$lang/$dir";

  my $mobile = do {
    my $a = getweek($day, $month, $year, 1) . "-" . (($dayofweek + 1) % 7);
    $a = '10-DU' if ($version !~ /1570|1617|1888|1910/ && $month == 10 && $dayofweek == 6 && $day > 23 && $day < 31);
    $a = 'Defuncti' if $winner{Rank} =~ /ex C9/i;
    $a = 'DefunctiM' if ($month == 11 && $day == 14 && $version =~ /Monastic/);
    my %a = %{setupstring($lang, "$dir/Mobile.txt")};
    $a{$a};
  };

  my ($m, $d) = split('-', nextday($month, $day, $year));

  # pool files are in the Martyrologium folders, the old flat files under
  # source/ where they still serve gabc
  my @a = martyrologium_elogia($lang, "$m-$d");

  unless (@a) {
    my $fname = "$datafolder/$lang/$dir/source/$m-$d.txt";
    $fname = checkfile($lang, "Martyrologium/source/$m-$d.txt") unless -e $fname;
    @a = do_read($fname);
  }

  my $output;

  if (@a) {
    my $luna = _luna($m, $d, $m == 1 && $d == 1 ? $year + 1 : $year, $lang);

    if ($lang =~ /Latin/i) {
      $a[0] .= " $luna";
    } else {
    FINDDATE:
      {
        foreach (@a) {
          last FINDDATE if s/^Upon the \d+ ?.. day of \S+/$luna /i;                                          # English
          last FINDDATE if s/^Dnia \d+-go \S+ (.)/${luna}r. \u$1/;                                           # Polski
          last FINDDATE if s/^\d+\. (?:\(\d+.\) )?\S+/${luna}/;                                              # Bohemice
          last FINDDATE if s/^(Le(?: même)? \d+ .*?\,)/$1 \l$luna, /i;                                       # French 1
          last FINDDATE if s/^((?:Le \d+ des|La veille des|Aux) (?:ides|calendes|nones).*)/$1, \l$luna/i;    # French 2
          last if /^\s*\_\s*/;
        }

        # Put $luna at the start if and only if we didn't find a
        # suitable substitution in the loop above.
        unshift(@a, $luna, "_\n");
      }
    }

    $output = join("\n", map { length($_) > 4 && !/^\/:/ ? "r. $_" : $_ } @a) . "\n";
    $output =~ s/^r/v/;
    $output =~ s/\_/"r. $mobile"/e if $mobile;
    $output =~ s/\_\n//g;

    $output = join("\n", @a) . "\n" if $lang eq 'Latin-gabc';
  }

  $output . prayer('Conclmart', $lang);
}

#*** martyrologium_elogia($lang, $mmdd)
# builds the day's martyrology from the elogia pool files
#
# <Lang>/Martyrologium/MM-DD.txt is the whole day in reading order:
# [Titulus], optional [Separatio], then one section per entry. A value
# starting with '=' is escaped ('=_' is a literal _, '=' alone a blank).
#
# Martyrologium{1955R,1960,1570}/MM-DD.txt holds only that version's changes:
#   [Key]              empty  entry deleted
#   [Key]              value  value overridden, stays put
#   [Key post Other]   value  placed after Other
#   [Key ante Other]   empty  moved before Other, keeps its value
# [MM-DD:Key] is a reference to that day's entry. 1570 Latin values are
# derived by deaccenting the base ones unless overridden.
#
# The vernacular always keeps its own order; the Latin only decides which
# entries the version has. With $martyrfallback set, entries the language
# never mentions are filled from the other column ($lang1).
#
# Returns () for gabc or when there is no pool file, and the caller reads
# the old flat files instead.
sub martyrologium_elogia {
  my ($lang, $mmdd) = @_;
  our ($version, $datafolder, $langfb, $lang1, $martyrfallback);

  return () if $lang =~ /gabc/i;

  my $inherits = $martyrfallback && $lang1 && lc $lang1 ne lc $lang;
  my $vdir =
      $version =~ /1960|Newcal/ ? 'Martyrologium1960'
    : $version =~ /1955/        ? 'Martyrologium1955R'
    : $version =~ /1570/        ? 'Martyrologium1570'
    :                             '';

  my $lbase = _elogia_read("$datafolder/Latin/Martyrologium/$mmdd.txt");
  return () unless $lbase;
  my $lover = $vdir ? _elogia_read("$datafolder/Latin/$vdir/$mmdd.txt") : undef;

  if ($lang =~ /^Latin$/i && !$inherits) {
    my ($keys, undef) = _elogia_merge($lbase, $lover);
    my @lines = _elogia_head($lbase, $lover, $vdir eq 'Martyrologium1570');

    foreach my $key (@$keys) {
      my $text = _elogia_value($key, $lbase, $lover, 'Latin', $vdir, $mmdd);
      return () unless defined $text;
      push @lines, _elogia_lines($text);
    }
    return @lines;
  }

  my $vbase = _elogia_read("$datafolder/$lang/Martyrologium/$mmdd.txt");

  unless ($vbase) {
    my $src = _elogia_lang($lang, $mmdd);
    return $src ? martyrologium_elogia($src, $mmdd) : ();
  }
  my $vover = $vdir ? _elogia_read("$datafolder/$lang/$vdir/$mmdd.txt") : undef;
  my $fallback;

  if ($inherits) {
    my $src = _elogia_lang($lang1, $mmdd);
    $fallback = _elogia_source($src, $vdir, $lbase, $lover, $mmdd)
      if $src && lc $src ne lc $lang;
  }

  # nothing to merge: render the day as stored
  unless ($vover || $fallback) {
    my @lines = _elogia_head($vbase, undef);
    foreach my $e (@{$vbase->{entries}}) {
      next if $e->{value} eq '';
      push @lines, _elogia_lines($e->{value});
    }
    return @lines;
  }

  # the Latin says which entries the version has, the language says where
  my ($lkeys) = _elogia_merge($lbase, $lover);
  my ($vkeys) = _elogia_merge($vbase, $vover);
  my %in_version = map { $_ => 1 } @$lkeys;
  my %latin_known = map { $_->{key} => 1 } @{$lbase->{entries}};
  $latin_known{$_} = 1 for @$lkeys;

  # a key the language mentions is never filled in: empty means deleted
  my %vmentions;
  $vmentions{$_->{key}} = 1 for @{$vbase->{entries}};

  if ($vover) {
    $vmentions{$_->{key}} = 1 for @{$vover->{entries}};
  }

  my @order = @$lkeys;

  if ($fallback) {
    my ($fkeys) = _elogia_merge($fallback->{base}, $fallback->{over});
    @order = @{_elogia_union(\@order, $fkeys)};
  }

  my (@lines, @slots, %rendered);
  push @lines, _elogia_head($vbase, $vover,
    $lang =~ /^Latin$/i && $vdir eq 'Martyrologium1570');

  foreach my $key (@$vkeys) {

    # dropped by this version (suppressed octave, feast moved to another day)
    next if $latin_known{$key} && !$in_version{$key};
    my $text = _elogia_value($key, $vbase, $vover, $lang, $vdir, $mmdd);
    next unless defined $text && $text ne '';
    push @slots, {key => $key, lines => [_elogia_lines($text)]};
    $rendered{$key} = 1;
  }

  # entries the language's day does not carry, placed after the nearest
  # preceding entry both arrangements have
  my %fills;
  my $anchor = "\0START";

  foreach my $key (@order) {
    if ($rendered{$key}) { $anchor = $key; next; }
    my $text = _elogia_value($key, $vbase, $vover, $lang, $vdir, $mmdd);

    if ($fallback && !(defined $text && $text ne '') && !$vmentions{$key}) {
      my $t = _elogia_value($key, $fallback->{base}, $fallback->{over},
        $fallback->{lang}, $vdir, $mmdd);

      if (defined $t && $t ne '') {

        # webdia.pl only spell_var's a Latin column, so Latin text put in
        # another column has to be done here
        $t = main::spell_var($t)
          if $fallback->{lang} =~ /^Latin$/i && defined &main::spell_var;
        $text = $t;
      }
    }
    next unless defined $text && $text ne '';
    push @{$fills{$anchor}}, [_elogia_lines($text)];
  }

  push @lines, map { @$_ } @{$fills{"\0START"} || []};
  foreach my $slot (@slots) {
    push @lines, @{$slot->{lines}};
    push @lines, map { @$_ } @{$fills{$slot->{key}} || []};
  }
  return @lines;
}

#*** _elogia_union($a, $b)
# both key lists, keeping the order of the first and slotting each key only
# in the second after whatever it follows there
sub _elogia_union {
  my ($a, $b) = @_;
  my %have = map { $_ => 1 } @$a;
  my @out = @$a;
  my $after;

  foreach my $key (@$b) {
    if ($have{$key}) { $after = $key; next; }
    my $at = @out;

    if (defined $after) {
      for my $i (0 .. $#out) { $at = $i + 1 if $out[$i] eq $after; }
    } else {
      $at = 0;
    }
    splice(@out, $at, 0, $key);
    $have{$key} = 1;
    $after = $key;
  }
  return \@out;
}

#*** _elogia_lang($lang, $mmdd)
# which language's pool actually answers for this one, the same order
# checkfile() uses: itself, then the parent of a hyphenated name
# (Latin-Bea -> Latin), then the fallback language.  undef if none has it.
sub _elogia_lang {
  my ($lang, $mmdd) = @_;
  our ($datafolder, $langfb);
  return undef unless $lang && $lang !~ /gabc/i;

  while (1) {
    return $lang if -e "$datafolder/$lang/Martyrologium/$mmdd.txt";
    last unless $lang =~ s/-[^-]+$//;
  }
  return $langfb
    if $langfb && -e "$datafolder/$langfb/Martyrologium/$mmdd.txt";
  return undef;
}

#*** _elogia_source($lang, $vdir, $lbase, $lover, $mmdd)
# the pool files to read a fallback value out of
sub _elogia_source {
  my ($lang, $vdir, $lbase, $lover, $mmdd) = @_;
  our $datafolder;
  return {lang => 'Latin', base => $lbase, over => $lover}
    if $lang =~ /^Latin$/i;
  my $base = _elogia_read("$datafolder/$lang/Martyrologium/$mmdd.txt")
    or return undef;
  return {
    lang => $lang,
    base => $base,
    over => $vdir ? _elogia_read("$datafolder/$lang/$vdir/$mmdd.txt") : undef,
  };
}

#*** _elogia_read($file)
# Parses a pool day file into
#   { titulus, separatio, has_sep, entries => [ {key, rel, anchor, value} ],
#     bykey => {key => value} }
# Not setupstring: file order is meaningful and these per-language files
# must not inherit another language's sections through layering.
sub _elogia_read {
  my $file = shift;
  return undef unless -e $file;

  my %d = (titulus => undef, separatio => undef, has_sep => 0, entries => [], bykey => {});
  my ($raw, @buf);

  my $flush = sub {
    return unless defined $raw;
    pop @buf while @buf && $buf[-1] !~ /\S/;
    my $value = join("\n", @buf);
    my ($key, $rel, $anchor) = ($raw, undef, undef);
    $rel = $2, $anchor = $3, $key = $1 if $raw =~ /^(\S+)\s+(ante|post)\s+(\S+)$/;

    if ($key eq 'Titulus') {
      $d{titulus} = $value;
    } elsif ($key eq 'Separatio') {
      $d{separatio} = $value;
      $d{has_sep} = 1;
    } else {
      push @{$d{entries}}, {key => $key, rel => $rel, anchor => $anchor, value => $value};
      $d{bykey}{$key} = $value unless exists $d{bykey}{$key};
    }
  };

  foreach my $line (do_read($file)) {
    if ($line =~ /^\[([^\]]+)\]\s*$/) {
      $flush->();
      $raw = $1;
      @buf = ();
    } elsif (defined $raw) {
      push @buf, $line;
    }
  }
  $flush->();
  return \%d;
}

#*** _elogia_merge($base, $overlay)
# applies a version's deltas to the base order, returns (\@keys, \%deleted)
sub _elogia_merge {
  my ($base, $over) = @_;
  my @base_keys = map { $_->{key} } @{$base->{entries}};
  return (\@base_keys, {}) unless $over;

  my (%deleted, %moved, @anchored);

  foreach my $e (@{$over->{entries}}) {
    if (defined $e->{rel}) {
      $moved{$e->{key}} = 1;
      push @anchored, $e;
    } elsif ($e->{value} eq '') {
      $deleted{$e->{key}} = 1;
    }
  }
  my @keys = grep { !$deleted{$_} && !$moved{$_} } @base_keys;

  # loop until every anchor resolves: anchors may point at each other
  my @pending = @anchored;

  while (@pending) {
    my @rest;

    foreach my $e (@pending) {
      my $i = -1;

      for my $j (0 .. $#keys) {
        if ($keys[$j] eq $e->{anchor}) { $i = $j; last; }
      }

      if ($i >= 0) {
        splice(@keys, ($e->{rel} eq 'ante' ? $i : $i + 1), 0, $e->{key});
      } else {
        push @rest, $e;
      }
    }
    last if @rest == @pending && do { push @keys, map { $_->{key} } @rest; 1 };
    @pending = @rest;
  }

  my %have = map { $_ => 1 } @keys;
  my %inbase = map { $_ => 1 } @base_keys;

  foreach my $e (@{$over->{entries}}) {
    next if defined $e->{rel} || $e->{value} eq '' || $inbase{$e->{key}} || $have{$e->{key}};
    push @keys, $e->{key};
    $have{$e->{key}} = 1;
  }
  return (\@keys, \%deleted);
}

#*** _elogia_head($base, $overlay)
# the day's title lines and separator
sub _elogia_head {
  my ($base, $over, $deaccent) = @_;
  my $titulus;

  if ($over && defined $over->{titulus}) {
    $titulus = $over->{titulus};
  } else {
    $titulus = $base->{titulus};
    $titulus = _deaccent($titulus) if $deaccent && defined $titulus;
  }
  return () unless defined $titulus;
  $titulus =~ s/[\r\n]+$//;
  my @lines = split(/\n/, $titulus);
  @lines = ($titulus) unless @lines;

  my $sep = $base->{has_sep} ? $base->{separatio} : '_';
  $sep = $over->{separatio} if $over && $over->{has_sep};
  push @lines, $sep if defined $sep && $sep ne '';
  return @lines;
}

#*** _elogia_value($key, $base, $overlay, $lang, $vdir, $mmdd)
# one key's text: version override, else base, else the referenced day.
# undef when this language has no value for it.
sub _elogia_value {
  my ($key, $base, $over, $lang, $vdir, $mmdd) = @_;
  our $datafolder;

  if ($over) {
    my $v = $over->{bykey}{$key};
    return $v if defined $v && $v ne '';
    return undef if defined $v && !_elogia_anchored($over, $key);
  }

  if ($key =~ /^(\d\d-\d\d):(.+)$/) {
    my ($d2, $k2) = ($1, $2);

    # text stored here wins; the Latin leaves these empty
    my $own = $base->{bykey}{$key};
    return $own if defined $own && $own ne '';

    return undef if $d2 eq $mmdd;
    my $ob = _elogia_read("$datafolder/$lang/Martyrologium/$d2.txt");
    return undef unless $ob;

    # that day's version file may reword it, but a deletion there
    # does not apply here
    my $oo = $vdir ? _elogia_read("$datafolder/$lang/$vdir/$d2.txt") : undef;

    if ($oo) {
      my $ov = $oo->{bykey}{$k2};
      return $ov if defined $ov && $ov ne '';
    }
    my $bv = $ob->{bykey}{$k2};
    return undef unless defined $bv && $bv ne '';
    $bv = _deaccent($bv) if $lang =~ /^Latin$/i && $vdir eq 'Martyrologium1570';
    return $bv;
  }

  my $v = $base->{bykey}{$key};
  return undef unless defined $v;
  $v = _deaccent($v) if $lang =~ /^Latin$/i && $vdir eq 'Martyrologium1570';
  return $v;
}

# true when the overlay anchors this key, so empty means keep the text
sub _elogia_anchored {
  my ($over, $key) = @_;

  foreach my $e (@{$over->{entries}}) {
    return defined $e->{rel} if $e->{key} eq $key;
  }
  return 0;
}

# a value's lines, with the '=' escape removed
sub _elogia_lines {
  my $v = shift;
  return map { my $l = $_; $l =~ s/^=//; $l } split(/\n/, $v, -1);
}

sub _deaccent {
  my $s = shift;
  require Unicode::Normalize;
  $s = Unicode::Normalize::NFKD($s);
  $s =~ s/\p{Mn}//g;
  $s =~ s/\x{e6}/ae/g;
  $s =~ s/\x{c6}/Ae/g;
  $s =~ s/\x{153}/oe/g;
  $s =~ s/\x{152}/Oe/g;
  return $s;
}

sub _luna_table {

  # return luna day for year day and letter as in tables printed in Martyrolgia
  # a  b  c  d  e  f  g  h  i  k  l  m  n  p  q  r  s  t  u   A  B  C  D  E  R  F  G  H  M  N  P # R is F black
  # 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20, 21,22,23,24,25,26,26,27,28,29,30, 1 # Die  1 ianuarii
  # 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21, 22,23,24,25,26,27,27,28,29,30, 1, 2 # Die  2 ianuarii
  # ...
  #12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,  1, 2, 3, 4, 5, 6, 6, 7, 8, 9,10,11 # Die 31 decembris

  my ($yday, $letter) = @_;

  my $all_martyrologium_letters = 'abcdefghiklmnpqrstuABCDERFGHMNP';
  my $letter_position = index($all_martyrologium_letters, $letter) + 1;
  my $m = $yday < 36 ? 30 : (($yday - 35) % 59 || 59) < 29 ? 29 : 30;
  my $i = $yday % 59 < 36 ? $letter_position : $letter_position - 1;

  if ($yday % 59 < 36) {
    $i -= 1 if $letter_position > 25;
    $i += 1 if ($letter_position == 25 && $yday % 59 == 35);
  } else {
    $i -= 2 if $letter_position > 25;
  }

  if ($yday > 58) {
    $i -= 1 if ($letter_position > 25 && $yday % 59 < 5);
    $i -= 1 if ($letter_position == 26 && $yday % 59 == 5);
  }

  ($i - 1 + ($yday % 59)) % $m + 1;
}

# finds luna day
sub _luna_day {
  my ($month, $day, $year) = @_;

  # Lit. Mart. for Aur. num.
  my $letters4aurea = '';

  if ($year < 1582) {
    main::error('Unreachable');
  } elsif ($year < 1700) {
    $letters4aurea = 'amDdqGgtNkBbnEerHhu';
  } elsif ($year < 1900) {
    $letters4aurea = 'PlCcpFfsMiAamDdqGgt';
  } elsif ($year < 2200) {
    $letters4aurea = 'NkBbnEerHhuPlCcpRfs';
  }    # R is F black
  elsif ($year < 2300) {
    $letters4aurea = 'MiAamDdqGgtNkBbnEer';
  } else {
    main::error('Unreachable');
  }

  my $aur_num = $year % 19 + 1;
  my $letter_for_aurea = substr($letters4aurea, $aur_num - 1, 1);
  my $yday = DivinumOfficium::Date::date_to_ydays($day, $month, $year);
  $yday -= 1 if (leapyear($year) && ($month > 2 || $month == 2 && $day > 23));

  my $luna = _luna_table($yday, $letter_for_aurea);
  $luna -= 1
    if ( $aur_num == 1
      && $month == 1
      && $letter_for_aurea ne 'P'
      && $day + _luna_table(1, $letter_for_aurea) < 32);

  $luna;
}

sub _number_suffix {
  my ($n) = @_;
      ($n > 3 && $n < 21) ? 'th'
    : (($n % 10) == 1) ? 'st'
    : (($n % 10) == 2) ? 'nd'
    : (($n % 10) == 3) ? 'rd'
    : 'th';
}

sub _luna {
  my ($month, $day, $year, $lang) = @_;

  my $lday = _luna_day($month, $day, $year);
  $day += 0;

  if ($lang =~ /Latin/i) {
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

    "Luna $ordinals[$lday-1]. Anno Dómini $year\n";
  } elsif ($lang =~ /Polski/) {
    my @months_pl = (
      'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca',
      'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia',
    );

    "Roku Pańskiego $year, ${day}-go $months_pl[$month - 1], ${lday}-go dnia księżyca.\n_\n";
  } elsif ($lang =~ /Francais/) {
    "Le $lday" . "e jour de la Lune, l’année du Seigneur $year";
  } elsif ($lang =~ /Italiano/) {
    my @months_it = (
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
    );

    "Anno del Signore $year, $day $months_it[$month - 1], Luna $lday";
  } elsif ($lang =~ /Bohemice/) {
    my @months_cz = (
      'ledna', 'února', 'března', 'dubna', 'května', 'června',
      'července', 'srpna', 'září', 'října', 'listopadu', 'prosince',
    );

    "Léta Páně $year, $day. $months_cz[$month - 1], $lday. dne věku měsíce.";
  } else {
    my @months = (
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    );

    sprintf("$months[$month - 1] $day%s $year, the $lday%s day of the Moon,",
      _number_suffix($day), _number_suffix($lday),);
  }
}

1;
