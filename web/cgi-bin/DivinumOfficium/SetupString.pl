#!/usr/bin/perl
use utf8;

#use strict;
#use warnings;
use Carp;
use DivinumOfficium::FileIO qw(do_read);
use DivinumOfficium::Date qw(monthday);

# Read only global variables
our $version, $datafolder;

# Global Variables to be filled here
our %setupstring_caches_by_version;

# Pseudo constants to be used in vero() sub
# Commune Summorum Pont. introduced in 1942 only (=> not for Monastic 1930)
my %subjects = (

  # Standard subjects
  rubricis => sub {$version},
  rubrica => sub {$version},
  tempore => \&get_tempus_id,
  missa => sub { our $missanumber },
  communi => sub { our $version },
  'die' => \&get_dayname_for_condition,
  feria => sub { our $dayofweek + 1 },
  commune => sub { our $commune },
  votiva => sub { our $votive },
  officio => sub { $dayname[1]; },
  ad => sub { our $missa ? 'missam' : our $hora; },
  mense => sub { our $month },    # mense is not perfect eg. 1 matches also 10 11 12
  dioecesis => sub { our $dioecesis },

  # GABC subjects
  tonus => sub {$chantTone},
  toni => sub {$chantTone},
);
my %predicates = (

  # Standard predicates
  tridentina => sub { shift =~ /Trident/ },
  monastica => sub { shift =~ /Monastic/ },
  innovata => sub { shift =~ /2020 USA|NewCal/i },
  innovatis => sub { shift =~ /2020 USA|NewCal/i },
  paschali => sub { shift =~ /Paschæ|Ascensionis|Octava Pentecostes/i },
  'post septuagesimam' => sub { shift =~ /Septua|Quadra|Passio/i },
  prima => sub { shift == 1 },
  secunda => sub { shift == 2 },
  tertia => sub { shift == 3 },
  longior => sub { shift == 1 },
  brevior => sub { shift == 2 },
  'summorum pontificum' => sub { shift =~ /194[2-9]]|195[45]|196/ },
  feriali => sub { shift =~ /feria|vigilia/i; },

  # GABC predicates (for "tonus" and "tempore", respectively
  'in solemnitatibus' => sub { shift =~ /solemnis|resurrectionis/i },
  'in hieme' => sub { shift =~ /hieme|Adventus|Nativitatis|Epiphani|gesimæ|Passionis/i },
  'in æstate' => sub { shift !~ /hieme|Adventus|Nativitatis|Epiphani|gesimæ|Passionis/i },
);

# Constants specifying which @-directives to resolve when calling &setupstring.
use constant {
  RESOLVE_NONE => 0,
  RESOLVE_WHOLEFILE => 1,
  RESOLVE_ALL => 2,
};

my %conditional_values;
my %stopword_weights;
my %backscoped_stopwords;
my $stopwords_regex;
my $scope_regex;
my $conditional_regex;

BEGIN {
  # Main stopwords. These have implicit backward scope.
  $stopword_weights{'sed'} = $stopword_weights{'vero'} = 1;
  $stopword_weights{'atque'} = 2;
  $stopword_weights{'attamen'} = 3;
  %backscoped_stopwords = %stopword_weights;

  # Extra stopwords which require explicit backward scoping.
  $stopword_weights{'si'} = 0;
  $stopword_weights{'deinde'} = 1;
  my $stopwords_regex_string = join('|', keys(%stopword_weights));
  $stopwords_regex = qr/$stopwords_regex_string/i;
  $scope_regex = qr/
	(?:\bloco\s+(?:hu[ij]us\s+versus|horum\s+versuum)\b)?
	\s*
	(?:
	\b
	(?:
	(?:dicitur|dicuntur)(?:\s+semper)?
	|
	(?:hic\s+versus\s+)?omittitur
	|
	(?:hoc\s+versus\s+)?omittitur
	|
	(?:hæc\s+versus\s+)?omittuntur
	|
	(?:hi\s+versus\s+)?omittuntur
	|
	(?:haec\s+versus\s+)?omittuntur
	)
	\b
	)?
	/ix;
  $conditional_regex = qr/\(\s*($stopwords_regex\b)*(.*?)($scope_regex)?\s*\)/o;
}

# We have four types of scope (in each direction):
use constant SCOPE_NULL => 0;     # Null scope.
use constant SCOPE_LINE => 1;     # Single line.
use constant SCOPE_CHUNK => 2;    # Until the next blank line.
use constant SCOPE_NEST => 3;     # Until a (weakly) stronger conditional.

#*** evaluate_conditional($conditional)
#	Evaluates a expression from a data-file conditional directive.
sub evaluate_conditional($) {
  my $conditional = shift;
  my $expression = '';

  # Pick out tokens.
  while ($conditional =~ /([a-z_\d]+|[><!\(\)]+|==|>=|<=|!=|&&|\|\||\s*)/gi) {

    # Look up identifiers in the hash.
    my $token = $1;
    $expression .= ($token =~ /[a-z_]/) ? "$conditional_values{$token}" : $token;
  }
  return eval $expression;
}

