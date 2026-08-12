package MartyrLib;

# Shared library for the martyrology tools.
#
# One file per day per language, the whole day in reading order:
#
#     web/www/horas/<Lang>/Martyrologium/MM-DD.txt
#
#     [Titulus]        the date line, may be several lines
#     [Separatio]      only when the separator is not a plain '_'
#     [Martyrologium]  the Latin's index of the day, in order
#     [<Key>]          one per elogium
#
# Key names must fit setupstring's grammar; the ones made here use only
# [A-Za-z0-9 -].

use strict;
use warnings;
use utf8;
use Exporter 'import';
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec;
use Unicode::Normalize qw(NFKD);

our @EXPORT_OK = qw(
  $HORAS $TOOLS all_days do_read_lines deaccent words make_key
  pool_new pool_set pool_get pool_render pool_write pool_read pool_read_text
  pool_entries parse_section_name elogia_path flat_path
  latin_entries reserved_keys key_name_ok %TITLE_STOPWORDS
);

my $HERE = dirname(File::Spec->rel2abs(__FILE__));
our $TOOLS = dirname($HERE);
our $REPO = dirname(dirname($TOOLS));

# DO_MARTYR_DATA points the tools at another data root, used by the tests
our $HORAS = $ENV{DO_MARTYR_DATA} || "$REPO/web/www/horas";

# the martyrology as it read before it was broken into elogia
our $LEGACY = $ENV{DO_MARTYR_LEGACY} || "$REPO/obsolete/martyrologium-source";

my @DMAX = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

sub all_days {
  my @days;

  for my $m (1 .. 12) {
    push @days, sprintf('%02d-%02d', $m, $_) for 1 .. $DMAX[$m - 1];
  }
  return @days;
}

#*** do_read_lines($path)
# Reads a data file the way DO's do_read() sees it: UTF-8, BOM stripped,
# split on \r?\n, trailing empty lines dropped.
sub do_read_lines {
  my $path = shift;
  open(my $fh, '<:raw', $path) or die "$path: $!";
  my $raw = do { local $/; <$fh> };
  close $fh;
  utf8::decode($raw);
  $raw =~ s/^\x{feff}//;
  my @lines = split(/\r?\n/, $raw, -1);
  pop @lines while @lines && $lines[-1] eq '';
  return @lines;
}

#*** deaccent($s)
# Decomposes FIRST: an accented ligature is a single codepoint (ǽ is
# U+01FD), so expanding the ligatures first would miss it and leave a bare
# æ behind.
sub deaccent {
  my $s = shift;
  return $s unless defined $s;
  $s = NFKD($s);
  $s =~ s/\p{Mn}//g;
  $s =~ s/\x{e6}/ae/g;
  $s =~ s/\x{c6}/Ae/g;
  $s =~ s/\x{153}/oe/g;
  $s =~ s/\x{152}/Oe/g;
  return $s;
}

# Letters only: no digits, no underscore, and no combining marks either.
# A few entries write the accent as a separate codepoint (Potamiœ́næ has a
# combining acute), and a word breaks there, so that Potamiœ and næ are
# folded on their own.
sub words {
  my $t = shift;
  return () unless defined $t;
  return $t =~ /([^\W\d_\p{M}]+)/g;
}

sub key_name_ok { return $_[0] =~ /^[A-Za-z0-9][A-Za-z0-9 -]*$/ }

# Common titles and descriptors that follow an honorific but are not names.
our %TITLE_STOPWORDS = map { $_ => 1 } qw(
  martyrum martyris martyrium virginis virginum viduae
  confessoris confessorum episcopi episcoporum papae
  presbyteri diaconi subdiaconi abbatis abbatissae
  monachi monachorum militis militum regis reginae
  prophetae apostoli apostolorum evangelistae sacerdotis
  sacerdotum pontificis doctoris imperatoris imperatricis
  levitae senis pueri puerorum fratrum sororis
  matris patris anachoretae eremitae sanctimonialis
  dei domini nostri jesu christi mariae
);

my %LINKWORDS = map { $_ => 1 } qw(et ac atque cum de in item);

