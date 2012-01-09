#!/usr/bin/perl
use utf8;
# vim: set encoding=utf-8 :

# Name : Laszlo Kiss
# Date : 01-25-04
# dialog/setup related subs

$a=4;

#*** getini(file)
# loads and interprets .ini file
# the file consists of $var='value' lines
sub getini
{
    my $file = shift;   
    eval for do_read("$Bin/$file.ini")
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
    } else {$str .= "$_=\"$hash{$_}\",";}
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
	 if (!$item) {$item = '';}
     push(@b, $item);
  }
  return @b;
}   

#*** getdialogcolumnstring($name, $sep, $col)
# returns the array resolted from getdialogcolumn sub
# as a comma separated string
sub getdialogcolumnstring {
  my @c = getdialogcolumn(@_);
  my $c	= '';
  foreach (@c) {$c .= "\'$_\',";}
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
     if ($i == $ind) {$script[$i] = $elems[0] . '=\'' . $value . '\''; }
	   $script .= "$script[$i];;" 
  }
  $setup{$name} = $script;  
}

our %tempora =
(
    Nat => 'Nativitatis',
    Epi => 'Epiphaniæ',
    Quad => 'Quadrigesimæ',
    Pasc => 'Paschali',
    Pent => 'post Pentecosten',
);

our %subjects =
(
    rubricis    => sub { $version },
    rubrica     => sub { $version },
    tempore     => sub { $dayname[0] =~ /(\pL+)/; $tempora{$1} },
    missa       => sub { $missanumber },
    communi     => sub { {summpont => ($version =~ /1960/ || $version =~ /1955/ || $version =~ /Divino/)} },
);

our %predicates =
(
    1960        => sub { shift =~ /1960/ },
    tridentina  => sub { shift =~ /Trident/ },
    divino      => sub { shift =~ /Divino/ },
    monastica   => sub { shift =~ /Monastic/ },
    innovata    => sub { shift =~ /NewCal/i },
    innovatis   => sub { shift =~ /NewCal/i },
    paschali    => sub { shift =~ /Pasc/i },
    passionis   => sub { shift =~ /Quad/i && $dayname[0] =~ /(\d+)/ && $1 >= 5 }, # Temporary solution pending some replumbing.
    prima       => sub { shift == 1 },
    secunda     => sub { shift == 2 },
    tertia      => sub { shift == 3 },
    longior     => sub { shift == 1 },
    brevior     => sub { shift == 2 },
    'summorum pontificum'
                => sub { ${shift()}{summpont} },
);

# parse and evaluate a condition
sub vero($)
{
    my $condition = shift;
    my $vero;

    $condition =~ s/^\s*//;
    $condition =~ s/\s*$//;

    # The empty condition is _true_ : safer, since previously conditions were's used.
    return 1 unless $condition;

    # Remove noise words
    $condition =~ s/\b(est|in|cum|si|sed)\b//g;

    # aut binds tighter than et
    AUTEM: for ( split /\baut\b/, $condition )
    {
        for ( split /\bet\b/ )
        {
            s/^\s*(.*?)\s*$/$1/;
            my ($subject, $predicate) = split /\s+/, $_, 2;

            # Subject is optional: defaults to tempore
            ($predicate, $subject) = ($subject, 'tempore') if not $predicate;

            $predicate = $predicates{lc($predicate)};
            $subject = $subjects{lc($subject)};

            next AUTEM unless $subject && $predicate && &$predicate(&$subject());
        }
        print STDERR "vero=1\n";
        return ($vero=1);
    }
    print STDERR "vero=0\n";
    return ($vero=0);
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
     $script[$i] = $elems[0] . '=\'' . $a[$i+1] . '\'';
	   $script .= "$script[$i];;" 
  }
  $setup{$name} = $script;
}

