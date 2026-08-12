package Cognates;

# Proper-noun matching between Latin elogia and their translations.
#
# Martyrology entries are saturated with the names of people and places,
# and those names survive translation recognisably - but rarely letter
# for letter.  Latin writes Æthérii where English writes Etherius,
# Philíppi where Italian writes Filippo, and Joánnis where French writes
# Jean.  So names are compared by folding the spellings that vary
# systematically (ae/e, ph/f, th/t, j/i, doubled letters, dropped h),
# stripping Latin case endings, and consulting a small table for the names
# no rule reaches (Guilielmus / William).
#
# Two entries are scored by how well their name sets agree, both ways, so
# a long notice that merely shares a city cannot outrank a short entry
# whose names match exactly.

use strict;
use warnings;
use utf8;
use Exporter 'import';
use File::Basename qw(dirname);

use MartyrLib qw(
  $TOOLS all_days do_read_lines deaccent words flat_path %TITLE_STOPWORDS
);

our @EXPORT_OK = qw(
  normalize stem proper_nouns cognate entry_score match_quality entry_ok
  set_lexicon add_case_corpus lexicon_lang shift_hint
);

# Capitalised words that are not names, across the languages we convert.
my %STOP = map { $_ => 1 } (
  qw(
    natalis item eodem ipso die apud via sanctorum
    ibidem likewise also meme dememe aussi igualmente
    commemoratio festum vigilia octava translatio inventio
    dedicatio solemnitas passio depositio conversio ordinis
    sancti sanctae beati beatae beatorum
    ),
  qw(
    the le la les en a at in upon de del
    della di da du des au aux el los las un
    une il lo w na v u z o y e et
    ),
  qw(saint sainte saints st ste san santa santo sant sw sv sw. santi),
  qw(
    apostle apostles bishop archbishop pope king queen
    virgin virgins martyr martyrs abbot abbess priest
    deacon subdeacon confessor confessors prophet widow
    emperor empress monk monks brothers company order
    blessed holy feast solemnity vigil octave
    translation finding dedication commemoration church
    lord our lady god christ jesus mother
    ),
  qw(
    apotre apotres eveque archeveque pape roi reine
    vierge vierges martyre abbe abbesse pretre diacre
    sous confesseur confesseurs prophete veuve empereur
    imperatrice moine moines freres ordre bienheureux
    bienheureuse fete solennite vigile invention dedicace
    memoire sont nes eternelle vie eglise seigneur
    notre dame dieu mere
    ),
  qw(
    apostol obispo papa rey reina virgen martir abad
    sacerdote confesor profeta viuda vescovo re regina
    vergine martire abate prete confessore iglesia chiesa
    ),
);
$STOP{$_} = 1 foreach keys %TITLE_STOPWORDS;

# Spellings that vary systematically between Latin and its vernaculars.
my @FOLD = (
  ['ae', 'e'], ['oe', 'e'],    # Æthérii -> eteri, Cælestíni -> celestini
  ['ph', 'f'], ['th', 't'], ['ch', 'c'],
  ['y', 'i'], ['j', 'i'], ['k', 'c'], ['w', 'v'], ['v', 'u'],
  ['z', 's'], ['x', 'cs'], ['qu', 'cu'], ['gu', 'g'],
);

# Latin -ti- is -ci-/-zi- in the Romance languages (Patiéntis/Paciente).
# Only used when comparing two names: in normalize() it would merge t with
# c and split the stopword stems (beáti/beáto).
my @ROMANCE = (['ti', 'si'], ['ci', 'si']);

sub _romance {
  my $s = shift;
  $s =~ s/\Q$_->[0]\E/$_->[1]/g foreach @ROMANCE;
  return $s;
}

# Latin case endings; the stem is what carries the name.
my @ENDINGS = qw(orum arum ibus ius ium iae ii is es us um ae as os em am im o a e i s);

sub normalize {
  my $s = lc deaccent(shift);
  $s =~ s/\Q$_->[0]\E/$_->[1]/g foreach @FOLD;
  $s =~ s/(.)\1+/$1/g;    # collapse doubled letters
  $s =~ s/h//g;
  return $s;
}

sub stem {
  my $s = shift;

  foreach my $e (@ENDINGS) {
    return substr($s, 0, length($s) - length($e))
      if length($s) - length($e) >= 3 && substr($s, -length($e)) eq $e;
  }
  return $s;
}

# Titles occur in every case (Epíscopi, Epíscopo, Epíscopum): one listing
# covers the declensions once they are compared by stem.
my %STOP_STEMS = map { stem(normalize($_)) => 1 } keys %STOP;

