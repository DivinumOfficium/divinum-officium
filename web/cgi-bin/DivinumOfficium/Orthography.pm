package DivinumOfficium::Orthography;
use utf8;
use strict;
use warnings;

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(j_orthography is_plain_latin);
}

# *** j_orthography($text)
#
# Renders text using the "j" orthography for Latin, the convention in which
# consonantal i is printed as j (e.g. "eius" -> "ejus", "cuius" -> "cujus",
# "Iesus" -> "Jesus", "iam" -> "jam"). This is the orthography used by most
# printed editions of the Roman liturgical books (the Graduale, the pre-1962
# Missale and Breviarium, etc.).
#
# Only *consonantal* i is converted. The rule of the convention is that i is
# consonantal (and therefore printed j) when it stands before another vowel:
#
#   1. word-initial i before a vowel:  Iesus -> Jesus, iam -> jam
#   2. i between two vowels:           eius -> ejus, cuius -> cujus,
#                                      huius -> hujus, Maius -> Majus
#
# Safeguards baked into the rules:
#   * "i" before a following "i" is vocalic, never converted: the dative
#     "iis" and the numeral "ii" stay untouched.
#   * "i" in the "qu" cluster is never converted: "quia", "quies", "quis"
#     keep their spelling.
#   * HTML tags are left alone (the text is split on tags, like spell_var()
#     does, so <FONT COLOR="red"> markup is never damaged).
#   * Conversion is idempotent: text already spelled with j ("ejus") passes
#     through unchanged, and case is preserved (Eius -> Ejus, IESU -> JESU).
#
# It is deliberately a whole-phrase pass over already-rendered cells: it
# knows nothing about word meaning and relies on the orthographic rule above,
# which is exact for classical/ecclesiastical Latin spelling.

# Vowels that a consonantal i may stand next to. Deliberately excludes the
# i family (i, í, ì, ï ...): i before i is vocalic ("iis", the numeral "ii").
# Covers plain, acute, grave, diaeresis and ligature spellings in both cases,
# which the liturgical data uses freely ("Eius", "Eú", "eú", "exǽrdia"...).
my $VOWEL = '['
  . 'aeouyAEOUY'
  . chr(0x00E6) . chr(0x01FD) . chr(0x0153)    # æ ǽ œ
  . chr(0x00C6) . chr(0x01FC) . chr(0x0152)    # Æ Ǽ Œ
  . join('', map { chr($_) }
    (0x00E1, 0x00E9, 0x00F3, 0x00FA, 0x00FD),    # á é ó ú ý
  (0x00E0, 0x00E8, 0x00F2, 0x00F9),                # à è ò ù
  (0x00E4, 0x00EB, 0x00F6, 0x00FC),                # ä ë ö ü
  (0x00C1, 0x00C9, 0x00D3, 0x00DA),                # Á É Ó Ú
  (0x00C0, 0x00C8, 0x00D2, 0x00D9),                # À È Ò Ù
  (0x00C4, 0x00CB, 0x00D6, 0x00DC))                # Ä Ë Ö Ü
  . ']';

# *** is_plain_latin($lang)
# True for the Latin columns the toggle applies to: plain Latin and the
# accented Latin-Bea psalter. Not for 'Cantilenæ/Latin-gabc' - chant code
# must never be rewritten (same exclusion spell_var() applies).
sub is_plain_latin {
  my ($lang) = @_;
  return defined($lang) && $lang =~ /^Latin(?:-Bea)?$/i;
}

sub j_orthography {
  my ($text) = @_;
  return $text unless defined $text && length $text;

  # Reunite words split by the initiale styling: a word-initial letter
  # wrapped in markup (<FONT..><B><I>I</I></B></FONT>esus) lets the lone
  # letter see the following vowel that decides whether it is consonantal.
  # Same shape as the reunification in DivinumOfficium::Lexicon.
  $text =~ s{
    ((?:<[a-zA-Z][^<>]*>)*)    # 1: opening markup (may be empty)
    (?<![\p{L}])               # the letter must start a word
    ([iI])                     # 2: the lone leading letter
    ((?:</[^<>]*>)*)           # 3: closing markup (may be empty)
    ($VOWEL)                 # 4: a following vowel makes it consonantal
  }{$1 . ($2 eq 'I' ? 'J' : 'j') . $3 . $4}gex;

  my @parts = split(/(<[^<>]*>)/, $text);

  for my $part (@parts) {
    next if !defined $part or $part eq '';
    next if $part =~ /^</;    # skip HTML markup

    # 1. word-initial consonantal i before a vowel (Iesus -> Jesus)
    $part =~ s{(?<![\p{L}])[iI](?=$VOWEL)}
      {substr($&, 0, 1) eq 'I' ? 'J' : 'j'}ge;

    # 2. intervocalic consonantal i (eius -> ejus, cuius -> cujus)
    #    "i" directly behind the "qu" cluster is part of "qu" and stays.
    $part =~ s{(?<=$VOWEL)(?<![qQ][uU])[iI](?=$VOWEL)}
      {substr($&, 0, 1) eq 'I' ? 'J' : 'j'}ge;
  }

  return join('', @parts);
}

1;
