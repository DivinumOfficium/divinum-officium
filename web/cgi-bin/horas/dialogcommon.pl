#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-25-04
# dialog/setup related subs
$a = 4;

#*** getini(file)
# loads and interprets .ini file
# the file consists of $var='value' lines
sub getini {
  my $file = shift;
  eval for do_read("$Bin/$file.ini");
}

#*** chompd($str)
# removes the newline characters from the end of the string
# returns the modified string
sub chompd {
  my $a = shift;
  chomp($a);
  $a =~ s/\r//g;
  return $a;
}

#*** printhas(\%hash, $sep)
#returns the referenced hash as key=value$sep string
sub printhash {
  my $hash = shift;
  my %hash = %$hash;
  my $flag = shift;
  my $str = "";

  foreach (sort keys %hash) {
    if ($flag) {
      my $value = $hash{$_};
      $value =~ s/\;+\s*$//;
      $str .= "$_;;;$value;;;";
    } else {
      $str .= "$_=\"$hash{$_}\",";
    }
  }
  return $str;
}

#*** getsetuppar($name) {
#returns $dialog{$name} value, evaluating the variables
sub getsetuppar {
  my $name = shift;
  my $par = $dialog{$name};
  return setuppar($par);
}

#*** getdialogcolumn($name, $sep, $col)
# returns the array of the $col-th column from $dialog{$name} hash element
# the hash value is cleared from newline characters and is split
# into and string array where the elements are separated by , comma
# Each string is split by $sep separator, and the $col-th element
# of this split is collected onto the returned array.
sub getdialogcolumn {
  my ($name, $sep, $col) = @_;
  my $str = $dialog{$name};
  $str =~ s/\n//g;
  my @a = split(',', $str);
  my @b = splice(@b, @b);

  foreach (@a) {
    my @c = split($sep, $_);
    my $item = $c[$col];
    if (!$item) { $item = ''; }
    push(@b, $item);
  }
  return @b;
}

#*** getdialogcolumnstring($name, $sep, $col)
# returns the array resolted from getdialogcolumn sub
# as a comma separated string
sub getdialogcolumnstring {
  my @c = getdialogcolumn(@_);
  my $c = '';
  foreach (@c) { $c .= "\'$_\',"; }
  $c =~ s /\,$//;
  return $c;
}

#*** setsetupvalue($name, $ind, $value)
# set $value to the $ind-th line of $setup{$name} hash item
sub setsetupvalue {
  my $name = shift;
  my $ind = shift;
  my $value = shift;
  my $script = $setup{$name};
  $script =~ s/\n\s*//g;
  my @script = split(';;', $script);
  $script = "";

  for ($i = 0; $i < @script; $i++) {
    my $si = $script[$i];
    $si =~ s/\=/\~\>/;
    my @elems = split('~>', $si);
    if ($i == $ind) { $script[$i] = $elems[0] . '=\'' . $value . '\''; }
    $script .= "$script[$i];;";
  }
  $setup{$name} = $script;
}

sub get_tempus_id {

  our @dayname;
  our ($day, $month, $day_of_week);
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
      : 'post Epiphaniam'
    : /^Quadp(\d)/ && ($1 < 3 || $dayofweek < 3) ? 'Septuagesimæ'
    : /^Quad(\d)/ && $1 < 5 ? 'Quadragesimæ'
    : /^Quad/ ? 'Passionis'
    : /^Pasc0/ ? 'Octava Paschæ'
    : /^Pasc(\d)/ && ($1 < 5 || ($1 == 5 && ($dayofweek < 3 || (!$vesp_or_comp && $dayofweek == 3))))
    ? 'post Octavam Paschæ'
    : /^Pasc6-(5|6)/ ? 'post Octavam Ascensionis'
    : /^Pasc(\d)/ && $1 < 7 ? 'Octava Ascensionis'
    : /^Pasc/ ? 'Octava Pentecostes'
    : 'post Pentecosten';
}

# Returns the name of the day for use as a subject in conditionals.
sub get_dayname_for_condition {
  our ($day, $month, $day_of_week);
  our $hora;
  my $vesp_or_comp = ($hora =~ /Vespera/i) || ($hora =~ /Completorium/i);
  return 'Epiphaniæ' if ($month == 1 && ($day == 6 || ($day == 5 && $vesp_or_comp)));
  return '';
}
our %subjects = (
  rubricis => sub {$version},
  rubrica => sub {$version},
  tempore => \&get_tempus_id,
  missa => sub {$missanumber},
  communi => sub { {summpont => ($version =~ /1960/ || $version =~ /1955/ || $version =~ /Divino/)} },
  'die' => \&get_dayname_for_condition,
);
our %predicates = (
  tridentina => sub { shift =~ /Trident/ },
  monastica => sub { shift =~ /Monastic/ },
  innovata => sub { shift =~ /NewCal/i },
  innovatis => sub { shift =~ /NewCal/i },
  paschali => sub { shift =~ /Paschæ|Ascensionis|Octava Pentecostes/i },
  'post septuagesimam' => sub { shift =~ /Septua|Quadra|Passio/i },
  prima => sub { shift == 1 },
  secunda => sub { shift == 2 },
  tertia => sub { shift == 3 },
  longior => sub { shift == 1 },
  brevior => sub { shift == 2 },
  'summorum pontificum' => sub { ${shift()}{summpont} },
);

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

