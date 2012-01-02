#!/usr/bin/perl
# vim: set encoding=utf-8 :
use utf8;
# áéíóöõúüûÁÉ  ‡
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office

$a = 1;

#*** ordo()
# collects and prints the ordo
# first let specials to fill the chapters
# then break the text into units (separated by double newline)
# resolves the references (formatting characters, prayers hash references and subs) 
#and prints the result
sub ordo
{
             
$tlang = ($lang1 !~ /Latin/) ? $lang1 : $lang2;    
#???%translate = %{setupstring($datafolder, $tlang, "Ordo/Translate.txt")}; 

$savesolemn = $solemn;
if ($winner =~ /Quad6-[456]/i) {$solemn = 1;}
$column = 1;
if ($Ck) {$version = $version1; setmdir($version); precedence();}
@script1 = getordinarium($lang1, $command); 
@script1 = specials(\@script1, $lang1);		
$column = 2;
if ($Ck) {$version = $version2; setmdir($version); precedence();}
@script2 = getordinarium($lang2, $command);	  
@script2 = specials(\@script2, $lang2);  
$solemn = $savesolemn; 
table_start();
             

$ind1 = $ind2 = 0;
$searchind = 0;

ante_post('Ante');

if ($rule =~ /Full text/i) {
  @script1 = ();
  @script2 = ();
  $rule = 'Prelude';
}

if ($rule =~ /prelude/i) {
   my $str = $winner{Prelude};
   $str = norubr1($str);
   unshift(@script1, split('_', $str));
   $str = $winner2{Prelude};
   $str = norubr1($str);
   unshift(@script2, split('_', $str));
}

if ($rule =~ /Post Missam/i) {
   my $str = $winner{'Post Missam'};
   $str = norubr1($str);
   push(@script1, split('_', $str));
   $str = $winner2{'Post Missam'};
   $str = norubr1($str);
   push(@script2, split('_', $str));
}

while ($ind1 < @script1 || $ind2 < @script2) {
  ($text1, $ind1) = getunit(\@script1, $ind1);
  ($text2, $ind2) = getunit(\@script2, $ind2); 
  
  $column = 1;
  if ($Ck) {$version = $version1;}

  $text1 =  resolve_refs($text1, $lang1);  
  
  $text1 =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;  

  if ($lang1 =~ /Latin/i && $version =~ /1960/) {$text1 = jtoi($text1);}
  if ($text1  && $text1 !~ /^\s+$/) {setcell($text1, $lang1);} 

  if (!$only) {
    $column = 2;        
    if ($Ck) {$version = $version2;}
    $text2 = resolve_refs($text2, $lang2);    
 	$text2 =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;

    if ($lang2 =~ /Latin/i && $version =~ /1960/) {$text2 = jtoi($text2);}
    if ($text2  && $text2 !~ /^\s+$/) {setcell($text2, $lang2);}  
 }
}

ante_post('Post');

table_end();

if ($column == 1) {$searchind++;}
}



