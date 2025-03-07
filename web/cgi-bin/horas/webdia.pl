#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-11-04
# WEB dialogs
#use warnings;
#use strict "refs";
#use strict "subs";
my $a = 4;

#*** htmlHead($title, $onload)
# generate html head
sub htmlHead {
  my ($title, $onload) = @_;

  my ($horasjs) = "<SCRIPT TYPE='text/JavaScript' LANGUAGE='JavaScript1.2'>\n" . horasjs() . '</SCRIPT>';
  $onload && ($onload = " onload=\"$onload\";");

  print <<"PrintTag";
Content-type: text/html; charset=utf-8

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
  <META NAME="Resource-type" CONTENT="Document">
  <META NAME="description" CONTENT="Divine Office">
  <META NAME="keywords" CONTENT="Divine Office, Breviarium, Liturgy, Traditional, Zsolozsma">
  <META NAME="Copyright" CONTENT="Like GNU">
  <meta name="color-scheme" content="dark light">
  <STYLE>
    /* https://www.30secondsofcode.org/css/s/offscreen/ */
    .offscreen {
      border: 0;
      clip: rect(0 0 0 0);
      height: 1px;
      margin: -1px;
      overflow: hidden;
      padding: 0;
      position: absolute;
      width: 1px;
    }
    h1, h2 {
      text-align: center;
      font-weight: normal;
    }
    h2 {
      margin-top: 4ex;
      color: maroon;
      font-size: 112%;
      font-weight: bold;
      font-style: italic;
    }
    p {
      color: black;
    }
    a:link { color: $link; }
    a:visited { color: $visitedlink; }
    body {
      background: $dialogbackground;
    }
    .contrastbg { background: white; }
    .nigra { color: black; }

PrintTag

  if (our $whitebground) {
    print <<"PrintTag";
    \@media (prefers-color-scheme: dark) {
      body {
        background: black;
        color: white;
      }
      table { color: white; }
      a:link { color: #AFAFFF; }
      a:visited { color: #AFAFFF; }
      p { color: white; }
      .contrastbg {
        background: #3F3F3F;
        color: white;
      }
      .nigra {  color: white;  }
      }
PrintTag
  } else {
    print <<"PrintTag";
    \@media (prefers-color-scheme: dark) {
      body {
        background: $dialogbackground;
        color: black;
      }
      select {
        background: lightgrey;
        color: black;
      }
      input[type="select"] {
        background: lightgrey;
        color: black;
      }
      input[type="submit"] {
        background: grey;
        color: black;
      }
      input[type="text"] {
        background: white;
        color: black;
      }
PrintTag
  }

  print <<"PrintTag";
  </STYLE>
  <TITLE>$title</TITLE>
$horasjs
</HEAD>
<BODY $onload>
<FORM ACTION="$officium" METHOD="post" TARGET="_self">
PrintTag
}

sub htmlEnd {
  if ($error) { print "<P ALIGN='CENTER'><FONT COLOR='red'>$error</FONT></P>\n"; }
  if ($debug) { print "<P ALIGN='center'><FONT COLOR='blue'>$debug</FONT></P>\n"; }
  print "</FORM></BODY></HTML>";
}

#*** htmlInput()
# generates html inputs as input, select, checkbox
# parmode = Label | Entry~>'width' | Text~>'rows'x'columns' |
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

sub htmlInput {
  my ($parname, $parvalue, $parmode, $parpar, $parfunc, $parhelp) = @_;
  my $output = '';

  if ($parmode =~ /^label/i) {
    my $ilabel = $parvalue;
    if ($parpar) { $ilabel = wrap($ilabel, $parpar, "<br/>\n"); }
    $output .= "$ilabel";
    $output .= "<INPUT TYPE='HIDDEN' NAME=\'$parname\' VALUE=\'$parvalue\'>\n";
  } elsif ($parmode =~ /entry/i) {
    $width = $parpar;
    if (!$width || $width == 0) { $width = 3; }
    my $jsfunc = '';
    if ($parfunc) { $jsfunc = "onchange=\"$parfunc;\""; }
    $output .= "<INPUT TYPE='TEXT' NAME=\'$parname\' ID=\'$parname\' $jsfunc SIZE=$width VALUE=\'$parvalue\'>\n";
  } elsif ($parmode =~ /^text/i) {
    my @size = split('x', $parpar);
    if (@size < 2) { @size = (3, 12); }
    my $pv = $parvalue;
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
    $output .= "<TEXTAREA NAME=\'$parname\' ID=\'$parname\' COLS='$size[1]' ROWS='$size[0]'>$pv</TEXTAREA><br/>\n";
    $output .= "<A HREF='#' onclick='loadrut();'>";
    $output .= setfont($dialogfont) . "Load</FONT></A>";
  } elsif ($parmode =~ /checkbutton/i) {
    my $checked = ($parvalue) ? 'CHECKED' : '';
    my $jsfunc = '';
    if ($parfunc) { $jsfunc = "onclick=\"$parfunc;\""; }
    $output .= "<INPUT TYPE='CHECKBOX' NAME=\'$parname\' ID=\'$parname\' $checked $jsfunc>\n";
  } elsif ($parmode =~ /^radio/i) {
    if ($parmode =~ /vert/i) { $output .= "<TABLE>"; }
    $rpar = $parpar;
    @rpar = split(',', $rpar);

    for ($j = 1; $j <= @rpar; $j++) {
      my $checked = ($parvalue == $j) ? 'CHECKED' : '';
      if ($parmode =~ /vert/i) { $output .= "<TR><TD>"; }
      my $jsfunc = '';
      if ($parfunc) { $jsfunc = "onclick=\"$parfunc;\""; }
      $output .= "<INPUT TYPE=RADIO NAME=\'$parname\' ID=\'$parname\' VALUE=$j $checked $jsfunc>";
      $output .= "<FONT SIZE=-1> $rpar[$j-1] </FONT>\n";
      if ($parmode =~ /vert/i) { $output .= "</TD></TR>"; }
    }
    if ($parmode =~ /vert/i) { $output .= "</TABLE>"; }
  } elsif ($parmode =~ /^updown/i) {
    if (!$parvalue && $parvalue != 0) { $parvalue = 5; }
    $output .= "<IMG SRC=\"$htmlurl/down.gif\" ALT=down ALIGN=TOP onclick=\"$parfunc($parpos,-1)\">\n";
    $output .= "<INPUT TYPE=TEXT NAME=\'$parname\' ID=\'$parname\' SIZE=$parpar "
      . "VALUE=$parvalue onchange=\"$parfunc($parpos,0);\">\n";
    $output .= "<IMG SRC=\"$htmlurl/up.gif\" ALT=up ALIGN=TOP onclick=\"$parfunc($parpos,1);\">\n";
  } elsif ($parmode =~ /^scale/i) {
    $output .= "<INPUT TYPE=TEXT SIZE=6 NAME=\'$parname\' ID=\'$parname\' VALUE=$parvalue>\n";
  } elsif ($parmode =~ /filesel/i) {    #type=file value is read only
    if ($parpar =~ /stack/i) {
      $output .= "<INPUT TYPE=RADIO NAME='mousesel' VALUE='stack'" . " onclick=\'mouserut(\"stack$parpos\");\'>\n";
    }
    $output .= "<INPUT TYPE=TEXT SIZE=16 NAME=\'$parname\' ID=\'$parname\'" . " VALUE=\'$parvalue\'>\n";

    if ($parpar !~ /stackonly/i) {
      $output .= "<INPUT TYPE=BUTTON VALUE=' ' onclick='filesel(\"$parname\", \"$parpar\");'>\n";
    }
  } elsif ($parmode =~ /color/i) {
    my $size = 3;
    if ($parpar) { $size = $parpar; }
    $output .= "<INPUT TYPE=RADIO NAME='mousesel' VALUE='color'" . " onclick=\'mouserut(\"color$parpos\");\'>\n";
    $output .= "<INPUT TYPE=TEXT SIZE=8 NAME=\'$parname\' ID=\'$parname\'" . " VALUE=\'$parvalue\'>\n";
    $output .= "<INPUT TYPE=BUTTON VALUE=' ' onclick='colorsel(\"$parname\",$size);'>\n";
  } elsif ($parmode =~ /font/i) {
    my $size = 16;
    if ($parpar) { $size = $parpar }
    $output .= "<INPUT TYPE=TEXT SIZE=$size NAME=\'$parname\' ID=\'$parname\'" . " VALUE=\'$parvalue\'>\n";
    $output .= "<INPUT TYPE=BUTTON VALUE=' ' " . "onclick='fontsel(\"$parname\");'>\n";
  } elsif ($parmode =~ /^option/i) {
    my $a = $parpar;
    if (!$a) { $error = "Missing parameter for Optionmenu"; return ""; }

    if ($a =~ /\@/ || ref($a) =~ /ARRAY/i) {
      @optarray = eval($a);
    } elsif ($a =~ /^\s*\{(.+)\}\s*$/) {
      @optarray = split(',', $1);
    } else {
      @optarray = getdialog($a);
    }
    my $onclick =
        ($parmode =~ /select/i) ? "onchange=\'buttonclick(\"$command\");\'"
      : ($parfunc) ? qq(onchange="$parfunc;")
      : '';
    my $osize = @optarray;
    chomp($optarray[-1]);
    $output .= "<SELECT ID=$parname NAME=$parname SIZE=1 $onclick>\n";

    foreach (@optarray) {
      my ($display, $value) = split(/\//);
      $value ||= $display;
      my $selected = $value eq $parvalue ? 'SELECTED' : '';
      $output .= "<OPTION $selected VALUE=\"$value\">$display\n";
    }
    $output .= "</SELECT>\n";
  }
  return $output;
}

#*** cleanse(s)
# Return tainted string s cleansed of dangerous characters.
sub cleanse($) {
  my $str = shift;

  unless ($str =~ /^\w*$/) {

    # Complex params are generally ;-separated chunks where
    # a chunk is either an identifier or a quoted string of assorted chars,
    # possibly preceded by an assignment $id= .
    @parts = split(/;/, $str);

    foreach my $part (@parts) {
      unless ($part =~ /^([^'`"\\={}()]*|'[^'`"\\]*'|\$\w+='[^'`"\\]*')$/i) {    #`

        #print STDERR "erasing $part\n";
        $part = '';
      }
    }
    $str = join(';', @parts);
  }
  return $str;
}

#*** beep()
# generates a beep sound. Inactive in cgi version
sub beep {
}

#*** strictparam(name)
# get the parameter value for name, empty string if undef
sub strictparam {
  my $pstr = shift;
  my $v = cleanse($q->param($pstr));
  $v = '' unless defined $v;
  return $v;
}

#*** clean_setupsave($setupsave)
# Takes a settings string in the format stored in the cookies, and returns a
# cleaned version.
sub clean_setupsave {
  my $setupsave = shift;
  $setupsave =~ s/[‘’]|\x{e2}\x{80}(\x{98}|\x{99})/'/g;
  return $setupsave;
}

#*** setfont($font, $text)
# input font description is "[size][ italic][ bold] color" format, and the text
# returns <FONT ...>$text</FONT> string
sub setfont {
  my $istr = shift;
  my $text = shift;
  return $text unless $istr;

  my $size = ($istr =~ /^\.*?([0-9\-\+]+)/i) ? $1 : 0;
  my $color = ($istr =~ /([a-z]+)\s*$/i) ? $1 : '';
  if ($istr =~ /(\#[0-9a-f]+)\s*$/i || $istr =~ /([a-z]+)\s*$/i) { $color = $1; }
  $color = '' if $color eq 'italic';                                    # italic is not a color
  my $font = "<FONT ";
  if ($size) { $font .= "SIZE='$size' "; }
  if ($color && $color !~ /black/i) { $font .= "COLOR=\"$color\""; }    # black not explictly for dark mode
  $font .= ">";
  if (!$text) { return $font; }
  my $bold = '';
  my $bolde = '';
  my $italic = '';
  my $italice = '';
  if ($istr =~ /bold/) { $bold = "<B>"; $bolde = "</B>"; }
  if ($istr =~ /italic/) { $italic = "<I>"; $italice = "</I>"; }
  return "$font$bold$italic$text$italice$bolde</FONT>";
}

# Fetch and cleanse cookies
sub fetch_cookies() {
  my %cookies = fetch CGI::Cookie;
  $_->value(cleanse($_->value)) for values %cookies;
  return %cookies;
}

#*** getcookies($cname, $setupname)
# get the cookie named as cname and sets the values into $setupname group
# separates the perl scripts from the stack array
# return the perl script string and the array reference
sub getcookies {

  my $cname = shift;
  my $name = shift;
  my @sti = splice(@sti, @sti);
  my $sti = '';
  my $checkname = $name . 'check';

  $check = getsetup($checkname);
  $check =~ s/\s//g;
  %cookies = fetch_cookies();

  foreach (keys %cookies) {
    my $c = $cookies{$_};
    if ($c->name eq $cname) { $sti = $c->value; }
  }

  if ($sti) {
    @sti = split(';;;', $sti);
    my $param = getsetup($name);
    $param =~ s/\;\;\s*$//;
    my @param = split(';;', $param);

    #check if the structure of the parameters is the same
    if (@sti > @param + 1 || ($check !~ /^$sti[-1]/)) {
      $error = "Cookie $cname mismatch $name need $check has $param<br/>== $sti[-1]";
      return 0;
    }
    setsetup($name, @sti);
    return 1;
  }
  return 0;
}

#*** setcookies($cname, $name)
#saves $name setup table as cookie named $cname
sub setcookies {

  my $cname = shift;
  my $name = shift;
  my @values = split(';;', getsetup($name));
  my $value = '';
  my $checkname = $name . 'check';

  $check = getsetup($checkname);
  $check =~ s/\s//g;

  if (!$values[-1]) {
    $values[-1] = $check;
  }

  foreach (@values) {
    my @a = split('=', $_);
    $value .= "$a[1]";
    while ($value !~ /\;\;\;$/) { $value .= ';' }
  }
  $value .= "$check;;;";
  $value =~ s/\r*\n/  /g;
  $c = $q->cookie(
    -name => "$cname",
    -value => "$value",
    -expires => "$cookieexpire",
  );

  if (length($c) < 4096) {
    print "Set-Cookie:$c\n";
  } else {
    $error .= 'Command/stack is longer than 4095 characters';
  }
  return "$c";
}

#cookie for recognize the new day
sub setcookie1 {
  my $cname = shift;
  my $value = shift;
  my @t = localtime(time() + 60 * 60 * 24);
  my $t = timelocal($t[0], $t[1], $t[2], $t[3], $t[4], $t[5]);
  $c = $q->cookie(
    -name => "$cname",
    -value => "$value",
    -expires => $t,
  );
  print "Set-Cookie:$c\n";
}

sub getcookie1 {
  my $cname = shift;
  my $sti = 0;
  %cookies = fetch_cookies();

  foreach (keys %cookies) {
    my $c = $cookies{$_};
    if ($c->name =~ /$cname/) { $sti = $c->value; }
  }
  return $sti;
}

#*** setcross($line)
# changes +++, ++ + to crosses in the line
# +++ is "make a cross with finger and thumb on lips or heart"
# ++ is "make three crosses with thumb, on forehead, lips, and heart, at the Holy Gospel"
# + is "make a cross over the forehead and abdomen: cross yourself"
# This version uses Unicode entities instead of small GIFs.
sub setcross {
  $_[0] =~ s/ (\+{1,3}) /" <span style='color:red; font-size:1.25em'>" .
                          ($nofancychars ? $1 : $1 eq '+++' ? '✙︎' :
                                                $1 eq '++' ? '+' : '✠') .
                          "<\/span> "/ger;
}

#*** setvrbar($line)
# set R- & V-bar
sub setvrbar {
  my $line = shift;
  if ($nofancychars) { return $line; }
  $line =~ s/^V\./℣./g;
  $line =~ s/^R\./℟./g;
  return $line;
}

#*** activate_links($text)
# replace %Laudes% etc. with html link
sub activate_links {
  my ($text, $lang) = @_;
  our ($date1, $caller, $version, $testmode, $lang2, $votive, $hora, $command);
  local ($_) = $$text;

  if ($officium =~ /Pofficium/i) {
    if ($hora =~ /Matutinum/i) {
      s{%(.*?)%}{<A HREF="Pofficium.pl?date1=$date1&caller=$caller&command=prayLaudes&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">$1</A>}i;
    } elsif ($hora =~ /Vespera/i) {
      s{%(.*?)%}{<A HREF="Pofficium.pl?date1=$date1&caller=1&command=prayVespera&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">$1</A>}i;
    } elsif ($hora =~ /Laudes/i) {
      s{%(.*?)%}{<A HREF="Pofficium.pl?date1=$date1&caller=1&command=prayMatutinum&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">$1</A>}i;
    } elsif ($command =~ /Appendix/i) {
      s{%(.*?)%}{qq(<A HREF="Pofficium.pl?date1=$date1&caller=1&command=Appendix $1&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">) . translate($1, $lang) . '</A>'}ie;
    }
  } else {
    if ($hora =~ /Matutinum/i) {
      s{%(.*?)%}{<A HREF="#" onclick="hset('Laudes');">$1</A>}i;
    } elsif ($hora =~ /Vespera/i) {
      s{%(.*?)%}{<A HREF="#" onclick="defunctorum('Vespera');">$1</A>}i;
    } elsif ($hora =~ /Laudes/i) {
      s{%(.*?)%}{<A HREF="#" onclick="defunctorum('Matutinum');">$1</A>}i;
    } elsif ($command =~ /Appendix/i) {
      s{%(.*?)%}{'<A HREF="#" onclick="appendix(\''. $1. '\');">' . translate($1, $lang) . '</A>'}ie;
    }
  }
  $_;
}

#*** setcell($text1, $lang1);
# output the content of the cell
sub setcell {
  my $text = shift;
  my $lang = shift;
  my $width = ($only) ? 100 : 50;

  return unless ($text && $text !~ /^[_\s]+$/);
  $text = resolve_refs($text, $lang);
  return unless $text;    # No empty cells in 'Lineamenta'

  if (!$Ck) {
    if (columnsel($lang)) {
      $searchind++ if ($text !~ /{omittitur}/);
      print "<TR>";    # unless $officium =~ /Eofficium/;

      if ($notes && $text =~ /\{\:(.*?)\:\}/) {
        my $notefile = $1;
        $notefile =~ s/^pc/p/;
        my $colspan = ($only) ? 1 : 2;
        print "<TR><TD COLSPAN='$colspan' WIDTH='100%' VALIGN='MIDDLE' ALIGN='CENTER'>\n"
          . "<IMG SRC=\"$imgurl/$notefile.gif\" WIDTH='80%'></TD></TR>\n";
      }
    }
    print "<TD VALIGN='TOP' WIDTH='$width%'"
      . ($lang1 ne $lang || $text =~ /{omittitur}/ ? "" : " ID='$hora$searchind'") . ">";
    print "<p>" if $officium =~ /Eofficium|Emissa/;
    topnext_cell(\$text, $lang) unless $popup || $officium =~ /Eofficium|Emissa/;
  }

  process_inline_alleluias(\$text, $dayname[0] =~ /Pasc/) unless $missa;    # missa use own solution
                                                                            # which should removed

  suppress_alleluia(\$text) if ($dayname[0] =~ /Quadp|Quad[1-5]|Quad6-[0-5]/i && ($missa || !Septuagesima_vesp()));

  $text =~ s/\<br\/\>\s*\<br\/\>/\<br\/\>/ig;
  if ($lang =~ /Latin/i) { $text = spell_var($text); }

  if ($text =~ /%(.*?)%/) {
    $text = activate_links(\$text, $lang);
  }
  $text =~ s/wait[0-9]+//ig;
  $text =~ s/\_/ /g;

  # $text =~ s/\{\:.*?\:\}(<br/>)*\s*//g;
  $text =~ s/\{\:.*?\:\}//sg;
  $text =~ s/\`//g;                                      #`
  $text =~ s/\s([»!?;:])/&nbsp;$1/g;                     # no-break space before punctutation (mostly French)
  $text =~ s/«\s/«&nbsp;/g unless $lang eq 'Deutsch';    # no-break space after begin quote
  $text =~ s/\s\&\s/ &amp; /;                            # HTML - Ampersand;
  $text =~
    s/↊|\&\#x218a\;/<span style='color:grey; display:inline-block; transform: rotate(180deg) translate(-40%, 15%);'>2<\/span><span style='color:grey; display:inline-block; transform: translate(-100%, 16%);'>.<\/span>/gu;

  if ($Ck) {
    if ($column == 1) {
      push(@ctext1, $text);
    } else {
      push(@ctext2, $text);
    }

    #  } elsif ($officium =~ /Eofficium/) {
    #    print $text;
  } else {
    $text .= '</p>' if $officium =~ /Eofficium|Emissa/;
    print setfont($blackfont, $text) . "</TD>\n";
    if (!columnsel($lang) || $only) { print "</TR>\n"; }
  }
}

#*** topnext_Cell()
#prints T N for positioning
sub topnext_cell {
  if ($officium =~ /Pofficium/i) { return; }
  my ($text, $lang) = @_;
  my @a = split('<br/>', $$text);

  if (@a > 2 && $expand ne 'lineamenta') {
    my $str = "<DIV ALIGN='right'><FONT SIZE='1' COLOR='green'>";

    if (columnsel($lang)) {
      $str .= "<A HREF='#${hora}top'>Top</A>&nbsp;&nbsp;";
      $str .= "<A HREF='#$hora" . ($searchind + 1) . "'>Next</A>";
    } else {
      $str .= "$searchind";
    }
    $str .= "</FONT></DIV>\n";
    print $str;
  }
}

#*** table_start
# start main table
sub table_start {
  if ($Ck) {
    @ctext1 = splice(@ctext1, @ctext1);
    @ctext2 = splice(@ctext2, @ctext2);
  }
  my $width =
    ($textwidth && $textwidth =~ /^[0-9]+$/ && 0 < $textwidth && $textwidth <= 100)
    ? "$textwidth\%"
    : '80%';
  print "<TABLE BORDER='$border' ALIGN='CENTER' CELLPADDING='8' WIDTH='$width' $background>";
}

#antepost('$title')
# prints Ante of Post call
sub ante_post {
  my $title = shift;
  if ($Ck) { return; }
  my $colspan = ($only) ? '' : 'COLSPAN="2"';
  print "<TR><TD VALIGN='TOP' $colspan ALIGN='CENTER'>\n";

  if ($0 =~ /missa/) {
    print "<A HREF=\"mpopup.pl?popup=$title&rubrics=$rubrics&lang1=$lang1&lang2=$lang2\" TARGET='_NEW'>$title</A>\n";
    print "<FONT SIZE='1'>Missam</FONT></TD></TR>";
  } else {
    print "<INPUT TYPE='RADIO' NAME='link' onclick='linkit(\"\$$title\", 0, \"Latin\");'>\n";
    print "<FONT SIZE='1'>$title Divinum officium</FONT></TD></TR>";
  }
}

#table_end()
# finishes main table
sub table_end {
  if ($Ck) {
    my $width = ($only) ? 100 : 50;
    print "<TR><TD VALIGN='TOP' WIDTH='$width%'>\n";
    my $item;
    my $len1 = 0;
    foreach $item (@ctext1) { print "$item<br/>\n"; $len1 += wnum($item); }
    print "</TD>\n";

    if (!$only) {
      $len2 = 0;
      print "<TD VALIGN='TOP' WIDTH='$width%'>\n";
      foreach $item (@ctext2) { print "$item<br/>\n"; $len2 += wnum($item); }
      print "</TD></TR>\n";
    }
    print "<TR><TD VALIGN='TOP' WIDTH='$width%'><FONT SIZE='1'>$len1 words</FONT></TD>";

    if (!$only) {
      print "<TD VALIGN='TOP' WIDTH='$width%'><FONT SIZE='1'>$len2 words</FONT></TD></TR>";
    }
  }
  print "</TABLE><A ID='$hora$searchind'></A>";
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

#*** linkcode($name, $ind, $lang, $disabled)
# set a link line
sub linkcode {
  my ($name, $ind, $lang, $disabled) = @_;

  # We need to mask paranthesis to be passed via JavaScript to popup.pl
  $name =~ s/\(/\&lpar/;
  $name =~ s/\)/\&rpar/;
  $name =~ s/\'/\&apos/g;
  return "<INPUT TYPE='RADIO' NAME='link' $disabled onclick='linkit(\"$name\", $ind, \"$lang\");'>";
}

#*** linkcode1()
# sets a collpse radiobutton
sub linkcode1 {
  return "&ensp;" . "<INPUT TYPE='RADIO' NAME='collapse' onclick=\"linkit('','10000','');\">\n";
}

sub option_selector {
  my ($label, $onchange, $default, @options) = @_;
  my $id = $label;
  $id =~ s/\s+//g;
  $id = lc($id);
  my $output = "&ensp;<LABEL FOR='$id' CLASS='offscreen'>$label</LABEL>\n";
  $output .= sprintf("<SELECT ID='%s' NAME='%s' SIZE='%d' onchange=\"%s\">\n", $id, $id, 1, $onchange);

  foreach (@options) {
    my ($display, $value) = split(/;/);
    $value = $display unless $value;
    $output .= sprintf("<OPTION %s VALUE=\"%s\">%s\n", ($value eq $default) ? 'SELECTED' : '', $value, $display);
  }
  return $output . "</SELECT>\n";
}

#*** selectables
# generate selects from .dialog data
sub selectables {
  my ($dialog) = @_;
  my (@output);

  foreach (split(/;;\n*/, getdialog($dialog))) {
    my ($parname, $parvar, $parmode, $parpar, $parpos, $parfunc, $parhelp) = split('~>');
    my $parvalue = eval($parvar);
    my $parlabel = $parname;
    $parname = substr($parvar, 1);
    my $output = "<LABEL FOR='$parname' CLASS='offscreen'>$parlabel</LABEL>\n";
    $output .= htmlInput($parname, $parvalue, $parmode, $parpar, 'parchange()', $parhelp);
    push(@output, $output);
  }
  join('&ensp;', @output);
}

#*** selectable_p
# generate signle select from .dialog for Poffice
sub selectable_p {
  my ($dialog, $curvalue, $date1, $version, $lang2, $votive, $testmode, $title) = @_;
  $title ||= ucfirst($dialog);
  if ($dialog eq 'votives') { $curvalue ||= 'Hodie' }
  my @output = ("<TR><TD ALIGN='CENTER'>$title");

  foreach (getdialog($dialog)) {
    chomp;
    my ($text, $name) = split(/\//);
    $name ||= $text;
    my $href =
        "Pofficium.pl?date1=$date1&version="
      . ($dialog eq 'versions' ? $name : $version)
      . "&testmode=$testmode&lang2="
      . ($dialog eq 'languages' ? $name : $lang2)
      . "&votive="
      . ($dialog eq 'votives' ? $name : $votive);
    my $colour = $curvalue eq $name ? 'red' : '';
    push(@output, qq(\n<A HREF="$href"><FONT COLOR=$colour>$text</FONT></A>));
  }
  join('<br/>', @output) . "</TD></TR>\n";
}

sub horas_menu {
  my ($completed, $date1, $version, $lang2, $votive, $testmode) = @_;
  my @horas = gethoras($votive eq 'C9');
  push(@horas, 'Omnes', 'Plures') if ($0 !~ /Cofficium/);

  my $i = 0;
  my $output = '';

  foreach (@horas) {
    $i += 1;
    my $href = '#';
    my $onclick = '';

    if ($0 =~ /Pofficium/) {
      $href = qq("Pofficium.pl?date1=$date1&command=pray$_)
        . qq(&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive");
    } else {
      $onclick = qq(onclick="hset('$_');");
    }
    $output .= qq(\n<A HREF=$href $onclick>$_</A>\n);

    if (($0 =~ /Pofficium/ && $votive ne 'C9' && ($i == 2 || $i == 6)) || (($i == (@horas - 2)) && ($0 !~ /Cofficium/)))
    {
      $output .= '<br/>';
    } else {
      $output .= '&nbsp;&nbsp;';
    }
  }

  # For Cistercian version (not to complicate other versions) added the option to click on next day's Lauds
  if ( $version =~ /Cist/i ) {
    $output .= qq(\n<A HREF=# onclick="prevnext(1);hset('Laudes')"><FONT COLOR=$colour>Laudes crastinæ</FONT></A>\n) if ( $0 !~ /Cofficium/ );
    $output .= '&nbsp;&nbsp;';
  }

  my $a =
    ($0 =~ /Pofficium/)
    ? qq(HREF="Pofficium.pl?date1=$date1&command=Appendix Index)
    . qq(&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive")
    : qq(HREF="#" onclick="appendix('Index')");
  $output .= qq(\n<A $a><FONT COLOR=$colour>Appendix</FONT></A>\n) if ($0 !~ /Cofficium/);
  $a = qq(HREF="#" onclick="callkalendar('kalendar')");
  $output .= qq(&nbsp;&nbsp;\n<A $a><FONT COLOR=$colour>Kalendarium</FONT></A>\n) if ($0 !~ /Pofficium/);
  $output;
}

sub bottom_links_menu {
  my ($compare) = shift;

  my @options = map { "<A HREF=\"../../www/horas/Help/" . lcfirst($_) . ".html\" TARGET=\"_BLANK\">$_</A>\n"; }
    qw(Versions Credits Download Rubrics Technical Help);
  join("&emsp;\n", @options);
}

#*** html_dayhead($head, $subhead)
# return day headline in html
sub html_dayhead {
  my ($head, $subhead) = @_;

  my $output = setfont(liturgical_color($head), $head);

  if ($subhead) {
    ($pre, $main) = split(/: /, $subhead, 2);
    $output .= "<br/>\n<SPAN STYLE=\"font-size:82%; color:maroon;\"><I>$pre";
    $output .= ": " . setfont(liturgical_color($main, ''), $main) if $main;
    $output .= "</I></SPAN>\n";
  }
  $output =~ s/\s\&\s/ &amp; /;    # HTML - ampersand
  $output;
}

sub print_content {
  my ($lang1, $script1, $lang2, $script2, $antepost) = @_;
  our $version, $version1, $version2, $only, $expandind, $column;
  my ($ind1, $ind2);

  table_start();
  ante_post('Ante') if $antepost;

  while ($ind1 < @$script1 || $ind2 < @$script2) {
    $column = 1;
    $version = $version1 if $Ck;
    ($text, $ind1) = getunit($script1, $ind1);

    $expandind++ if ($text =~ /^\#/);
    setcell($text, $lang1);

    if (!$only) {
      $column = 2;
      $version = $version2 if $Ck;
      ($text, $ind2) = getunit($script2, $ind2);
      setcell($text, $lang2);
    } else {
      $ind2 = $ind1;
    }
  }
  ante_post('Post') if $antepost;
  table_end();
}

#*** getunits(\@s, $ind)
# break the array into units separated by double newlines
# from $ind to the returned new $ind
sub getunit {
  my $s = shift;
  my @s = @$s;
  my $ind = shift;
  my $t = '';

  while ($ind < @s) {
    my $line = chompd($s[$ind]);
    $ind++;
    if ($line && !($line =~ /^\s+$/)) { $t .= "$line\n"; next; }
    if (!$t) { next; }
    last;
  }

  return ($t, $ind);
}

#*** sub expand($line, $lang, $antline)
# for & references calls the sub
# $ references are filled from Psalterium/Prayers file
# antline to handle redding the beginning of psalm is same as antiphona
# returns the expanded text or the link
sub expand {
  use strict;
  my ($line, $lang, $antline) = @_;
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;

  # Extract and remove the sigil indicating the required expansion type.
  # TODO: Fail more drastically when the sigil is invalid.
  $line =~ s/^([&\$](?:rubrica |Preces )?)// or return $line;
  my $sigil = $1;
  our ($expand, $missa);
  local $expand = $missa ? 'all' : $expand;

  # Make popup link if we shouldn't expand.
  if (
    $sigil ne '$rubrica '
    && ($expand eq 'propria'
      || ($expand eq 'psalteria' && ($line =~ /^(?:[A-Z](?!men)|pater_noster)/)))
  ) {
    setlink($sigil . $line, 0, $lang);
  } elsif ($sigil eq '&') {

    # Actual expansion for & references.
    # Get function name and any parameters.
    my ($function_name, $arg_string) = ($line =~ /(.*?)(?:[(](.*)[)])?$/);
    my @args = (parse_script_arguments($arg_string), $lang);

    # If we have an antiphon, pass it on to the script function.
    if ($antline) {
      $antline =~ s/^\s*Ant\. //i;
      push @args, $antline;
    }
    dispatch_script_function($function_name, @args);
  } elsif ($sigil eq '$rubrica ') {
    rubric($line, $lang);
  } elsif ($sigil eq '$Preces ') {
    prex("Preces $line", $lang);
  } else {    # Sigil is $, so simply look up the prayer.
    prayer($line, $lang);
  }
}