# Names whose vernacular forms no orthographic rule reaches.  Each row is
# one name; membership is what makes two spellings cognate.
my @SAME_NAME = (
  'Joannes Ioannes Johannes John Jean Juan Giovanni Jan Janos',
  'Jacobus James Jacques Giacomo Jakub Santiago Diego Jakob',
  'Guilielmus Vilhelmus William Guillaume Guglielmo Guillermo Wilhelm Vilem',
  'Ludovicus Louis Luis Luigi Ludwik Lewis Ludvik',
  'Carolus Charles Carlo Karol Carlos Karel',
  'Aegidius Giles Gilles Egidio Idzi',
  'Hieronymus Jerome Girolamo Jeronimo Hieronim',
  'Stephanus Stephen Steven Etienne Esteban Stefano Szczepan Stepan',
  'Elisabeth Elizabeth Isabel Isabella Alzbeta',
  'Ioseph Joseph Jose Giuseppe Jozef',
  'Catharina Catherine Katherine Caterina Catalina Katerina',
  'Margarita Margaret Marguerite Margherita Malgorzata',
  'Wenceslaus Wenceslas Vaclav Waclaw',
  'Adalbertus Adalbert Vojtech Wojciech',
  'Hugo Hugh Hugues Ugo',
  'Agnes Ines Agnieszka',
  'Ioanna Joan Jeanne Juana Giovanna',
  'Helena Helen Helene Elena',
  'Eduardus Edward Edouard Edoardo',
  'Ludmilla Ludmila',
);

# Indexed by stem, since the text carries declined forms (Joánnis, not
# Joannes).  A stem can belong to more than one row (Joannes and Ioanna
# both stem to 'ioan'), so a match is any overlap.
my %NAME_GROUP;
for my $i (0 .. $#SAME_NAME) {
  $NAME_GROUP{stem(normalize($_))}{$i} = 1 foreach split(' ', $SAME_NAME[$i]);
}

# learned name pairs for one language, from namelex/<Lang>.txt.  Package
# state, because the tools do one language at a time.
my %LEXICON;
my $LEXICON_LANG;

sub lexicon_lang { return $LEXICON_LANG }

#*** set_lexicon($lang)
# Loads namelex/<lang>.txt as the active learned lexicon; undef for none.
sub set_lexicon {
  my $lang = shift;
  no warnings 'uninitialized';
  return if defined $lang && defined $LEXICON_LANG && $lang eq $LEXICON_LANG;
  return if !defined $lang && !defined $LEXICON_LANG;

  my (%pairs, %veto);

  if ($lang) {
    my $root = $ENV{MARTYR_NAMELEX} || "$TOOLS/namelex";
    my $path = "$root/$lang.txt";

    if (-e $path) {
      foreach my $line (do_read_lines($path)) {
        $line =~ s/#.*//;
        $line =~ s/^\s+|\s+$//g;
        next unless $line ne '';
        my $target = \%pairs;

        if (substr($line, 0, 1) eq '-') {
          $target = \%veto;
          $line = substr($line, 1);
        }
        my @parts = split(' ', $line);

        if (@parts == 2) {
          $target->{"$parts[0]\0$parts[1]"} = 1;
          $target->{"$parts[1]\0$parts[0]"} = 1;
        }
      }
    }
  }
  delete $pairs{$_} foreach keys %veto;
  %LEXICON = %pairs;
  $LEXICON_LANG = $lang;
}

# Entries often have commentary tacked on, and every sentence in it starts
# with a capital, so words like 'Tuvo' or 'Por' would count as names.  A
# real name is basically never written lowercase, so count that instead of
# keeping a word list.
my %CASE;

# a count, not a ratio: a word like 'murió' starts enough sentences to
# look capitalised half the time, while a name is never written lowercase
my $COMMON_LOWER = 10;

#*** _case_table($lang)
# token -> [upper count, lower count] in this language's martyrology.
#
# Vernacular only.  Latin has no commentary to trip over, and plenty of
# adjectives that are also names (clarus/Clara, felix, magnus, pius), so
# measuring it would drop St Clare from her own elogium.
sub _case_table {
  my $lang = shift;

  unless (exists $CASE{$lang}) {
    my $table = {};

    foreach my $day (all_days()) {
      my $path = flat_path($lang, $day);
      next unless -e $path;
      my @lines = eval { do_read_lines($path) };
      next if $@;
      add_case_corpus($lang, \@lines, $table);
    }
    $CASE{$lang} = $table;
  }
  return $CASE{$lang};
}