sub parse_conditional($$$) {
  my ($stopwords, $condition, $scope) = @_;
  my ($strength, $result, $backscope, $forwardscope);
  $strength = 0;
  $strength += $stopword_weights{$_} foreach (split /\s+/, lc($stopwords));
  $result = vero($condition);

  # The regexes we use to test here are considerably more general
  # than is allowed by the specification, but we're working on the
  # assumption that the input was first matched against the regex
  # returned by &conditional_regex, which is rather stricter.
  # Do we have a stopword that gives us implicit backscope?
  my $implicit_backscope = 0;
  $implicit_backscope ||= exists($backscoped_stopwords{$_}) foreach (split /\s+/, lc($stopwords));
  $backscope =
      $scope =~ /versuum|omittuntur/i ? SCOPE_NEST
    : $scope =~ /versus|omittitur/i ? SCOPE_CHUNK
    : $scope !~ /semper/i && $implicit_backscope ? SCOPE_LINE
    : SCOPE_NULL;

  if ($scope =~ /omittitur|omittuntur/i) {
    $forwardscope = SCOPE_NULL;
  } elsif ($scope =~ /dicuntur/i) {
    $forwardscope = ($backscope == SCOPE_CHUNK) ? SCOPE_CHUNK : SCOPE_NEST;
  } else {
    $forwardscope = ($backscope == SCOPE_CHUNK || $backscope == SCOPE_NEST) ? SCOPE_CHUNK : SCOPE_LINE;
  }
  return ($strength, $result, $backscope, $forwardscope);
}

sub get_tempus_id {

  our @dayname;
  our ($day, $month, $year, $dayofweek, $version, $hora);
  my $vesp_or_comp = ($hora =~ /Vespera/i) || ($hora =~ /Completorium/i);
  our $monthday;
  my $oct_or_nov = $monthday =~ /^(10|11)\d\-/;
  local $_ = $dayname[0];

  # Standard: Adventus—Nativitatis—Epiphaniæ—post Epiphaniam—Septuagesimæ–Quadragesimæ–Passionis–...
  #           ...–8va Paschæ–post 8vam Paschæ–8va Ascensionis–post 8vam Ascensionis–8va Pentecostes–...
  #           ...–post Pentecosten
  # Standard augmentation for "post Pentecosten": Corpus Christi—8va C.C.—SSmi Cordis—8va—8va SSmi Cordis
  # GABC: Augmented periods for determining correct chant scores:
  #           post partum: Jan 14th — Feb 2nd usque ad Nonam inclusive
  #           in hieme:    Sabbato ante Dominica I Octobris ad Vesperas usque ad Triduum Sacrum
  #           in æstate:   Pascha – Sabbato ante Dom. I. Oct. usque ad Nonam inclusive
  /^Adv/
    ? 'Adventus'
    : /^Nat/ ? ($month == 1 && ($day >= 6 || ($day == 5 && $vesp_or_comp)))
      ? 'Epiphaniæ'
      : 'Nativitatis'
    : /^Epi/ ? ($month == 1 && $day <= 13)
      ? 'Epiphaniæ'
      : ($month == 1 || ($month == 2 && ($day == 1 || $day == 2 && !$vesp_or_comp))) ? 'post Epiphaniam post partum'
      : ($month == 2) ? 'post Epiphaniam'
      : 'post Pentecosten in hieme'
    : /^Quadp(\d)/ && ($1 < 3 || $dayofweek < 3)
    ? ($month == 1 || ($month == 2 && ($day == 1 || $day == 2 && !$vesp_or_comp)))
      ? 'Septuagesimæ post partum'
      : 'Septuagesimæ'
    : /^Quad(\d)/ && $1 < 5 ? 'Quadragesimæ'
    : /^Quad/ ? 'Passionis'
    : /^Pasc0/ && $vesp_or_comp && $dayofweek == 6 ? 'Vigilia Paschalis'
    : /^Pasc0/ ? 'Octava Paschæ'
    : /^Pasc(\d)/ && ($1 < 5 || ($1 == 5 && ($dayofweek < 3 || (!$vesp_or_comp && $dayofweek == 3))))
    ? 'post Octavam Paschæ'
    : /^Pasc6-(5|6)/ ? 'post Octavam Ascensionis'
    : /^Pasc(\d)/ && $1 < 7 ? 'Octava Ascensionis'
    : /^Pasc/ ? 'Octava Pentecostes'
    : /^Pent01/ && $dayofweek == 4 ? 'Corpus Christi post Pentecosten'
    : /^Pent0(\d)/
    && ( ($1 == 1 && $dayofweek > 4 && !($dayofweek == 6 && $vesp_or_comp))
      || ($1 == 2 && ($dayofweek < 5 || ($dayofweek == 6 && $vesp_or_comp))))
    && $version !~ /19(?:55|6)/ ? 'Octava Corpus Christi post Pentecosten'
    : /^Pent02/ && $dayofweek == 5 && $version !~ /1570/ ? 'SSmi Cordis post Pentecosten'
    : /^Pent0(\d)/
    && ( ($1 == 2 && $dayofweek > 5 && !($dayofweek == 6 && $vesp_or_comp))
      || ($1 == 3 && ($dayofweek < 6 || ($dayofweek == 6 && $vesp_or_comp))))
    && $version =~ /Divino/i ? 'Octava SSmi Cordis post Pentecosten'
    : /^Pent/ && !$oct_or_nov ? 'post Pentecosten'
    : 'post Pentecosten in hieme';
}

