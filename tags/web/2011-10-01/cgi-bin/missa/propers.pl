#!/usr/bin/perl
# ·ÈÌÛˆı˙¸˚¡…Ê á
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office fills the chapters from ordinarium

$a=4;

#*** specials(\@s, $lang)
# input the array of the script for hora, and the language
# fills the content of the various chapters from the databases
# returns the text for further adjustment and print to sub horas 
sub specials {
  my $s = shift;
  my $lang = shift;	
  
  $octavam = ''; #check duplicate commemorations
  my %w = (columnsel($lang)) ? %winner : %winner2; 
  
  if ($column == 1) {
    my $r = $w{Rule};
    $r =~ s/\s*$//;
    $r =~ s/\n/ /sg;
    $buildscript = setfont($largefont, "$hora $date1") . "\n" . 
      setfont($smallblack, "$dayname[1] ~ $dayname[2] : $r") . "\n";
  }


  our @s = @$s;
  @t = splice(@t, @t);	 
  foreach (@s) {push (@t, $_);}
  @s = splice(@s, @s);
  $tind = 0;

  while ($tind < @t) {	   
    $item = $t[$tind];  
    if ($item =~ /\&communicantes/ && $rule =~ /Communicantes/) {
	  my %w = (columnsel($lang)) ? %winner : %winner2; 
      $item = $w{Communicantes};
	  while ($t[$tind] !~ /!!!/ && $tind < @t) {$tind++;}
	  $tind--;
	}
	
	if ($item =~ /N\.p/) {$item = replaceNpb($item, $pope, $lang, 'p', 'o');}
    if ($item =~ /N\.b/) {$item = replaceNpb($item, $bishop, $lang, 'b', 'o');}


    $tind++;

	if ($item =~ /^\s*!\*/) {
	  $skipflag = 0;
	  if ($item =~ /!\*(\&[a-z]+)\s/i) {$skipflag = eval($1);} 
	  if ($item =~ /!\*[A-Z]*nD/ && $votive =~ /Defunct/i) {$skipflag = 1;}
	  if ($item =~ /!\*S/ && !$solemn) {$skipflag = 1;}
	  if ($item =~ /!\*R/ && $solemn) {$skipflag = 1;}
	  if ($item =~ /!\*D/ && $votive !~ /Defunct/i) {$skipflag = 1;}
	  if ($skipflag) {
	    while ($tind < @t && $t[$tind] !~ /^\s*$/) {$tind++;}
	    if ($tind < @t) {next;}
		else {last;}
	  } else {next;}
    }

    if ($item =~/^\s*#/) {
      $label = $item;   
      $label = translate_label($label, $lang);	
      push (@s, $label);	
      next;
    }

	if ($item !~ /^\s*!!/ && ($item !~ /^\s*!x!/ || $item =~ /!x!!/) && $item =~ /^\s*!/ && !$rubrics) {next;}
	
	my $after = $item;
	$item = '';
	while ($after =~ /\((.*?)\)/) {
	  $after = $';
	  $item .= "$` ";
	  if ($rubrics) {$item .= setfont($smallfont, $1) . ' ';}
	}
	$item .= $after;

    $N = setfont($largefont, 'N.');
    $item =~ s/N\./$N/g;

	push(@s, $item);
  }	   			
  return @s;  
}

#***  ($label, $comment, $ind, $lang, $prefix)
# prepares for print the chapter headline.
# $label is the large font (translated), prefix is untranslated
# comment[ind] is translated
sub setcomment {
  my $label = shift;
  my $comment = shift;
  my $ind = shift;
  my $lang = shift;
  my $prefix = shift;

  if ($comment =~ /Source/i && $votive) {$ind = 7;}
  $label = translate_label($label, $lang);	 
  my %comm = %{setupstring("$datafolder/$lang/Ordo/Comment.txt")};  
  my @comm = split("\n", $comm{$comment});
  $comment = $comm[$ind];
  if ($prefix) {$comment = "$prefix $comment";} 

  if ($label =~ /\}\s*/) {$label =~ s/\}\s*$/ $comment}/;}
  else {$label .= "{$comment}";}   
  push (@s, $label);	
}    


#*** translate_label($label, $lang) 
# finds the equivalent of the latin label in translate file
sub translate_label { 
  my $item = shift;
  my $lang = shift;   

  $item =~ s/\s*$//;              
  if ($lang !~ /Latin/i) {
    my %p = %{setupstring("$datafolder/$lang/Ordo/Prayers.txt")};
	if (exists($p{$item})) {$item = $p{$item};}
  }
  if ($item =~ /Gradual/i) {
    if ($dayname[0] =~ /Quad/i || $winner{Rank} =~ /(Quattuor|Quatuor)/i) {$item = '# Tractus';}
	elsif ($dayname[0] =~ /Pasc/i && $winner !~ /Defunct/i) {$item = '# Alleluia';}
  }
  $item =~ s/\n//g;   
  return $item;
}


