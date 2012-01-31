#!/usr/bin/perl

#·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€
# Name : Laszlo Kiss
# Date : 09-25-08
# Tk specific dialogs

#use warnings;
#use strict "refs";
#use strict "subs";

my $a = 4;


#*** savesetuphash($name, \%setup)
# saves the referenced setup hash modified by each dialog call
# into $name.setup file
# called by ondestroy callback of MainWindow
sub savesetuphash {
  my $name = shift;
  my $setup = shift;
  my %setup = %$setup; 
  if (open (OUT, ">$datafolder/$name.setup")) {
     my ($key, $value);
	 foreach $key (sort keys %setup) {	
	    print OUT '[' . $key . "]\n";
		$value = $setup{$key};	
		$value =~ s/\n//g;
		$value =~ s/;;/;;\n/g; 
		print OUT "$value\n";  
     }
	 close OUT;
  }
}

#*** setfont($font, $text)
# input font description is "[size][ italic][ bold] color" format, and the text
# returns <FONT ...>$text</FONT> string
sub setfont {
  my $istr = shift;    
  my $text = shift;
  
  my $color = 'green';
  my $font = '{Times} 12';
  if ($istr =~ /(\#[0-9a-f]+)\s*$/i || $istr =~ /([a-z]+)\s*$/i)
  {
     $color = $1;        
     $font = $`;      
	 $color =~ s/\s*$//;
	 $font =~ s/\s*$//;
  }	
 
  if (!$text)
  {
      return ($font, $color);
  }

  #here comes set for colors;
  $after = '';						   
  if ($text =~ /\{\^/) {$text = $`; $after = "{^$'";}
  $text = "{^$font,$color,,$text^}" . $after;
  return $text;
}


#*** setcross($line)
# changes +++, ++ + to crosses in the line
# handle it in setcell
sub setcross {
  my $line = shift;
  return $line;
}

#*** setcell($text, $lang);
sub setcell {
  my $text = shift;	    
  my $lang = shift;

  my $cellnote = '';
  if ($column == 1) {
    $searchind++;
    if ($voicecolumn =~ /chant/i && ($hora !~ /matutinum/i || $chantmatins)) {
      ($cellnote, $noteheight) = show_notes($text);
      if ($cellnote) {
	    $cell[$searchind][$column] = 
		  $cellnote->grid(-row=>$searchind-1, -column=>$column-1, -columnspan=>2);
        $heights[$searchind] = ($searchind > 0) ? $heights[$searchid -1] : $totalheight;
		$notelines[$searchind] = $noteheight;
		$searchind++;
	  }
	}
  }
  
  our $wrapper = Text::Wrapper->new();
  my $asearchind = $searchind;
  my $acolumn = $column;


  $text =~ s/\n/ /g;
  $text =~ s/  / /g;
  $text =~ s/\<BR\>/\n/g;
  $cellwidth = ($only) ? $mw->width * .8 : $mw->width * .4;
  my $linewidth = floor($cellwidth / $blackfontsize *1.125); 
			  
  #creates cell
  $cell[$asearchind][$acolumn] = $middleframe->ROText(-background=>$bgcolor, 
    -width=>$linewidth, -height=>$height, ,-borderwidth=>0,
    -highlightthickness=>$border, -relief=>'solid', -wrap=>'none') 
	->grid(-row=>$searchind-1, -column=>$column-1, -sticky=>'ns');
  my $cell = $cell[$asearchind][$acolumn]; 
  configure($cell, $bgcolor, $blackfont);

  my $fontitem = $cell->cget(-font); 	
  our $lineheight = $cell->fontMetrics($fontitem, -linespace); 
  our $charawidth = $cell->fontMeasure($fontitem, 'aaaaaaaaaa') / 10;	
  $linewidth = floor($cellwidth / $charawidth);	
  $cell->configure(-width=>$linewidth);

  topnext_cell($cell, $text, $lang);  
  my $refnum = 0;
  $tagnum = 0;
 
 my @text = split("\n", $text);
 for ($speechind = 0; $speechind < @text; $speechind++) {
  
  $speechindex1 = $cell->index(insert);
  my $text = "lll$speechind $text[$speechind]";
  #handles expand or popup references
  while ($text =~ /\% (.*?) \%/g) {
    my $before = $`;
    my $ref = $1;
    $text = $';
    if ($before) {setcell_rut($cell, $before, $linewidth, $asearchind);}
	my $ind1 = $cell->index(insert);
	$refnum++;
	my $rnum = $refnum;
    $cell->tagConfigure("ref$rnum", -font=>"{Arial} 8", -foreground=>$blue);
    $cell->insert(insert, ' ');
	$cell->insert(insert, "[+]", "ref$rnum");
    $cell->insert(insert, ' ');  
	if ($ref !~ /disabled/) {
	  if ($ref =~ /^[0-9]+$/)
	    {$cell->tagBind("ref$rnum", '<ButtonRelease>'=>sub{$expandnum = $ref; return mainpage();});}
	  else {
	    my @ref = split('=', $ref);
	    {$cell->tagBind("ref$rnum", '<ButtonRelease>'=>sub{popup($ref[0], $ref[1]);});}
	  }  
      mouseover($cell, "ref$rnum");
	}
  }
  setcell_rut($cell, $text, $linewidth, $asearchind);   
  $speechindex2 = $cell->index(insert);
  $cell->tagAdd("spoken$speechind", $speechindex1, $speechindex2);  
  setcell_rut($cell, "\n", $linewidth, $asearchind);
 }
  $cell->configure(-height=>$height);
  $cell->tagConfigure("all", -lmargin1=>10, -lmargin2=>10, -rmargin=>10);
  $cell->tagAdd("all", '1.0', 'end');

  if ($column == 1) {$height1 = $height;}
  if ($column == 2 && $height1 < $height) {$height1 = $height;}
  if ($only || $column == 2) {
    $totalheight += $height1;
	$voicemaxline[$searchind] = $height1;
	$notelines[$searchind] = 0;
    $heights[$searchind] = $totalheight;   
  }
}

#*** setcell_rut($cell, $text, $linewidth)
# handles setfont($font, $text) notations
# and calls cellout($cell, $before, $linewidth) for text
sub setcell_rut {
  my $cell = shift;
  my $text = shift;      
  my $linewidth = shift;
  my $cellind = shift;			  

  if ($text =~ /(lll[0-9]+ )/) { 

    if ($only || $column == $vcol) {$speecharray[$cellind] .= $1;}
    $text = $';
  }
  $height = 5;
  my $line;

  my ($ind1, $ind2);
  my $after = $text;
  my $addheight = 0; 
  while ($after =~ /\{\^(.*?)\,\,(.*?)\^\}/g) {
	  my $before = $`;        
	  my $attr = $1;      
	  my $str = $2;	 	
	  $after = $';	
	
    if ($before) {
	    if ($only || $column == $vcol) {$speecharray[$cellind] .= $before;}
	    cellout($cell, $before, $linewidth);
	  }
	
	  my @attr = split(',', $attr);		 
      $fontsize = $blackfontsize;
	  if ($attr[0] =~ /\{.*?\}\s*([0-9]+)/) {$fontsize = $1;}
	  $tagnum++;                                               
      $cell->tagConfigure("tag$tagnum", -font=>"$attr[0]", -foreground=>"$attr[1]");
	  $ind1 = $cell->index(insert);
	  my $newlinewidth = floor($linewidth * $blackfontsize / $fontsize);
	
	  if ($only || $column == $vcol) {  
	    if ($str =~ /^[a-z]$/i || $str =~ /\%[a-z ·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€]+\%/i ||
	      $str =~ /([\!\#]H[iy]mn|\&lectio|\&antiphona_finalis)/i) {$speecharray[$cellind] .= $str;}
		  if ($str =~ /\{\:.*?\:\}/) {$speecharray[$cellind] .= $&;}
	  }
 	  cellout($cell, $str, $newlinewidth, "tag$tagnum");
  	$ind2 = $cell->index(insert);	
	  my @ind1 = split('\.', $ind1);
	  my @ind2 = split('\.', $ind2);
	  if ($fontsize > $blackfontsize + .5) {$addheight += ($fontsize / $blackfontsize - 1);}	 

  }

  if ($only || $column == $vcol) {$speecharray[$cellind] .= $after; }
  cellout($cell, $after, $linewidth);
  
  $ind1 = $cell->index(insert);	  
  $addheight = ceil($addheight);
  if ($ind1 =~ /\./) {$height = $` + $addheight;}	  
 } 

#*** cellout($cell, $text, $newlinewidth, $tag)
# breaks the given $text into lines fit to the cell using newlinewidth
# and write it into the given ROText as a tag if $tag id defined.
sub cellout {
  my $cell = shift;
  my $text = shift;
  my $newlinewidth = shift;
  my $tag = shift;	

  
  $text =~ s/\`//g;
  $text =~ s/\{\:.*?\:\}\s*//sg; 
  if ($text =~ /^\n/) {	 $text = '_' . $text;}
  $text =~ s/^ /\_/;
  $text =~ s/ $/_/;
  
  my $ind = $cell->index(insert);	 
  my @ind = split('\.', $ind);
  while ($ind[1] > $newlinewidth) {	
    $cell->insert($ind, "\n");
	$ind = $cell->index(insert);
	$ind[1] -= $newlinewidth;
  }
  $rest = $ind[1];
  if ($rest) {
    my $i = $rest;
	while ($i) {$text = 'a' . $text; $i--;}
  }
  $flag = ($text =~ /(\n+)$/) ? $1 : '';
  $text =~ s/\n*$//;
  $wrapper->columns($newlinewidth);
  $text = $wrapper->wrap($text); 
  while ($a =~ /\n/g) {$rest++;}
  if ($rest) {$text = substr($text, $rest);}
  $text =~ s/\n*$//;
  $text =~ s/\_/ /g;
  $text .= $flag;	      
  if ($text =~ /\%([a-z ·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€]+?)\%/i) {	 
    my $before = $`;
	  my $str = $1;   
	  $text = $';	  
    $cell->tagConfigure('lauds1', -foreground=>$red);
    if ($before) {$cell->insert($ind, $before, 'lauds1');}
    $ind = $cell->index(insert);	 
	if ($str) {	 
	  $cell->tagConfigure('lauds', -foreground=>$blue);
	  $cell->insert($ind, $str, 'lauds');
	  
    if ($hora =~ /Laudes/i) {
         $cell->tagBind('lauds', '<ButtonRelease>'=>sub{$command = 'Matutinum'; 
           $date1 = "11-02-$year"; $caller = 1; return mainpage();});
      } elsif ($hora =~ /Vespera/i) {
         $cell->tagBind('lauds', '<ButtonRelease>'=>sub{$command = 'Vespera'; 
           $date1 = "11-02-$year"; $caller = 1; return mainpage();});
      } elsif ($hora =~ /Matutinum/i) {
         $caller1 = $caller;
         $cell->tagBind('lauds', '<ButtonRelease>'=>sub{$command = 'Laudes';
           $caller = $caller1; 
           return mainpage();});
	    }
    mouseover($cell, 'lauds');
	  $ind = $cell->index(insert);
	  $tag = '';
	} 
    
    
    if ($text) {
	  $cell->tagConfigure('lauds2', -foreground=>$red);
	  $cell->insert($ind, $text, 'lauds2');
	  $ind = $cell->index(insert);
      $text = '';
    }
 }
 if ($text =~ /\+/) {
   my $iname = ($text =~ /\+\+\+/) ? 'cross3' : ($text =~ /\+\+/) ? 'cross2' : 'cross1';
   my $imgphoto =  $cell->Photo(-file=>"$datafolder/$iname.gif", -format=>'gif'); 
   my $before = $`;
   $text = $';
   if ($before) {$cell->insert($ind, $before);}
   $ind = $cell->index(insert);	 
   $cell->imageCreate(insert, -image=>$imgphoto);
   $ind = $cell->index(insert);
 } 		 
   
  if ($text) {
    if ($tag) {$cell->insert($ind, $text, $tag);}
    else {$cell->insert($ind, $text);}
  }
}

#*** topnext_cell() 
#prints T N for cell_positioning
sub topnext_cell {
    my $cell = shift;
    my $text = shift;   
    my $lang = shift;	 
    if (!$lang) {return;}
    my @a = split('\n', $text);
    if (@a > 2 && $expand !~ /skeleton/i) {topnext($cell, $lang);}
}

#*** topnext($cell, $lang)
# writes the references ar the top of the cell
sub topnext {  
  my $cell = shift;
  my $lang = shift;  
  
  my ($font, $color) = setfont($smallblack);
  my $ind1 = '1.0';
  my $cellind = $searchind;
  my $color = $blue;
  $cell->tagConfigure('top1', -font=>$font, -foreground=>$color, justify=>'right');
  $cell->insert($ind1, " ", 'top1');

  if ($column == 1) {
	$ind1 = $cell->index(insert);
    $cell->tagConfigure('top', -font=>$font, -foreground=>$color, justify=>'right');
	$cell->insert($ind1, "Top ", 'top');
	my $ind2 = $cell->index(insert);
	$cell->tagBind('top', '<ButtonRelease>'=>sub{cell_position_r($cellind-1);});
    mouseover($cell, 'top');
	$ind1 = $ind2;
  }	
  if ($only || $column == 2) {
  	$ind1 = $cell->index(insert);
    $cell->tagConfigure('reload', -font=>$font, -foreground=>$color, justify=>'right');
	$cell->insert($ind1, "Reload ", 'reload');
	my $ind2 = $cell->index(insert);
	$cell->tagBind('reload', '<ButtonRelease>'=>sub{reload($cellind-1);});
    mouseover($cell, 'reload');
	$ind1 = $ind2;
  }
  
  my $str = (columnsel($lang)) ? " Next" : " $searchind";   
  $color = (columnsel($lang)) ? $blue : $red;
  $cell->tagConfigure('next', -font=>$font, -foreground=>$color, justify=>'right');
  $cell->insert($ind1, $str, 'next'); 
	if (columnsel($lang)) {
      $cell->tagBind('next', '<ButtonRelease>'=>sub{cell_position_r($cellind);});
      mouseover($cell, 'next');
  }
  if ($only) {
    $cell->insert('insert', " $searchind", 'searchind');
    $cell->tagConfigure('searchind', -font=>$font, -foreground=>$red, justify=>'right');
  }
  my $ind2 = $cell->index(insert);
  $cell->insert($ind2, "\n");
  return;
}
    
#*** table_start
# start main table
# here set only 
#  - $blackfontsize value, used in setcell
#  - $totallines for position
sub table_start {
  our %revtrans = %{setupstring("$datafolder/$voicelang/Psalterium/Revtrans.txt")};
  our @cell = splice(@cell, @cell);
  our $tagnum = 0;
  our @speecharray = splice(@speecharray, @speecharray);
  our $vcol = 1;
    if ($voicecolumn =~ /([12])/) {$vcol = $1;}
    if ($only) {$vcol = 1;}
  my ($font, $color) = setfont($blackfont);
  $blackfontsize = 11;
  if ($font =~ /\{.*?\}\s*([0-9]+)/) {$blackfontsize = $1;}
  $totalheight = 0;
  $height1 = 0;
  @heights = splice(@heights, @heights);
  $heights[0] = 0;
}



#antepost('$title')
# prints Ante of Post call
sub ante_post{
  my $title = shift;
  my $line =  setlink("\$$title", 0, $lang1); 
  $column = 1;
  my $str = 'Divinum Officium';
  $str = $translate{$lang1}{$str};
  setcell("$line", $lang1);
  if (!$only) {
    $column = 2;
    $str = 'Divinum Officium';
    $str = $translate{$voicelang}{$str};
    $line =  setlink("\$$title", 0, $lang2); 
    setcell("$line", $lang2);
  }
  return;
}

#table_end()
# finishes main table
# nothing here for standalone
sub table_end {	
  $caller = 0;
}

#*** linkcode($name, $ind, $lang, $disabled)
# set a link line
sub linkcode {
  my ($name, $ind, $lang, $disabled) = @_; 
  if ($disabled =~ /disabled/i) {return "% disabled %";}
  if ($ind) {return "% $ind %";}
  return "% $name=$lang %"; 
}

#*** linkcode1()
# sets a collpse radiobutton
sub linkcode1 {
   return "% 10000 %";
}

#*** cell_position_r($ind)
# clears voicehold and calls cell_position
sub cell_position_r {
  my $ind = shift;
  $voicehold=0;
  $stopvoice = 0;
  return cell_position($ind);
}

#*** cell_position($ind)
# positions to $ind cell
sub cell_position {
  my $ind = shift;    
  if ($ind == -1 && $version !~ /(1955|1960)/) 
    {$anteflag = 1;  popup("\$Ante", $voicelang); return voiceit("Ante");}
  if ($ind == 99) {popup("\$Post", $voicelang); return voiceit("Post");}
  if ($ind < 0) {$ind = 0;}
  if ($ind > 99) {$ind = @heights - 1;}  
  if ($ind >= @heights) {
    if ($anteflag) {popup("\$Post", $voicelang); $anteflag = 0; return voiceit("Post"); }
    writetimelog();
    $command = shift(@command); 
	  mainpage();
    $actcell = -3;
	  if ($command) {return cell_position($actcell);}
	  return; 
  }
  
  my $perc = ($heights[$ind] + $voiceposadd) / ($heights[-1] + 10);   
  $mwf->yview(moveto=>$perc);
  $mwf->focus();
  if ($ind !~ /[a-z]/i) {$actcell = $ind;}
  $pressedkey = 0;
  voiceit($ind);  
 }

#*** reload($ind);
#reloads the database and positions to $ind	cell
sub reload {
  my $ind = shift;	 
  my $perc = ($heights[$ind] + $voiceposadd) / ($heights[-1] + 10);
  mainpage();				  
  $stopvoice = 1;
  $mwf->yview(moveto=>$perc);
  $mwf->focus(); 
 }

#*** mouseover($cell, $tagname)
# changes color for mouseover
sub mouseover {
  my $cell = shift;
  my $tagname = shift;
  my $bg = shift;
  if (!$bg) {$bg = $bgcolor;}
	  
  $cell->tagBind($tagname, '<Enter>'=>sub{$cell->tagConfigure($tagname, -background=>$voicegrey1);});
  $cell->tagBind($tagname, '<Leave>'=>sub{$cell->tagConfigure($tagname, -background=>$bg);});
}


#*** voiceit($index)
# gets the text of the appropriate cell	for the numbered cell ($index)
# truncates from the printing extras and calls speakit
# handles the Aperi Sacrosanctae and the end for continuous  
sub voiceit {
  my $index = shift;     
  if ($voicecolumn =~ /mute/i) {return;}
  my $lang = $voicelang;  
  my %prayer = %{setupstring("$datafolder/$lang/Psalterium/Prayers.txt")};
  my $text = '';
  my ($i, $line, $rest);
  my $ind = 0; 

  if ($index =~ /[a-z]/i) {$text = $speecharray[0];}
  elsif ($index >= 0) { $text = $speecharray[$index+1];} 
  else {return;} 
  
  our $texttone = '';	   					
                               
  if ($laudescont && $command =~ /laudes/i && $index == 1 && $version !~ /1955|1960/ &&
    $text =~ /lll[0-9]\s*\_\s*/) {$text = $'; $laudescont = 0;}

  if ($hora =~ /matutinum/i && $text =~ /\%[a-z ·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€]+\%/i) {  
     writetimelog();
     $command = 'Laudes'; 
     $laudescont = 1;
     mainpage();
     if ($voicecontinue) {$actcell = -3; cell_position($actcell);}
     return;
  }

  if ($hora =~ /(Laudes|Vespera)/i && $text =~ /\%[a-z ·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€]+\%/i) {  
     $command = ($hora =~ /Laudes/i) ? 'Matutinum' : 'Vespera'; 
     $date1 = "11-02-$year";
     $laudescont = 1;
     mainpage();
	 if ($voicecontinue) {$actcell = -3; cell_position($actcell);}
     return;
  }

  my @t;   

  my $hymnflag = 0;	
  if ($text =~ /([\!\#]H[iy]mn|\&lectio|\&antiphona_finalis)/i) {$hymnflag = 1;} 
  @t = split("\n", $text);  
  
  my $voiceflag;
  our $greyflag = -1;
  do {
    $voiceflag = 0;
    @o = splice(@o, @o);
    foreach $line (@t) {
      my $l = $line;
	  my $prev = '';
	  if ($l =~ /lll[0-9]+/) {$prev = $&; $l = $';}
	  $l =~ s/^\s*//;
	  $l =~ s/\s*$//;      
	  if ($expand !~ /all/i) {   
      if ($l =~ /\. Alleluia, alleluia$/) {  #Pasc0 Benedicamus Domino
        my $l1a = $`;   
        if (exists($revtrans{$l1a})) {$l = $l1a;}    
      }
      $l =~ s/\`//g;  
      if (exists($revtrans{$l})) {$line = "$prev $revtrans{$l}";}	 
	  }

    if ($lang =~ /Latin/i && $l =~ /Dominus_vobiscum/i) {$line = "$prev \&Dominus_vobiscum";}
	  if ($lang =~ /Latin/i && $l =~ /Benedicamus_Domino/i) {$line = "$prev \&Benedicamus_Domino";}
    if ($line =~ /\&psalm/i) {
        $line =~ s/ //g;
        $line =~ s/\&/\&voice/;
        $line =~ s/\)/\,$lang\)/;    
        push(@o, split("\n", eval($line)));	 
        $voiceflag = 1;
        next;
      }
    if ($line =~ /\&/) {   
	    my $prev = $`;
		  $line = "$&$'";
      $line =~ s/\s*$//;  
      if ($line =~ /\)/) {$line =~ s/\)/\,$lang\)/}
      else {$line = "$line($lang)";}
      if ($prev) {push(@o, $prev);}  
		  push(@o, split("\n", eval($line)));
      $voiceflag = 1;
      next; 
    }

	  if ($line =~ /(Oremus|Let us pray|Kˆnyˆrˆgj¸nk)/) {	
        push(@o, "jjj0 $line");  
        push(@o, 'jjj0');
		next; 
	  }
	 
	  if ($line =~ /\sR\./) {
	    $line =~ s/\sR\./\nR./g;
		push(@o, split("\n", $line));
		next;
	  }
	                   
    #$line =~ s/^r\. Pater noster/\$Pater noster/;
	  #$line =~ s/^r\. Ave Maria/\$Ave Maria/;
	  if ($line =~ /\$/) {
	    if ($line =~ /Per Dominum|Per eumdem|Qui cum Patre|Qui vivis|Qui tecum|Tu autem/i) 
		   {push(@o, 'jjj');}
        if ($line =~ /Deo gratias/i) {push(@o, 'kkk');}
	    $line =~ s/\$([a-z ]+)/$prayer{$1}/ig;  
		$voiceflag = 1;
	  }
      push(@o, split("\n", $line));
      next;
    } 
    @t = splice(@t, @t);   
    foreach(@o) {push(@t, $_);}
    
  } while ($voiceflag);
						 
  if ($hymnflag) {
	my $flag = 1;
	my $i;
	for ($i = 0; $i < @t; $i++) {
	  if ($t[$i] =~ /([\!\#]Hymnus|\_)/) {$flag = 1; next;}	
	  if ($t[$i] =~ /(Benedictio\.|Absolutio\.|Ant\.|R\.br\.|\*|V\.|R\.|jjj|kkk)/i) 
	    {$flag = 0; next;}
	  if ($flag && $t[$i] !~ /\~\s*$/) {$t[$i] .= '~';}	
	}  
  }    

  $text = '';
  for ($i = 0; $i < @t; $i++) {
    $line = $t[$i];             
	  if ($line =~ /^\s*[\#\!]/) {next;}
    $line =~ s/\{\^.*?\^\}//mg;
    $line =~ s/\{\^.*\~/~/mg;
    $line =~ s/^.*?\^\}//mg;
    $line =~ s/[\n ]+$//mg;
    $line =~ s/\_//;
    $line =~ s/^(lll[0-9]+)*\s*(Benedictio\.|Absolutio\.|Ant\.|R\.br\.|V\.)/$1 jjj0/mg;
	  $line =~ s/^(lll[0-9]+)*\s*(v\.|r\.|\*)/$1 /mig;
    $line =~ s/^\s*//mg;
  	if ($line =~ /^Amen/i && $i > 0 && $t[$i-1] !~ /\~/) {$text .= "jjj1\n";}
	  $line =~ s/[\+]//g;
    $line =~ s/^[ [0-9\.]+//;
    $line =~ s/N\.//g; 
    if ($line =~ /\~+\s*$/) {$text .= "$` "}
    else {$text .= "$line\n";}
   }   
   $text =~ s/\n\s*\n+/\n/g;               


 if (!$text) {$index++; return cell_position($index);}   
 if (!$voice || $voicecolumn =~ /mute/i) {return;}
										
 our $vcell = ($index =~ /[a-z]+/i) ? $popupcell[$vcol] : $cell[$index+1][$vcol];
 our $vcell1 = ($index =~ /[a-z]+/i) ? $popupcell[3 - $vcol] : $cell[$index+1][3 - $vcol];
 
 my $g = $vcell->geometry();
 $g =~ s/\+/x/gi;
 my @g = split('x', $g);
 $voicescreenheight= ($index =~ /[a-z]/i) ? $popupheight : $fullheight;
 $voicecellheight = $g[1];

 speakit($text, $index, $vcol); 
 if ($greyflag >= 0 && Exists($vcell)) {
    $vcell->tagConfigure("spoken$greyflag", -background=>"$bgcolor");
    if (Exists($vcell1)) {$vcell1->tagConfigure("spoken$greyflag", -background=>"$bgcolor");}
    $greyflag = -1;
 }


if ($voicecontinue && !$stopvoice && !$voicehold) {
   $actcell++; 
   if ($popupwindow && Exists($popupwindow)) {$popupwindow->destroy();} 
   return cell_position($actcell);
 }
}

#*** voicepsalm($num, $lang);
# get the psalm or part of it from the appropriate database
# returns the text adding gloria if necessary
sub voicepsalm {
  my @a = @_;			
                    
  my ($num, $lang, $line);						   
  if (@a < 3) {$num = $a[0]; $lang = $a[1];}
  else {$num = "$a[0]($a[1]-$a[2])"; $lang = $a[3];}	

  my $nogloria = 0;     
  if ($num =~ /^-/) {$num = $'; $nogloria = 1;}	   
  																	
  if ($num =~ /^\s*([0-9]+)/) {$psnum = $1;}
  else {return '';}

  my $v1 = 1;
  my $v2 = 1000;
  if ($num =~ /\((.*?)\)/) { 
     my @v = split('-', $1);
     $v1 = $v[0];
     $v2 = $v[1];   
  }						

  my $t = '';
  $psalmfolder = ($accented =~ /plane/i) ? 'psalms' : 'psalms1';   
  $fname=checkfile($lang, "$psalmfolder/Psalm$psnum.txt");

  if (open(INP, $fname)) {
	  while ($line = <INP>) {
      if ($line =~ /^\s*([0-9]+)\:([0-9]+)/) {$v = $2;}
      elsif ($line =~ /^\s*([0-9]+)/) {$v = $1;}
      if ($v < $v1) {next;}
      if ($v > $v2) {last;}
      $lnum = '';
	    $line =~ s/^([0-9]*[\:]*[0-9]+)//; 
      $line =~ s/(\(.*?\))//g;
      $t .= $line;
	}
    close INP; 		
    if ($psnum != 210 && $nogloria == 0) {$t .= Gloria($lang);} 
	return $t;
  }
  return "";
}

#*** speakit($text, $index, $vcol)
# do nothing is $voice is not set (no speak mode, SAPI5 is not installed)
# stops the voice if any
# speaks the voice, lines alternately, if $vocename1 =~ /$voicename2/i
# if $voicelang latin then changes ae|oe to È and s to sz for hungarian voice
sub speakit {       
  if (!$voice) {return;}
  my $text = shift;       
  my $index = shift;
  my $vcol = shift;	  
                               
  $voice->Speak(' ', 2); $voice->StopSpeaking();
  if ($stopvoice || $voicecolumn =~ /mute/i || $voicehold) {return;}

  @t = split("\n", $text);
  my $i;
  my $j = 0;
  my $popupscroll = 0;
  
  #process by 'lines'
  for ($i = 0; $i < @t; $i++) {
    $mw->update(); 
	  if ($voicehold || $stopvoice) {return;} 
    if (!$t[$i] || $t[$i] =~ /^\s*$/) {next;} 
    if ($t[$i] =~ /jjj([01])/) {$j = $1; $t[$i] =~ s/jjj[01]//;}
	  if ($t[$i] =~ /^jjj$/) {$j++; next;}
    if ($t[$i] =~ /^kkk$/) {next;}
  	$t[$i] =~ s/(jjj|kkk)//g;
    
    #gray the sentence, move the view
	  if ($t[$i] =~ /lll([0-9]+)/) { 
      $t[$i] = $';
      my $gf = $1;		  
      if ($greyflag >= 0) {
        $vcell->tagConfigure("spoken$greyflag", -background=>"$bgcolor");
        if (Exists($vcell1)) {$vcell1->tagConfigure("spoken$greyflag", -background=>"$bgcolor");}
      }
      $greyflag = $gf;

      #move the page if necessary
	  my @a = $vcell->tagRanges("spoken$greyflag"); 
      my $ln0 = ($a[0] =~ /^(.*?)\./) ? $1 : 0; 
      my $ln1 = ($a[1] =~ /^(.*?)\./) ? $1 : 0;   

	  if ($ln0 && $ln1) {			 
	    while (($ln1 + $notelines[$index] - $popupscroll) * $lineheight > $voicescreenheight- 5 * $lineheight) {
		  if ($ln0 - $popupscroll < 11) {last;}
		  my $perc = $ln0 / ($voicemaxline[$index+1]); 
          my $a = $perc * ($heights[$index+1] - $heights[$index]);
          $perc = ($heights[$index] + $a + $voiceposadd - 2) / ($heights[-1] + 10);
		  if ($index =~ /[a-z]+/) {$popupframe->yview(moveto=>0.99); last;}
		  else {$mwf->yview(moveto=>$perc); $popupscroll = $ln0 - 5;}
        }
      }       
      
      #remove old gray set new
      $vcell->tagConfigure("spoken$greyflag", -background=>$voicegrey1);
      if (Exists($vcell1)) {$vcell1->tagConfigure("spoken$greyflag", -background=>$voicegrey2);}
      $mw->update(); 
  	  if ($voicehold || $stopvoice) {return;}
    } 

    if ($t[$i] =~ /\{\:(.*?)\:\}/) {
	    $tfile = $1;      
 	    $texttone = '';
	    if ($tfile =~ /[a-z0-9]/ && open (INP, "$datafolder/tones/$tfile.txt")) {
		   my $line;
		   while ($line = <INP>) {$texttone .= $line;};
	      close INP;
	      $psalmline = 0;  
      } 
	  }
	  $t[$i] =~ s/\{\:(.*?)\:\}\s*//g;    

    if (!$t[$i] || $t[$i] =~ /^\s*$/) {next;}
								
	if ($voicecolumn =~ /chant/i && $texttone =~ /,/ && ($hora !~ /matutinum/i || $chantmatins)) {	
      singit($t[$i], $tfile, $texttone, $psalmline, $psalmline);
      $psalmline++;
      while ($voicehold && !$stopvoice) {
	      Win32::Sleep(100);  #select(undef,undef,undef,.1);
		    $mw->update();
		  }
    } else {  

    	#select voice according to sequence
      if ($j & 1) {	
        setvoice($voicename2);
        $t[$i] = modify_voice($t[$i], $voicename2);
        $t[$i] = "<pitch absmiddle=\"$pitch2\">$t[$i]</pitch>";
      }
      else {
        setvoice($voicename1);
        $t[$i] = modify_voice($t[$i], $voicename1);
        $t[$i] = "<pitch absmiddle=\"$pitch1\">$t[$i]</pitch>";
      }

      #say sentence, wait for finish
	    $t[$i] =~ s/\*//g;
      $voice->Speak($t[$i], 3);    
	    while (!$voice->WaitUntilDone(20) && !$stopvoice) {
        if ($voicehold) {
	        $voice->Pause();
		      while ($voicehold) {
		        Win32::Sleep(100);  #select(undef,undef,undef,.1);
		        $mw->update();
		      }
	        $voice->Resume();
        }
	    $mw->update(); 		 
	  }
  }
  $j++;
  }
}

#*** modify_voice($text, $voicename)
# makes the outside modifications in text for the specific laguage
# for Magyar switches between Hungarian and English voice
# for for latin with -HU espeak voice extended changes
sub modify_voice {
  my $text = shift;
  my $voicename = shift;	
  if ($voicelang =~ /magyar/i) {  
    if ($text =~ /[·ÈÌÛˆıÙ˙¸˚˙¡…”÷‘⁄‹€`]/ || length($text) <10 ||
      $text =~ /(kyrie| az )/i) {
	    $text =~ s/ı/ˆˆ/ig;
      $text =~ s/˚/¸¸/g;   
      definevoicelang('Magyar');
	  }else {definevoicelang('English');}
  }
  if ($voicelang =~ /latin/i && $voicename =~ /\-hu/i) {
    foreach (@voicedict) {
      my @item = split('=', $_);
  	  $text =~ s/$item[0]/$item[1]/g;
	}
  
    $text =~ s/y/i/ig;
    $text =~ s/ti([aeiou])/ci$1/ig;
    $text =~ s/c/k/ig;
    $text =~ s/th/t/ig;	
    $text =~ s/qu/kv/ig;
    $text =~ s/ngu/ngv/ig;
    $text =~ s/gn/gny/gi;
    $text =~ s/s/sz/ig;
  
    #if ($text !~ /·ÈÌÛˆı˙¸˚¡…”÷‘⁄‹€/) {$text = emphases($text);}
    $text =~ s/·/a:/ig;
    $text =~ s/È/e:/ig;
    $text =~ s/Ì/i/ig;
    $text =~ s/Û/o:/ig;
    $text =~ s/˙/u:/ig;
	  $text =~ s/¡/a:/ig;
	  $text =~ s/…/e:/ig;
	  $text =~ s/”/o:/ig;
	  $text =~ s/⁄/u:/ig;
 
    $text =~ s/([ao])(\:*)e/e$2/ig;
    $text =~ s/:([a-z])i/$1i/ig;	  
    $text =~ s/k([ei])/cs$1/ig;	
  }    
  return $text;
}

#*** emphases($text)
# a primitive attempt to set accents into Latin text
sub emphases {
  my $text = shift;
  my @t = split(' ', $text);
  my $w;
  $text = '';
  foreach $w (@t) {
    my $l = length($w);
	$w .= ' ';
	my $w1 = $w;
	my $flag = 0;
	while ($l >= 0) { 
	  my $s = substr($w, $l, 1);
	  if ($s =~ /[aeiouÈ]/i && substr($w, $l+1, 1) !~ /[aeiouÈ]/i) {$flag++;}
	  if ($flag == 2) {
	    if ($s eq 'a') {$s = '·';}
	    if ($s eq 'e') {$s = 'È';}
	    if ($s eq 'i') {$s = 'Ì';}
	    if ($s eq 'o') {$s = 'Û';}
	    if ($s eq 'u') {$s = '˙';}
	    substr($w, $l, 1) = $s;
	  }
      $l--;
	}
    if ($flag < 3) {$w = $w1;}
	$text .= $w;
  }
 return $text;
}


#*** definevoicelang($lang)
# get voicename1 form parameters for $lang and defines the voice
# used bu language change for hungarian
sub definevoicelang {
  my $lang = shift;  
  my $a = $setup{"Voice$lang"};  
  my $voicename = ($a =~ /voicename[12]\=\'(.*?)\'/is) ? $1 : $voicename1;    
  my $voiceindex = 0;
  my $i;
  my @voicenames = splice(@voicenames, @voicenames);
	@voicenames=$voice->GetInstalledVoices('');
  if ($voicename) {for ($i = 0; $i < @voicenames; $i++) {
    if ($voicenames[$i] =~ /^$voicename$/) {$voiceindex = $i; last;}
  }} 
  if ($voiceindex >= @voicenames) {$voiceindex = 0;}
  my $voicehash = $voice->Getvoices()->Item($voiceindex); 
  $voice->SetProperty('Voice', $voicehash);  
}

#*** definevoice
# defines Win32::SAPI5::Spvoice object, gets @vocenames array
# sets voicename1 as default
sub definevoice {
  $voice = '';
  @voicenames = splice(@voicenames, @voicenames);
  our $stopvoice = 1;
  if ($Tk < 2) {return;}
  $voice = Win32::SAPI5::SpVoice->new(); 
  if ($voice){
    $voice->GetObject()->Register("", "$O");
	  @voicenames=installedvoices($voicelang);  
  }
  if ($voicecolumn =~ /[12]/ && $command && $voice) {
    setvoice($voicename1);
    $stopvoice = 0;
  }
}

#*** installedvoices($lang)
# selects the usable voices for the given language
# returns the list of voicenames
sub installedvoices {
  my $lang = shift;    
  if (!$voice) {
    $voicecolumn = 'mute';
	  $voicename1 = $voicename2 = 'no voice';
  }
  my @a=$voice->GetInstalledVoices(''); 
  my @v = splice(@v, @v);
  my $item;
  foreach $item (@a) {
    if ($lang =~ /latin/i && $item =~ /(LA|HU|IT|ES)/) {push(@v, $item);}  
    if ($lang =~ /magyar/i && $item =~ /hu/i) {push(@v, $item);}
    if ($lang =~ /English/i && $item !~ /(LA|HU|IT|ES)/) {push(@v, $item);}
  }
  if (!@v) {
    $error = "No voice installed for $lang, mute is set";
	$voicecolumn = 'mute';
	$voicename1 = $voicename2 = 'no voice';
  } else {
    if ($voicename1 =~ /no voice/i) {$voicename1 = $v[0];}
    if ($voicename2 =~ /no voice/i) {$voicename2 = $v[0];}
  }

  return @v;
}

#*** setvoice($voicename)
# find the index for $voicename (error if not found in @voicenames)
# sets rate, volume and voice properties
sub setvoice {
  my $voicename = shift;
  if (!$voice || $voicecolumn =~ /mute/i) {return;}
  my @a=$voice->GetInstalledVoices(''); 
  my $voiceindex = @a;	 
  my $i;  
  if ($voicename) {for ($i = 0; $i < @a; $i++) {
    if ($a[$i] =~ /^$voicename$/) {$voiceindex = $i; last;}
  }} 	 

  if ($voiceindex >= @a) {
    $error = "No voice installed for $voicelang $voicename, mute is set";
    $voicecolumn = 'mute';
  }

  my $voicehash = $voice->Getvoices()->Item($voiceindex); 
  $voice->SetProperty('Voice', $voicehash);	 

  $voice->SetProperty('Rate', $voicerate); 
  $voice->SetProperty('Volume', $volume);
  $voice->SetProperty('Format','16kHz 16 bit Mono');
}