# Words that open an entry by pointing back at the one before -- 'likewise
# at Rome', 'in the same place' and are capitalised for that reason
# alone.  They are never anybody's name, so an entry that falls back to
# naming itself after its opening words must not settle on one.
my %NOT_A_NAME = map { $_ => 1 } qw(item ibidem eodem idem alibi);

# Plenty of elogia name nobody: they are a number of martyrs, or soldiers,
# or monks, put to death together.  What such an entry IS, is that group
# and how many of them there were, so that is what its key says.
my $GROUP = qr/^(?:martyr|milit|monach|virgin|fratr|soci|puer|cleric|
                   presbyter|episcop|ancill|eremit|confessor|apostol|
                   discipul|matron|vidu|senator|infant)/x;

# Latin counts them in words, and compounds them: 'quadraginta duorum' is
# forty-two, 'centum viginti' is a hundred and twenty.  Every numeral word
# in the run is kept, or forty-two and forty-seven come out alike.
my $NUMERAL = qr/^(?:un|duo|du[ao]rum|tr[ei]|tri[ubm]|quattuor|quinque|sex|septem|octo|
                     novem|decem|undecim|duodecim|tredecim|quindecim|sedecim|
                     vigint|trigint|quadragint|quinquagint|sexagint|septuagint|
                     octogint|nonagint|cent|ducent|trecent|quadringent|quingent|
                     sescent|septingent|octingent|nongent|mill)/x;

my $MANY = qr/^(?:plurim|multor|complur|innumerabil)/;

# The word before the name: sancti, sanctæ, sanctórum, beáti, beatíssimæ.
# Tested against the deaccented token, because the martyrology is accented
# throughout and matching the written form misses every beáti in it.
my $HONORIFIC = qr/^(?:san?ct[ioae]|beat[ioae])/;

