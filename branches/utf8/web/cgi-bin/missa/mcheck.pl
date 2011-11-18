#!/usr/bin/perl
# αινσφυϊόϋΑΙ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office

$a = 1;

sub check { 
  my $text = shift;
  @t = @$text;
  my @r;
                              
  my $rname = ($version =~ /monastic/i) ? 'rulerM' : 'ruler';
  if (@r = do_read("$datafolder/$rname.txt")) {
      $_ = "$_\n" for @r;
  } else {return "$datafolder/ruler.txt cannot open";}

  my $errs = '';                      
  my $i  = 0;
					 

 $allkeys = '';
 $rulekey = '';
 while ($i < @t) {
    my $line = $t[$i];  
	  $i++;
	  if ($line =~ /\[([a-z0-9 ]+)\]/i) {	  
      $key = $1;     
      $allkeys .= " $key ";
      my $j;
	    my $rkey = '';
	    my $rules = '';
      for ($j = 0; $j < @r; $j++) {
        my $rline = $r[$j];
        if ($rline =~ /\:/) {$rkey = $`; $rules = $';}
        if ($key =~ /^$rkey$/i) {last}
      }	 
      if ($j < @r) {
        if ($i > 2 && $t[$i-2] !~ /^\s*$/) {$errs .= "Unseparated key: <B>$key</B>\n";}
        if ($i > 3 && $t[$i-3] =~ /^\s*$/) {$errs .= "Double separation lines  before <B>$key</B>\n";}
        my @u = splice(@u, @u);
        while ($i < @t && $t[$i] !~ /\[[a-z0-9 ]+\]/i) {
	        if ($t[$i] !~ /^\s*$/) {push(@u, $t[$i]);}
		      $i++;
	      } 
        if ($rules) {$errs .= checkunit(\@u, $rules);}
        if ($key =~ /Rule/i) {$rulekey = "@u";}
      } else {
        if ($key =~ /^[a-z0-9 ]+$/i) {$errs .= "Extra key <B>$key</B>\n";}
        while ($i < @t && $t[$i] !~ /\[[a-z0-9 ]+\]/i) {$i++;}
      }
    }
  }
  return $errs;
}

sub checkunit {
  my $u = shift;
  my @u = @$u;
  my $rules = shift;	 

  my $e = '';         

  my @sr = split('~>', $rules);
  foreach $item (@sr) {       
    if ($item =~ /^([0-9]+)\s*(plus|minus)*\s*line/i) { 
      my $num = $1;
      my $plus = $2;
      my $u = @u;
      my $flag = 0; 
      if ($item =~ /\=/) {
	      @item = split(',', chompd($')); 
	      for ($k = 0; $k < @u; $k++) {
	        if ($u[$k] =~ /^\@/) {$flag = 1;  last;}
          if ($u[$k] !~ /^$item[$k]/) {$e .= "<B>$key</B> line $k does not starts with $item[$k]\n";}
	      }
	    }
      if (!$flag) {
        if ($u < $num && $plus !~ /minus/i) {$e .= "<B>$key</B> only $u must be $num lines\n"; next;}
        if ($u > $num && $plus !~ /plus/i) {$e .= "<B>$key</B> is $u lines must be only $num\n"; next;}
      }
        
    } elsif ($item =~ /^([0-9]+)\s*(plus|minus)*\s*unit/) {  
       my $num = $1;
       my @up = split(';;', @u[0]);
       my $u = @up;
       if (@up < $num) {$e .= "<B>$key</B> only $u units, must be greater that $num\n";}
       next;
      
    } elsif ($item =~ /\s*(.*?)\s+inside/i) {
       my $ch = $1;
       my $flag = 0;
       foreach (@u) {
         my $lin = $_;
         if ($lin =~ /$ch/i || $lin =~ /\@/) {$flag = 1;}
       }
       if (!$flag) {$e .= "<B>$key</B> does not have required $ch\n";}
       next;
    }
  }
          
  return $e;
}         
