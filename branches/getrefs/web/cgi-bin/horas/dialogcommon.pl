#!/usr/bin/perl

#αινσφυϊόϋΑΙ
# Name : Laszlo Kiss
# Date : 01-25-04
# dialog/setup related subs

$a=4;

#*** getini(file)
# loads and interprets .ini file
# the file consists of $var='value' lines
sub getini {
  my $file = shift;   
  if (open(INP, "$Bin/$file.ini")) {
    my @initfiles = <INP>;      
    close INP;
    foreach (@initfiles) { eval($_);}    
  }
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

  open(SETUP, $fullpath) or return '';
  my @filelines = <SETUP>;
  close SETUP;
  
  # Regex for matching section headers.
  my $sectionregex = qr/^\h*\[([^\]]+)\]\h*$/m;

  my %sections;
  my $key = '__preamble';
  
  foreach my $line (@filelines)
  {
    # Fix up line endings. TODO: Remove after UTF-8 support is merged.
    $line = chompd($line);
    
    if ($line =~ /$sectionregex/)
    {
      # New section.
      $key = $1;
    }
    else
    {
      # Add line to array for later concatenation.
      push @{$sections{$key}}, "$line\n";
    }
  }
  
  # Flatten sections.
  $sections{$_} = join '', @{$sections{$_}} foreach (keys %sections);
  
  my $inclusionregex = qr/^\s*\@
    ([^\n:]+)                     # Filename.
    (?:                           # Keywords, which are
      (?!:)|                      #   optional; but if present,
      :((?i:(?!Gregem)[^\n:])+?)) #   mustn't contain 'Gregem'.
    \h*                           # Ignore trailing whitespace.
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
    foreach my $key (keys %sections)
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
  my %inclusioncache;
  
  #*** get_file_for_inclusion($basedir, $lang, $fname)
  # Loads the database file from path "$basedir/$lang/$fname" through
  # the inclusion cache.
  sub get_file_for_inclusion($$$)
  {
    my ($basedir, $lang, $fname) = @_;
    my $fullpath = "$basedir/$lang/$fname";
    
    return $inclusioncache{$fullpath} if (exists $inclusioncache{$fullpath});
    
    # Not in cache, so open it, add it to the cache and return it.
    my $fileref = setupstring($basedir, $lang, "$fname.txt", 'resolve@' => 0);
    
    if ($fileref)
    {
      $inclusioncache{$fullpath} = $fileref;
      return $fileref;
    }
    else
    {
      return '';
    }
  }
}


#*** get_loadtime_inclusion(\%sections, $basedir, $lang, $fname, $section, $substitutions, $callerfname)
# Retrieves the $section section of the file "$basedir/$lang/$fname"
# and performs the substitutions specified in $substitutions according
# to the syntax of the @ directive. \%sections is the file containing
# the reference to be expanded, for back references when necessary.
sub get_loadtime_inclusion(\%$$$$$$)
{
  my ($sections, $basedir, $lang, $fname, $section, $substitutions, $callerfname) = @_;
  my $inclfile = get_file_for_inclusion($basedir, $lang, $fname);
  
  # Adjust offices of martyrs in Paschaltide to use the special common.
  if ($dayname[0] =~ /Pasc/i && !$missa && $callerfname !~ /C[23]/)
  {
    $fname =~ s/(C[23])(?!p)/$1p/g;
  }
  
  # Point to antiphon-and-versicleless version of the commemoration of
  # St Peter or St Paul under 1960 rubrics. TODO: Use data-file
  # conditionals to make this unnecessary.
  $section =~ s/Commemoratio4/Commemoratio4r/ if ($version =~ /1960/ && ${$sections}{'Rule'} =~ /sub unica conc/i);
    
  if (exists ${$inclfile}{$section})
  {
    my $text = ${$inclfile}{$section};
    
    # TODO: Substitutions.
    
    return $text;
  }
  else
  {
    return "$fname:$section is missing!";
  }
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