#*** add_case_corpus($lang, \@lines, $table)
# Adds text to a language's case table, for files not yet installed.
sub add_case_corpus {
  my ($lang, $lines, $table) = @_;
  $table ||= ($CASE{$lang} ||= {});

  foreach my $line (@$lines) {
    foreach my $tok (words($line)) {
      next if length($tok) < 3;
      my $low = lc deaccent($tok);
      $table->{$low} ||= [0, 0];
      $table->{$low}[$tok =~ /^\p{Lu}/ ? 0 : 1]++;
    }
  }
  return $table;
}

sub _is_common {
  my ($lang, $low) = @_;
  my $e = _case_table($lang)->{$low};
  return $e && $e->[1] >= $COMMON_LOWER;
}

#*** proper_nouns($text, $lang)
# The entry's distinct proper nouns, de-duplicated by stem so a place
# repeated in a long notice cannot outweigh a short exact match.  With
# $lang, also drops words that are only capitalised because a sentence
# started there.
sub proper_nouns {
  my ($text, $lang) = @_;
  my (@names, %seen);

  foreach my $tok (words($text)) {
    next if length($tok) < 3 || $tok !~ /^\p{Lu}/;
    my $low = lc deaccent($tok);
    my $key = stem(normalize($tok));
    next if $STOP{$low} || $STOP_STEMS{$key} || $seen{$key};
    next if $lang && _is_common($lang, $low);
    $seen{$key} = 1;
    push @names, $low;
  }
  return @names;
}

#*** cognate($a, $b)
# True when two proper nouns are the same name across languages.
sub cognate {
  my ($a, $b) = @_;
  my ($na, $nb) = (normalize($a), normalize($b));
  return 1 if $na eq $nb;

  my ($ra, $rb) = (_romance($na), _romance($nb));
  return 1 if $ra eq $rb || (length(stem($ra)) >= 3 && stem($ra) eq stem($rb));

  my ($sa, $sb) = (stem($na), stem($nb));
  return 1 if %LEXICON && $LEXICON{"$sa\0$sb"};

  my ($ga, $gb) = ($NAME_GROUP{$sa}, $NAME_GROUP{$sb});

  if ($ga && $gb) {
    foreach my $i (keys %$ga) { return 1 if $gb->{$i} }
  }

  my $n = 0;
  my $min = length($na) < length($nb) ? length($na) : length($nb);
  $n++ while $n < $min && substr($na, $n, 1) eq substr($nb, $n, 1);
  return 1 if $n >= 4;
  return 1 if $n >= 3 && $min <= 5;

  return length($sa) >= 3 && $sa eq $sb;    # Aetherii / Etherius -> eteri
}

#*** entry_score($latin_text, $vern_text)
# (matched, total) over the Latin entry's proper nouns.
sub entry_score {
  my ($latin, $vern) = @_;
  my @la = proper_nouns($latin);
  my @vb = proper_nouns($vern, $LEXICON_LANG);
  my $m = 0;

  foreach my $x (@la) {
    foreach my $y (@vb) {
      if (cognate($x, $y)) { $m++; last }
    }
  }
  return ($m, scalar(@la));
}

#*** match_quality($latin_text, $vern_text)
# How well two entries name the same people and places, 0..1.  Both ways,
# so a long notice sharing only a city cannot outrank an entry whose names
# match exactly.
sub match_quality {
  my ($latin, $vern) = @_;
  my @la = proper_nouns($latin);
  my @vb = proper_nouns($vern, $LEXICON_LANG);
  return 0 unless @la && @vb;
  my ($m) = entry_score($latin, $vern);
  return 2 * $m / (scalar(@la) + scalar(@vb));
}

sub entry_ok {
  my ($matched, $total) = entry_score(@_);
  return $total == 0 || $matched >= 1;
}

#*** shift_hint(\@refs, \@body, $get_latin_text)
# For a flagged day, tests whether a constant offset k aligns the
# vernacular entries with the Latin ones (vern[i] ~ latin[i+k]).
sub shift_hint {
  my ($refs, $body, $get_latin_text) = @_;
  my $best;

  for my $k (-3 .. 3) {
    my ($matched, $total) = (0, 0);

    for my $i (0 .. $#$body) {
      my $j = $i + $k;
      next unless $j >= 0 && $j <= $#$refs;
      $total++;
      $matched++ if entry_ok($get_latin_text->($refs->[$j]), $body->[$i]);
    }
    $best = [$k, $matched, $total]
      if $total >= 3 && (!$best || $matched / $total > $best->[1] / $best->[2]);
  }

  if ($best && $best->[1] / $best->[2] >= 0.8) {
    return sprintf('aligns at shift %+d (%d/%d)', @$best);
  }
  return 'no constant-shift alignment';
}

1;