#*** setsetup($name, $value1, $value2 ...)
# set the values into $setup{$name} hash item
sub setsetup {
  my @a = @_;
  my $name = $a[0];
  my $script = $setup{$name};
  $script =~ s/\n\s*//g;
  my @script = split(';;', $script);
  $script = "";

  for ($i = 0; $i < @script; $i++) {
    my $si = $script[$i];
    $si =~ s/\=/\~\>/;
    my @elems = split('~>', $si);
    $script[$i] = $elems[0] . '=\'' . $a[$i + 1] . '\'';
    $script .= "$script[$i];;";
  }
  $setup{$name} = $script;
}
our %setupstring_caches_by_version;

# Constants specifying which @-directives to resolve when calling
# &setupstring.
use constant {
  RESOLVE_NONE => 0,
  RESOLVE_WHOLEFILE => 1,
  RESOLVE_ALL => 2
};

#*** setupstring($basedir, $lang, $fname, %params)
# Loads the database file from path "$basedir/$lang/$fname" through
# the cache. Inclusions are performed according to the value of
# $params{'resolve@'}. If omitted, the default is RESOLVE_ALL.
sub setupstring($$$%) {

  my ($basedir, $lang, $fname, %params) = @_;
  my $fullpath = "$basedir/$lang/$fname";
  our ($lang1, $lang2, $missa);
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
      $base_sections = setupstring($basedir, 'Latin', $fname, 'resolve@' => RESOLVE_NONE);
    } elsif ($lang =~ /-/) {

      # If $lang contains dash, the part before the last dash is taken as a new fallback
      my $temp = $lang;
      $temp =~ s/-[^-]+$//;
      $base_sections = setupstring($basedir, $temp, $fname, 'resolve@' => RESOLVE_NONE);
    } elsif ($lang && $lang ne 'Latin') {

      # Other non-Latin languages layer on top of English.
      $base_sections = setupstring($basedir, 'English', $fname, 'resolve@' => RESOLVE_NONE);
    }

    # Get the top layer.
    $new_sections = setupstring_parse_file($fullpath, $basedir, $lang) if (-e $fullpath);

    if (%$new_sections) {

      # Fill in the missing things from the layer below.
      ${$new_sections}{'__preamble'} .= "\n${$base_sections}{'__preamble'}";
      ${$new_sections}{$_} ||= ${$base_sections}{$_} foreach (keys(%{$base_sections}));
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
      my $incl_sections = setupstring($basedir, $lang, $incl_fname, 'resolve@' => RESOLVE_NONE);
      $sections{$_} ||= ${$incl_sections}{$_} foreach (keys %{$incl_sections});
    }
    delete $sections{'__preamble'};
  }

  if ($params{'resolve@'} == RESOLVE_ALL) {

    # Iterate over all sections, resolving inclusions. We make sure we
    # do [Rule] first, if it exists: we need to use the rule to work
    # out some subsequent substitutions.
    foreach my $key ((exists $sections{'Rule'}) ? 'Rule' : (), keys %sections) {
      if ($key !~ /Commemoratio/i || $missa) {
        1 while $sections{$key} =~ s/$inclusionregex/
          get_loadtime_inclusion(\%sections, $basedir, $lang,
          $1,             # Filename.
          $2 ? $2 : $key, # Keyword.
          $3,             # Substitutions.
          $fname)         # Caller's filename.
          /ge;
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
    $sections{$key} = join "\n",
      (process_conditional_lines(@{$sections{$key}}), '');
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
      my ($strength, $result, $backscope, $forwardscope) = parse_conditional($1, $2, $3);

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
sub get_loadtime_inclusion(\%$$$$$$$) {
  my ($sections, $basedir, $lang, $ftitle, $section, $substitutions, $callerfname) = @_;
  my $text;
  our $version;

  # Adjust offices of martyrs in Paschaltide to use the special common.
  if ($dayname[0] =~ /Pasc/i && !$missa && $callerfname !~ /C[23]/) {
    $ftitle =~ s/(C[23])(?!p)/$1p/g;
  }

  # Load the file to resolve the reference; if none specified, it's a
  # self-reference.
  my $inclfile = $ftitle ? setupstring($basedir, $lang, "$ftitle.txt", 'resolve@' => RESOLVE_WHOLEFILE) : $sections;

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

#*** setuppar($par)
# returns the parameter variables evaluated
sub setuppar {
  my $par = shift;
  $par =~ s/\;*\s*$//;
  $par =~ s/\;\;+\s*/\;\;/g;
  my @par = split(';;', $par);
  $par = "";
  my $s;

  for ($i = 0; $i < @par; $i++) {
    if (!$par[$i]) { next; }
    my @a = split('~>', $par[$i]);
    $a[1] = eval($a[1]);

    foreach $s (@a) {
      if (!$s && $s ne '0') { $s = ''; }
      $par .= "$s~>";
    }
    $par =~ s/\~\>$/\;\;/;
  }
  $par =~ s/\;+\s*$//;
  return $par;
}
1;