#*** getunits(\@s, $ind)
# break the array into units separated by double newlines
# from $ind  to the returned new $ind
sub getunit {
  my $s = shift;
  my @s = @$s;
  my $ind = shift;
  my $t = '';
  my $plen = 1;

  while ($ind < @s) {
    my $line = chompd($s[$ind]);
    $ind++;
    if ($line && !($line =~ /^\s+$/)) {$t .= "$line\n"; next;}
    if (!$t) {next;}
    last;
  }    
  if ($dayname[0] !~ /Pasc/i) {$t =~ s/\(Alleluia.*?\)//ig;}
  else {$t =~ s/\((Alleluia.*?)\)/$1/ig;}  
  return ($t, $ind);
}

#*** resolve_refs($text_of_block, $lang)
#resolves $name &name references and special characters 
#retuns the to be listed text
sub resolve_refs {
  my $t = shift;        
  my $lang = shift;	 
  my @t = split("\n", $t); 	

  my $t = '';	
 				
  if ($t[0] =~ /(omit|elmarad)/i) {$t[0] =~ s/^\s*\#/\!x\!/;}
  else {$t[0] =~ s/^\s*\#/\!\!/;}


  #cycle by lines 
  my $it;
  for ($it = 0; $it < @t; $it++) {
    $line = $t[$it];

    #$ and & references
    if ($line !~ /(callpopup|rubrics)/i && $line =~ /[\$\&]/) {     #??? was " /[\#\$\&]/)   
      $line =~ s/\.//g;   
      $line =~ s/\s+$//;
      $line =~ s/^\s+//;   
      #prepares reading the part of common w/ antiphona
	    if ($line =~ /psalm/ && $t[$it -1] =~ /^\s*Ant\. /i) {   
	      $line = expand($line, $lang, $t[$it - 1]);  
	    } else {$line = expand($line, $lang);}  
                                           
    if ((!$Tk && $line !~ /\<input/i) || ($Tk && $line !~ /\% .*? \%/))
       {$line = resolve_refs($line, $lang);}  #for special chars
    } 
	  #cross
    $line = setcross($line);   

    #red prefix
	  if ($line =~ /^\s*(R\.|V\.|S\.|P\.|M\.|A\.|O\.|C\.|D\.|Benedictio\.* |Absolutio\.* |Ant\. |Ps\. )/) {
   	    my $h = $1;
        my $l = $';
        if ($h =~ /(Benedictio|Absolutio)/) {	 
	      my $str = $1;		   
          if ($lang !~ /Latin/i) {$str = $translate{$str};} 
		  $h =~ s/(Benedictio|Absolutio)/$str/; 
	    }
        $line = setfont($redfont, $h) . $l;
      }   
    #Quad6 Gospels
	 if ($winner =~ /Quad6/) {
	  my $rest = $line;
	  $line = '';
	  while ($rest =~ /( [A-Z]\. )/  && $` !~ /,,\s*$/) {
	    $rest = $';
	    $line .= $` . setfont($redfont, $1); 
      }
	  $line .= $rest;
    }

	  #consecration words
	  if ($line =~ /\s*\!\[\:(.*?)\:\]/) {
	    $line = $1;
		my $cfont = $redfont;
		$cfont =~ s/red/blue/i;
		$line = setfont($cfont, $line);
	  
	  } elsif ($line =~ /^\s*\!\!\!/) { 
	    $line = $';
		my $cfont = $redfont;
		$cfont =~ s/red/black/i;
		$line = setfont($cfont, $line);
	  
	  #small omitted comment
	  } elsif ($line =~ /^\s*\!x\!\!/) {
	    $l = $';
		$line = setfont($smallfont, $l); 
	  }

	  #small omitted title
	  elsif ($line =~ /^\s*\!x\!/) {
	    $l = $';
		$line = setfont($smallblack, $l);
	  }
	  
	  #large chapter title
	  elsif ($line =~ /^\s*\!\!/) {  
      my $l = $';              
      my $suffix = '';
      if ($l =~ /\{.*?\}/) {
        $l =~ s/(\{.*?\})//; 
  	    $suffix = $1;
		    $suffix = setfont($smallblack, $suffix); 
      }
      $line = setfont($largefont, $l) . " $suffix\n";   
    } 
	
	#red line
	elsif ($line =~ /^\s*\!/) {
      $l = $';
      $line = setfont($redfont, $l);
    }

	  #first letter red 
	  if ($line =~ /^\s*r\.\s*/) {
	    $line = $';
	    $line = setfont($largefont, substr($line, 0, 1)) . substr($line, 1);
	  }
	
	  # first letter initial
	  if ($line =~ /^(\s*)v\.\s*/ || $line =~ /(\{\:.*?\:\}\s*)\v.\s*/) {
	    my $prev = $1;
      $line = $';
	    $line = $prev . setfont($initiale, substr($line, 0, 1)) . substr($line, 1);
	  }

  #connect lines marked by tilde, or but linebrak
	if ($line =~ /\~/) {$line =~ s/\~//g; $t .= "$line ";}
	else {$t .= "$line<BR>\n";}
  }  #line by line cycle ends

  #removes occasional double linebreaks
  $t =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;  
  $t =~ s/<\/P>\s*<BR>/<\/P>/g;   
  return $t;
 }

 #*** sub expand($line, $lang, $antline)
 # for & references calls the sub
 # $ references are filled from Ordo/Prayers file
 # antline to handle redding the beginning of psalm is same as antiphona
 # returns the expanded text or the link
 sub expand {
   my $line = shift;          
   my $lang = shift;
   my $antline = shift;     
   					 
   my $title = "";


   #returns the link or text for & references
   if ($line =~ /^\s*\&/) {  
     $line = $';   			 
     
     #actual expansion for & references
	 #is the beginning of psalm the same as antiphona
	 if ($antline) {   
	   $antline =~ s/^\s*Ant\. //i;
	   $line =~ s/\)\s*$//;
	   $line = "&$line,\"$lang\",\"$antline\");";	 
	 }
	 #sub with parameter
	 elsif ($line =~ /\)\s*$/) {$line = "&$`,\"$lang\");";}
     #other subs
	 else {$line = "&$line(\"$lang\");";}   

	 my $t = eval($line); 
     return $t;
   }
                     

   #actual expansion for $ references
   my %prayer = %{setupstring($datafolder, $lang, 'Ordo/Prayers.txt')};
   $line =~ s/\$//;
   $line =~ s/\s*$//; 
   my $text = $prayer{$line};     
   $line =~ s/\n/\<BR\>\n/g;
   $line =~ s/\<BR\>\n$/\n/;
   return $text;
}

#*** Alleluia($lang)
# return the text Alleluia or Laus tibi
sub Alleluia { 
  my $lang = shift;  
  my %prayer = %{setupstring($datafolder, $lang, 'Ordo/Prayers.txt')};
  my $text = $prayer{'Alleluia'};   
  my @text = split("\n", $text); 
  $text = $text[0];
  #if ($dayname[0] =~ /Pasc/i) {$text = "Alleluia, alleluia, alleluia";}   
  return $text;
}

#*** Benedicamus_Domino
# adds Alleluia, alleluia for Pasc0
sub Benedicamus_Domino {
  my $lang = shift;    
  my %prayer = %{setupstring($datafolder, $lang, 'Ordo/Prayers.txt')};
  my $text = $prayer{'Benedicamus Domino'}; 
  if ($dayname[0] !~ /Pasc0/i) {return $text;}
  my @text = split("\n", $text);       
  return "$text[0]. Alleluia, alleluia\n$text[1]. Alleluia, alleluia\n";
}


sub depunct {
  my $item = shift;
  $item =~ s/[\.\,\:\?\!\"\'\;\*]//g;
  $item =~ s/[áÁ]/a/g;
  $item =~ s/[éÉ]/e/g;
  $item =~ s/[íí]/i/g;
  $item =~ s/[óöõÓÖÔ]/o/g;
  $item =~ s/[úüûÚÜÛ]/u/g;	  
  $item =~ s/æ/ae/g;
  return $item;
}



#*** translate($name)
# return the translated name (called only for column2 if necessary)
sub translate { 
  my $name = shift;	

  my $n = $name;             
  my $prefix = '';
  if ($n =~ s/(\$|\&)//) {$prefix = $&;}
  $n =~ s/^\n*//;
  $n =~ s/\n*$//; 
  $n =~ s/\_/ /g;            
  if (!exists($translate{$n})) {return $name;}
  $n = $translate{$n}; 
  if ($name !~ /(omit|elmarad)/i) {$n = $prefix.$n;}
  $n =~ s/\n*$//;
  return "$n";
}


#*** getordinarium($lang, $command)
# returns the full pathname of ordinarium for the language and hora
sub getordinarium {
  my $lang = shift; 
  
  my @script;
  if ($Propers && (@script = do_read("$datafolder/Latin/Ordo/Propers.txt"))) {
	return @script;  
  }
  
  my $fname = 'Ordo';
  if ($version =~ /(1967|Newcal)/i) {$fname = 'Ordo67';}
  if ($NewMass) {$fname = ($column == 1) ? $ordos{$version1} : $ordos{$version2}; }
  $fname = checkfile($lang, "Ordo/$fname.txt"); 
  if (@script = do_read($fname)) {
    $_ = "$_\n" for @script;
  } else {$error = "$fname cannot open!";}
  return @script;
}
    
sub columnsel {
  my $lang = shift;
  if ($Ck || $NewMass) {return ($column == 1) ? 1 : 0;}
  return ($lang =~ /$lang1/i) ? 1 : 0;
}
