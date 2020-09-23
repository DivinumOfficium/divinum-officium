#!/usr/bin/perl
use utf8;
# vim: set encoding=utf-8 :

# Name : Laszlo Kiss
# Name : Stepan Srubar (XHtml version)
# Date : 01-11-04
# WEB dialogs

#use warnings;
#use strict;
#use strict "subs";

my $a = 4;
#our %fontOverrides=('red113bi'=>'<b>', 'black82'=>'<em>', 'red0i'=>'<span class="ri">', 'red63'=>'<abbr>', 'red150bi'=>'<i class="a">');
#our %fontOverridesEnd=('red113bi'=>'</b>', 'black82'=>'</em>', 'red0i'=>'</span>', 'red63'=>'</abbr>', 'red150bi'=>'</i>');

our %fontOverrides=('red113bi'=>'<b>', 'black82'=>'<em>', 'red0i'=>'<span class="ri">', 'red63'=>'<span class="w">', 'red150bi'=>'<span class="a">');
our %fontOverridesEnd=('red113bi'=>'</b>', 'black82'=>'</em>', 'red0i'=>'</span>', 'red63'=>'</span>', 'red150bi'=>'</span>');

#*** htmlHead($title, $flag)
# generated the standard head with $title
sub htmlHead {
  my $title = shift;
  my $flag = shift;
  if (!$title) {$title = ' ';}


  print << "PrintTag";
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="la"><head> <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> <link href="s.css" rel="stylesheet" type="text/css"/><title>$title</title></head>
PrintTag
}

