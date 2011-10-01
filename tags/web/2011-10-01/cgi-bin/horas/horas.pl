#!/usr/bin/perl
# áéíóöõúüûÁÉ  ‡
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office

$a = 1;

#*** horas($hora)
# collects and prints the officium for the given $hora
# first let specials to fill the chapters
# then break the text into units (separated by double newline)
# resolves the references (formatting characters, prayers hash references and subs) 
#and prints the result
sub horas
{
    $command = shift;
    $hora = $command;	

    our $canticum = 0;
    our $reciteindex = 0;
    our $recitelimit = 0;
                       
    $tlang = ($lang1 !~ /Latin/) ? $lang1 : $lang2;    
    %translate = %{setupstring("$datafolder/$tlang/Psalterium/Translate.txt")}; 

    %chant = %{setupstring("$datafolder/Latin/Psalterium/Chant.txt")};

    $column = 1;
    if ($Ck) {$version = $version1; setmdir($version); precedence();}
    @script1 = getordinarium($lang1, $command);
    @script1 = specials(\@script1, $lang1);	

    $column = 2;
    if ($Ck) {$version = $version2; setmdir($version); precedence();}
    @script2 = getordinarium($lang2, $command);	  
    @script2 = specials(\@script2, $lang2);  

    $expandind = 0;
    if (!$Tk && !$Hk) {$expandnum = strictparam('expandnum');}

    table_start();

    $ind1 = $ind2 = 0;
    $searchind = 0;

    if ($version !~ /(Monastic|1570|1955|1960)/i) {ante_post('Ante');}
    else {$searchind++;}

    while ($ind1 < @script1 || $ind2 < @script2)
    {
        $expandind++;
        ($text1, $ind1) = getunit(\@script1, $ind1);
        ($text2, $ind2) = getunit(\@script2, $ind2); 

        $column = 1;
        $version = $version1 if $Ck;
        $text1 =  resolve_refs($text1, $lang1);  

        # Suppress (Alleluia) during Quadrigesima.
        if ( $dayname[0] =~ /Quad/i && !Septuagesima_vesp() )
        {
            $text1 =~ s/[(]*allel[uú][ij]a[\.\,]*[)]*//ig;
        } 

        $text1 =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;  

        if ($lang1 =~ /Latin/i) {$text1 = jtoi($text1);}
        if ($text1  && $text1 !~ /^\s+$/) {setcell($text1, $lang1);} 

        if (!$only)
        {
            $column = 2;        
            if ($Ck) {$version = $version2;}
            $text2 = resolve_refs($text2, $lang2);    
            if ($dayname[0] =~ /Quad/i && !Septuagesima_vesp())
            {
                $text2 =~ s/[(]*allel[uú][ij]a[\.\,]*[)]*//ig;
            } 

            $text2 =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;
            if ($lang2 =~ /Latin/i) {$text2 = jtoi($text2);}
            if ($text2  && $text2 !~ /^\s+$/) {setcell($text2, $lang2);}  
        }
    }

    if ($version !~ /(Monastic|1570|1955|1960)/) {ante_post('Post');}
    else {$searchind++;}

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
  if ($dayname[0] !~ /Pasc/i) {$t =~ s/\(Allel[uú][ij]a.*?\)//isg;}
  else {$t =~ s/\((Allel[uú][ij]a.*?)\)/$1/isg;}

  return ($t, $ind);
}

#*** resolve refs($text_of_block, $lang)
#resolves $name &name references and special characters 
#retuns the to be listed text
sub resolve_refs {
  my $t = shift;        
  my $lang = shift;	 
  my @t = split("\n", $t); 	

  my $t = '';	
				
  #handles expanding for skeleton
  if ($t[0] =~ /#/) {
    if ($expandind == $expandnum) {$expandflag = 1;}
	  else {$expandflag = 0;} 
  }
  if ($expand =~ /skeleton/ && !$expandflag) {	 
    if ($t[0] =~ /\#/) {return setlink($t[0], $expandind, $lang); }
    else {return "";}
  }
  if ($t[0] =~ /(omit|elmarad)/i) {$t[0] =~ s/^\s*\#/\!\!\!/;}
  else {$t[0] =~ s/^\s*\#/\!\!/;}


  #cycle by lines 
  my $it;
  for ($it = 0; $it < @t; $it++) {
    $line = $t[$it];

    #$ and & references
    if ($line =~ /[\#\$\&]/) {   
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
	  if ($line =~ /^\s*(R\.br|R\.|V\.|Ant\.|Benedictio\.* |Absolutio\.* )/) {
   	    my $h = $1;
        my $l = $';
        if ($h =~ /(Benedictio|Absolutio)/) {	 
	      my $str = $1;		   
          if ($lang !~ /Latin/i) {$str = $translate{$str};} 
		  $h =~ s/(Benedictio|Absolutio)/$str/; 
	    }
        $line = setfont($redfont, $h) . $l;
      }   
    
	  #small omitted title
	  if ($line =~ /^\s*\!\!\!/) {
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
	  if ($expand =~ /skeleton/i) {$line .= linkcode1();}
    } 
	
	#red line
	elsif ($line =~ /^\s*\!/) {
      $l = $';
      $line = setfont($redfont, $l);
    }
    if ($line =~ /\/:(.*?):\//) {$line = $` .setfont($smallfont, $1) . $';} 

	  #first letter red 
	  if ($line =~ /^\s*r\.\s*/) {
	    $line = $';
	    $line = setfont($largefont, substr($line, 0, 1)) . substr($line, 1);
	  }
	
	  # first letter initial
	  if ($line =~ /^(\s*)v\.\s*/ || $line =~ /(\{\:.*?\:\}\s*)v\.\s*/) {
	    my $prev = $1;
        $line = $';
	    $line = $prev . setfont($initiale, substr($line, 0, 1)) . substr($line, 1);
	  }

  #connect lines marked by tilde, or but linebrak
	if ($line =~ /\~\s*$/) {$line =~ s/\~\s*$//g; $t .= "$line ";}
	else {$t .= "$line<BR>\n";}


  }  #line by line cycle ends

  #removes occasional double linebreaks
  $t =~ s/\<BR\>\s*\<BR\>/\<BR\>/g;  
  $t =~ s/<\/P>\s*<BR>/<\/P>/g;   
  return $t;
 }

 #*** sub expand($line, $lang, $antline)
 # for & references calls the sub
 # $ references are filled from Psalterium/Prayers file
 # antline to handle redding the beginning of psalm is same as antiphona
 # returns the expanded text or the link
 sub expand {
   my $line = shift;          
   my $lang = shift;
   my $antline = shift;     
   					 
   my $title = "";

   #returns the popup link if not all mode $ for $references
   if ($expand !~ /all/i && $line =~ /^\s*\$/) 
     {return setlink($line, 0, $lang);}

   #returns the link or text for & references
   if ($line =~ /^\s*\&/) {  
     $line = $';   			 
     
     # &[A-Z] popup link if not all
	   if ($expand !~ /all/i && ($line =~ /^[A-Z]/ || $line =~ /^pater_noster/)) 
       {return setlink("&$line", 0, $lang);}
	 
     # &[a-z] popup links in not all or not psalm
	 elsif ($expand =~ /nothing/i) {return setlink("&$line", 0, $lang);}
                                            
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
   my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
   $line =~ s/\$//;
   $line =~ s/\s*$//; 
   my $text = $prayer{$line};     
   $line =~ s/\n/\<BR\>\n/g;
   $line =~ s/\<BR\>\n$/\n/;
   return $text;
}

#*** Pater noster($lang)
# returns the text of the prayer without Amen, setting V. and R. to the last 2 lines 
sub pater_noster {
  $lang = shift;   
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  my $text = $prayer{'Pater_noster1'};
  return $text;

  my @text = split("\n", $text);
  $text[5] =~ s/\~//;
  $text[6] =~ s/\~//;
  $text[6] = "V. $text[6]";
  $text[7] = "R. $text[7]";  
  $text[7] =~ s/~//;
  $text[8] =~ s/[AÁ]men[\.]*//;
  $text = '';
  foreach (@text) {$text .= "$_\n";}    
  return $text; 
}

#*** teDeum($lang)
# returns the text of the hymn
sub teDeum {
  my $lang = shift;
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  my $text = ($version =~ /1570/ && exists($prayer{'Te DeumO'})) ? $prayer{'Te DeumO'} : $prayer{'Te Deum'};
  $text = "\n_\n!Te Deum\n" . $text;
  return $text; 
}
   

#*** Alleluia($lang)
# return the text Alleluia or Laus tibi
sub Alleluia { 
  my $lang = shift;  
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  my $text = $prayer{'Alleluia'};   
  my @text = split("\n", $text); 
  if ($dayname[0] =~ /Quad/i && !Septuagesima_vesp()) {$text = $text[1];}
  else {$text = $text[0];}
  #if ($dayname[0] =~ /Pasc/i) {$text = "Alleluia, alleluia, alleluia";}   
  return $text;
}

sub Septuagesima_vesp {
  if ($dayofweek == 6 && $winner{Rank} =~ /Dominica Septuagesima/ && $hora =~ /Vespera/i) 
    {return 1;}
  return 0;;
}
  

#*** Gloria
# returns the text or the omit notice
sub Gloria {
  my $lang = shift;	 
  if ($dayname[0] =~ /Quad6/i && $dayofweek > 3 && 
    !($dayofweek == 6 && $hora =~ /(Vespera|Completorium)/i)) {return "";}
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  if ($rule =~ /Requiem gloria/i) {return $prayer{Requiem};}
  return $prayer{'Gloria'};    
}

sub Gloria1 {   #* responsories
  my $lang = shift;	 
  if ($dayname[0] =~ /(Quad5|Quad6)/i && $winner !~ /Sancti/i && $rule !~ /Gloria responsory/i)
    {return "";}
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  return $prayer{'Gloria1'};    
}

sub Gloria2 { #*Invitatorium
  my $lang = shift;	 
  if ($dayname[0] =~ /(Quad[56])/i) {return "";}
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  if ($rule =~ /Requiem gloria/i) {return $prayer{Requiem};}
  return $prayer{'Gloria'};    
}



#*** Dominus_vobiscum
#returns the text of the 'Domine exaudi' for non priests
sub Dominus_vobiscum {     
  my $lang = shift;
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  my $text = $prayer{'Dominus'};
  my @text = split("\n", $text);       
  if ($priest) {$text = "$text[0]\n$text[1]"}
  else {  
    if (!$precesferiales) {$text = "$text[2]\n$text[3]"}
	else {$text = "$text[4]";}
    $precesferiales = 0;
  }	
  return $text;
}

sub Dominus_vobiscum1 { #* prima after preces
  my $lang = shift;  
  if (preces('Dominicales et Feriales')&& !$priest) {$precesferiales = 1; }
  return Dominus_vobiscum($lang);
}

sub Dominus_vobiscum2 { #* officium defunctorum
  my $lang = shift;  
  if (!$priest) {$precesferiales = 1; }   
  return Dominus_vobiscum($lang);
}


#*** Benedicamus_Domino
# adds Alleluia, alleluia for Pasc0
sub Benedicamus_Domino {
  my $lang = shift;    
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  my $text = $prayer{'Benedicamus Domino'}; 
  if (Septuagesima_vesp()) {$text = $prayer{'Benedicamus Domino1'};}
  if ($dayname[0] !~ /Pasc0/i || $hora !~ /(Laudes|Vespera)/i) {return $text;}
  my @text = split("\n", $text);       
  return "$text[0]. Alleluia, alleluia\n$text[1]. Alleluia, alleluia\n";
}

#*** antiphona_finalis
#return the text for the appropriate time
sub antiphona_finalis {	 
  my $lang = shift;
  my %ant = %{setupstring("$datafolder/$lang/Psalterium/Mariaant.txt")};	
  my $t = '';  
  if ($dayname[0] =~ /adv/i && $winner{Rank} !~ /In Nativitate Domini/i) {$t = $ant{'Advent'};}
  elsif ($dayname[0] =~ /Nat/i || ($month == 12 && $day > 23) || 
     $month == 1 || ($month == 2 && $day < 2) || 
     ($month == 2 && $day == 2 && $hora !~ /Completorium/i)) 
     {$t = $ant{'Nativiti'};} 
  elsif (($month == 2 || $month == 3 || $dayname[0] =~ /Quad/i) && $dayname[0] !~ /Pasc/i) 
    {$t = $ant{'Quadragesimae'};}
  elsif ($dayname[0] =~ /Pasc/) {$t = $ant{'Paschalis'};}
  else {$t = $ant{'Postpentecost'};}  
  return ($t);
}

#*** psalm($chapter, $lang)  or
# psalm($chapter, $fromverse, $toverse, $lang)
# selects the text, attaches the head, 
# sets red color for the introductory comments
# returns the visible form 
sub psalm {
  my @a = @_;			        
                    
  my ($num, $lang, $antline);	

  if (@a < 4) {$num = $a[0]; $lang = $a[1]; $antline = $a[2];}
  else {$num = "$a[0]($a[1]-$a[2])"; $lang = $a[3]; $antline = $a[4];}	  

  if ($ck) {
    if ($lang =~ $lang1) {$version = $version1}
	else {$version = $version2;}
  }

  my $nogloria = 0; 
  if ($num =~ /^-/) {
    $num = $';
    if (($version =~ /Trident/i && $num =~ /(62|148|149)/) || 
      ($version =~ /Monastic/i && $num =~ /115/)) {$nogloria = 1;}
  }		  
  															
  #$psalmfolder = ($accented =~ /plain/i) ? 'psalms' : 'psalms1';
  $psalmfolder = 'psalms1';   
  
  $fname=checkfile($lang, "$psalmfolder/Psalm$a[0].txt"); 
  if ($version =~ /1960/ && $fname =~ /226/) {$fname =~ s/226/226r/;}  
  if ($version =~ /1960/ && $num !~ /\(/ && $dayname[0] =~ /Nat/i && $fname =~ /88/) 
    {$fname =~ s/88/88r/;}      
  if ($version =~ /1960/ && $num !~ /\(/ && $month == 8 && $day == 6 && $fname =~ /88/) 
    {$fname =~ s/88/88a/;}      

  my $str = 'Psalmus';                        
  if ($lang !~ /Latin/i) {$str = translate($str);} 

  my $pnum;
  if ($column == 1) {	
    $psalmnum1++;   
    $pnum = setfont($smallblack, " [" . $psalmnum1 . "]");
  } else {
    $psalmnum2++;   
    $pnum = setfont($smallblack, " [" . $psalmnum2 . "]");
  }
  my $t = '';
  
  if ($num > 150 && $num < 300 && open(INP, $fname)) {
     my $line = <INP>;
     close INP;          
     if ($line =~ /\s*([a-z]+\s+[a-z_]+) /i) {$t = setfont($redfont, $1) . settone(1) . $pnum;}   
  }
  if (!$t) {$t = setfont($redfont,"$str $num") . settone(1) . $pnum; }	

  
  if ($rule =~ /Special Matutinum Incipit/i && $num == 86) {return special_epi_invit();}

  my $psnum = 0;
  my $v1 = 1;
  my $v2 = 1000;
  
  if ($num =~ /\[(.*?)\]/) {
    $num = $1;
    if ($dayname[0] !~ /(adv|quad)/i) {return;}
  }   
  
  if ($num =~ /^\s*([0-9]+)/) {$psnum = $1;}
  else {return $t;}

  if ($num =~ /\((.*?)\)/) { 
     my @v = split('-', $1);
     $v1 = $v[0];
     $v2 = $v[1];   
  }
						
  $fname = checkfile($lang, "$psalmfolder/Psalm$psnum.txt");
  if ($version =~ /1960/ && $fname =~ /226/) {$fname =~ s/226/226r/;}  
  if ($version =~ /1960/ && $num !~ /\(/ && $dayname[0] =~ /Nat/i && $fname =~ /88/) 
    {$fname =~ s/88/88r/;}      
   if ($version =~ /1960/ && $num !~ /\(/ && $month == 8 && $day == 6 && $fname =~ /88/) 
    {$fname =~ s/88/88a/;}      

  if (open(INP, $fname)) {
	my $first = ($antline) ? 1 : 0;
	while ($line = <INP>) {   
	  
	  if ($line =~ /^\s*([0-9]+)\:([0-9]+)/) {$v = $2;}
      elsif ($line =~ /^\s*([0-9]+)/) {$v = $1;}
      if ($v < $v1) {next;}
      if ($v > $v2) {last;}
      $lnum = '';
	  if ($line =~ /^([0-9]*[\:]*[0-9]+)/) {$lnum = setfont($smallfont, $1); $line = $';}  
	  

      my $rest;
      if ($line =~ /(\(.*?\))/) {
	    $rest = $';
	    $before = $`;
        $this = $1;
        if ($before =~ /^\s*([a-z])/i) {$before = uc($1) . $';}
        $line = $before . setfont($smallfont,($this));
      }	else {$rest = $line; $line = '';}
	  
	   
      $rest =~	s/[ ]*//;

	  if ($version !~ /monastic/i && $first && $rest && $rest !~ /^\s*$/) {
	    $rest = getantcross($rest, $antline); 
		$first = 0;
	  }

      if ($lang =~ /magyar/i) {$rest = setasterisk($rest);}

      if ($rest =~ /^\s*([a-z])/i) {$rest = uc($1) . $';}
      
      $t .= "\n$lnum $line $rest";       
    }
    close INP;	 
    $t .= "\n";
    if ($num != 210 && !$nogloria) {$t .= "\&Gloria\n";}  

    $t .= settone(0); 
    return $t;
  } else {return "$t$datafolder/$lang/$psalmfolder/Psalm$psnum.txt not found";}
}


#*** getantcross($psalmline, $antline)
# set a	‡ sign if psalmline matches antline
# eliminating accents and pintuation 
sub getantcross {
  my $psalmline = shift;
  my $antline = shift;

  my @psalmline = split(' ', $psalmline);
  my @antline = split(' ', $antline);
  my $pind = 0;
  my $aind = 0;
  $psalmline1 = $psalmline;
  $psalmline = '';
  $antline = ''; 

  while ($aind < @antline) {
    if ($pind >= @psalmline) { return "$psalmline1 " . setfont($redfont, '‡');}
	my $item1 = $psalmline[$pind];
	$pind++;
	$item1 = depunct($item1);
	if (!$item1) {next;}
	my $item2 = $antline[$aind];
	$aind++;
	$item2 = depunct($item2);
	if (!$item2) {$pind--; next;}  
	if ($item1 !~ /$item2/) {return $psalmline1;}
	$psalmline .= " $psalmline[$pind-1]";
	next;
  }
  $psalmline .= ' ' . setfont($smallfont, '‡ ');
  while ($pind < @psalmline) {$psalmline .= " $psalmline[$pind]"; $pind++;}
  return $psalmline;
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

sub settone {  	
  if (((!$Hk && $Tk < 3) || $voicecolumn !~ /chant/i  || ($hora =~ /Matutinum/i && 
    !$chantmatins )) && !$notes) {return '';} 
			
  my $flag = shift;	
  if (!$flag) {return " {::} ";}
  
  my $ind = 0;
  my $i = 0;
  my @parray;
  my $tone = '';

  if ($version =~ /Monastic/i) {
    if ($hora =~ /Matutinum/i) {return '';}
    if ($hora =~ /(Laudes|Vespera)/i) {
      if ($flag != 2 && $psalmnum1 == 0) {return ' {:p9d:} ';}
	  @parray = split("\n", $chant{"Monastic $hora"});
      my @a = split(',', $parray[$dayofweek]);
      my $j = ($flag == 2) ? -1 : $psalmnum1 - 1;
      return " {:p$a[$j]:} ";
    
    } else {
      @parray = split("\n", $chant{"Monastic Horas"});
      my $j = ($hora =~ /Prima/i) ? 0 : ($hora =~ /Tertia/i) ? 1 : ($hora =~ /Sexta/i) ? 2 :
        ($hora =~ /Nona/i) ? 3 : 4;
      my @a = split(',', $parray[$j]);
      return " {:p$a[$dayofweek]:}";
    }

  } elsif ($hora =~ /matutinum/i) {
	@parray = ($dayname[0] =~ /Pasc/i) ? split("\n", $chant{'Matins Pasc'}) :
	   ($dayname[0] =~ /Adv/i && $winner =~ /tempora/i && $dayofweek == 0) ?
	   split("\n",$chant{'Matins Adv'}) : split("\n", $chant{'Matins'});
    $i = $dayofweek;
	if ($version =~ /Trident/i && $winner{Rank} =~ /(ex|vide) C([0-9]+)/i) {
	  my $n = $2;  
	  if ($n != 10) {
	    if ($dayname[0] =~ /Pasc/i) {$n = 'p';}	 	
		@parray = split("\n", $chant{"Matins C$n"});	
		$i = 0;	
	  }
	}
	$ind = $psalmnum1 - 1;
	if ($dayname[0] =~ /Pasc/i) {$ind = floor($ind / 3);}
    elsif ($version =~ /Trident/i && @parray > 1) {
        my @tridind = ($dayofweek == 0) ? (0,0,0,0,1,1,1,1,2,2,2,2,3,4,5,6,7,8) : 
          (0,0,1,1,3,3,4,4,6,6,7,7);
        $ind = $tridind[$ind];
    }

  } else {
    my $d = ($rule =~ /psalmi dominica/i) ? 0 : $dayofweek;
    @parray = split("\n", $chant{"Day$d"});   
    $i = ($hora =~ /laudes/i) ? 0 : ($hora =~ /vespera/i) ? 3 : 2;
    if ($hora =~ /laudes/ && $laudes == 2 && $flag == 1) {$i++;}
    $ind = ($flag == 1) ? $psalmnum1 -1 : 5;
    my @tridind = (0,1,2,2,3,4,4,4,5);
    my @tridind0 = (0,0,0,0,3,4,4,4,5);  
    if ($version =~ /Trid/i && $hora =~ /Laudes/i) 
      {$ind = ($flag > 1) ? 5 : ($d > 0) ? $tridind[$ind] : $tridind0[$ind];} 
  }
  
  my @a = split(',', $parray[$i]);
  my $j = ($hora =~ /(laudes|vespera|matutinum)/i) ? $ind : ($hora =~ /Prima/i) ? 0 :
     ($hora =~ /Tertia/i) ? 1 : ($hora =~ /Sexta/i) ? 2 : ($hora =~ /Nona/i) ? 3 : 4;
  $tone = $a[$j];  
  return ($flag == 2) ? " {:pc$tone:} " : " {:p$tone:} ";
}



sub special_epi_invit {
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my $ant = "Ant. $w{InvitE}";
  my $ant2 = $ant[1];
	my $t = "_\n";
  							  
  $fname = checkfile($lang, "Psalterium/Invitatorium1.txt");
  if (open(INP, $fname)) {
    my @a = <INP>;
    close INP;
    
    foreach $item (@a) {
      if ($item =~ /\$ant2/i) {$item = "$ant2";}
      elsif ($item =~ /\$ant/i) {$item = "$ant";}
      $t .= $item;
    }
  } else {$error .= "$fname cannnot open";}
  return $t;
}

#*** setlink($name, $ind, $lang
# sets a link for expand a skeleton chapter line or to call a popup
sub setlink {
  my $name = shift;
  my $ind = shift;
  my $lang = shift;	
  my $disabled = ($name =~ /(omit|elmarad)/i) ? 'DISABLED' : ''; 
  my $smallflag = ($name =~ /(ante|post)/i) ? 1 : 0;  
                                    
  $name =~ s/\s*$//;  
  my $suffix = '';			 
  if ($name =~ /\{.*?\}/) {
    $name =~ s/(\{.*?\})//; 
  	$suffix = $1;
    $suffix = setfont($smallblack, $suffix); 
  }    													 
  if ($name =~ /\&Gloria/ && $rule =~ /Requiem gloria/i) {$name = '$Requiem';}
                             
  if (($name =~ /\&Gloria$/i && $dayname[0] =~ /Quad6/i && $dayofweek > 3 &&
   !($version !~ /(1955|1960)/i && $dayofweek == 6 && $hora =~ /(Vespera|Completorium)/i)) ||
    ($name =~ /\&Gloria[12]/i && $dayname[0] =~ /(Quad[56])/i)
        && $winner !~ /Sancti/i && $rule !~ /Gloria responsory/i)  {
     $name = 'Gloria omittitur';    
     if ($name !~ /^\#/ && $lang !~ /Latin/i) {$name = translate($name);} 
     return setfont($smallfont, $name);
  }

  my $t = linkcode($name, $ind, $lang, $disabled);
  
  if ($name =~ /\&Gloria1/i) {$name = "\&gloria";}
  if ($name =~ /\&Gloria2/i) {$name = "\&Gloria";}

  
  if (($name =~ /&Dominus_vobiscum1/i && !$priest  && !preces('Dominicales et Feriales')) ||
  ($name =~ /&Dominus_vobiscum2/i && !$priest )) {
	$name = 'secunda Domine exaudi omittitur'; 
  if ($name !~ /^\#/ && $lang !~ /Latin/i) {$name = translate($name);} 
	return setfont($smallfont, $name);
  }
  elsif ($name =~ /&Dominus/i && !$priest) {$name = '&Domine exaudi';}
  elsif ($name =~ /&Dominus/) {$name =~ s/[12]//;}
  elsif ($name =~ /&Alleluia/i && $dayname[0] =~ /Quad/i && !Septuagesima_vesp()) 
    {$name = '&Laus tibi';}
   
   

  if ($name =~ /(Deus in adjutorium|Indulgentiam|Te decet)/i) {$suffix = " + $suffix";}
  if ($name =~ /Domine labia/i) {$suffix = " ++ $suffix";}
  
  if ($name =~ /\&Benedicamus_Domino/i && (($dayname[0] =~ /(Pasc0)/i && 
     $hora =~ /(Laudes|Vespera)/i) || Septuagesima_vesp())) {  
     if ($name !~ /^\#/ && $lang !~ /Latin/i) {$name = translate($name);} 
     $name .= '. Alleluia, alleluia';  
  }                                   
  elsif ($name !~ /^\#/ && $lang !~ /Latin/i) {$name = translate($name);} 
                             

  $name .= $suffix;	 

  $name =~ s/[\#\$\&]//g;                             
  
  my $after = '';
  if (!$Tk && $name =~ /\<input/i) {$name = $`; $after = "$&$'";}
  if ($Tk && $name =~ /\{\^/) {$name = $`; $after = "$&$'";} 
  
  if ($disabled || $smallflag) {$name = setfont($smallblack, $name)}
  elsif ($expand =~ /skeleton/i) {$name = setfont($largefont, substr($name, 0, 1)) . setfont($redfont, substr($name,1));}
  else  {$name = setfont($largefont, substr($name, 0, 1)) . substr($name, 1); }
  return "$t$name$after";
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

#*** ant_Benedictus($num, $lang)
# returns the antiphona $num=1 = for beginning =2 for end
sub ant_Benedictus {  
  my $num = shift;
  my $lang = shift;      
  
  if ($ck) {
    if ($lang =~ $lang1) {$version = $version1}
	else {$version = $version2;}
  }

  my ($a, $c) = getantvers('Ant', 2, $lang);  
  if ($month == 12 && ($day == 21 || $day == 23) && $winner =~ /tempora/i) {
    my %v = %{setupstring("$datafolder/$lang/Psalterium/Major Special.txt")};
    $a = $v{"Adv Ant $day" . "L"};    
  }
  if ($dayname[0] !~ /Pasc/i) {$a =~ s/\(Allel[uú][ij]a.*?\)//isg;}
  else {$a =~ s/\((Allel[uú][ij]a.*?)\)/$1/isg;}
  
  my @a = split('\*', $a);
  if ($num == 1 && $duplex < 3 && $version !~ /1960/) {return "Ant. $a[0]";}
  elsif ($num == 1) {return "Ant. $a"}
  else {"Ant. {::}$a";}
}

#*** ant_Magnificat($num, $lang)
# returns the antiphon for $num=1 the beginning, or =2 for the end
sub ant_Magnificat {     
  my $num = shift;   #1=before, 2=after
  my $lang = shift;

  if ($ck) {
    if ($lang =~ $lang1) {$version = $version1}
	  else {$version = $version2;}
  }
								      
  my $v = ($version =~ 1960 && $winner =~ /Sancti/i && $rank < 5) ? 3 : $vespera;
  if ($version =~ /1960/ && $commune =~ /C[45]a/i && $rank < 5) {$v = 1;}
                   
  my ($a, $c) = getantvers('Ant', $v, $lang);   
  if ($version !~ /Trident/i && $winner{Rule} =~ /OPapaC=([a-z ]*)\;/i && $v == 3) {
    my $martyr = $1;
	  my $name = $2;
	  my %c = %{setupstring("$datafolder/$lang/$communename/C4.txt")};
	  $a = $c{'Ant 9'};	  
  }
  
  if ($month ==12 && ($day > 16 && $day < 24) && $winner =~ /tempora/i) {
    my %v = %{setupstring("$datafolder/$lang/Psalterium/Major Special.txt")};
	  $a = $v{"Adv Ant $day"};
    $num = 2;
  }
  if ($dayname[0] !~ /Pasc/i) {$a =~ s/\(Allel[uú][ij]a.*?\)//isg;}
  else {$a =~ s/\((Allel[uú][ij]a.*?)\)/$1/isg;}

  my @a = split('\*', $a);
  if ($num == 1 && $duplex < 3 && $version !~ /1960/) {return "Ant. $a[0]";}
  elsif ($num == 1) {return "Ant. $a"}
  else {"Ant. {::}$a" ;}
}

#*** canticum($psnum, $lang)
# returns the formatted text of Benedictus, Magnifificat or Nunc dimittis ($num=1-3)
sub canticum {
  my $psnum = shift;
  my $lang = shift;   
  $psnum += 230;

  my $w = '';
  #$psalmfolder = ($accented =~ /plain/i) ? 'psalms' : 'psalms1';   
  $psalmfolder = 'psalms1';   

  my $fname = checkfile($lang, "$psalmfolder/Psalm$psnum.txt");    
  if (open(INP, $fname)) {
    my @w = <INP>;
    close INP;
    $w[0] =~ s/\!//;  
    $w .= setfont($redfont, chompd(shift(@w))) . settone(2) . "\n"; 
    foreach $item (@w) {
      if ($item =~ /^([0-9]+\:)*([0-9]+) /) {
        my $rest = $';
        my $num = "$1$2";
        $item = setfont($smallfont, $num) . " $rest";   
      }
      $w .= "$item";
    }
  return $w;
  } else {return "$w $datafolder/$lang/$psalmfolder/Psalm$psnum.txt not found";}

}

#*** martyrologium($lang)
#returns the text of the martyrologium for the day
sub martyrologium {
  my $lang = shift;

  my $t = setfont($largefont, "Martyrologium ") . setfont($smallblack, "(anticipated)") . "\n_\n";
  #<FONT SIZE=1>(anticipated)</FONT>\n_\n";
  
  my $a = getweek(1);    
  my @a = split('=', $a);    
  $a = "$a[0]-$nextdayofweek";  
  $a =~ s/\s//g;                      
  my %a = %{setupstring("$datafolder/$lang/Martyrologium/Mobile.txt")}; 
  if ($version =~ /1570/ && $lang =~ /Latin/i) 
    {%a = %{setupstring("$datafolder/$lang/Martyrologium1/Mobile.txt")};} 
  if ($version =~ /(1955|1960)/ && $lang =~ /Latin/i) 
    {%a = %{setupstring("$datafolder/$lang/Martyrologium2/Mobile.txt")};} 

  my $mobile = '';
  my $hd = 0;
  if (exists($a{$a})) {$mobile = "$a{$a}\n";}  
  if ($month == 10 && $dayofweek == 6 && $day > 23 && $day < 31 && exists($a{'10-DU'})) {$mobile = $m{'10-DU'};}

  if ($a =~ /Pasc0\-1/i) {$hd = 1;} 
  if ($winner{Rank} =~ /ex C9/i && exists($a{'Defuncti'})) {$mobile = $a{'Defuncti'}; $hd = 1;} 
  #if ($month == 12 && $day == 25 && exists($a{'Nativity'})) {$mobile = $a{'Nativity'}; $hd = 1;}
  if ($hd == 1) {$t = "v. $mobile" . "_\n$t"; $mobile = '';}

  $fname = nextday($month, $day, $year); 
  my ($m, $d) = split('-', $fname);
  my $y = ($m == 1 && $d == 1) ? $year + 1 : $year;

  if ($version =~ /1570/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1/$fname.txt"))
    {$fname = "$datafolder/Latin/Martyrologium1/$fname.txt";}
  elsif ($version =~ /(1955|1960)/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium2/$fname.txt"))
    {$fname = "$datafolder/Latin/Martyrologium2/$fname.txt";}
  else {$fname = checkfile($lang, "Martyrologium/$fname.txt");}  
  if (open (INP, "$fname")) {
    my @a = <INP>;
    close INP;
	my ($luna, $mo) = ($year >= 1900 && $year < 2200) ? gregor($m, $d, $y, $lang) : luna($m, $d, $y, $lang);
	if ($lang =~ /Latin/i) {$a[0] =~ s/\n/ /g; $a[0] .=  $luna;}
	else {
	  if ($a[0] =~ /U[p]+on.*?$mo[, ]*/i) {$a[0] = "$luna $'";}
	  elsif ($a[1] =~ /U[p]+on.*?$mo[, ]*/i) {$a[1] = "$luna $'";}
	  else {unshift(@a, ($luna, "_\n"));}
   }
		
	my $prefix = "v. ";
    foreach $line (@a) {
      if (length($line) > 4) {$t .= "$prefix$line";}
      else {$t .= $line;}
      $prefix = "r. ";
      if ($mobile && $line =~ /\_/) {$t .= "$prefix$mobile"; $mobile = '';}
    }
  }

  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  $t .= $prayer{Conclmart};
  return $t;
}

sub gregor {
 my ($month, $day, $year, $lang) = @_;  
 my $golden = $year % 19;  
 my @epact = (29,10,21,2,13,24,5,16,27,8,19,30,11,22,3,14,25,6,17);
 my @om = (30,29,30,29,30,29,30,29,30,29,30,29,30, 100);
 my @firstmonth =(2,21,10,29,18,7,26,15,4,23,12,1,20,9,28,17,6,25,14); 
 
 
 if ($golden==18) {$om[12] = 29;} else {$om[12] = 30;}
 if (leapyear($year) && ($month > 2 || ($month == 2 && $day > 24))) {$om[1] = 30;}
 if ($golden == 0) {unshift(@om, 30);}
 if ($golden == 8 || $golden == 11) {unshift(@om, 30);}
 
 my $t = date_to_days($day, $month-1, $year);
 my @d = days_to_date($t);
 my $yday = $d[7];
 my $num = - $epact[$golden] -1;
 my $i = 0; 
 while ($num < $yday) {
  $num += $om[$i];
  $i++;
 }
 my $gday;  
 $num -= $om[$i-1];
 $gday = $yday - $num;

 my @ordinals = ('prima', 'secunda', 'tertia', 'quarta', 'quinta', 'sexta', 'septima', 'octava', 'nona', 'decima',
   'undecima', 'duodecima', 'tertia decima', 'quarta decima', 'quinta decima', 'sexta decima', 'septima decima',
   'duodevicesima', 'undevicesima', 'vicesima', 'vicesima prima', 'vicesima secunda', 'vicesima tertia', 
   'vicesima quarta', 'vicesima quinta', 'vicesima sexta', 'vicesima septima', 'vicesima octava', 'vicesima nona',
   'tricesima');
 my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December');
 my $sfx1 = ($day > 3 && $day < 21) ? 'th' : (($day %10) == 1) ? 'st' : (($day % 10) == 2) ? 'nd' : (($day % 10)== 3) ? 'rd' : 'th';
 my $sfx2 = ($gday > 3 && $gday < 21) ? 'th' : (($gday %10) == 1) ? 'st' : (($gday % 10) == 2) ? 'nd' : (($gday % 10)== 3) ? 'rd' : 'th';
 $day = $day + 0; 
 if ($lang =~ /Latin/i) {return ("Luna $ordinals[$gday-1] Anno $year Domini\n", ' '); }
 else {return ("$months[$month - 1] $day$sfx1 anno Domini $year The $gday$sfx2 Day of Moon", $months[$month-1]);}

 #return sprintf("%02i", $gday);
}

sub luna {
  my ($month, $day, $year, $lang) = @_;
  my $epact2008=23;
  my $edays = date_to_days(1,0,2008);
  my $lunarmonth = 29.53059;
  my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July',
  'Augustus', 'September', 'October', 'November', 'December');
  my @ordinals = ('prima', 'secunda', 'tertia', 'quarta', 'quinta', 'sexta', 'septima', 'octava', 'nona', 'decima',
   'undecima', 'duodecima', 'tertia decima', 'quarta decima', 'quinta decima', 'sexta decima', 'septima decima',
   'duodevicesima', 'undevicesima', 'vicesima', 'vicesima prima', 'vicesima secunda', 'vicesima tertia', 
   'vicesima quarta', 'vicesima quinta', 'vicesima sexta', 'vicesima septima', 'vicesima octava', 'vicesima nona',
   'tricesima');

  my $sfx1 = (($day %10) == 1) ? 'st' : (($day % 10) == 2) ? 'nd' : (($day % 10)== 3) ? 'rd' : 'th';
  
  my $t = (date_to_days($day, $month-1, $year) - $edays + $epact2008) ;
  $mult = floor($t / $lunarmonth); 
  $dist = floor($t - $mult * $lunarmonth -.25);
  if ($dist <= 0) {$dist = 30 + $dist;}
  my $sfx2 = (($dist %10) == 1) ? 'st' : (($dist % 10) == 2) ? 'nd' : (($dist % 10)== 3) ? 'rd' : 'th';

  $day = $day + 0; 
  if ($lang =~ /Latin/i) {return ("Luna $ordinals[$dist-1] Anno $year\n", ' '); }
  else {return ("$months[$month - 1] $day$sfx1 anno Domini $year. The $dist$sfx2 Day of Moon.", $months[$month-1]);}
}

#*** laudes()
# not used
sub laudes {   
  return "skip";
}

#*** special($name, $lang)
# used for 11-02 office
sub special {
  my $name = shift;
  my $lang = shift;
  my $r = '';
                      
  %w = (columnsel($lang)) ? %winner : %winner2;     
  if (exists($w{$name})) {$r = "!Special $name\n_\n" . chompd($w{$name}) . "\n";}
  else {$r = "$name is missing";}
  return $r;
}


#*** getordinarium($lanf, $command)
# returns the ordinarium for the language and hora
sub getordinarium {
  my $lang = shift;
  my $command = shift;
  
  my @script = splice(@script, @script);
  my $fname = checkfile($lang, "Ordinarium/$command.txt");
  if ($command =~ /Matutinum/i && $rule =~ /Special Matutinum Incipit/i) 
    {$fname =~ s/\.txt/e\.txt/;}
  if ($command =~ /(Prima|Completorium)/i && $dayname[0] =~ /Pasc/) {$fname =~ s /\.txt/p\.txt/;}
  if ($command =~ /(Tertia)/i && $dayname[0] =~ /Pasc7/) {$fname =~ s /\.txt/p\.txt/;}
  if ($version =~ /(1955|1960)/) {$fname =~ s/\.txt/1960\.txt/;}
  if ($version =~ /trident/i && $hora =~ /(laudes|vespera)/i && $version !~ /monastic/i) 
    {$fname =~ s/\.txt/Trid\.txt/;}
  if ($version =~ /Monastic/i) {$fname =~ s/\.txt/M\.txt/;}
  if (open(INP, $fname)) {
    @script = <INP>;
    close INP;
  } else {$error = "$fname cannot open!";}
  return @script;
}


#*** setasterisk($line)
# stets the asterisk to a non pointed psalm verse line by line
sub setasterisk {
  my $line = shift;
  $line =~ s/\s*$//;  
  
  if ($line =~ /\*/ && length($') > 9) {return $line;}
  
  my $lp2 = (length($line) > 64) ? 24 : (length($line) < 24) ? 6 : 12;
  my $t = '';
  my $l = $line;
  if ($line =~ /(.*?)[\.\:\;\?\!](.*)$/ && length($2) > $lp2) { 
    while ($l =~ /(.*)([\.\:\;\?\!])(.*?)$/) {
      $breaker = $2;
	    $after = $3;
	    $l = $1;
	    if (length("$after$t") > $lp2) {	 
	      if (length($l) > $lp2) {return "$l$breaker *$after$t";}
		   last;
	    }
	    $t = "$breaker$after$t";
    }
  } 
    
  $t = '';
  $l = $line;
  my $b = ($line =~ /(.*?),(.*)$/ && length($2) > $lp2) ? ',' : ' ';
  while ($l =~ /(.*)($b)(.*?)$/) {
    $breaker = $2;
    $after = $3;
    $l = $1;

    if (length($l) < $lp2 && $b eq ',') {$b = ' '; $l = $line; $t = ''; next;}
    while ($breaker eq ' ' && length($l) > ($lp2 + 3) && $l =~ /(.*) (.*?)$/ && length($2) < 4) 
	  {$l = $1; $after = "$2 $after";}
	  
	if (length("$after$t") > $lp2) {
    if ($after !~ /^ /) {$after = " $after";}
    return "$l$breaker *$after$t";
  }
	$t = "$breaker$after$t";
  }
  if ($t !~ /^ /) {$t = " $t";}
  return "$l *$t";
}     

    
sub columnsel {
  my $lang = shift;
  if ($Ck) {return ($column == 1) ? 1 : 0;}
  return ($lang =~ /^$lang1$/i) ? 1 : 0;
}

