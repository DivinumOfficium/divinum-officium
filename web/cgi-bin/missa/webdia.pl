#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ ‡
# Name : Laszlo Kiss
# Date : 01-11-04
# WEB dialogs
#use warnings;
#use strict "refs";
#use strict "subs";
my $a = 4;

#*** htmlHead($title, $flag)
# generated the standard head with $title
sub htmlHead {
  my $title = shift;
  my $flag = shift;
  if (!$title) { $title = ' '; }
  print "Content-type: text/html; charset=utf-8\n\n";
  print << "PrintTag";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
  <META NAME="Resource-type" CONTENT="Document">
  <META NAME="description" CONTENT="Divine Office">
  <META NAME="keywords" CONTENT="Divine Office, Breviarium, Liturgy, Traditional, Zsolozsma">
  <META NAME="Copyright" CONTENT="Like GNU">
  <TITLE>$title</TITLE>
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
  </STYLE>
PrintTag
  if ($flag == 2) { horasjs(); }
  print "</HEAD>";
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
  if (!$name) { $name = "noname"; }
  my $scripto = shift;
  if (!$scripto) { beep(); $error = 'No setup parameter'; return; }
  my $script = $scripto;
  $script =~ s/[\r\n]+//g;
  my @script = split(';;', $script);
  my $i;
  my $helpfile = "$htmlurl/../horashelp/horashelp.html";
  $helpfile =~ s/\//\\/g;
  @parname = splice(@parname, @parname);
  @parvalue = splice(@parvalue, @parvalue);
  @parmode = splice(@parmode, @parmode);
  @parpar = splice(@parpar, @parpar);
  @parfunc = splice(@parfunc, @parfunc);
  @parhelp = splice(@parhelp, @parhelp);

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
  $input = "<TABLE BORDER=2 CELLPADDING=5 ALIGN=CENTER BACKGROUND=\"$htmlurl/horasbg.jpg\"><TR>\n";
  my $k = 0;

  for ($i = 0; $i < @script; $i++) {
    if (!$parmode[$i]) { next; }
    my $v0 = $parvalue[0];
    $input .= "<TR><TD ALIGN=left>\n";

    if ($parmode[$i] !~ /label/) {
      if ($parhelp[$i] =~ /\#/) { $input .= "<A HREF=\"$helpfile$parhelp[$i]\" TARGET='_new'>\n"; }
      $input .= setfont($dialogfont) . " $parname[$i]";
      $input .= "</FONT>\n";
      if ($parhelp[$i] =~ /\#/) { $input .= "</A>\n"; }
      $input .= " : </TD><TD ALIGN=right>";
    }

    if ($parmode[$i] =~ /^label/i) {
      my $ilabel = $parvalue[$i];
      if ($parpar[$i]) { $ilabel = wrap($ilabel, $parpar[$i], "<BR>\n"); }
      $input .= "$ilabel";
      $input .= "<INPUT TYPE=HIDDEN NAME=\'I$k\' VALUE=\'$parvalue[$i]\'>\n";
    } elsif ($parmode[$i] =~ /entry/i) {
      $width = $parpar[$i];
      if (!$width || $width == 0) { $width = 3; }
      my $jsfunc = '';
      if ($parfunc[$i]) { $jsfunc = "onchange=\"$parfunc[$i];\""; }
      $input .= "<INPUT TYPE=TEXT NAME=\'I$k\' ID=\'I$k\' $jsfunc SIZE=$width VALUE=\'$parvalue[$i]\'>\n";
    } elsif ($parmode[$i] =~ /^text/i) {
      my @size = split('x', $parpar[$i]);
      if (@size < 2) { @size = (3, 12); }
      my $pv = $parvalue[$i];
      $pv =~ s/  /\n/g;
      my $loadfile = strictparam('loadfile');

      if ($loadfile) {
        $loadfile =~ s/\.gen//;
        $pv = join("\n", do_read("$datafolder/gen/$loadfile.gen"));
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
      if ($parfunc[$i]) { $jsfunc = "onclick=\"$parfunc[$i];\""; }
      $input .= "<INPUT TYPE=CHECKBOX NAME=\'I$k\' ID=\'I$k\' $checked $jsfunc>\n";
    } elsif ($parmode[$i] =~ /^radio/i) {
      if ($parmode[$i] =~ /vert/i) { $input .= "<TABLE>"; }
      $rpar = $parpar[$i];
      @rpar = split(',', $rpar);

      for ($j = 1; $j <= @rpar; $j++) {
        my $checked = ($parvalue[$i] == $j) ? 'CHECKED' : '';
        if ($parmode[$i] =~ /vert/i) { $input .= "<TR><TD>"; }
        my $jsfunc = '';
        if ($parfunc[$i]) { $jsfunc = "onclick=\"$parfunc[$i];\""; }
        $input .= "<INPUT TYPE=RADIO NAME=\'I$k\' ID=\'I$k\' VALUE=$j $checked $jsfunc>";
        $input .= "<FONT SIZE=-1> $rpar[$j-1] </FONT>\n";
        if ($parmode[$i] =~ /vert/i) { $input .= "</TD></TR>"; }
      }
      if ($parmode[$i] =~ /vert/i) { $input .= "</TABLE>"; }
    } elsif ($parmode[$i] =~ /^updown/i) {
      if (!$parvalue[$i] && $parvalue[$i] != 0) { $parvalue[$i] = 5; }
      $input .= "<IMG SRC=\"$htmlurl/down.gif\" ALT=down ALIGN=TOP onclick=\"$parfunc[$i]($k,-1)\">\n";
      $input .= "<INPUT TYPE=TEXT NAME=\'I$k\' ID=\'I$k\' SIZE=$parpar[$i] "
        . "VALUE=$parvalue[$i] onchange=\"$parfunc[$i]($k,0);\">\n";
      $input .= "<IMG SRC=\"$htmlurl/up.gif\" ALT=up ALIGN=TOP onclick=\"$parfunc[$i]($k,1);\">\n";
    } elsif ($parmode[$i] =~ /^scale/i) {
      $input .= "<INPUT TYPE=TEXT SIZE=6 NAME=\'I$k\' ID=\'I$k\' VALUE=$parvalue[$i]>\n";
    } elsif ($parmode[$i] =~ /filesel/i) {    #type=file value is read only
      if ($parpar[$i] =~ /stack/i) {
        $input .= "<INPUT TYPE=RADIO NAME='mousesel' VALUE='stack'" . " onclick=\'mouserut(\"stack$k\");\'>\n";
      }
      $input .= "<INPUT TYPE=TEXT SIZE=16 NAME=\'I$k\' ID=\'I$k\'" . " VALUE=\'$parvalue[$i]\'>\n";

      if ($parpar[$i] !~ /stackonly/i) {
        $input .= "<INPUT TYPE=BUTTON VALUE=' ' onclick='filesel(\"I$k\", \"$parpar[$i]\");'>\n";
      }
    } elsif ($parmode[$i] =~ /color/i) {
      my $size = 3;
      if ($parpar[$i]) { $size = $parpar[$i]; }
      $input .= "<INPUT TYPE=RADIO NAME='mousesel' VALUE='color'" . " onclick=\'mouserut(\"color$k\");\'>\n";
      $input .= "<INPUT TYPE=TEXT SIZE=8 NAME=\'I$k\' ID=\'I$k\'" . " VALUE=\'$parvalue[$i]\'>\n";
      $input .= "<INPUT TYPE=BUTTON VALUE=' ' onclick='colorsel(\"I$k\",$size);'>\n";
    } elsif ($parmode[$i] =~ /font/i) {
      my $size = 16;
      if ($parpar[$i]) { $size = $parpar[$i] }
      $input .= "<INPUT TYPE=TEXT SIZE=$size NAME=\'I$k\' ID=\'I$k\'" . " VALUE=\'$parvalue[$i]\'>\n";
      $input .= "<INPUT TYPE=BUTTON VALUE=' ' " . "onclick='fontsel(\"I$k\");'>\n";
    } elsif ($parmode[$i] =~ /^option/i) {
      my $a = $parpar[$i];
      if (!$a) { $error = "Missing parameter for Optionmenu"; return ""; }

      if ($a =~ /\@/ || ref($a) =~ /ARRAY/i) {
        @optarray = eval($a);
      } elsif ($a =~ /^\s*\{(.+)\}\s*$/) {
        @optarray = split(',', $1);
      } else {
        @optarray = getdialogcolumn($a, '~', 0);
      }
      my $bgo = $i;
      my $onclick =
          ($parmode[$i] =~ /select/i) ? "onchange=\'buttonclick(\"$name\");\'"
        : ($parfunc[$i]) ? "onchange=\"$parfunc[$i];\""
        : '';
      while (!(-d "$datafolder/$optarray[-1]")) { pop(@optarray); }
      my $osize = @optarray;
      if ($osize > 5) { $osize = 5; }
      $input .= "<SELECT SIZE=$osize NAME=\'I$k\' ID=\'I$k\' $onclick>\n";

      for ($j = 0; $j < @optarray; $j++) {
        my $pv = $parvalue[$i];
        $pv =~ s/[\[\]]//;
        my $ov = $optarray[$j];
        $ov =~ s/[\[\]]//;
        my $selected = ($pv =~ /^$ov\s*$/i) ? 'SELECTED' : '';
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
sub cleanse($) {
  my $str = shift;

  unless ($str =~ /^\w*$/) {

    # Complex params are generally ;-separated chunks where
    # a chunk is either an identifier or a quoted string of assorted chars,
    # possibly preceded by an assignment $id= .
    @parts = split(/;/, $str);

    foreach my $part (@parts) {
      unless ($part =~ /^([\w (),+-]*|'[\w (),+-]*'|\$\w+='[\w (),+-]*')$/i) {
        print STDERR "erasing $part\n";
        $part = '';
      }
    }
    $str = join(';', @parts);
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
    if (!$value && $value ne '0') { $value = ''; }
    if ($value =~ /^on$/) { $value = 1; }
    $value =~ s/\n/  /g;
    if ($elems[0] =~ /check/i) { $value = $check; }
    my $str = $elems[0] . '=\'' . $value . '\'';
    eval($str);
    $script .= "$str;;";
  }
  $setup{$name} = $script;
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
  if (!defined($v)) { $v = ''; }
  return $v;
}

#*** setfont($font, $text)
# input font description is "[size][ italic][ bold] color" format, and the text
# returns <FONT ...>$text</FONT> string
sub setfont {
  my $istr = shift;
  my $text = shift;
  my $size = ($istr =~ /^\.*?([0-9\-\+]+)/i) ? $1 : 0;
  my $color = ($istr =~ /([a-z]+)\s*$/i) ? $1 : '';
  if ($istr =~ /(\#[0-9a-f]+)\s*$/i || $istr =~ /([a-z]+)\s*$/i) { $color = $1; }
  my $font = "<FONT ";
  if ($size) { $font .= "SIZE=$size "; }
  if ($color) { $font .= "COLOR=\"$color\""; }
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

  $check = $setup{$checkname};
  $check =~ s/\s//g;
  %cookies = fetch_cookies();

  foreach (keys %cookies) {
    my $c = $cookies{$_};
    if ($c->name =~ /$cname/) { $sti = $c->value; }
  }

  if ($sti) {
    $sti =~ s/\s\s(\s*)/\n$1/g;
    @sti = split(';;;', $sti);
    my $param = $setup{$name};
    $param =~ s/\;\;\s*$//;
    my @param = split(';;', $param);

    #check if the structure of the parameters is the same
    if (@sti != @param + 1 || $sti[-1] !~ /^$check$/) {
      eval($setup{$name});
      return 0;
    }
    my $i;
    $param = '';

    for ($i = 0; $i < @sti; $i++) {
      my @a = split('=', $param[$i]);
      if ($a[0]) { $param .= "$a[0]=$sti[$i];;"; }
    }
    eval($param);
    $setup{$name} = $param;
    return 1;
  }
  return 0;
}

#*** setcookies($cname, $name)
#saves $name setup table as cookie named $cname
sub setcookies {

  my $cname = shift;
  my $name = shift;
  my @values = split(';;', $setup{$name});
  my $value = '';
  my $checkname = $name . 'check';

  $check = $setup{$checkname};
  $check =~ s/\s//g;

  if (!$values[-1]) {
    my %s = %{setupstring($datafolder, '', 'missa.setup')};
    eval($s{$name});
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
    -expires => "$cookieexpire"
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
  my $t = timelocal(0, 0, 0, $t[3], $t[4], $t[5]);
  $c = $q->cookie(
    -name => "$cname",
    -value => "$value",
    -expires => $t
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
# Note: the subsitutions are different in the Misssa from the Horas.
sub setcross {
  my $line = shift;

  if (CGI::user_agent("BlackBerry")) {

    # Use a PLUS SIGN for everything.
    my $csubst = "<span style='font-size:1.25em;color:red'>+</span>";
    $line =~ s/\+\+\+/$csubst/g;
    $line =~ s/\+\+/$csubst/g;
    $line =~ s/ \+ / $csubst /g;
  } else {
    my $csubst = "<span style='font-size:1.25em;color:red'>&#x2628;&#xFE0E;</span>";
    $line =~ s/\+\+\+/$csubst/g;

    # Cross type 2: Greek Cross (at the Gospel)
    $csubst = "<span style='color:red; font-size:1.25em'>+︎</span>";
    $line =~ s/\+\+/$csubst/g;

    # cross type 1: Latin Cross
    $csubst = "<span style='color:red; font-size:1.25em'>✠</span>";
    $line =~ s/ \+ / $csubst /g;

    #$line =~ s/(\pL)\+(\pL)/$1&nbsp;$csubst&nbsp;$2/g;
  }
  return $line;
}

#*** setcell($text1, $lang1);
# output the content of the cell
sub setcell {
  my $text = shift;
  my $lang = shift;
  my $width = ($only) ? 100 : 50;

  if (!$Ck) {
    if (columnsel($lang)) { $searchind++; print "<TR>"; }
    print "<TD $background VALIGN=TOP WIDTH=$width% ID=L$searchind>";
    topnext_cell($lang);
  }
  $text =~ s/wait[0-9]+//ig;
  $text =~ s/\_/ /g;
  $text =~ s/\{\:.*?\:\}(<BR>)*\s*//g;
  $text =~ s/\{\:.*?\:\}//sg;
  $text =~ s/\`//g;
  $text =~ s/\{(.*?)\}/'<BR>' . setfont($smallblack .'maroon', $1)/e;

  if ($Ck) {
    if ($column == 1) {
      push(@ctext1, $text);
    } else {
      push(@ctext2, $text);
    }
  } else {
    print setfont($blackfont, $text) . "</TD>\n";
    if (!columnsel($lang)) { print "</TR>\n"; }
  }
}

#*** topnext_Cell()
#prints T N for positioning
sub topnext_cell {
  if ($officium =~ /Pofficium/i) { return; }
  my $lang = shift;
  my @a = split('<BR>', $text1);
  if (@a > 2) { print topnext($lang); }
}

sub topnext {
  if ($officium =~ /Pofficium/i) {return:}
  my $lang = shift;
  my $str = "<FONT SIZE=1 COLOR=green><DIV ALIGN=right>";

  if (columnsel($lang)) {
    $str .= "<A HREF=# onclick=\"setsearch($searchind);\">Top</A>&nbsp;&nbsp;";
    $str .= "<A HREF=# onclick=\"setsearch($searchind+1);\">Next</A>";
  } else {
    $str .= "$searchind";
  }
  $str .= "</DIV></FONT>\n";
  return $str;
}

#*** table_start
# start main table
sub table_start {
  if ($Ck) {
    @ctext1 = splice(@ctext1, @ctext1);
    @ctext2 = splice(@ctext2, @ctext2);
  }
  my $width =
    ($textwidth && $textwidth =~ /^[0-9]+$/ && 50 <= $textwidth && $textwidth <= 100)
    ? "$textwidth\%"
    : '80%';
  print "<TABLE BORDER=$border ALIGN=CENTER CELLPADDING=8 WIDTH=$width>";
}

#antepost('$title')
# prints Ante of Post call
sub ante_post {
  my $title = shift;
  if ($Ck) { return; }
  my $colspan = ($only) ? '' : 'COLSPAN=2';
  print "<TR><TD $background VALIGN=TOP $colspan ALIGN=CENTER>\n";
  print htmlcall($title);
  print "<FONT SIZE=1>Missam</FONT></TD></TR>";
}

#table_end()
# finishes main table
sub table_end {
  if ($Ck) {
    my $width = ($only) ? 100 : 50;
    print "<TR><TD $background VALIGN=TOP WIDTH=$width%>\n";
    my $item;
    my $len1 = 0;
    foreach $item (@ctext1) { $len1 += length($item); print "$item<BR>\n"; }
    print "</TD>\n";

    if (!$only) {
      $len2 = 0;
      print "<TD $background VALIGN=TOP WIDTH=$width%>\n";
      foreach $item (@ctext2) { $len2 += length($item); print "$item<BR>\n"; }
      print "</TD></TR>\n";
    }
    print "<TR><TD $background VALIGN=TOP WIDTH=$width%><FONT SIZE=1>$len1 characters</FONT></TD>";

    if (!$only) {
      print "<TD $background VALIGN=TOP WIDTH=$width%><FONT SIZE=1>$len2 characters</FONT></TD></TR>";
    }
  }
  print "</TABLE><span ID=L$searchind></span>";
}

#*** linkcode($name, $ind, $lang, $disabled)
# set a link line
sub linkcode {
  my ($name, $ind, $lang, $disabled) = @_;
  return "<INPUT TYPE=RADIO NAME=link $disabled onclick='linkit(\"$name\", $ind, \"$lang\");'>";
}

#*** linkcode1()
# sets a collpse radiobutton
sub linkcode1 {
  return "&nbsp;&nbsp;&nbsp;" . "<INPUT TYPE=RADIO NAME=collapse onclick=\"linkit('','10000','');\">\n";
}

#*** htmlcall($ref);
# returns the html come
sub htmlcall {
  my $ref = shift;
  return "<A HREF=\"mpopup.pl?popup=$ref&rubrics=$rubrics&lang1=$lang1&lang2=$lang2\" TARGET=_NEW>$ref</A>\n";

  #return "<A HREF=# onclick=callpopup(\"$ref\");>$ref</A>\n";
}