# Returns the name of the day for use as a subject in conditionals.
sub get_dayname_for_condition {
  our ($day, $month, $year, $winner, $version, $commemoratio);
  our $hora;
  our $rule;
  my $vesp_or_comp = ($hora =~ /Vespera/i) || ($hora =~ /Completorium/i);
  return 'Epiphaniæ' if ($month == 1 && ($day == 6 || ($day == 5 && $vesp_or_comp)));
  return 'Baptismatis Domini' if ($month == 1 && ($day == 13 || ($day == 12 && $vesp_or_comp)));
  return 'Tridui Sacri' if $winner =~ /Quad6\-[456]/;
  return 'in Cœna Domini' if $winner =~ /Quad6\-4/;
  return 'in Parasceve' if $winner =~ /Quad6\-5/;
  return 'Sabbato Sancto' if $winner =~ /Quad6\-6/;
  return 'Vigilia Paschalis' if $winner =~ /Pasc0\-0/ && $vesp_or_comp && $dayofweek == 6;
  return 'regis DNJC' if ($winner =~ /10\-DU/ || $commemoratio =~ /10\-DU/);
  return 'Omnium Defunctorum'
    if (
      $month == 11
      && ($day == 2 || ($day == 3 && $dayofweek == 1) || ($day == 1 && day_of_week(11, 1, $year) != 6 && $vesp_or_comp))
    );
  return 'Malachiae' if $month == 11 && $day == 3;
  return 'Caroli' if $month == 11 && $day == 4;
  return 'Nicolai' if $month == 12 && $day == 6;
  return 'Nat28' if $month == 12 && $day == 28;
  return 'Nat29' if $month == 12 && $day == 29;
  return 'doctorum' if ($dayname[1] =~ /Doctor/i || $dayname[2] =~ /Doctor/i);
  return 'transfigurationis' if ($month == 8 && ($day == 6 || ($day == 5 && $vesp_or_comp)));
  return 'septem doloris' if $winner =~ /09-15$|09-DT|Quad5-5$/;
  return 'Nativitatis' if $winner =~ /12-25/;
  return 'post Dominicam infra Octavam Epiphaniæ' if $dayname[0] =~ /Epi1-[1-6]/;
  return 'post Epi1-0' if $dayname[0] =~ /Epi1-[1-6]/;
  return 'Bernardi' if $winner =~ /08-20|00-VB/;
  return '3 lectionum' if $winner{Rule} =~ /3 lectio/i;
  return '3 lect' if $winner{Rule} =~ /3 lectio/i;
  return '';
}

# parse and evaluate a condition
sub vero($) {
  my $condition = shift;
  my $vero;
  $condition =~ s/^\s*//;
  $condition =~ s/\s*$//;

  # The empty condition is _true_ : safer, since previously conditions were's used.
  return 1 unless $condition;

  # aut binds tighter than et
AUTEM: for (split /\baut\b/, $condition) {
    my $negation = 0;    # the first condition always has to be true

    for (split /\b(et|nisi)\b/) {
      $negation = 1 if /nisi/;    # everthing after 'nisi' has to be false until the next 'aut'
      next if /et|nisi/;          # don't evaluate the captured seperator

      s/^\s*(.*?)\s*$/$1/;

      # Normalise whitespace.
      s/\s+/ /g;
      my ($subject, $predicate) = split /\s+/, $_, 2;

      # Subject is optional
      ($predicate, $subject) = ($subject, '') if not $predicate;

      # Multi-word predicate with implicit subject.
      if ($subject && !exists($subjects{lc($subject)})) {
        $predicate = "$subject $predicate";
        $subject = '';
      }

      # Subject defaults to tempore
      $subject ||= 'tempore';

      # Look up the subject and predicate. If we don't recognise
      # the predicate, treat it as a regex and test the subject
      # against it.
      my $predicate_text = $predicate;
      $predicate = $predicates{lc($predicate)} || sub { shift =~ /$predicate_text/i };
      $subject = $subjects{lc($subject)};

      next AUTEM unless $subject && (&$predicate(&$subject()) xor $negation);
    }

    return ($vero = 1);
  }
  return ($vero = 0);
}

my $InclusionRegex = qr/^\s*\@
([^\n:]+)?                    # Filename (self-reference if omitted).
(?::([^\n:]+?))?              # Optional keywords.
[^\S\n\r]*                    # Ignore trailing whitespace.
(?::(.*))?                    # Optional substitutions.
$
\n?                           # Eat up to one newline.
/mx;

