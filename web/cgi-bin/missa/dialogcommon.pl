#!/usr/bin/perl
# vim: set encoding=utf-8 :
use utf8;

#áéíóöõúüûÁÉ
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
);

our %predicates =
(
    1960        => sub { shift =~ /1960/ },
    innovata    => sub { shift =~ /NewCal/i },
    innovatis   => sub { shift =~ /NewCal/i },
    paschali    => sub { shift =~ /Pasc/i },
    prima       => sub { shift == 1 },
    secunda     => sub { shift == 2 },
    tertia      => sub { shift == 3 },
    longior     => sub { shift == 1 },
    brevior     => sub { shift == 2 },
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
            my ($subject, $predicate) = split;

            # Subject is optional: defaults to tempore
            ($predicate, $subject) = ($subject, 'tempore') if not $predicate;

            $predicate = $predicates{$predicate};
            $subject = $subjects{$subject};

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

#*** setupstring($fname)
# loads $Bin/$fname file and 
#  returns a reference to %ps hash
# $fname.setup file consists of one or more items
#   each having the [itemname] headline an
#   one or more itemlines
#The hash key is itemname, values are strings
# This allows conditional keys: [itemname] ( si condition )
# and conditional lines: ( si condition ) content
# conditions tested using vero($)

sub setupstring($)
{
    my $fname = shift;  
    my $lang = '';           

    if ($lang1 && $lang2 && $fname =~ /($lang1|$lang2)\//i)
    {
        $fname = checkfile($1, $');
    }   
                                      
    if (my @a = do_read($fname))
    {
        my %ps = ();

        my $key = '';
        my $value = '';
        my $key_condition = '';
        for my $l ( @a )
        {
            if ($l =~ /^\s*\[([\pL0-9\_\- \#]+)\]/i)
            {
                my $new_key = $1;

                # Stash the previous one if any
                $ps{$key} = $value if $key && vero($key_condition);

                # Check for condition on this key
                if ( $l =~ /\]\s*\((.*)\)/ )
                {
                    $key_condition = $1;
                    print STDERR "\$new_key = $new_key\n";
                    print STDERR "\$key_condition = $key_condition\n";
                }
                else
                {
                    $key_condition = '';
                }

                $key = $new_key;
                $value = '';
                next;
            }
            elsif ( $l =~ /^\(([^()]*)\)(.*)$/ )
            {
                $value .= "$2\n" if vero($1)
            }
            else
            {
                $value .= "$l\n"
            }
        } 
        $ps{$key} = $value if $key && vero($key_condition);
        return \%ps;
    }
    else
    {
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
