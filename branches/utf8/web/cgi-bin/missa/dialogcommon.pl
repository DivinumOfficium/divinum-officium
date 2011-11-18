#!/usr/bin/perl

#·ÈÌÛˆı˙¸˚¡…
# Name : Laszlo Kiss
# Date : 01-25-04
# dialog/setup related subs

$a=4;

#*** getini(file)
# loads and interprets .ini file
# the file consists of $var='value' lines
sub getini {
  my $file = shift;   
  if (my @initfiles = do_read("$Bin/$file.ini")) {
    foreach (@initfiles) {eval($_);}    
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

#*** setupstring($fname)
# loads $Bin/$fname file and 
#  returns a reference to %ps hash
# $fname.setup file consists of one or more items
#   each having the [itemname] headline an
#   one or more itemlines
#The hash key is itemname, values are strings
sub setupstring {
  my $fname = shift;  
  my $lang = '';           
  if ($lang1 && $lang2 && $fname =~ /($lang1|$lang2)\//i) {$fname = checkfile($1, $');}   
                                      
  if (my @a = do_read($fname)) {   
	 my %ps;		
     foreach (keys %ps) {delete($ps{$_});}
	 my $i;
	 my $key = '';
	 my $value = '';
	 for ($i = 0; $i <  @a; $i++) {
	   my $l = $a[$i];
	   $l= chompd($l);
	   #$l =~ s/^\s*//;
	   #$l=~ s/\s*$//;
	   #if (!$l) {next;}
     if ($l =~ /^\s*\[([a-z0-9·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€\_\- \#]+)\]/i) {
		  $l = $1;
	    if ($key) {$ps{$key} = $value;}
		  $key = $l;        
      $value = '';
      next;
	   }
	   $value .= "$l\n";
    } 
    if ($key) {$ps{$key} = $value; }
    return \%ps;
  } else {
	#print STDERR "$Bin/$fname cannot be opened\n";
	return "";
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

    
    
