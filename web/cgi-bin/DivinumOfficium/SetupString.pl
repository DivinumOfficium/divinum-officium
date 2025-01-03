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
  rubricis => sub {$version},
  rubrica => sub {$version},
  tempore => \&get_tempus_id,
  missa => sub { our $missanumber },
  communi => sub { our $version },
  'die' => \&get_dayname_for_condition,
  feria => sub { our $dayofweek + 1 },
  commune => sub {$commune},
  officio => sub { $dayname[1]; },
);
my %predicates = (
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
  'summorum pontificum' => sub { shift =~ /^Divino|1955|1960/ },
  feriali => sub { shift =~ /feria|vigilia/i; },
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

#*** conditional_regex()
#	Returns a regex that matches conditionals, capturing stopwords,
#	the condition itself and scope keywords, in that order.
sub conditional_regex() {
  return qr/\(\s*($stopwords_regex\b)*(.*?)($scope_regex)?\s*\)/o;
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
  our ($day, $month, $dayofweek, $version);
  our $hora;
  my $vesp_or_comp = ($hora =~ /Vespera/i) || ($hora =~ /Completorium/i);
  local $_ = $dayname[0];

  /^Adv/
    ? 'Adventus'
    : /^Nat/ ? ($month == 1 && ($day >= 6 || ($day == 5 && $vesp_or_comp)))
      ? 'Epiphaniæ'
      : 'Nativitatis'
    : /^Epi/ ? ($month == 1 && $day <= 13)
      ? 'Epiphaniæ'
      : ($month == 1 || ($month == 2 && ($day == 1 || $day == 2 && !$vesp_or_comp))) ? 'post Epiphaniam post partum'
      : ($month == 2) ? 'post Epiphaniam'
      : 'post Pentecosten'
    : /^Quadp(\d)/ && ($1 < 3 || $dayofweek < 3) ? ($month == 1 || $day == 1 || ($day == 2 && !$vesp_or_comp))
      ? 'Septuagesimæ post partum'
      : 'Septuagesimæ'
    : /^Quad(\d)/ && $1 < 5 ? 'Quadragesimæ'
    : /^Quad/ ? 'Passionis'
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
    && $version =~ /Divino/i
    ? 'Octava SSmi Cordis post Pentecosten'
    : 'post Pentecosten';
}

# Returns the name of the day for use as a subject in conditionals.
sub get_dayname_for_condition {
  our ($day, $month, $year, $winner, $version);
  our $hora;
  my $vesp_or_comp = ($hora =~ /Vespera/i) || ($hora =~ /Completorium/i);
  return 'Epiphaniæ' if ($month == 1 && ($day == 6 || ($day == 5 && $vesp_or_comp)));
  return 'in Cœna Domini' if $winner =~ /Quad6-4/;
  return 'in Parasceve' if $winner =~ /Quad6-5/;
  return 'Sabbato Sancto' if $winner =~ /Quad6-6/;
  return 'Omnium Defunctorum'
    if (
      $month == 11
      && ($day == 2 || ($day == 3 && $dayofweek == 1) || ($day == 1 && day_of_week(11, 1, $year) != 6 && $vesp_or_comp))
    );
  return 'Nicolai' if $month == 12 && $day == 6;
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
    for (split /\bet\b/) {
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
      next AUTEM unless $subject && &$predicate(&$subject());
    }
    return ($vero = 1);
  }
  return ($vero = 0);
}