#*** setupstring_parse_file($fullpath, $basedir, $lang)
# Loads the database file from $fullpath and returns a reference to
# a hash whose keys are the section headings and whose values are
# their contents. $basedir and $lang are used for inclusions only.
sub setupstring_parse_file($$$) {
  my ($fullpath, $fname, $lang) = @_;

  my @filelines = do_read($fullpath) or return '';

  # Regex for matching section headers.
  my $sectionregex = qr/^\s*\[([\pL\pN_ #,:-]+)\]/i;

  # Regex for matching conditionals, which we shall embed into our own
  # regexes for parsing lines.
  my %sections;
  my $key = '__preamble';
  my $use_this_section = 1;

  foreach my $line (@filelines) {

    # Check for a new section.
    if (substr($line, 0, 1) eq '[' && $line =~ /$sectionregex(?:\s*$conditional_regex)?/o) {

      # If we have a conditional clause, it had better be true.
      my $section_condition = $3;

      if (!$section_condition || vero($section_condition)) {

        # New section.
        $use_this_section = 1;
        $key = $1;
        $sections{$key} = [];
      } else {
        $use_this_section = 0;
      }
    } elsif ($use_this_section) {

      # Fill missing info in substitute rules

      $line =~ s/$InclusionRegex/
      '@' .
      ($1 || $fname) . ':' .   # Filename.
      ($2 || $key) .           # Keyword.
      ($3 ? ":$3" : '');       # Substitutions.
      /ge if (substr($line, 0, 1) eq '@') && $key ne '__preamble';

      push @{$sections{$key}}, $line;
    }
  }

  # Process conditionals in and flatten each section.
  foreach my $key (keys %sections) {

    # The extra empty string gives us a newline at the end.
    $sections{$key} = join "\n", (process_conditional_lines(@{$sections{$key}}), '');
  }
  return \%sections;
}

my $blankline_regex = qr/^\s*_?\s*$/;

### process_conditional_lines(@lines)
# Returns the array resulting from processing conditional directives in the
# array @lines of lines.
sub process_conditional_lines {

  my @output;
  use constant 'COND_NOT_YET_AFFIRMATIVE' => 0;
  use constant 'COND_AFFIRMATIVE' => 1;
  use constant 'COND_DUMMY_FRAME' => 2;
  my @conditional_stack = ([COND_AFFIRMATIVE, SCOPE_NEST]);
  my @conditional_offsets = (-1);

  foreach (@_) {

    # Break the aliasing.
    my $line = $_;

    # Check for a new condition.
    if ($line =~ /^\s*$conditional_regex\s*(.*)$/o) {
      my ($strength, $result, $backscope, $forwardscope) = parse_conditional($1 || '', $2, $3);

      # Sequel.
      $line = $4;

      # If the parent conditional is not affirmative, then the new one
      # must break out of the nest, as it were.
      if (${$conditional_stack[-1]}[0] == COND_AFFIRMATIVE
        || $strength >= $#conditional_offsets)
      {
        if ($strength >= $#conditional_offsets) {
          @conditional_stack = ();
        } elsif ($strength >= $#conditional_offsets - $#conditional_stack) {
          $#conditional_stack = $#conditional_offsets - $strength - 1;
        }

        if ($result) {

          # Find the nearest insurmountable fence.
          my $fence =
              $#conditional_offsets >= $strength
            ? $conditional_offsets[$strength]
            : -1;

          # Handle the backward scope.
          if ($backscope == SCOPE_LINE) {

            # Remove preceding line.
            pop @output if $#output > $fence;
          } elsif ($backscope == SCOPE_CHUNK) {

            # Remove preceding consecutive non-whitespace lines.
            pop @output while ($#output > $fence && $output[-1] !~ $blankline_regex);

            # Remove any whitespace lines.
            pop @output while ($#output > $fence && $output[-1] =~ $blankline_regex);
          } elsif ($backscope == SCOPE_NEST) {

            # Truncate output at the point to which we have to backtrack.
            $#output = $fence;
          }
        }

        # Having backtracked, null forward scope now behaves like a
        # satisfied conditional with nesting forward scope.
        if ($forwardscope == SCOPE_NULL) {
          $forwardscope = SCOPE_NEST;
          $result = 1;
        }

        if ($result) {

          # Remember where we encountered this conditional.
          $conditional_offsets[$_] = $#output foreach (0 .. $strength);
        }

        # Push dummy frame(s) onto the conditional stack to bring it
        # into sync with the strength.
        push @conditional_stack, [COND_DUMMY_FRAME, $forwardscope]
          while ($strength < $#conditional_offsets - $#conditional_stack - 1);

        # Push the new conditional frame onto the stack.
        push @conditional_stack, [$result ? COND_AFFIRMATIVE : COND_NOT_YET_AFFIRMATIVE, $forwardscope];
      }

      # Parse anything left over.
      next unless $line;
    }

    # Handle escaped lines.
    $line =~ s/^~//;

    # Add line to output array if it's not in a failed conditional block.
    push @output, $line if (${$conditional_stack[-1]}[0] == COND_AFFIRMATIVE);

    # Check to see whether we'll fall off the end of the current scope
    # after this line.
    while (${$conditional_stack[-1]}[1] == SCOPE_LINE
      || (${$conditional_stack[-1]}[1] == SCOPE_CHUNK && $line =~ $blankline_regex))
    {
      do {
        pop @conditional_stack;
        } while (@conditional_stack
          && ${$conditional_stack[-1]}[0] == COND_DUMMY_FRAME);

      # If we've emptied the conditional stack, push an always-true,
      # unbounded frame to allow uniformity in testing.
      push @conditional_stack, [COND_AFFIRMATIVE, SCOPE_NEST]
        if (@conditional_stack == 0);
    }
  }
  return @output;
}

#*** do_inclusion_substitutions(\$text, $subs)
# Performs manipulation in text from 'include' directive:
# (de)select line(s) (numbered from 1!) or substitute text
sub do_inclusion_substitutions(\$$) {
  my ($text, $subs) = @_;

  while ($subs =~ m{(?:s/(?<s>[^/]*)/(?<r>[^/]*)/(?<f>[gism]*))|(?:(?<n>\!?)(?<b>\d+)(-(?<e>\d+))?)}go) {
    if ($+{b}) {
      my $s = $+{b} - 1;
      my $l = $+{e} ? $+{e} - $s : 1;
      my @t1 = split(/\n/, $$text);
      my @t2 = splice(@t1, $s, $l);
      $$text = join("\n", $+{n} ? @t1 : @t2) . "\n";
    } else {
      eval "\$\$text =~ s/$+{s}/$+{r}/$+{f}";
    }
  }
}

#*** get_loadtime_inclusion(\%sections, $basedir, $lang, $ftitle, $section, $substitutions, $callerfname)
# Retrieves the $section section of the file "$basedir/$lang/$ftitle.txt"
# and performs the substitutions specified in $substitutions according
# to the syntax of the @ directive. \%sections is the file containing
# the reference to be expanded, for back references when necessary.
# If $ftitle is empty, then use \%sections itself to resolve the
# reference.
sub get_loadtime_inclusion($$$$$$$) {
  my ($sections, $basedir, $lang, $ftitle, $section, $substitutions, $callerfname) = @_;
  my $text;
  our ($version, $missa, @dayname);

  # Adjust offices of apostles & martyrs in Paschaltide to use the special common.
  # Github #525: Safeguard against infinite loops: exclude Hymnus, Oratio, and Lectio which are partially copied from "extra Tempus Paschalis"
  if ( index($dayname[0], 'Pasc') >= 0
    && !$missa
    && $callerfname !~ /C[123]/
    && $section !~ /Hymnus|Oratio|Lectio|Secreta|Postcommunio|Versum/i)
  {
    $ftitle =~ s/(C[123][abcd]*)(?![p\d])/$1p/g;
  }

  # Load the file to resolve the reference; if none specified, it's a
  # self-reference.
  my $inclfile = $ftitle ? setupstring($lang, "$ftitle.txt", 'resolve@' => RESOLVE_WHOLEFILE) : $sections;

  ($text = ${$inclfile}{$section}) =~ s/\n+$/\n/s if (exists ${$inclfile}{$section});

  if ($text) {
    do_inclusion_substitutions($text, $substitutions);
    return $text;
  }
  return "$ftitle:$section is missing!";
}

my %_cache_latin_name;

#*** setupstring_layers($lang, $ofname)
# Resolves a (language, file name) pair into the four values that setupstring()
# needs to locate the file on disk: the language directory, the file name, the
# base directory and the resulting path. Kept separate so that a caller can ask
# "where would this language's own copy of this file live?" without loading and
# merging every layer above it.
# Returns ($lang, $fname, $basedir, $fullpath).
sub setupstring_layers($$) {

  my ($lang, $ofname) = @_;
  my $fname = $ofname;
  my $basedir = our $datafolder;

  if ((my $i = index($lang, '../missa')) >= 0) {    # For Monastic look-up of Evangelium, prevent __preamble from
    $lang = substr($lang, $i + 9);                  # horas file to contaminate missa structure which could lead
    $basedir =~ s/horas/missa/g;                    # to infinite cycles github #525
  }

  # modifies $fname if fallback to Roman folder from Monastic or OP is used in Latin
  if (exists($_cache_latin_name{$ofname})) {
    $fname = $_cache_latin_name{$ofname};
  } else {
    checklatinfile(\$fname);
    $_cache_latin_name{$ofname} = $fname;
  }

  # missa uses comments and Commune files from horas dir
  $basedir =~ s/missa/horas/g
    if (index($basedir, 'missa') >= 0 && $fname =~ /Comment.txt$|C\d/)
    || (!(-e "$basedir/$lang/$fname") && -e "$basedir/../horas/$lang/$fname");

  return ($lang, $fname, $basedir, "$basedir/$lang/$fname");
}

#*** section_in_own_layer($lang, $ofname, $section)
# Answers whether the translation in $lang has a section of its own for
# $section in $ofname, i.e. whether the text it contributes is really written in
# $lang rather than borrowed from the fallback language or from Latin. A section
# that is only another @-inclusion does not count: the question is whether the
# translation exists here, not whether it delegates somewhere.
# Self-references must be passed as $ofname; callers normalize an empty
# reference target to the file being merged.
sub section_in_own_layer($$$) {

  my ($lang, $ofname, $section) = @_;

  return 0 if !$lang || $lang eq 'Latin' || !$ofname;
  $ofname .= '.txt' unless $ofname =~ /\.txt$/;

  my ($l, $f, $fullpath) = (setupstring_layers($lang, $ofname))[0, 1, 3];

  return 0 unless -e $fullpath;
  my $own = setupstring_parse_file($fullpath, $f =~ s/\.txt$//r, $l);
  return 0 unless exists $own->{$section};
  return 0 if $own->{$section} !~ /\S/;
  return 0 if $own->{$section} =~ /^\s*\@[^\n]*\s*$/m;
  return 1;
}

#*** pure_inclusion($text)
# True when the body of a section is nothing but @-inclusion directives, i.e.
# the section does not carry a text of its own but points at other propers.
# Leading !-rubric lines are the section's own scripture citation, and the
# referenced section brings a citation of its own, so they are not held against
# it. Blank lines are ignored. A section carrying any other line is not a bare
# reference.
sub pure_inclusion($) {
  my ($text) = @_;
  return 0 unless defined $text;
  1 while $text =~ s/^\s*![^\n]*\n//;
  my $any = 0;
  for my $line (split /\n/, $text) {
    next if $line =~ /^\s*$/;
    return 0 unless $line =~ /^\s*\@[^\n]*$/;
    $any = 1;
  }
  return $any;
}

# Sections whose value drives day selection, ranking, rule guards or the
# display name. These are never taken from the Latin layer by reference: their
# fallback-language value is the meaningful one.
my $not_a_proper = qr/^(?:__preamble|Rank|Rule|Officium|Name)$/;

#*** prefer_latin_inclusion(\%new, \%base, $calledlang, $latinlang, $ofname)
# The fallback language is allowed to translate a proper by writing the text out
# in full where Latin only holds a reference to another proper. When the
# requested language has nothing of its own for that section, taking the
# fallback's text drops the requested language out of a proper it does have
# elsewhere - so before doing that, look at the Latin section: if it is a bare
# reference and the proper it points at exists in the requested language, keep
# the reference instead, so that it resolves in the requested language.
# A section may consist of several @-directives; every one of them then has to
# be satisfiable in the requested language, otherwise the whole section is left
# to the fallback language.
# The references are carried over together with their substitutions: they encode
# data transforms (stripping psalm numbers, renumbering) that must survive
# whichever language the reference resolves in.
# Every structural key is left to the fallback language, and a reference the
# requested language cannot satisfy is left alone as well.
sub prefer_latin_inclusion {

  my ($new, $base, $calledlang, $latinlang, $ofname) = @_;

  return unless $calledlang && $calledlang ne $latinlang;
  return unless %$base;

  my $latin_sections = setupstring($latinlang, $ofname, 'resolve@' => RESOLVE_NONE);
  return unless %$latin_sections;

  # An @-directive names its file without the extension.
  (my $selfname = $ofname) =~ s/\.txt$//;

  foreach my $key (keys %$base) {
    next if $key =~ $not_a_proper;
    next if $new->{$key};
    next unless pure_inclusion($latin_sections->{$key});

    # Only worth it if every referenced proper is actually present in the
    # requested language; otherwise the fallback translation is all there is.
    my @refs;
    for my $line (split /\n/, $latin_sections->{$key}) {
      next if $line =~ /^\s*$/;
      next if $line =~ /^\s*!/;
      unless ($line =~ /$InclusionRegex/) { @refs = (); last; }
      my ($file, $section) = ($1 || $selfname, $2 || $key);
      unless (section_in_own_layer($calledlang, $file, $section)) { @refs = (); last; }
      push @refs, $line;
    }
    next unless @refs;

    # The fallback language already satisfies the section by reference, with
    # substitutions of its own: it resolves in the requested language as it is,
    # so taking the Latin reference would only replace its language-adapted
    # substitutions (e.g. names) with the Latin ones.
    next if pure_inclusion($base->{$key});

    $new->{$key} = join("\n", @refs) . "\n";
  }
}

#*** setupstring($lang, $fname, %params)
# Loads the database file from path "$basedir/$lang/$fname" through
# the cache. Inclusions are performed according to the value of
# $params{'resolve@'}. If omitted, the default is RESOLVE_ALL.
sub setupstring($$%) {

  my ($calledlang, $ofname, %params) = @_;
  our $error;

  my ($lang, $fname, $basedir, $fullpath) = setupstring_layers($calledlang, $ofname);

  our ($missa);

  our $version;

  $setupstring_caches_by_version{$version} = {} unless (exists $setupstring_caches_by_version{$version});

  # Get hash of cached files for this version.
  my $inclusioncache = $setupstring_caches_by_version{$version};

  unless (exists ${$inclusioncache}{$fullpath}) {

    # Not yet in cache, so open it and add it.
    my ($base_sections, $new_sections) = ({}, {});
    my $latinlang = $calledlang =~ /\.\.\/missa/ ? '../missa/Latin' : 'Latin';

    # The Latin-reference rule only makes sense for a language which is neither
    # Latin itself nor the fallback language: for those the layer below already
    # *is* Latin, so there is nothing to prefer and their own pages must not
    # change.
    my $check_latin_inclusion = ($lang && $lang ne 'Latin' && $lang ne $main::langfb && $lang !~ /-/);

    if ($lang eq $main::langfb && $lang ne 'Latin') {

      # fallback langauage layers on top of Latin.
      $base_sections = setupstring($latinlang, $fname, 'resolve@' => RESOLVE_NONE);
    } elsif ($lang =~ /-/) {

      # If $lang contains dash, the part before the last dash is taken as a new fallback
      my $temp = $calledlang;
      $temp =~ s/-[^-]+$//;
      $base_sections = setupstring($temp, $fname, 'resolve@' => RESOLVE_NONE);
    } elsif ($lang && $lang ne 'Latin') {

      # Other non-Latin languages layer on top of fallback language.
      my $baselang = $calledlang =~ /\.\.\/missa/ ? "../missa/$main::langfb" : $main::langfb;
      $base_sections = setupstring($baselang, $fname, 'resolve@' => RESOLVE_NONE);
    }

    # Get the top layer.
    $new_sections = setupstring_parse_file($fullpath, $fname =~ s/\.txt$//r, $lang) if (-e $fullpath);

    if (%$new_sections) {

      # Fill in missing "pre-Urban hymn translations to avoid being overwritten by Latin
      # GABC: deactivated as pre-Urban Hymnody should not be overwritten by post-Urban at all
      unless ($lang =~ /^Latin(?:-gabc)?$/) {
        foreach my $seckey (keys(%{$new_sections})) {
          if ($seckey =~ /^Hymnus (.*)/ && !exists(${$new_sections}{"HymnusM $1"})) {
            ${$new_sections}{"HymnusM $1"} = ${$new_sections}{$seckey};
          }
        }
      }

      # The fallback language may have written out a proper in full where Latin
      # only refers to another one; prefer the Latin reference when it resolves
      # in the language we are actually rendering. This has to happen before the
      # layer below is merged in, while the gaps are still gaps.
      prefer_latin_inclusion($new_sections, $base_sections, $calledlang, $latinlang, $fname)
        if $check_latin_inclusion;

      # Fill in the missing things from the layer below.
      unless (${$new_sections}{'__preamble'} eq ${$base_sections}{'__preamble'}) {
        ${$new_sections}{'__preamble'} .= "\n${$base_sections}{'__preamble'}";
      }
      ${$new_sections}{$_} ||= ${$base_sections}{$_} foreach (keys(%{$base_sections}));

      # Ensure consistency in ranking of Offices by always defaulting to Latin even if there is a Translation itself
      my @baserank = split(';;', ${$base_sections}{Rank});

      if (@baserank) {
        my @newrank = split(';;', ${$new_sections}{Rank});
        my $office = ${$new_sections}{Officium};
        $office =~ s/\s+$//;
        $baserank[0] = $office || $newrank[0];
        ${$new_sections}{Rank} = join(';;', @baserank);
      } elsif (exists(${$new_sections}{Officium})) {
        my @newrank = split(';;', ${$new_sections}{Rank});
        $newrank[0] = ${$new_sections}{Officium};
        $newrank[0] =~ s/\s+$//;
        ${$new_sections}{Rank} = join(';;', @newrank);
      }

    } else {

      # No file of its own: the fallback language provides everything, but a
      # Latin reference to a proper the fallback wrote out in full can still be
      # satisfied in the requested language, so let it win where it can.
      $new_sections = {};
      prefer_latin_inclusion($new_sections, $base_sections, $calledlang, $latinlang, $fname)
        if $check_latin_inclusion;
      ${$new_sections}{$_} ||= ${$base_sections}{$_} foreach (keys(%{$base_sections}));
    }
    return '' unless %$new_sections;

    # Cache the final result.
    ${$inclusioncache}{$fullpath} = $new_sections;
  }

  # Take a copy.
  my %sections = %{${$inclusioncache}{$fullpath}};
  $params{'resolve@'} = RESOLVE_ALL unless (exists $params{'resolve@'});

  # Do whole-file inclusions.
  unless ($params{'resolve@'} == RESOLVE_NONE) {
    while (index($sections{'__preamble'}, '@') >= 0 && $sections{'__preamble'} =~ /$InclusionRegex/gc) {
      my $incl_fname .= "$1.txt";
      if (index($fullpath, $incl_fname) >= 0) { warn "Cyclic dependency in whole-file inclusion: $fullpath"; last; }
      my $incl_sections =
        setupstring($calledlang, $incl_fname, 'resolve@' => RESOLVE_WHOLEFILE)
        ;    # ensure daisy-chain (especially for Monastic)
      $sections{$_} ||= ${$incl_sections}{$_} foreach (keys %{$incl_sections});
    }
    delete $sections{'__preamble'};
  }

  if ($params{'resolve@'} == RESOLVE_ALL) {

    # Iterate over all sections, resolving inclusions. We make sure we
    # do [Rule] first, if it exists: we need to use the rule to work
    # out some subsequent substitutions.
    foreach my $key ((exists $sections{'Rule'}) ? 'Rule' : (), keys(%sections)) {
      if (
        (
          index($key, 'Commemoratio') < 0
          && (index($key, 'LectioE') < 0 && index($key, 'Evangelium') < 0 || index($sections{$key}, 'Commune') >= 0)
        )
        || $missa
        || index($basedir, 'missa') >= 0
      ) {
        my $iiij = 0;
        my $iiiT = $sections{$key};

        while (
          index($sections{$key}, '@') >= 0
          && $sections{$key} =~ s/$InclusionRegex/
				get_loadtime_inclusion(\%sections, $basedir, $calledlang,
				$1,             # Filename.
				$2 || $key,     # Keyword.
				$3,             # Substitutions.
				$fname)         # Caller's filename.
				/ge
        ) {

          if ($iiij++ > 6) {
            $error .= "Error in resolving $fname : $key :: $lang ::: $iiiT<br>";
            $sections{$key} = "Cannot resolve too deeply nested Hashes";
            last;
          }
        }
      }
    }
  }

  # Safeguard [Rank] to allow changing Rank and inherit Officium via section inclusions
  if (exists($sections{'Officium'})) {
    $sections{'Officium'} =~ s/\s+$//;
    $sections{'Rank'} =~ s/^.*?;;/$sections{'Officium'};;/;
  }

  return \%sections;
}

#*** officestring($lang, $fname, $flag)
# same as setupstring (reads the hash for $fname office)
# with the addition that for the monthly ferias/scriptures (aug-dec)
# it adds that office to the otherwise empty season related one
# if flag is 1 looks for the anticipated office for vespers
# returns the filled hash for the ofiice
sub officestring($$;$) {
  my ($lang, $fname, $flag) = @_;

  my $basedir = our $datafolder;
  my %s;

  # read only globals
  our ($version, $day, $month, $year);

  # set this global here
  our $monthday;

  if ( $fname !~ m{^Tempora[^/]*/(?:Pent|Epi)}
    || $fname =~ m{^Tempora[^/]*/Pent0[1-5]})
  {
    %s = %{setupstring($lang, $fname)};

    if ($version =~ /196/ && $s{Rank} =~ /Feria.*?(III|IV) Adv/i && $day > 16) {
      $s{Rank} =~ s/;;2\.1/;;4.9/;
    } elsif ($version =~ /cist/i && $s{Rank} =~ /Feria.*?(III|IV) Adv/i && $day > 16) {
      $s{Rank} =~ s/;;1\.15/;;2.1/;
    }
    return \%s;
  }

  $monthday = monthday($day, $month, $year, ($version =~ /196/) + 0, $flag);

  if (!$monthday) {
    %s = %{setupstring($lang, $fname)};
    return \%s;
  }
  %s = %{setupstring($lang, $fname)};
  if (!%s) { return ''; }
  my @rank = split(';;', $s{Rank});
  my $m = 0;
  my $w = 0;
  if ($monthday =~ /([0-9][0-9])([0-9])\-[0-9]/) { $m = $1; $w = $2; }
  my @weeks = ('I.', 'II.', 'III.', 'IV.', 'V.');

  if ($m) {
    my %m = %{setupstring($lang, 'Psalterium/Comment.txt')};
    my @months = split("\n", $m{Menses});
    $m = $months[$m - 8];
  }
  if ($w) { $w = $weeks[$w - 1]; }
  $rank[0] .= " $w $m";
  $s{Rank} = join(';;', @rank);
  my %m = %{setupstring($lang, subdirname('Tempora', $version) . "$monthday.txt")};

  foreach my $key (keys %m) {
    if (($version =~ //i && $key =~ /Rank/i)) {
      ;
    } else {
      $s{$key} = $m{$key};
    }
  }
  return \%s;
}

#*** checkfile($lang, $filename)
# substitutes $main::langfb if no $lang item, Latin if no $main::langfb
# if $lang contains dash, the part before the last dash is taken as a fallback recursively (till something exists)
sub checkfile {
  my $lang = shift;
  my $file = shift;
  our $datafolder;

  my $redirect = index($datafolder, "missa") >= 0 && $file =~ /C1[a-z]?/ ? '/../horas' : '';

  if (-e "$datafolder$redirect/$lang/$file") {
    return "$datafolder$redirect/$lang/$file";
  } elsif ($lang =~ /-/) {
    my $temp = $lang;
    $temp =~ s/-[^-]+$//;
    return checkfile($temp, $file);
  } elsif (-e "$datafolder$redirect/$main::langfb/$file") {
    return "$datafolder$redirect/$main::langfb/$file";
  } elsif ($redirect || $datafolder =~ /horas/i) {
    return "$datafolder$redirect/Latin/$file";
  } else {

    # While Commune files get auto-re-directed from missa to horas, for all other files we use
    # a dynamic re-direction if and only if the corresponding missa file does not exist.
    # By checking this re-direct last, a vernacular file in the corresponding horas folder is not taking
    # precedence over a fallback language file in the missa directories.
    $redirect = '/../horas';

    if (-e "$datafolder$redirect/$lang/$file") {
      return "$datafolder$redirect/$lang/$file";
    } elsif ($lang =~ /-/) {
      my $temp = $lang;
      $temp =~ s/-[^-]+$//;
      return checkfile($temp, $file);
    } elsif (-e "$datafolder$redirect/$main::langfb/$file") {
      return "$datafolder$redirect/$main::langfb/$file";
    } else {
      return "$datafolder$redirect/Latin/$file";
    }
  }
}

sub checklatinfile {

  my $file_ref = shift;
  my $file = $$file_ref;
  our $datafolder;
  my $txt = $file =~ s/\.txt$// ? '.txt' : '';

  my $redirect = index($datafolder, "missa") >= 0 && $file =~ /C1[a-z]?/ ? '/../horas' : '';

  # Hierarchy for Folder dependency:
  # Roman Missa => Roman Horas
  # OCist => OSB (a.k.a. "M")
  # OSB & OP => Roman
  -e "$datafolder$redirect/Latin/$file.txt"
    || -e "$datafolder/../horas/Latin/$file.txt"
    || $file =~ s/(Sancti|Tempora|Commune)(?:Cist)(.*)/$1M$2/
    && (-e "$datafolder$redirect/Latin/$file.txt")
    && ($$file_ref = "$file$txt")
    || $file =~ s/(Sancti|Tempora|Commune)(?:M|OP)(.*)/$1$2/
    && (-e "$datafolder$redirect/Latin/$file.txt")
    && ($$file_ref = "$file$txt");
}

1;