#*** oratio($lang, $type)
#input language
# collects and prints the appropriate oratio and commemorationes
sub oratio {
  my $lang = shift;
  my $type = shift;	 
  my $retvalue = '';
  our %cc = undef;
  our $ccind = 0;

  our $ctotalnum = 0; 
  our $addconclusio = '';
                     
  my %w = (columnsel($lang)) ? %winner : %winner2;
  $comment = ($winner =~ /sancti/i) ? 3 : 2;
  setcomment($label, 'Source', $comment, $lang);        

  if ($rule =~ /Oratio Dominica/i && !exists($w{$type})) { 
	  my $name = "$dayname[0]-0";
      if ($name =~ /(Epi1|Nat)/i) {$name = 'Epi1-0a';}
	  %w = %{officestring("$datafolder/$lang/$temporaname/$name.txt")};    
  }
  
  if ($dayofweek > 0 && exists($w{$type ."W"})) {$w = $w{$type . "W"};}
  else {$w = $w{$type};}

  if ($version !~ /Trident/i && $w{Rule} =~ /OPapa([CMD])=([a-z ]*)\;/i) {
    my $martyr = $1;
	my $name = $2;
	my %c = %{setupstring("$datafolder/$lang/$communename/C4.txt")};
	$w = $c{$type . '9'};	  
	$w =~ s/ N\.([a-z ]+N\.)*/ $name/;
    if ($mart !~ /M/i) {$w =~ s/\(.*?\)//;}
	else {$w =~ s/[\(\)]//;}
	setbuild2("$type Gregem tuum");
  }
  	 		 
  if (!$w && $commune) { 
    my %com = (columnsel($lang)) ? %commune : %commune2;    
    $w = $com{$type};
    if ($w) {setbuild2("$commune Oratio");}
 }
                                
  if ($winner =~ /tempora/i && !$w) {   
     my $name = "$dayname[0]-0";	
	 %w = %{officestring("$datafolder/$lang/$temporaname/$name.txt")};   
     $w = $w{$type};
     if ($w) {setbuild2("$type Dominica");}
  }

  $w = getreference($w, $lang);	 

  if (!$w) {$w = 'Oratio missing';}
                      
  if (($version =~ /1960/ || "$month$day" =~ /1102/) && $w =~ /\&psalm\([0-9]+\)\s*\_\s*/i) 
    {$w = "$`\_\n$'";} #triduum 1960  not 1955

  if ($winner{Rule} =~ /Sub unica conc/i) { 
    if ($version !~ /1960/) {
      if ($w =~ /\n\$Per .*?\s*$/) {$addconclusio = $&; $w = $`;}
      if ($w =~ /\n\$Qui .*?\s*$/) {$addconclusio = $&; $w = $`;}
    } else {$w =~ s/\$(Per|Qui) .*?\n//i;} 
  }

  my %prayer =%{setupstring("$datafolder/$lang/Ordo/Prayers.txt")};
  my $orm = ($type =~ /secreta/i) ? '' : "$prayer{Oremus}\n"; 
  $retvalue = "$orm\n$w\n";
  $ctotalnum = 1;

  my $coron = '';
  if (open(INP, "$datafolder/../horas/Latin/Tabulae/Tr1960.txt")) {
     my $tr = '';
     while ($line = <INP>) {$tr .= chompd($line);}
     $tr =~ s/\=/\;\;/g;
     close(INP);
     my %tr = split(';;', $tr);
	 my $mm = sprintf("C%02i-%02i", $month, $day);
	 if (exists($tr{$mm})) {$coron=$tr{$mm};}
  }
  
   
  if ($coron) {
    $retvalue =~ s/\$(Per|Qui) .*\n//g; 
	my %c = %{setupstring("$datafolder/$lang/$coron.txt")};
	my $c = $c{$type};
	if ($coron =~ /Coronatio/i) {$c =  replaceNpb($c, $pope, $lang, 'p', 'um');}
	$retvalue .= "_\n\$Papa\n$c";
  }
  if ($rule =~ /omit .*? commemoratio/i || ($version =~ /1960/ && $solemn)) {return resolve_refs($retvalue, $lang);}


  $w = '';
  our $oremusflag = "\_\n$prayer{Oremus}\n";
  if ($type =~ /Secreta/i) {$oremusflag = '';} 
  if (exists($w{'$type Vigilia'}) && ($version !~ /(1955|1960)/ || $rule =~ /Vigilia/i)) {
     $w = "!Commemoratio vigilia\n";
	 $w .= "!$type\n" . $w{"$type Vigilia"}; 
 	 $retvalue .= "$oremusflag$w\n"; 
	 $oremusflag = ""; 
  }
 
  #* add commemorated office
   if ($commemoratio1 && $rank < 6) {
    $w = getcommemoratio($commemoratio1, $type, $lang);  
    if ($w) {setcc($w, 1, setupstring("$datafolder/$lang/$commemoratio1"));}		  
  }

  if ($commemoratio && ($rank < 6 || $version !~ /(1955|1960)/i || $commemoratio{Rank} =~ /(Dominica|;;6)/i ||
	  ($commemoratio =~ /Tempora/i && $commemoratio{Rank} =~ /;;[23]/))) {  
	$w = getcommemoratio($commemoratio, $type, $lang);  
    if ($w) {setcc($w, 2, setupstring("$datafolder/$lang/$commemoratio"));}		  
  }                                                
  

  #add commemoratio in winner 
  if ($rule !~ /nocomm1960/i && (($version =~ /(1955|1960)/ && 
     ($winner{'Commemoratio Oratio'} !~ /Octav/i || $winner{'Commemoratio Oratio'} =~ /Octav.*?Nativ/i))
    || !($version =~ /(1955|1960)/ && $rank >= 5))) {commemoratio('winner', $type, $lang);   

  if ($version !~ /1960/ || $rank < 5 ) {
	  #commemoratio from commemorated office
	  if ($commemoratio) { commemoratio('commemoratio', $type, $lang); }	    
      if ($commemoratio1) { commemoratio('commemoratio1', $type, $lang);}  
      if ($commemorated && $version !~ /1960/) {commemoratio('commemorated', $type, $lang);}
    }
  }

  $retvalue = getcc($retvalue);
  if ($version =~ /1955|1960/ || !checksuffragium()) {
    $retvalue .= $addconclusio; 
    return resolve_refs($retvalue, $lang);
  }


  if ($winner =~ /Sancti/i && $duplex < 3 && $scriptura && $scriptura{Rule} =~ /Suffr.*?=(.*?);;/i)
    {$rule .= $&;}

  if ($rule =~ /Suffr.*?=(.*?);;/i) {
    my $sf = $1;  
	my @sf = split(';', $sf);
	my %sf = %{setupstring("$datafolder/$lang/Ordo/Suffragium.txt")};
    my ($sf1, @sf1);

	foreach $sf (@sf) {  
	  if ($ctotalnum > 3) {last;}
	  @sf1 = split(',', $sf); 
      my $i = ($dayofweek % @sf1); 
	  if ($sf1[$i] =~ /Maria2/i && ($month > 2 || ($month == 2 && $day > 1))) {$sf1[$i] = 'Maria3';}
	  $retvalue .= "_\n" . delconclusio($sf{"$type $sf1[$i]"}); 
    }
  }
  $retvalue .= $addconclusio;
  return resolve_refs($retvalue, $lang);
}


#*** setcc($str, $code, \%source) {
#set str with calculated code to %cc  
sub setcc {
  my $str = shift;
  my $code = shift; 
  my $s = shift;
  my %s = %$s;  
  my $key=90; 
  if ($version =~ /1955|1960/ && $ccind >= 3) {return;} 

  if ($s{Rank} =~ /Dominica/i && $code < 10) {$key = 10;}  #Dominica=10
  elsif ($s{Rank} =~ /;;Feria/i && $s{Rank} =~ /;;[23456]/) {$key = 50;} #Feria major=50
  elsif ($s{Rank} =~ /infra Octav/i) {$key = 40;} #infra octavam=4000
  elsif ($s{Rank} =~ /Vigilia com/i || ($code %10) == 3) {$key = 60;} #vigilia communis
  elsif ($s{Rank} =~ /;;([2-7])/ && $code < 10) {$key = 30 + (8 - $1 );} 
  elsif ($s{Rank} =~ /;;1/ || $code >= 10) {$key = 80;}  #Simplex=80;
  if ($s{Rule} =~ /Comkey=([0-9]+)/i) {$key = $1;} #oct day Epi Cor = 20, simpl=70
  if (($code % 10) != 1) {$key .= '0';} #concurrent
  else {$key .= '1';} #occurrent
  $key .= "$ccind"; 
  $ccind++;  
  $cc{$key} = $str; 
}

#*** getcc($retvalue) 
# adds the sorted items to retvalue
sub getcc {
  my $retvalue = shift;
  my $key;
  
  foreach $key (sort keys %cc) { 
    if ($key > 999) {$retvalue .= delconclusio($cc{$key});}
  }
  return $retvalue;
}     


#*** commemoratio($item, $type, $lang)
# adds commemoratio from $winner office $ind= hora
sub commemoratio {     
  my $item = shift;		  
  my $type = shift;	  	   
  my $lang = shift;  
  my $code = 10;  

  if ($rank > 6.9 || ($version =~ /(1955|1960)/ && $winner{Rank} =~ /Dominica/i)) {return '';}

							  
  if ($rule =~ /no commemoratio/i) {return '';};
  my %w;
  if ($item =~ /winner/i) {%w =(columnsel($lang)) ? %winner : %winner2; $ite = $winner;}
  elsif ($item =~ /commemoratio1/i) {%w = %{officestring("$datafolder/$lang/$commemoratio1")}; $code = 11; $ite = $commmemoratio1}
  elsif ($item =~ /commemoratio/i) {%w = (columnsel($lang)) ? %commemoratio : %commemoratio2; $code = 22; $ite = $commemoratio}
  elsif ($item =~ /commemorated/i) {%w = %{officestring("$datafolder/$lang/$commemorated")}; $code = 13; $ite = $commemoratio2}

  my $w = '';	

  if (exists($w{"Commemoratio $type"})) {$w = getrefs($w{"Commemoratio $type"}, $lang, $w{Rule});} 

  if ($version =~ /(1955|1960)/ && ($w =~ /!.*?(Octav|Dominica)/i && $w !~ /Octav.*?Nativ/i)) {return '';}
  if ($version =~ /(1955|1960)/ && $w =~ /!.*?Vigil/i && $rule =~ /no Vigil1960/i) {return '';}
  
  if ($winner =~ /Tempora/i && $w =~ /Ascension/i) {return '';}

  if ($w && $version =~ /1955|1960/ && $w =~ /!.*?Vigil/i && $ite =~ /Sancti/i && $ite !~ /(08\-14|06\-23|06\-28|08\-09)/) 
    {$w = '';}

  if ($w) {
    my $redn = setfont($largefont, 'N.');
	$w =~ s/ N\. / $redn /g; 
	setcc($w, $code, \%w)
  }
}

sub getcommemoratio {
  my $wday = shift;       
  my $type = shift;		
  my $lang = shift;     
  my %w = %{officestring("$datafolder/$lang/$wday")}; 
  my %c = undef;   
                   
  if ($rule =~ /no commemoratio/i) {return '';}
  my @rank = split(";;", $w{Rank});                 
  if ($rank[1] =~ /Feria/ && $rank[2] < 2) {return;} #no commemoration of no privileged feria
  

  if ($rank[3] =~ /(ex|vide)\s+(.*)\s*$/i) {
    my $file = $2;
    if ($file =~ /^C[0-9]+$/ && $dayname[0] =~ /Pasc/i) {$file .= 'p';}
    $file = "$file.txt";
	  if ($file =~ /^C/) {$file = "Commune/$file";}	  
	  %c = %{setupstring("$datafolder/$lang/$file")}; 
  }
  else {%$c = {};}
  if (!$rank) {$rank[0] = $w{Name};}  #commemoratio from commune


													 
  my $o = $w{$type};  
  if (!$o) {$o = $c{$type};}
  
  if ($o =~ /N\./) {replaceNdot($w, $lang);}  			      
  if (!$o && $w{Rule} =~ /Oratio Dominica/i)  {
    $wday =~ s/\-[0-9]/-0/; 
    $wday =~ s/Epi1\-0/Epi1-0a/;	   

  	my %w1 = %{officestring("$datafolder/$lang/$wday", ($i == 1) ? 1 : 0)};   
    if (exists($w1{$type . 'W'})) {$o = $w1{$type . 'W'};}
    else {$o = $w1{$type};}
  }
  
  my $martyr = '';	
  my %cp = {};	
  if ($version !~ /Trident/i && $w{Rule} =~ /OPapa([CMD])=([a-z ]*)\;/i) {
    $martyr = $1;
	my $name = $2;
	my %cp = %{setupstring("$datafolder/$lang/$communename/C4.txt")};
	$o = $cp{$type . '9'};	  
	$o =~ s/ N\.([a-z ]+N\.)*/ $name/;
    if ($mart !~ /M/i) {$o =~ s/\(.*?\)//;}
	else {$o =~ s/[\(\)]//;}
  } 
  if (!$o) {return '';}
  
  #sub unica concl
  if ($o && $version =~ /1960/ && $w{Rule} =~ /sub unica conc/i) 
    {$o =~ s/Commemoratio4/Commemoratio4r/} 
  $o = getreference($o, $lang); 
  
  $w = "! Commemoratio $rank[0]\nv. $o\n";   
  return $w;
}

#*** getproprium($name, $lang, $flag, $buidflag)
# returns $name item from tempora or sancti file
# if $flag and no item in the proprium checks commune
# if buildflag is set adds a composing libe to building scrip
sub getproprium {
  my $name = shift;
  my $lang = shift;
  my $flag = shift;
  my $buildflag = shift;      
								  
  my $w = '';             
  my $c = 0;
  my $prefix = 0;
  my %w = (columnsel($lang)) ? %winner : %winner2;  
  if (exists($w{$name})) {  
    $w = $w{$name};
    $c = ($winner =~ /sancti/i) ? 3 : 2;   
  } 		      
	   
  if ($w) {         
    if ($buildflag) {setbuild($winner, $name, 'subst');}
    return ($w, $c);
  } 	
                      
  if (!$w && $communetype && ($communetype =~ /ex/i || $flag)) {  
    my %com = (columnsel($lang)) ? %commune : %commune2;   
        
    if (exists($com{$name})) {	  
    $w = $com{$name};
     $c = 4;       
    }
 
    if (!$w && $commune =~ /Sancti/i && ($commune{Rank} =~ /;;ex\s*(C[0-9a-z]+)/i ||
      $commune{Rank} =~ /;;ex\s*(Sancti\/.*?)\s/i)) { 
     my $fn = $1;
     my $cn = ($fn =~ /^Sancti/i) ? $fn : "$communename/$fn";  
     my %c = %{setupstring("$datafolder/$lang/$cn.txt")};  
     $w = $c{$name};
	   $c = 4;
    }
    
	if ($w) {
    $w = replaceNdot($w, $lang);
    my $n = $com{Name};
	  $n =~ s/\n//g;
	  if ($buildflag) {setbuild($n, $name, 'subst');}
    } 
  }
  return ($w, $c);
}

#*** getfromcommune($name, $ind, $lang, $flag, $buildflag)
# collects and returns [$name $ind] item for the commemorated office from the commune
# if $flag ir collects for vide reference too
# if buildflag sets the building script item
sub getfromcommune {
  my $name = shift;
  my $ind = shift;  
  my $lang = shift;
  my $flag = shift;
  my $buildflag = shift;              
                                                                
  my $c = '';	
                              
  if ($commemoratio{Rule} =~ /ex\s*(C[0-9]+[a-z]*)/) {$c = $1;}  
  if ($commemoratio{Rule} =~ /vide\s*(C[0-9]+[a-z]*|Sancti\/.*?|Tempora\/.*?)(\s|\;)/ && $flag) {$c = $1;}   
  if ($hora =~ /Prima/i && $rule =~ /(ex|vide)\s*(C[0-9]+[a-z]*|Sancti\/.*?|Tempora\/.*?)(\s|\;)/) {$c = $2;} 	   
  if (!$c) {return;}	 
          
  if ($c =~ /^C/) {
    $c = "Commune/$c";
    my $fname = "$datafolder/$lang1/$c" ."p.txt";
    if ($dayname[0] =~ /Pasc/i && (-e $fname)) {$c .= 'p';}
  }

  my %w = %{setupstring("$datafolder/$lang/$c.txt")};  
  my $v = $w{$name};    
  if (!$v) {$v = $w{"$name $ind"};}  
  if (!$v) {$ind = 4 - $ind; $v = $w{"$name $ind"};}
  if ($v && $name =~ /Ant/i) {
    my $source = $w{Name};	  
	$source =~ s/\n//g;;
	setbuild($source, "$name $ind", 'try');
  }
  return $v;
}

#*** setbuild1($label, $coment)
# set a red black line into building script
sub setbuild1 {
  if ($column != 1) {return;}   #to avoid duplication
  my $label = shift;
  my $comment = shift; 

  $label =~ s/[\#\n]//g;
  $label = "$label";
  $buildscript .= setfont($redfont, $label) . " $comment\n";
}

#*** setbuild2(($comment)
# set a tabulated black line into building script
sub setbuild2 {		
  if ($column != 1) {return;} 
  my $comment = shift;	  
  $buildscript .= ",,,$comment\n";
}

#*** setbuild($line, $name, $vomment)
# set a headline into building script
sub setbuild {
  if ($column != 1) {return;}
                            
  my $file = shift;
  my $name = shift;
  my $comment = shift; 

  $source = $file;
  if ($source =~ /\//) {$source = $`;}
  if ($comment =~ /ord/i) {$comment = setfont($redfont, $comment);}
  else {$comment = ",,,$comment";}
  $buildscript .= "$comment: $source $name\n";	   
}

#setalleluia(@capit) set alleluia
sub setalleluia {
  my @capit = @_;      
  if ($dayname[0] !~ /Pasc/i) {
     for ($i = 0; $i < @capit; $i++) {
       $capit[$i] =~ s/\&Gloria/\&Gloria1/;
     }
     return @capit;
  }
  my $i;
  my $flag = 0;
  for ($i = 0; $i < @capit; $i++) {
     if ($capit[$i] =~ /^R\.br/i) {$flag = 3;}
     if ($capit[$i] =~ /^V\./ && $flag == 3) {$flag = 4; next;}
	 if ($capit[$i] =~ /^\&Gloria/i) {$capit[$i] = "$`\&Gloria1$'"; $flag = 2; next;}
     if ($flag == 0) {next;}
     if ($capit[$i] =~ /(alleluia|alleluja)/i || $capit[$i] !~ /[RV]\./i) {next;}
     $capit[$i] = chompd($capit[$i]);  
     if ($flag == 4) {$capit[$i] = 'R. Alleluia, alleluia'; $flag = 3;}
	 elsif ($flag > 1) {$capit[$i] .= " alleluia, alleluia\n";}
     else  {$capit[$i] .= " alleluia.\n";}
     if ($flag == 2) {$flag = 1;}
  }
  return @capit;
}


#*** checksuffragium
# versions 1956 and 1960 exclude from Ordinarium 
sub checksuffragium { 
  if ($rule =~ /no suffragium/i) {return 0;}
  if (!$dayname[0] || $dayname[0] =~ /Quad5/i) {return 0;} #christmas, passiontime omit
  if ($winner =~ /sancti/i && $rank >= 3 && $seasonalflag) {return 0;}	
  if ($commemoratio =~ /sancti/i && $commemoratio{Rank} =~ /;duplex/i && $seasonalflag) {return 0;} 
  if ($winner{Rank} =~ /octav/i && $winner{Rank} !~ /post Octavam/i) {return 0;} 
  if ($duplex > 2 && $version !~ /trident/i && $seasonalflag) {return 0;} 
  return 1;
}

#*** getrefs($w, $lang, $ind)
# $w may contain line starting with @ reference
# filename:commemoratio reference from file/Commemoratio [1|2]
# filename:oratio proper Ant|Versum $ind from file 
# filename:item collects item from file
# return the expanded string
# useable for lectio, responsory, commemoratio
sub getrefs { 
  my $w = shift;
  my $lang = shift;
  my $ind = shift;
  my $rule = shift;
  my $file = '';
  my $item = '';
  my $flag = 0;
  my %s = {};

  while ($w =~ /\@([a-z0-9\/\-]+?)\:([a-z0-9 ]*)/ig) {
    $before = $`;
    $file = $1; 
    $item = $2;
    $after = $';	
    $item =~ s/\s*$//; 


    %s = %{setupstring("$datafolder/$lang/$file.txt")};	   
    if ($item =~ /(commemoratio|Octava)/i) {
      my $ita = $1;			
      my $a = $s{"$ita"};
      if (!$a) {$a = $s{"$ita $ind"};}
      if (!$a) {my $i = ($ind == 2) ? 1 : 2; $a = $s{"$ita $i"};} 
	    if (!$a) {$a = "$file $item $ind missing\n";}	 
      $flag = 1;
	  if ($a =~ /\!.*?octava(.*?)\n/i) {
	    my $oct = $1;
		if ($octavam =~ /$oct/) {$flag = 0;}
		else {$octavam .= $oct;}
	  }	
	  if ($flag) {$a = "_\n$a" . "_\n";}
	  else {$a = '';}  
	  $w = "$before$a$after";   
      next;
   }
                
   if ($item =~ /oratio/i ) {  
      my $o = '';	 
      if ($item !~ /proper/) {
        $o = $s{$item};	 
		    if (!$o) {$o = "$file:$item missing\n";}
      }				               
      if ($version !~ /Trident/i && $rule =~ /CPapa([CMD])\=([a-z ]*)\;/i) {	
        my $name = $2;	
		    my %cp = %{setupstring("$datafolder/$lang/$communename/C4.txt")};
	      $o = $cp{'Oratio9'};	
	      $o =~ s/ N\.([a-z ]+N\.)*/ $name/;
        if ($mart !~ /M/i) {$o =~ s/\(.*?\)//;}
	      else {$o =~ s/[\(\)]//;}
	      $after = '';
	    } 

	    $w = $before . $o . $after; 
      next;
    }
		 
   my $a = $s{$item}; 	 
   if ($after && $after !~ /^\s*$/) {$after = "_\n$after";}
   if ($before && $before !~ /^\s*$/) {$before .= "_\n";}	 
   if (!$a) {$a = "$file $item missing\n";}
   $w = $before . $a . $after; 
   next;
 }                       
        

 $w =~ s/\_\n\_/\_/g; 

 return $w;
}

#*** getreference($str, $lang)
# checks for @... reference
# returns the expanded text
sub getreference {
  my $str = shift;
  my $lang = shift;       
  if ($str =~ /\@([a-z0-9 \/\-\:]+)/i) {
    my $key = $1;        
    my @key = split(':', $key);    
    my %v = %{setupstring("$datafolder/$lang/$key[0].txt")};
    $str=~ s/\@([a-z0-9 \/\-\:]+)/$v{$key[1]}/i; 
  }
  return $str;
}

#*** loadspecial($str)
# removes second part of antifones for non 1960 versions
# returns arrat of the string
sub loadspecial {
  my $str = shift;  
  my @s = split("\n", $str);  
  if ($version =~ /1960/) {return(@s);}
                             
  my $i;
  my $ant = 0;     
  for ($i = 0; $i < @s; $i++) { 
     if (($ant & 1) == 0 && $s[$i] =~ /^(Ant\..*?)\*/) {$s[$i] = $1;}
     if ($s[$i] =~ /^Ant\./) {$ant++;}
  }
  return @s;
}


#*** delconclusio($ostr)
# deletes the conclusio from the string
sub delconclusio  {
 $ctotalnum++;
 if ($version =~ /(1955|1960)/ && $rank >= 5 && $ctotalnum >2) {return "";}
 if ($version =~ /(1960|1960)/ && $ctotalnum > 3) {return "";}
 
 my $ostr = shift;    
 my @ostr = split("\n", $ostr);
 $ostr = ''; 
 if ($oremusflag) {$ostr = $oremusflag; $oremusflag = '';}
 my $line;
 foreach $line (@ostr) {
   if ($line =~ /^\$/ && $line !~ /\$Oremus/) {
     $addconclusio = "$line\n";
     next;
   }
   $ostr .= "$line\n";
 }    
 return $ostr;
}

#*** replaceNdot($s, $lang)
# repleces N. with name in $s from %c
# return corrected string
sub replaceNdot {
 my $s = shift;
 my $lang = shift;	 
 my $name = shift;
 if ($s !~ /N\./) {return $s;}
 
 my %c = (columnsel($lang)) ? %winner : %winner2; 
 if (!$name) {$name = $c{Name};}
 if (!$name) {
   %c = (columnsel($lang)) ? %commemoratio : %commemoratio2; 
   $name = $c{Name};  
 }		 	  		  
 if ($name) {
   $name =~ s/[\r\n]//g;
   $s =~ s/N\. (et|and|Ès) N\./$name/;
   $s =~ s/N\./$name/;
 }	 
 return $s;
}

sub replaceNpb {
  my $s = shift;
  my $pb = shift;
  my $lang = shift;
  my $let = shift;
  my $e = shift;

  my @pb = split(',', $pb);
  $pb = ($lang =~ /Latin/i) ? $pb[0] : ($lang =~ /English/i) ? $pb[1] : $pb[2];
  if ($lang =~ /Latin/i) {$pb =~ s/us$/$e/;}
  $s =~ s/N\.$let/$pb/g;
  return $s;
}

sub Gloria {
  my $lang = shift;	 
  if ($dayname[0] =~ /Quad[56]/i && $rule !~ /Requiem gloria/) {return "";}
  my %prayer = %{setupstring("$datafolder/$lang/Ordo/Prayers.txt")};
  if ($rule =~ /Requiem gloria/i) {return $prayer{Requiem};}
  return $prayer{'Gloria'};    
}

sub getitem {
  my $type = shift;
  my $lang = shift;  

  my %w = (columnsel($lang)) ? %winner : %winner2; 
  my $w = $w{$type}; 
  if ($type =~ /Graduale/i && $dayname[0] =~ /Pasc/i && exists($w{GradualeP})) {$w = $w{'GradualeP'};}
  if ($type =~ /Graduale/i && $dayname[0] =~ /Quad/i && exists($w{Tractus})) {$w = $w{'Tractus'};}
    
  if (!$w && $winner =~ /Tempora/i) {
	  my $name = "$dayname[0]-0";
      if ($name =~ /(Epi1|Nat)/i) {$name = 'Epi1-0a';}
	  if ($name =~ /Pent01/i) {$name = 'Pent01-0a';} 
	  %w = %{officestring("$datafolder/$lang/$temporaname/$name.txt")};    
      $w = $w{$type}; 
      if ($type =~ /Graduale/i && $dayofweek > 0 && exists($w{GradualeF})) {$w = $w{'GradualeF'};}
  }

  if (!$w) { 
    %w=  (columnsel($lang)) ? %commune : %commune2; 
    $w = $w{$type};
    if ($type =~ /Graduale/i && $dayname[0] =~ /Pasc/i && exists($w{GradualeP})) {$w = $w{'GradualeP'};}
    if ($type =~ /Graduale/i && $dayname[0] =~ /Quad/i && exists($w{Tractus})) {$w = $w{'Tractus'};}
  }

  if (!$w) {$w = "$type missing!\n"}
  $w = getrefs($w, $lang, $w{Rule});
  #if ($type =~ /(Introitus|Offertorium!Communio)/) {
    if ($dayname[0] =~ /Pasc/i) {$w =~ s/\((Allel.*?)\)/$1/ig;} 
	else {$w =~ s/\(Allel.*?\)//ig;}  
  #}
  
  if ($w && $w !~ /^\s*$/) {
    while ($w =~ /\((.*?)\)/s) { 
	  my $s = setfont($smallfont, $1); 
	  $w = "$`$s$'";
    }
  }

  return $w;
}

sub Vidiaquam { 
  my $lang = shift;
  if ($solemn && $rank >=5 && $winner{Rank} !~ /(Feria|Die |Sabbato)/i && $votive !~ /Defunct/i) {
    my %prayer = %{setupstring("$datafolder/$lang/Ordo/Prayers.txt")};
    my $name = ($dayname[0] =~ /Pasc/i) ? 'Vidi aquam' : 'Asperges me';
    my $w = $prayer{$name};
    return resolve_refs($w);
  } else {return '';}
}

sub Introibo {
  if ($votive =~ /Defunct/ || $dayname[0] =~ /Quad[5-6]/) {push(@s, "!omit. psalm"); return 1;}
  return 0;
}

sub gloriflag {
  my $flag = 1;
  if ($dayofweek == 0) {$flag = 0;}
  if ($rule =~ /no Gloria/i) {$flag = 1;}
  elsif ($rule =~ /Gloria/ || $communerule =~ /Gloria/i) {$flag = 0;}
  elsif ($votive &&  $votive =~ /Defunct/i) {$flag = 1;}
  elsif ($winner =~ /Sancti/) {$flag = 0;}
  elsif ($dayname[0] =~ /Adv|Quad/i) {$flag = 1;}
  elsif ($dayname[0] =~ /Pasc/) {$flag = 0;}
  return $flag;
}

sub GloriaL {
  my $lang = shift; 
  if ($winner{Rule} !~ /LectioL([0-9])/i) {return '';}
  my $n = $1; 
  my $i;
  my %w = (columnsel($lang) ? %winner : %winner2); 
  my $s = ''; 
  for ($i = 1; $i <= $n; $i++) {
     $s .= "\n#Oratio\[$i\]\n" . "\$Oremus\n";
     $s .= $w{"OratioL$i"} . "\n_\n";
     $s .= "\n! " . translate_label('Lectio', $lang) . " [$i]\n";
     $s .= $w{"LectioL$i"} . "\n_\n";
     if (exists($w{"GradualeL$i"})) {
	   $s .= "\n! " . translate_label('Graduale', $lang) . " [$i]\n";
	   $s .= $w{"GradualeL$i"} . "\n_\n_\n";
     }
  }
  if ($s && $s !~ /^\s*$/) {
    while ($s =~ /\((.*?)\)/s) { 
      my $a = setfont($smallfont, $1); 
      $s = "$`$a$'";
    }
  }
 $s =~ s/#/!!/g;
 return $s; 
}

sub GloriaM {
  my $flag = gloriflag();
  if ($flag) {push(@s, "!omit.");}
  return $flag;
}

sub Credo {
  my $flag = 1;
  if ($dayofweek == 0) {$flag = 0;}
  if ($rank >= 5 && $winner =~ /Sancti/ && $winner{Rank} !~ /Vigil/i) {$flag = 0;}
  if (($winner{Rank} =~ /Octav/i && $winner{Rank} !~ /post Octavam/i) 
  || ($commemoratio{Rank} =~ /Octav/i && $commemoratio{Rank} !~ /post Octavam/i && $version !~ /1960/)) {$flag = 0;}
  if ($rule =~  /no Credo/i) {$flag = 1;}
  elsif ($rule =~ /Credo/i || $communerule =~ /Credo/i) {$flag = 0;}
  if ($version =~ /(1955|1960)/ && $rule =~ /CredoDA/i) {$flag = 1;}
  if ($flag) {push(@s, "!omit.");}  
  return $flag;
}

sub introitus {
  my $lang = shift;
  return getitem('Introitus', $lang);
}

sub collect {
 my $lang = shift; 
 return oratio($lang, 'Oratio');
}


sub lectio {
  my $lang = shift;
  return getitem('Lectio', $lang) . "\$Deo gratias\n";
}

sub graduale {
  my $lang = shift;
  my $t = '';

  $t = getitem('Graduale', $lang);
  if (exists($winner{Sequentia})) {$t .= "_\n!!Sequentia\n" . 
    getreference(getitem('Sequentia', $lang), $lang);}
  elsif ($communerule =~ /Sequentia/i && exists($commune{Sequentia})) {
    my %c = columnsel($lang) ? %commune : %commune2;
	$t .= "_\n!!Sequentia\n" . getreference($c{Sequentia}, $lang);
  }
  return $t;
}

sub evangelium {
  my $lang = shift;
  my $t = getitem('Evangelium', $lang); 
  if ($t && $t !~ /^\s*$/) {
    $t =~ s/\n/\n\$Gloria tibi\n/;
    $t = "v. " . $t . "\$Laus tibi\n";
  }

  if ($version =~ /(1955|1960)/ && $rule =~ /Maundi/i) {
    my %w = columnsel($lang) ? %winner : %winner2;
	$t .= "_\n_\n" . norubr1($w{Maundi}); 

  }	 
  return $t;
}


sub offertorium {
  my $lang = shift;
  return getitem('Offertorium', $lang);
}


sub secreta {
  my $lang = shift;
  my $t = oratio($lang, 'Secreta');
  return "\n$t";
}

sub prefatio {
  my $lang = shift;
  my %pr = %{setupstring("$datafolder/$lang/Ordo/Prefationes.txt")};
  my $name = ($version =~ /(1955|1960)/ && $rule =~ /Prefatio1960=([a-z0-9]+)/i) ? $1 : 
    ($rule =~ /Prefatio=([a-z0-9]+)/i) ? $1 : 
     (($month == 12 && $day > 24) || ($month == 1 && $day == 1)) ? 'Nat' :
    ($month == 1 && $day > 5 && $day < 14) ? 'Epi' :
	($dayname[0] =~ /Quad[1-4]/i) ? 'Quad' :
	($dayname[0] =~ /Quad[56]/i) ? 'Quad5' :
	($dayname[0] =~ /Pasc[0-4]/i || ($dayname[0] =~ /Pasc5/i && $dayofweek < 4)) ? 'Pasch' :
	(($dayname[0] =~ /Pasc5/i && $dayofweek > 3) || $dayname[0] =~  /Pasc6/i) ? 'Asc' :
	($dayname[0] =~  /Pasc7/i) ? 'Spiritu' :	
	($winner{Rank} =~ /Beata.*?Maria.*?Virg/i) ? 'Maria' : 
    ($communetpe =~ /^C1$/i) ? 'Apostolis' : 
	($votive =~ /Defunct/i) ? 'Defunctorum' : 
	($dayofweek == 0) ? 'Trinitate' : 'Communis';
  my $pref = $pr{$name}; 
  my  %prw = (columnsel($lang)) ? %winner : %winner2;
  my $rr = $prw{Rule};
  if ($rr =~ /prefatio=(.*?)=(.*?);/i) {
	my $str = $2; 
    $pref =~ s/\*.*?\*/$str/;
  } else {$pref =~ s/\*//g;}
  return norubr($pref);
}

sub norubr {
  my $t = shift;
  if ($rubrics) {return $t;}
  $t =~ s/!!/``/g;
  $t =~ s/\n!.*?\n/\n/g;
  $t =~ s/\n!.*?\n/\n/g;
  $t =~ s/``/!!/g;
  return $t;
}

sub norubr1 {
  my $t = shift;
  if ($rubrics) {
   	my $after = $t;
	$t = '';
	while ($after =~ /\((.*?)\)/) {
	  $after = $';
	  $t .= $` . setfont($smallfont, $1) . ' ';
	}
	$t .= $after;
    return $t;
  }
  $t =~ s/\n! .*?\n/\n/g;
  $t =~ s/\n! .*?\n/\n/g;
  $t =~ s/\(.*?\)//g;
  return $t;
}

sub communicantes {
  my $lang = shift;
  my $name = (($month == 12 && $day > 24) || ($month == 1 && $day == 1)) ? 'Nat' :
    ($month == 1 && $day > 5 && $day < 14) ? 'Epi' :
	($dayname[0] =~ /Pasc0/) ? 'Pasc' : 
	(($dayname[0] =~ /Pasc[5]/i && $dayofweek > 3) || $dayname[0] =~ /Pasc[6]/i) ? 'Asc' :
	($dayname[0] =~ /Pasc[7]/i) ? 'Pent' : 'common';
  my %pr = %{setupstring("$datafolder/$lang/Ordo/Prefationes.txt")};
  if ($version =~ /1960/) {$name .= '1962';}
  my $t = chompd($pr{"C-$name"});
  return norubr($t);
}

sub hancigitur {
  my $lang = shift;
  if ($dayname[0] !~ /Pasc[07]/) {return '';}
  my %pr = %{setupstring("$datafolder/$lang/Ordo/Prefationes.txt")};
  my $t = chompd($pr{'H-Pent'});
  return norubr($t);
}

sub communio {
  my $lang = shift;
  return getitem('Communio', $lang);
}

sub postcommunio {
  my $lang = shift;
  my $str = oratio($lang, 'Postcommunio');
  if ($rule =~ /Super pop/i) {$str .= "_\n_\n" . getitem('Super populum', $lang);}
  return $str;
}

sub itemissaest {
  my $lang = shift; 
  my %prayer = %{setupstring("$datafolder/$lang/Ordo/Prayers.txt")};
  my $text = $prayer{'IteMissa'};
  my @text = split("\n", $text);       
  my $flag = gloriflag();  
  if (!$flag && $dayname[0] =~ /Pasc0/i) {$text = "$text[2]\n$text[3]"}
  elsif (!$flag) {$text = "$text[0]\n$text[1]"} 
  elsif ($votive =~ /Defunct/i) {$text = "$text[6]\n$text[7]"}
  elsif ($version =~ /1960/i) {$text = "$text[0]\n$text[1]"}
  else {$text = "$text[4]\n$text[5]"}
  return $text;
}

sub placeattibi {
  my $flag = 0;
  if ($version =~ /1960/ && $votive =~ /Defunct/i) {$flag = 1; push(@s, "!omit. Placeat tibi");}
  return $flag;
}  


sub Communio_Populi {
  my $lang = shift;

  return htmlcall('Communio', $lang);
}

sub Ultimaev {
  my $lang = shift;
  my ($t, %p);

  if ($version =~ /1960/ && $rule =~ /no Ultima Evangelium/i) {return;}
  if ($version =~ /(1955|1960)/ || !exists($commemoratio{Evangelium})) {
    %p =%{setupstring("$datafolder/$lang/Ordo/Prayers.txt")};
	$t = $p{'Ultima Evangelium'};
  } else {
    %p = (columnsel($lang)) ? %commemoratio : %commemoratio2;
    $t = $p{Evangelium}; 
  }
  
  
  if ($t && $t !~ /^\s*$/) {
    while ($t =~ /\((.*?)\)/ ) {
	  my $s = setfont($smallfont, $1);
	  $t = "$`$s$'";
    }
	$t =~ s/\n/\n\$Gloria tibi\n/;
    $t = "\$Dominus vobiscum\n$t\$Deo gratias";
  }
  
  return $t;
}