#*** setupstring($basedir, $lang, $fname[, %params])
# Loads the database file from path "$basedir/$lang/$fname" and returns
# a reference to a hash whose keys are the section headings and whose
# values are their contents. If $params{'resolve@'} is true (which it
# is by default), then most @ directives are resolved and substituted.
sub setupstring($$$%)
{
  my ($basedir, $lang, $fname, %params) = @_;
  my $fullpath = "$basedir/$lang/$fname";
  our ($lang1, $lang2, $missa);
  
  # Expand @ references unless we've been told not to.
  $params{'resolve@'} = 1 unless (exists $params{'resolve@'});
  
  if ($lang1 && $lang2 && $lang =~ /($lang1|$lang2)/i)
  {
    # Fall back to other languages if the specified file doesn't exist.
    $fullpath = checkfile($1, $fname);
  }

  my @filelines = do_read($fullpath) or return '';
  
  # Regex for matching section headers.
  my $sectionregex = qr/^\s*\[([\pL\pN_ #-]+)\]/i;
  
  # Regex for matching conditionals, which we shall embed into our own
  # regexes for parsing lines.
  my $conditional_regex = conditional_regex();
  
  my $blankline_regex = /^\s*_?\s*$/;

  my %sections;
  my $key = '__preamble';
  my $use_this_section = 1;
  
  use constant 'COND_NOT_YET_AFFIRMATIVE' => 0;
  use constant 'COND_AFFIRMATIVE' => 1;
  use constant 'COND_DUMMY_FRAME' => 1;
  
  my (@conditional_stack, @conditional_offsets);
  
  push @conditional_stack, [COND_AFFIRMATIVE, SCOPE_NEST];
  push @conditional_offsets, -1;
  
  foreach my $line (@filelines)
  {
    if ($line =~ /$sectionregex(?:\s*$conditional_regex)?/o)
    {
      # If we have a conditional clause, it had better be true.
      my $section_condition = $3;
      if (!$section_condition || vero($section_condition))
      {
        # New section.
        $use_this_section = 1;
        $key = $1;
        $sections{$key} = [];
        
        # Reset conditional state.
        @conditional_stack = ([COND_AFFIRMATIVE, SCOPE_NEST]);
        @conditional_offsets = (-1);
      }
      else
      {
        $use_this_section = 0;
      }
    }
    elsif ($use_this_section)
    {
      # Check for a new condition.
      if ($line =~ /^\s*$conditional_regex\s*(.*)$/o)
      {
        my ($strength, $result, $backscope, $forwardscope) = parse_conditional($1, $2, $3);
        
        # Sequel.
        $line = $4;
        
        # If the parent conditional is not affirmative, then the new one
        # must break out of the nest, as it were.
        if (${$conditional_stack[-1]}[0] == COND_AFFIRMATIVE || $strength >= $#conditional_offsets)
        {
          if ($strength >= $#conditional_offsets)
          {
            @conditional_stack = ();
          }
          elsif ($strength >= $#conditional_offsets - $#conditional_stack)
          {
            $#conditional_stack = $#conditional_offsets - $strength - 1;
          }
          
          if ($result)
          {
            # Find the nearest insurmountable fence.
            my $fence = $#conditional_offsets >= $strength ?
                $conditional_offsets[$strength] :
                -1;
            
            # Handle the backward scope.
            if ($backscope == SCOPE_LINE)
            {
              # Remove preceding line.
              pop @{$sections{$key}} if $#{$sections{$key}} > $fence;
            }
            elsif ($backscope == SCOPE_CHUNK)
            {            
              # Remove preceding consecutive non-whitespace lines.
              pop @{$sections{$key}} while $#{$sections{$key}} > $fence && ${$sections{$key}}[-1] !~ /^\s*_?\s*$/;
              
              # Remove any whitespace lines.
              pop @{$sections{$key}} while $#{$sections{$key}} > $fence && ${$sections{$key}}[-1] =~ /^\s*_?\s*$/;
            }
            elsif ($backscope == SCOPE_NEST)
            {
              # Truncate output at the point to which we have to backtrack.
              $#{$sections{$key}} = $fence;
            }
          }
          
          # Having backtracked, null forward scope now behaves like a
          # satisfied conditional with nesting forward scope.
          if ($forwardscope == SCOPE_NULL)
          {
            $forwardscope = SCOPE_NEST;
            $result = 1;
          }
          
          if ($result)
          {
            # Remember where we encountered this conditional.
            $conditional_offsets[$_] = $#{$sections{$key}} foreach (0..$strength);
          }
          
          # Push dummy frame(s) onto the conditional stack to bring it
          # into sync with the strength.
          push @conditional_stack, [COND_DUMMY_FRAME, $forwardscope]
            while ($strength < $#conditional_offsets - $#conditional_stack - 1);
          
          # Push the new conditional frame onto the stack.
          push @conditional_stack,
            [$result ? COND_AFFIRMATIVE : COND_NOT_YET_AFFIRMATIVE,
             $forwardscope];
        }
        
        # Parse anything left over.
        $line ? redo : next;
      }
      
      # Handle escaped lines.
      $line =~ s/^~//;
      
      # Add line to array for later concatenation.
      push @{$sections{$key}}, "$line\n" if (${$conditional_stack[-1]}[0] == COND_AFFIRMATIVE);
      
      # Check to see whether we'll fall off the end of the current scope
      # after this line.
      while (${$conditional_stack[-1]}[1] == SCOPE_LINE ||
        (${$conditional_stack[-1]}[1] == SCOPE_CHUNK && $line =~ $blankline_regex))
      {
        do
        {
          pop @conditional_stack;
        } while(@conditional_stack && ${$conditional_stack[-1]}[0] == COND_DUMMY_FRAME);
        
        # If we've emptied the conditional stack, push an always-true,
        # unbounded frame to allow uniformity in testing.
        push @conditional_stack, [COND_AFFIRMATIVE, SCOPE_NEST] if (@conditional_stack == 0);
      }
    }
  }
  
  # Flatten sections.
  $sections{$_} = join '', @{$sections{$_}} foreach (keys %sections);
  
  my $inclusionregex = qr/^\s*\@
    ([^\n:]+)                     # Filename.
    (?::([^\n:]+?))?              # Optional keywords.
    [^\S\n\r]*                    # Ignore trailing whitespace.
    (?::(.*))?                    # Optional substitutions.
    $
    /mx;
  
  # Do whole-file inclusions. We do these regardless of whether the
  # 'resolve@' parameter is set.
  while (my ($incl_fname, undef, $incl_subst) = ($sections{'__preamble'} =~ /$inclusionregex/g))
  {
    my $incl_sections = get_file_for_inclusion($basedir, $lang, $incl_fname);
    $sections{$_} ||= ${$incl_sections}{$_} foreach (keys %{$incl_sections});
  }
  
  delete $sections{'__preamble'};
  
  # Resolve inclusions in sections if the caller requires it.
  if ($params{'resolve@'})
  {
    # Iterate over all sections, but make sure we do [Rule] first, if
    # it exists: we need to use the rule to work out some subsequent
    # substitutions.
    foreach my $key ((exists $sections{'Rule'}) ? 'Rule' : (), keys %sections)
    {
      if ($key !~ /Commemoratio/i || $missa)
      {
        $sections{$key} =~ s/$inclusionregex/
          get_loadtime_inclusion(\%sections, $basedir, $lang,
          $1,             # Filename.
          $2 ? $2 : $key, # Keyword.
          $3,             # Substitutions.
          $fname)         # Caller's filename.
          /gex;
      }
    }
  }
  
  return \%sections;
}

# Block for subs using the cache of inclusion files.
{
  my %inclusion_caches_by_version;
  
  #*** get_file_for_inclusion($basedir, $lang, $fname)
  # Loads the database file from path "$basedir/$lang/$fname" through
  # the inclusion cache.
  sub get_file_for_inclusion($$$)
  {
    my ($basedir, $lang, $fname) = @_;
    my $fullpath = "$basedir/$lang/$fname";
    our $version;
    
    $inclusion_caches_by_version{$version} = {} unless (exists $inclusion_caches_by_version{$version});
    
    # Get hash of cached files for this version.
    my $inclusioncache = $inclusion_caches_by_version{$version};
    
    return ${$inclusioncache}{$fullpath} if (exists ${$inclusioncache}{$fullpath});
    
    # Not in cache, so open it, add it to the cache and return it.
    my $fileref = setupstring($basedir, $lang, "$fname.txt", 'resolve@' => 0);
    
    if ($fileref)
    {
      ${$inclusioncache}{$fullpath} = $fileref;
      return $fileref;
    }
    else
    {
      return '';
    }
  }
}


#*** do_inclusion_substitutions(\$text, $substitutions)
# Performs substitutions on $text, where $substitutions contains the
# substitutions in the syntax of the @ directive.
sub do_inclusion_substitutions(\$$)
{
  my ($text, $substitutions) = @_;
  eval "\$\$text =~ s'$1'$2'$3" while ($substitutions =~ m{s/([^/]*)/([^/]*)/([gi]*)}g);
}


#*** get_loadtime_inclusion(\%sections, $basedir, $lang, $fname, $section, $substitutions, $callerfname)
# Retrieves the $section section of the file "$basedir/$lang/$fname"
# and performs the substitutions specified in $substitutions according
# to the syntax of the @ directive. \%sections is the file containing
# the reference to be expanded, for back references when necessary.
sub get_loadtime_inclusion(\%$$$$$$$)
{
  my ($sections, $basedir, $lang, $fname, $section, $substitutions, $callerfname) = @_;
  my $text;
  our $version;
  
  # Adjust offices of martyrs in Paschaltide to use the special common.
  if ($dayname[0] =~ /Pasc/i && !$missa && $callerfname !~ /C[23]/)
  {
    $fname =~ s/(C[23])(?!p)/$1p/g;
  }
  
  my $inclfile = get_file_for_inclusion($basedir, $lang, $fname);
  
  if ($version !~ /Trident/i && $section =~ /Gregem/i && (my ($plural, $class, $name) = papal_commem_rule(${$sections}{'Rule'})))
  {
    my ($itemkey) = ($section =~ /(.*?)\s*Gregem/);
    $text = papal_prayer($lang, $plural, $class, $name, $itemkey);
  }
  else
  {
    # Point to antiphon-and-versicleless version of the commemoration of
    # St Peter or St Paul under 1960 rubrics. TODO: Use data-file
    # conditionals to make this unnecessary.
    $section =~ s/Commemoratio4/Commemoratio4r/ if ($version =~ /1960/ && ${$sections}{'Rule'} =~ /sub unica conc/i);
      
    $text = ${$inclfile}{$section} if (exists ${$inclfile}{$section});
  }
  
  if ($text)
  {
    do_inclusion_substitutions($text, $substitutions);
    return $text;
  }
  
  return "$fname:$section is missing!";
}


#*** setuppar($par)
# returns the parameter variables evaluated
sub setuppar {
  my $par =shift;  
  $par =~ s/\;*\s*$//;
  $par =~ s/\;\;+\s*/\;\;/g; 
  my @par = split(';;', $par); 
  $par = "";
  my $s;
  for ($i = 0; $i < @par; $i++) {
	if (!$par[$i]) {next;} 
	my @a = split('~>', $par[$i]); 
	$a[1] = eval($a[1]);
	foreach $s (@a) {if (!$s && $s ne '0') {$s = '';} $par .= "$s~>";}
	$par =~ s/\~\>$/\;\;/;
  }
  $par =~ s/\;+\s*$//;
  return $par;
}

1;