sub _cap_names_after {
  my ($tokens, $start, $limit, $window) = @_;
  $limit ||= 2;
  $window ||= 8;
  my @names;

  for my $tok (@$tokens[$start .. ($start + $window - 1 > $#$tokens ? $#$tokens : $start + $window - 1)]) {
    next unless defined $tok;
    my $low = lc deaccent($tok);

    if ($tok =~ /^\p{Lu}/) {
      next if $TITLE_STOPWORDS{$low};
      push @names, $tok;
      last if @names >= $limit;
    } elsif ($LINKWORDS{$low}) {
      next;
    } else {
      last;
    }
  }
  return @names;
}

#*** _group_and_count(\@tokens, $hon)
# What an elogium that names nobody is about: how many, and of whom.
#
# The count runs either side of the noun - 'Mártyrum ducentórum
# sexagínta', 'quadragínta trium Monachórum' - so both are looked for
# across the whole clause and put back in the order they read.
sub _group_and_count {
  my ($tokens, $hon) = @_;
  my $to = $hon + 8 > $#$tokens ? $#$tokens : $hon + 8;
  my (@run, $group);

  for my $i ($hon + 1 .. $to) {
    my $w = lc deaccent($tokens->[$i]);

    if ($w =~ /$NUMERAL/ || $w =~ /$MANY/) { push @run, [$i, $tokens->[$i]] }
    elsif (!$group && $w =~ /$GROUP/) { $group = 1; push @run, [$i, $tokens->[$i]] }

    # the run has ended: 'Mártyrum, urbis uníus cívium' counts no martyrs
    elsif (@run) { last }
  }

  # 'plurimórum sanctórum Mártyrum' puts the quantity before the honorific
  unless (grep { lc(deaccent($_->[1])) =~ /$NUMERAL|$MANY/ } @run) {
    for my $i (($hon - 2 < 0 ? 0 : $hon - 2) .. $hon - 1) {
      unshift @run, [$i, $tokens->[$i]] if lc(deaccent($tokens->[$i])) =~ /$MANY/;
    }
  }
  # Only a group AND a count says anything: 'forty-three monks' is what
  # the entry is, where a bare 'Martyrum' is what half the book is, and a
  # bare numeral is as likely to be the nine months of the Nativity as a
  # tally of anybody.  Without both, the place remains the better name.
  my $group_seen = grep { lc(deaccent($_->[1])) =~ /$GROUP/ } @run;
  my $count_seen = grep { lc(deaccent($_->[1])) =~ /$NUMERAL|$MANY/ } @run;
  return () unless $group_seen && $count_seen;
  return map { ucfirst lc $_->[1] } sort { $a->[0] <=> $b->[0] } @run;
}

#*** make_key($text)
# A human-recognisable ASCII key for a Latin elogium.
sub make_key {
  my $text = shift;
  my @tokens = words($text);
  my @names;

  my $hon;

  for my $i (0 .. $#tokens) {
    next unless lc(deaccent($tokens[$i])) =~ /$HONORIFIC/;
    $hon = $i;
    # A handful of saints are named for what is also a title -- Papas of
    # Lycaonia, Regina of Alise -- and are filtered out with the titles.
    # Nothing tells them apart from 'beátæ Maríæ Vírginis' by shape, so
    # they keep a key named for the place instead.
    @names = _cap_names_after(\@tokens, $i + 1);
    last;
  }
  @names = _group_and_count(\@tokens, $hon) if !@names && defined $hon;

  unless (@names) {

    # fall back to the first capitalised tokens, usually the place name
    my @caps =
      grep { /^\p{Lu}/ && !$TITLE_STOPWORDS{lc deaccent($_)} && !$NOT_A_NAME{lc deaccent($_)} }
      @tokens[0 .. ($#tokens > 9 ? 9 : $#tokens)];
    @names = @caps[0 .. ($#caps > 1 ? 1 : $#caps)] if @caps;
  }
  return 'Elogium' unless @names;

  my $slug = join('-', map { my $n = deaccent($_); $n =~ s/[^A-Za-z0-9]//g; $n } @names);
  $slug =~ s/-+/-/g;
  $slug =~ s/^-|-$//g;
  return $slug eq '' ? 'Elogium' : $slug;
}

# ---------------------------------------------------------------- pool files

sub pool_new {
  my $day = shift;
  return {day => $day, sections => {}, order => []};
}

sub pool_set {
  my ($pool, $name, $text) = @_;
  push @{$pool->{order}}, $name unless exists $pool->{sections}{$name};
  $pool->{sections}{$name} = $text;
}

sub pool_get {
  my ($pool, $name, $default) = @_;
  return exists $pool->{sections}{$name} ? $pool->{sections}{$name} : $default;
}

sub pool_render {
  my $pool = shift;
  my @out;

  foreach my $name (@{$pool->{order}}) {

    # a conditional belongs outside the brackets: '[Key] (rubrica X)'
    push @out, ($name =~ /\] / ? "[$name" : "[$name]");
    push @out, $pool->{sections}{$name};
    push @out, '';
  }
  my $text = join("\n", @out);
  $text =~ s/\n+$//;
  return "$text\n";
}

sub pool_write {
  my ($pool, $path) = @_;
  make_path(dirname($path));
  open(my $fh, '>:raw', $path) or die "$path: $!";
  my $text = pool_render($pool);
  utf8::encode($text);
  print $fh $text;
  close $fh;
}

sub pool_read_text {
  my ($text, $day) = @_;
  my @lines = split(/\r?\n/, $text, -1);
  pop @lines while @lines && $lines[-1] eq '';
  return _from_lines(\@lines, $day);
}

sub pool_read {
  my ($path, $day) = @_;

  unless (defined $day) {
    ($day = $path) =~ s{.*/}{};
    $day =~ s/\.txt$//;
  }
  my @lines = do_read_lines($path);
  return _from_lines(\@lines, $day);
}

sub _from_lines {
  my ($lines, $day) = @_;
  my $pool = pool_new($day);
  my ($name, @buf);

  my $flush = sub {
    return unless defined $name;
    my @b = @buf;
    pop @b while @b && $b[-1] !~ /\S/;
    pool_set($pool, $name, join("\n", @b));
  };

  foreach my $line (@$lines) {
    if (substr($line, 0, 1) eq '[' && $line =~ /^\s*\[([^\]]+)\]\s*(\(.*\))?\s*$/) {
      $flush->();

      # a version's wording is its own section, '[Key] (rubrica X)'.  It
      # has to keep the qualifier here, or it would land under the same
      # name as the base and overwrite the text it is a variant of.
      $name = defined $2 ? "$1] $2" : $1;
      @buf = ();
    } elsif (defined $name) {
      push @buf, $line;
    }
  }
  $flush->();
  return $pool;
}

my @STRUCTURAL = qw(Titulus Separatio Martyrologium);

#*** parse_section_name($raw)
# 'Key' -> 'Key'; the version qualifier of '[Key] (rubrica X)' is parsed
# off, since the tools work on the entry, not on one version of it.
sub parse_section_name {
  my $raw = shift;
  $raw =~ s/^\s+|\s+$//g;
  $raw =~ s/\]\s*\(.*\)$//;
  return $raw;
}

#*** pool_entries($pool)
# Ordered ([key, value]) for a day, structural sections left out.  A key
# reworded by a version appears once, under its base text.
sub pool_entries {
  my $pool = shift;
  my (@out, %seen);

  foreach my $raw (@{$pool->{order}}) {
    my $key = parse_section_name($raw);
    next if grep { $_ eq $key } @STRUCTURAL;
    next if $seen{$key}++;
    push @out, [$key, $pool->{sections}{$raw}];
  }
  return @out;
}

sub elogia_path {
  my ($lang, $day) = @_;
  return "$HORAS/$lang/Martyrologium/$day.txt";
}

#*** flat_path($lang, $day)
# The original flat day file, kept out of the way under obsolete/.
sub flat_path {
  my ($lang, $day) = @_;
  return "$LEGACY/$lang/Martyrologium/$day.txt";
}

#*** latin_entries($day)
# ([key, text]) for every elogium the Latin day can have, in the order the
# [Martyrologium] index gives.  The version conditionals are ignored on
# purpose: a translation is aligned against the day's elogia whichever
# version happens to carry them.
#
# An entry a version moved is listed twice in the index, once in each
# place; it is one elogium, so only the first listing is kept.
sub latin_entries {
  my $day = shift;
  my $path = elogia_path('Latin', $day);
  return () unless -e $path;
  my $pool = pool_read($path, $day);
  my $index = pool_get($pool, 'Martyrologium');
  my %text = map { $_->[0] => $_->[1] } pool_entries($pool);

  # no index yet (a day still in the old shape): fall back to file order
  return grep { defined $_->[1] && $_->[1] ne '' } pool_entries($pool)
    unless defined $index;

  my (@out, %seen);

  foreach my $line (split(/\n/, $index)) {
    next unless substr($line, 0, 1) eq '@';

    if ($line =~ m{^\@(?:Martyrologium/)?(\d\d-\d\d):(.+)$}) {
      my ($d2, $k2) = ($1, $2);
      next if $d2 eq $day || $seen{"$d2:$k2"}++;
      my $other = elogia_path('Latin', $d2);
      next unless -e $other;
      my %o = map { $_->[0] => $_->[1] } pool_entries(pool_read($other, $d2));
      push @out, ["$d2:$k2", $o{$k2}] if defined $o{$k2} && $o{$k2} ne '';
    } elsif ($line =~ /^\@:(.+)$/) {
      my $key = $1;
      next if $seen{$key}++;
      push @out, [$key, $text{$key}] if defined $text{$key} && $text{$key} ne '';
    }
  }
  return @out;
}

#*** reserved_keys($day)
# Every name the Latin day already uses; a translation's own keys must not
# collide with these.
sub reserved_keys {
  my $day = shift;
  my %names = map { $_ => 1 } @STRUCTURAL;
  my $path = elogia_path('Latin', $day);
  return %names unless -e $path;
  my $pool = pool_read($path, $day);
  $names{parse_section_name($_)} = 1 foreach @{$pool->{order}};
  return %names;
}

1;