#*** setupstring_parse_file($fullpath, $basedir, $lang)
# Loads the database file from $fullpath and returns a reference to
# a hash whose keys are the section headings and whose values are
# their contents. $basedir and $lang are used for inclusions only.
sub setupstring_parse_file($$$) {
  my ($fullpath, $basedir, $lang) = @_;

  my @filelines = do_read($fullpath) or return '';

  # Regex for matching section headers.
  my $sectionregex = qr/^\s*\[([\pL\pN_ #,:-]+)\]/i;

  # Regex for matching conditionals, which we shall embed into our own
  # regexes for parsing lines.
  my $conditional_regex = conditional_regex();
  my %sections;
  my $key = '__preamble';
  my $use_this_section = 1;

  foreach my $line (@filelines) {

    # Check for a new section.
    if ($line =~ /$sectionregex(?:\s*$conditional_regex)?/o) {

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

### process_conditional_lines(@lines)
# Returns the array resulting from processing conditional directives in the
# array @lines of lines.
sub process_conditional_lines {

  my $conditional_regex = conditional_regex();
  my @output;
  use constant 'COND_NOT_YET_AFFIRMATIVE' => 0;
  use constant 'COND_AFFIRMATIVE' => 1;
  use constant 'COND_DUMMY_FRAME' => 2;
  my @conditional_stack = ([COND_AFFIRMATIVE, SCOPE_NEST]);
  my @conditional_offsets = (-1);
  my $blankline_regex = qr/^\s*_?\s*$/;
  my $conditional_regex = conditional_regex();

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

#*** do_inclusion_substitutions(\$text, $substitutions)
# Performs substitutions on $text, where $substitutions contains the
# substitutions in the syntax of the @ directive.
sub do_inclusion_substitutions(\$$) {
  my ($text, $substitutions) = @_;

  # substitute text or select line(s) (numbered from 1!)
  while (($substitutions =~ m{(?:s/([^/]*)/([^/]*)/([gism]*))|(?:(\d+)(-\d+)?)}g)) {
    if ($4) {
      my ($s) = $4 - 1;
      my ($l) = $5 ? -$5 - $s : 1;
      my (@t) = split(/\n/, $$text);
      $$text = join("\n", splice(@t, $s, $l)) . "\n";
    } else {
      eval "\$\$text =~ s/$1/$2/$3";
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
  if ($dayname[0] =~ /Pasc/i && !$missa && $callerfname !~ /C[123]/ && $section !~ /Hymnus|Oratio|Lectio/i) {
    $ftitle =~ s/(C[123])(?![p\d])/$1p/g;
  }

  # Load the file to resolve the reference; if none specified, it's a
  # self-reference.
  my $inclfile = $ftitle ? setupstring($lang, "$ftitle.txt", 'resolve@' => RESOLVE_WHOLEFILE) : $sections;

  if ( $version !~ /Trident/i
    && $section =~ /Gregem/i
    && (my ($plural, $class, $name) = papal_commem_rule(${$sections}{'Rule'})))
  {
    my ($itemkey) = ($section =~ /(.*?)\s*Gregem/);
    $text = papal_prayer($lang, $plural, $class, $name, $itemkey);
  } else {

    # Get text from reference, less any trailing blank lines.
    ($text = ${$inclfile}{$section}) =~ s/\n+$/\n/s if (exists ${$inclfile}{$section});
  }

  if ($text) {
    do_inclusion_substitutions($text, $substitutions);
    return $text;
  }
  return "$ftitle:$section is missing!";
}

#*** setupstring($lang, $fname, %params)
# Loads the database file from path "$basedir/$lang/$fname" through
# the cache. Inclusions are performed according to the value of
# $params{'resolve@'}. If omitted, the default is RESOLVE_ALL.
sub setupstring($$%) {
  my ($lang, $fname, %params) = @_;
  my $basedir = our $datafolder;
  my $calledlang = $lang;
  our $error;

  if ($lang =~ /\.\.\/missa\/(.+)/) {    # For Monastic look-up of Evangelium, prevent __preamble from
    $lang = $1;                          # horas file to contaminate missa structure which could lead
    $basedir =~ s/horas/missa/g;         # to infinite cycles github #525
  }

  if ($fname =~ /Comment.txt$/) {
    $basedir =~ s/missa/horas/g;         # missa uses comments from horas dir
  }

  checklatinfile(\$fname);    # modifies $fname if fallback to Roman folder from Monastic or OP is used in Latin

  my $fullpath = "$basedir/$lang/$fname";
  our ($missa);
  my $inclusionregex = qr/^\s*\@
	([^\n:]+)?                    # Filename (self-reference if omitted).
	(?::([^\n:]+?))?              # Optional keywords.
	[^\S\n\r]*                    # Ignore trailing whitespace.
	(?::(.*))?                    # Optional substitutions.
	$
	\n?                           # Eat up to one newline.
	/mx;
  our $version;

  $setupstring_caches_by_version{$version} = {} unless (exists $setupstring_caches_by_version{$version});

  # Get hash of cached files for this version.
  my $inclusioncache = $setupstring_caches_by_version{$version};

  unless (exists ${$inclusioncache}{$fullpath}) {

    # Not yet in cache, so open it and add it.
    my ($base_sections, $new_sections) = ({}, {});

    if ($lang eq 'English') {

      # English layers on top of Latin.
      my $baselang = $calledlang =~ /\.\.\/missa/ ? '../missa/Latin' : 'Latin';
      $base_sections = setupstring($baselang, $fname, 'resolve@' => RESOLVE_NONE);
    } elsif ($lang =~ /-/) {

      # If $lang contains dash, the part before the last dash is taken as a new fallback
      my $temp = $calledlang;
      $temp =~ s/-[^-]+$//;
      $base_sections = setupstring($temp, $fname, 'resolve@' => RESOLVE_NONE);
    } elsif ($lang && $lang ne 'Latin') {

      # Other non-Latin languages layer on top of English.
      my $baselang = $calledlang =~ /\.\.\/missa/ ? '../missa/English' : 'English';
      $base_sections = setupstring($baselang, $fname, 'resolve@' => RESOLVE_NONE);
    }

    # Get the top layer.
    $new_sections = setupstring_parse_file($fullpath, $basedir, $lang) if (-e $fullpath);

    if (%$new_sections) {

      # Fill in missing "pre-Urban hymn translations to avoid being overriden by Latin
      foreach my $seckey (keys(%{$new_sections})) {
        if ($seckey =~ /Hymnus(.*?) (.*)/) {
          unless (exists(${$new_sections}{"Hymnus$1M $2"})) {
            ${$new_sections}{"Hymnus$1M $2"} = ${$new_sections}{$seckey};
          }
        }
      }

      # Fill in the missing things from the layer below.
      unless (${$new_sections}{'__preamble'} eq ${$base_sections}{'__preamble'}) {
        ${$new_sections}{'__preamble'} .= "\n${$base_sections}{'__preamble'}";
      }
      ${$new_sections}{$_} ||= ${$base_sections}{$_} foreach (keys(%{$base_sections}));

      # Ensure consistency in ranking of Offices by always defaulting to Latin even if there is a Translation itself
      my @baserank = split(';;', ${$base_sections}{Rank});

      if (@baserank) {
        my @newrank = split(';;', ${$new_sections}{Rank});
        $baserank[0] = $newrank[0];
        ${$new_sections}{Rank} = join(';;', @baserank);
      }

    } else {
      $new_sections = $base_sections;
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
    while ($sections{'__preamble'} =~ /$inclusionregex/gc) {
      my $incl_fname .= "$1.txt";
      if ($fullpath =~ /$incl_fname/) { warn "Cyclic dependency in whole-file inclusion: $fullpath"; last; }
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
    foreach my $key ((exists $sections{'Rule'}) ? 'Rule' : (), sort(keys(%sections))) {
      if ($key !~ /Commemoratio|LectioE/i || $missa) {
        my $iiij = 0;
        my $iiiT = $sections{$key};

        while (
          $sections{$key} =~ s/$inclusionregex/
				get_loadtime_inclusion(\%sections, $basedir, $calledlang,
				$1,             # Filename.
				$2 ? $2 : $key, # Keyword.
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
  } else {

    # We're not resolving section inclusions, but we still need to parse
    # them to fill in implicit file- and section names, so that
    # daisy-chained references will work as expected.
    my ($fbasename) = ($fname =~ /(.*)\.txt/);

    foreach my $key (keys %sections) {
      $sections{$key} =~ s/$inclusionregex/
			'@' .
			($1 ? $1 : $fbasename) . ':' .   # Filename.
			($2 ? $2 : $key) .               # Keyword.
			($3 ? ":$3" : '') .              # Substitutions.
			"\n"
			/ge;
    }
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
# substitutes English if no $lang item, Latin if no English
# if $lang contains dash, the part before the last dash is taken as a fallback recursively (till something exists)
sub checkfile {
  my $lang = shift;
  my $file = shift;
  our $datafolder;

  if (-e "$datafolder/$lang/$file") {
    return "$datafolder/$lang/$file";
  } elsif ($lang =~ /-/) {
    my $temp = $lang;
    $temp =~ s/-[^-]+$//;
    return checkfile($temp, $file);
  } elsif ($lang =~ /english/i) {
    return "$datafolder/Latin/$file";
  } elsif (-e "$datafolder/English/$file") {
    return "$datafolder/English/$file";
  } else {
    return "$datafolder/Latin/$file";
  }
}

sub checklatinfile {
  my $file_ref = shift;
  my $file = $$file_ref;
  our $datafolder;
  my $txt = $file =~ s/\.txt$// ? '.txt' : '';

  -e "$datafolder/Latin/$file.txt"
    || $file =~ s/(Sancti|Tempora|Commune)(?:M|OP)(.*)/$1$2/
    && (-e "$datafolder/Latin/$file.txt")
    && ($$file_ref = "$file$txt");
}

1;