#*** setup($name, $script)
# generates an input table
# $name is the command name listed above the table
#
# $script is a string scalar contisting on lines separated by ';;' two semicolons
# each line have 3 to 5 elements separated by '~>' sign
# labelstring~>$default~>type~>mode~>condition
# labelstring is the name above the widget
# $default holds the the default value
# type = Label | Entry~>'width' | Text~>'rows'x'columns' |
#        Checkbutton  | Radiobutton~>'itemlist' | Optionmenu~>itemarray |
#        Listbox~>'itemlist' | Scale~>'from'~'to' | Filesel~>stock |
#        Color | Font | Pixel |Position | Points | Area | Ngon
#    itemlist is a comma separated list e.g "Radiobutton~>add,sub,both"
#    itemarray is either ~>Optionmenu~>\@oarray @oarray defined by the caller program,
#       or ~>Optionmenu~>oarray and defined by  [oarray] comma separated list entry in .setup file
#       or ~>Optionmenu~>{item1, item2, ...} list
#    stock option results a possibility to select the item from the stocked images
# condition is useable if the first item is Optionselect. The item is shown only
#   if condition string contains the selected item
#
# script usually is defined in  .dialog file, and obtained by getsetuppar($name) sub
# the result is saved to %setup hash by getsetupvalue($name) sub
#
sub setup {
  my $name = shift;
  if (!$name) {$name = "noname";}
  my $scripto = shift;
  if (!$scripto) {$error = 'No setup parameter'; return;}
  my $script = $scripto;
  $script =~ s/[\r\n]+//g;


  my @script = split(';;', $script);

  my $i;
  my $helpfile = "$htmlurl/help/horashelp.html";
  $helpfile =~ s/\//\\/g;


  @parname = splice(@parname, @parname);
  @parvalue = splice(@parvalue, @parvalue);
  @parmode = splice(@parmode, @parmode);
  @parpar = splice(@parpar, @parpar);
  @parfunc = splice(@parfunc,@parfunc);
  @parhelp = splice(@parhelp,@parhelp);

  for ($i = 0; $i < @script; $i++) {
     my @elems = split('~>', $script[$i]);
     $parname[$i] = $elems[0];
     $parvalue[$i] = $elems[1];
	 $parmode[$i] = $elems[2];
	 $parpar[$i] = $elems[3];
     $parfunc[$i] = $elems[4];
	 $parhelp[$i] = $elems[5];
  }

  my ($width, $rpar, @rpar, $size, @size, $range, @range, $j);
  my $tl = 0;

  $input = "<TABLE BORDER=\"2\" CELLPADDING=\"5\" ALIGN=\"CENTER\"><TR>\n";
  $input = "";

  my $k = 0;
  for ($i = 0; $i < @script; $i++) {
     if (!$parmode[$i]) {next;}
     my $v0 = $parvalue[0];


     $input .= "<TR><TD ALIGN=\"left\">\n";

     if ($parmode[$i] !~ /label/) {
	   if ($parhelp[$i] =~ /\#/) {$input .= "<A HREF=\"$helpfile$parhelp[$i]\" TARGET='_new'>\n";}
	   $input .= setfont($dialogfont) . " $parname[$i]";
     $input .= "</FONT>\n";
	   if ($parhelp[$i] =~ /\#/) {$input .= "</A>\n";}
     $input .= " : </TD><TD ALIGN=\"right\">";
     }

     if ($parmode[$i] =~ /^label/i) {
        my $ilabel = $parvalue[$i];
        if ($parpar[$i]) {$ilabel = wrap($ilabel, $parpar[$i], "<BR>\n");}
        $input .= "$ilabel";
        $input .= "<INPUT TYPE=HIDDEN NAME=\'I$k\' VALUE=\'$parvalue[$i]\'>\n";

     } elsif ($parmode[$i] =~ /entry/i) {
       $width = $parpar[$i];
       if (!$width || $width == 0) {$width = 3;}
	   my $jsfunc = '';
	   if ($parfunc[$i]) {$jsfunc = "onchange=\"$parfunc[$i];\"";}
       $input .= "<INPUT TYPE=TEXT NAME=\'I$k\' ID=\'I$k\' $jsfunc SIZE=$width VALUE=\'$parvalue[$i]\'>\n"

     } elsif ($parmode[$i] =~ /^text/i) {
		my @size = split('x',$parpar[$i]);
		if (@size < 2) {@size = (3,12);}
        my $pv = $parvalue[$i];
        $pv =~ s/  /\n/g;

        my $loadfile = strictparam('loadfile');
        if ($loadfile) {
          $loadfile =~ s/\.gen//;
          if (@cm = do_read("$datafolder/gen/$loadfile.gen")) {
            $pv = join('', @cm);
          }
        }

        my $savefile = strictparam('savefile');
        if ($savefile) {
          $savefile =~ s/\.gen//;
          do_write("$datafolder/gen/$savefile.gen", $pv);
        }

        $input .= "<TEXTAREA NAME=\'I$k\' ID=\'I$k\' COLS=$size[1] ROWS=$size[0]>$pv</TEXTAREA><BR>\n";
        $input .= "<A HREF='#' onclick='loadrut();'>";
        $input .= setfont($dialogfont) . "Load</FONT></A>";


     } elsif ($parmode[$i] =~ /checkbutton/i) {
         my $checked = ($parvalue[$i]) ? 'CHECKED' : '';
   	     my $jsfunc = '';
	     if ($parfunc[$i]) {$jsfunc = "onclick=\"$parfunc[$i];\"";}
         $input .= "<INPUT TYPE=CHECKBOX NAME=\'I$k\' ID=\'I$k\' $checked $jsfunc>\n";

     } elsif ($parmode[$i] =~ /^radio/i) {
	     if ($parmode[$i] =~ /vert/i) {$input .= "<TABLE>";}
         $rpar = $parpar[$i];
		 @rpar = split(',', $rpar);
		 for ($j = 1; $j <= @rpar; $j++) {
            my $checked = ($parvalue[$i] == $j) ? 'CHECKED' : '';
            if ($parmode[$i] =~ /vert/i) {$input.="<TR><TD>";}
            my $jsfunc = '';
	        if ($parfunc[$i]) {$jsfunc = "onclick=\"$parfunc[$i];\"";}
			$input .= "<INPUT TYPE=RADIO NAME=\'I$k\' ID=\'I$k\' VALUE=$j $checked $jsfunc>";
            $input .= "<FONT SIZE=\"-1\"> $rpar[$j-1] </FONT>\n";
            if ($parmode[$i] =~ /vert/i) {$input .= "</TD></TR>";}
         }
	     if ($parmode[$i] =~ /vert/i) {$input .= "</TABLE>";}

     } elsif ($parmode[$i] =~ /^updown/i) {
         if (!$parvalue[$i] && $parvalue[$i] != 0) {$parvalue[$i] = 5;}
		 $input .= "<IMG SRC=\"$htmlurl/down.gif\" ALT=down ALIGN=TOP onclick=\"$parfunc[$i]($k,-1)\">\n";
         $input .= "<INPUT TYPE=TEXT NAME=\'I$k\' ID=\'I$k\' SIZE=$parpar[$i] "
		   . "VALUE=$parvalue[$i] onchange=\"$parfunc[$i]($k,0);\">\n";
		 $input .= "<IMG SRC=\"$htmlurl/up.gif\" ALT=up ALIGN=TOP onclick=\"$parfunc[$i]($k,1);\">\n";

      } elsif ($parmode[$i] =~ /^scale/i) {
           $input .= "<INPUT TYPE=TEXT SIZE=6 NAME=\'I$k\' ID=\'I$k\' VALUE=$parvalue[$i]>\n";

     } elsif ($parmode[$i] =~ /filesel/i) { #type=file value is read only
         if ($parpar[$i] =~ /stack/i) {
           $input .= "<INPUT TYPE=RADIO NAME='mousesel' VALUE='stack'"
		    . " onclick=\'mouserut(\"stack$k\");\'>\n";
         }
         $input .= "<INPUT TYPE=TEXT SIZE=16 NAME=\'I$k\' ID=\'I$k\'"
            . " VALUE=\'$parvalue[$i]\'>\n";
         if ($parpar[$i] !~ /stackonly/i) {
           $input .= "<INPUT TYPE=BUTTON VALUE=' ' onclick='filesel(\"I$k\", \"$parpar[$i]\");'>\n";
         }

     } elsif ($parmode[$i] =~ /color/i) {
         my $size = 3;
         if ($parpar[$i]) {$size = $parpar[$i];}
         $input .= "<INPUT TYPE=RADIO NAME='mousesel' VALUE='color'"
		  . " onclick=\'mouserut(\"color$k\");\'>\n";
         $input .= "<INPUT TYPE=TEXT SIZE=8 NAME=\'I$k\' ID=\'I$k\'"
            . " VALUE=\'$parvalue[$i]\'>\n";
         $input .= "<INPUT TYPE=BUTTON VALUE=' ' onclick='colorsel(\"I$k\",$size);'>\n";

     } elsif ($parmode[$i] =~ /font/i) {
         my $size = 16;
         if ($parpar[$i]) {$size = $parpar[$i]};
         $input .= "<INPUT TYPE=TEXT SIZE=$size NAME=\'I$k\' ID=\'I$k\'"
            . " VALUE=\'$parvalue[$i]\'>\n";
         $input .= "<INPUT TYPE=BUTTON VALUE=' ' "
           . "onclick='fontsel(\"I$k\");'>\n";

     } elsif ($parmode[$i] =~ /^option/i) {
	     my $a = $parpar[$i];
		   if (!$a) {$error = "Missing parameter for Optionmenu"; return "";}
		   if ($a =~ /\@/ || ref($a) =~ /ARRAY/i) {@optarray = eval($a);}
		   elsif ($a =~ /^\s*\{(.+)\}\s*$/) {@optarray = split(',', $1);}
		   else {@optarray = getdialogcolumn($a, '~', 0);}
		   my $bgo = $i;
       my $onclick = ($parmode[$i] =~ /select/i) ? "onchange=\'buttonclick(\"$name\");\'" :
		     ($parfunc[$i]) ? "onchange=\"$parfunc[$i];\"" : '';
       while (!(-d "$datafolder/$optarray[-1]")) {pop(@optarray);}

       my $osize = @optarray;
       if ($osize > 5) {$osize = 5;}
       $input .= "<SELECT SIZE=$osize NAME=\'I$k\' ID=\'I$k\' $onclick>\n";
       for ($j = 0; $j < @optarray; $j++) {
         my $pv = $parvalue[$i];
         $pv =~ s/[\[\]]//;
         my $ov = $optarray[$j];
         $ov =~ s/[\[\]]//;
         my $selected = ($pv =~ /^$ov\s*$/i) ?'SELECTED' : '';
         $input .= "<OPTION VALUE=\'$optarray[$j]\' $selected>$optarray[$j]\n";
       }
       $input .= "</SELECT>\n";

     }
     $k++;
     $input .= "</TD></TR>\n";

  }
  $input .= "</TABLE>";

}

# cleanse(s)
# Return tainted string s cleansed of dangerous characters.
sub cleanse($)
{
    my $str = shift;
    unless ( $str =~ /^\w*$/ )
    {
        # Complex params are generally ;-separated chunks where
        # a chunk is either an identifier or a quoted string of assorted chars,
        # possibly preceded by an assignment $id= .
        @parts = split(/;/, $str);
        foreach my $part ( @parts )
        {
            unless ( $part =~ /^([^'`"\\={}()]*|'[^'`"\\]*'|\$\w+='[^'`"\\]*')$/i )
            {
                #print STDERR "erasing $part\n";
                $part = '';
            }
        }
        $str = join(';',@parts)
    }
    return $str;
}

#*** getsetupvalue($name)
# gets the input values of the table and saves the result as $name item into %setup hash
# the setup item contains $var='value' duple semicolon ;; separated lines. Value is
# changed getting param('In') values, where 'n' is a sequence number (0,1,...)
sub getsetupvalue {
  my $name = shift;
  my $script = $setup{$name};
  $script =~ s/\n\s*//g;
  my @script = split(';;', $script);
  eval($script);

  $script = "";
  for ($i = 0; $i < @script; $i++) {
     $script[$i] =~ s/\=/\~\>/;
     my @elems = split('~>', $script[$i]);
     my $value = cleanse($q->param("I$i"));
	 if (!$value && $value ne '0') {$value = '';}
	 if ($value =~ /^on$/) {$value = 1;}
	 $value =~ s/\n/  /g;

   if ($elems[0] =~ /check/i) {$value = $check;}
   my $str = $elems[0] . '=\'' . $value . '\'';
	 eval($str);
	 $script .= "$str;;"
  }
  $setup{$name} = $script;
}



#*** strictparam(name)
# get the parameter value for name, empty string if undef
sub strictparam
{
    my $pstr = shift;
    my $v = cleanse($q->param($pstr));
    $v = '' unless defined $v;

    return $v;
}

#*** setfont($font, $text)
# input font description is "[size][ italic][ bold] color" format, and the text
# returns <FONT ...>$text</FONT> string
sub setfont {
  my $istr = shift;
  my $text = shift;

  my $size = ($istr =~ /^\.*?([0-9\-\+]+)/i) ? $1 : 0;
  my $color = ($istr =~ /([a-z]+)\s*$/i)  ? $1 : '';
  if ($istr =~ /(\#[0-9a-f]+)\s*$/i || $istr =~ /([a-z]+)\s*$/i) {$color = $1;}

  #my $font = "<SPAN STYLE=\"";
  #if ($size) {$font .= "font-size:${size}%; ";}
  #if ($color) {$font .= "color:$color;";}
  #$font .= "\">";
  #if (!$text) {return $font;}

  my $bold = '';
  #my $bolde = '';
  my $italic = '';
  #my $italice = '';
  #if ($istr =~ /bold/) {$bold = "<B>"; $bolde = "</B>";}
  #if ($istr =~ /italic/) {$italic = "<I>"; $italice = "</I>";}
  if ($istr =~ /bold/) {$bold = "b";}
  if ($istr =~ /italic/) {$italic = "i";}


  #return "$font$bold$italic$text$italice$bolde</SPAN>";
  $key="$color$size$bold$italic";

  #unless(exists($fontOverrides{$key})) {die "'$key'=>'' does not exist" ;}

  return "$fontOverrides{$key}$text$fontOverridesEnd{$key}";
}


#*** setcross($line)
# changes +++, ++ + to crosses in the line
# +++ is "make a cross with finger and thumb on lips or heart"
# ++ is "make three crosses with thumb, on forehead, lips, and heart, at the Holy Gospel"
# + is "make a cross over the forehead and abdomen: cross yourself"
# This version uses Unicode entities instead of small GIFs.
sub setcross
{
    my $line = shift;
    my $csubst = '<span class="rd">+</span>'; #the unicode symbols do not display correctly on some eReaders, just use plain + instead
    # Cross type 3: Cross of Lorraine
    #my $csubst = "<span style=\"color:red; font-family:'DejaVu Sans';\">&#x2628;</span>";
    $line =~ s/\+\+\+/$csubst/g;
    # Cross type 2: Greek Cross (Cross of Jerusalem)
    #my $csubst = "<span style=\"color:red; font-family:'DejaVu Sans';\">&#x2720;</span>";
    $line =~ s/\+\+/$csubst/g;
    # cross type 1: Latin Cross
    #my $csubst = "<span style=\"color:red; font-family:'DejaVu Sans';\">&#x271D;</span>";
    $line =~ s/ \+ / $csubst /g;
    return $line;
}

#*** setcell($text1, $lang1);
# output the content of the cell
sub setcell {
  #note this subroutine produces correct output only for the single-column layout
  #the double-column layout is yet to be converted to XHTML

  my $text = shift;

  my $lang = shift;

  my $width = ($only) ? 100 : 50;

    if (columnsel($lang)) { #if this is the primary language
	  $searchind++;
	  #print "<DIV STYLE=\"width: 100%; display: table-row;\">&nbsp;</DIV><DIV STYLE=\"display: table-row;\">";
      if ($notes && $text =~ /\{\:(.*?)\:\}/) {
        my $notefile = $1;
	    $notefile =~ s/^pc/p/;
		my $colspan = ($only) ? 1 : 2;
	    print "<TR><TD COLSPAN=\"$colspan\" WIDTH=\"100%\" VALIGN=\"MIDDLE\" ALIGN=\"CENTER\">\n" .
	    "<IMG SRC=\"$imgurl/$notefile.gif\" WIDTH=\"80%\"></TD></TR>\n";
      }
    if ($text =~ /%([^;].*?)%/) {
      my $q = $1;
      if ($hora =~ /Matutinum/i) {
        $text =~ s{%(.*?)%}{<a href="$date1-2-Laudes.html">$q</a>}i;
      } elsif ($hora =~ /Vespera/i) {
        $text =~ s{%(.*?)%}{<a href="$date1-7-Vespera.html">$q</a>}i;
      } elsif ($hora =~ /Laudes/i) {
         $text =~ s{%(.*?)%}{<a href="$date1-1-Matutinum.html">$q</a>}i;
      }
    }
	}

  #remove auxiliary characters
  $text =~ s/wait[0-9]+//ig;
  $text =~ s/\_/ /g;
  $text =~ s/\{\:.*?\:\}(<BR>)*\s*//g;
  $text =~ s/\{\:.*?\:\}//sg;
  $text =~ s/\`//g;

  $tdtext2 = '';
  if ($column == 1) {$tdtext1 = $text;}
  else {$tdtext2 = $text;}

  $htmltext = '';

  #handle two columns output (if there are two columns)
  if ($column == 2 && !$only) {
    my ($b1, $b2) = longtd($tdtext1, $tdtext2);
        @tdtext1 = @$b1;
        @tdtext2 = @$b2;
    my $item;
    my $i = 0;

        while ($i < @tdtext1 && $i < @tdtext2) {
          $item = $tdtext1[$i];
      if ($i > 0) {$htmltext .= "<DIV STYLE=\"display: table-row;\">";}
              $htmltext .="<DIV CLASS='lang1'>";
      $htmltext .=  setfont($blackfont,$item) . "</DIV>\n";

      $item = $tdtext2[$i];
      $htmltext .="<DIV CLASS='lang2'>";
      $htmltext .=  setfont($blackfont,$item) . "</DIV></DIV>\n";
      if ($extracolumn) {
            $htmltext .="<DIV STYLE=\"width: 10%; display: table-cell; vertical-align: top; text-align: center;\">";
        $htmltext .=  "$filler</DIV>\n";
      }
          if ($filler && $filler ne ' ') {$filler = ' ';}

      $i++;
        }
        @tdtext1 = splice(@tdtext1, @tdtext1);
    @tdtext2 = splice(@tdtext2, @tdtext2);
    print $htmltext;
  }

  #otherwise simply output
  if ($only) {
    #$htmltext .=  "<DIV STYLE=\"width: $width%; vertical-align: top;\">";
    #$htmltext .=  setfont($blackfont,$text) . "</DIV>\n";
    #if ($only || !columnsel($lang)) {$htmltext .= "</DIV>\n";}

    $text =~ s/<BR>/<br \/>/sg;
    #$text =~ s/\n//g;
    print $text;
  }
}

#*** table_start
# start main table
sub table_start {
  #print "<DIV STYLE=\"display:table;\">";
}

#table_end()
# finishes main table
sub table_end {
  #print "</DIV>\n";
}

sub wnum {
  my $item = shift;
  $item =~ s/\<.*?\>//g;
  $item =~ s/\s[a-z]\.\s//ig;
  $item =~ s/[0-9,.,;:\-*]//g;
  $item =~ s/[\{\[\(].*?[\}\]\)]//g;
  $item =~ s/\s+/ /g;
  my @item = split(' ', $item);
  my $n = @item;
  return $n;
}

sub longtd {
  my $celllength = 10000;
  my $a1 = shift;
  my $a2 = shift;

  my @a1 = split('<BR>', $a1);
  my @a2 = split('<BR>', $a2);
  my @b1 = splice(@b1, @b1);
  my @b2 = splice(@b2, @b2);
  my $i;
  my $lim = @a1;
  if (@a2 > $lim) {$lim = @a2;}

  for ($i = 0; $i < $lim; $i++) {
    my $b1 = $a1[$i];
	my $b2 = $a2[$i];
    if (length($b1) < $celllength && length($b2) < $celllength) {
	  if ($b1) {push(@b1, $b1);}
	  if ($b2) {push(@b2, $b2);}
	  next;
	}
	my @c1 = split('|', $b1);
	my @c2 = split('|', $b2);
    my $flag = 0;
	my $i = 0;
	my $s = '';

	while ($i < @c1) {
	  my $c = $c1[$i];
	  $i++;
      if (!$flag && length($s) > $celllength && $c eq '<' && $s) {push(@b1, $s); $s = '';}
	  if ($c eq '<' && $c1[$i] ne '/') {$flag++;}
	  if ($c eq '<' && $c1[$i] eq '/' && $flag) {$flag--;}
	  $s .= $c;
	  if ($flag) {next;}
	  if (($c =~ /[.?]/ && length($s) > $celllength && $i < @c1-1 && $c1[$i] eq ' ' && $c1[$i+1] =~ /[A-Z"]/) ||
	   ($c =~ /[,;:]/ && length($s) > $celllength)) {push(@b1, $s); $s = '';}
    }
	if ($s) {push(@b1, $s);}

	$i = 0;
	$s = '';
	$flag = 0;
	while ($i < @c2) {
	  my $c = $c2[$i];
	  $i++;
      if (!$flag && length($s) > $celllength && $c eq '<' && $s) {push(@b2, $s); $s = '';}
	  if ($c eq '<' && $c2[$i] ne '/') {$flag++;}
	  if ($c eq '<' && $c2[$i] eq '/' && $flag) {$flag--;}
	  $s .= $c;
	  if ($flag) {next;}
	  if (($c =~ /[.?]/ && length($s) > $celllength && $i < @c2-1 && $c2[$i] eq ' ' && $c2[$i+1] =~ /[A-Z"]/) ||
	   ($c =~ /[,;:]/ && length($s) > $celllength)) {push(@b2, $s); $s = '';}
    }
	if ($s) {push(@b2, $s);}

	while (@b1 < @b2) {push(@b1, ' ');}
	while (@b2 && @b2 < @b1) {push(@b2, ' ');}
  }

  return (\@b1, \@b2);
}
