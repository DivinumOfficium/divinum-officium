#*** daylineheader_c($head)

# return headline for main and pray for Compare
sub html_dayhead_c {
  my ($head, $version1, $version2) = @_;
  $version = $version2;
  precedence();
  my $head2 = html_dayhead(setheadline(), $dayname[2]);
  $version = $version1;
  '<TABLE CELLPADDING="5"><TR>'
    . "<TD ALIGN='RIGHT' VALIGN='TOP' WIDTH='50%' STYLE='border-right: 1pt solid red;'>$head</TD>"
    . "<TD ALIGN='LEFT' VALIGN='TOP' WIDTH='50%'>$head2</TD>"
    . '</TR></TABLE>';
}

#*** headline($head) prints headline for main and pray
sub headline {
  my ($head, $variant, $version1, $version2) = @_;
  my $compone;
  my $vers = version_displayname($version1);

  if ($variant eq 'C') {
    $head = html_dayhead_c($head, $version1, $version2);
    $compone = "<A HREF='#' onclick=\"callbrevi(\'$date1\')\">One version</A>";
    $vers .= '/' . version_displayname($version2);
  } else {
    $compone = '<A HREF="#" onclick="callcompare()">Compare</A>';
  }
  my $output = par_c($head);
  $output .=
    "<H1><FONT COLOR='MAROON' SIZE='+1'><B><I>Divinum Officium</I></B></FONT>&nbsp;<FONT COLOR='RED' SIZE='+1'>$vers</FONT></H1>\n";

  # add warning for uncompleted versions
  $output .=
    "<H2><FONT COLOR='RED' SIZE='+1'>Please note that the database for this version ($vers) is still incomplete and under construction.</FONT></H2>\n"
    if ($vers =~ /1962/ || $vers =~ /Cist/ && $month > 7);
  $output .=
    "<H2><FONT COLOR='RED'>Please note that 'Ad Matutinum' for this version ($vers) is still incomplete and under construction.</FONT></H2>\n"
    if $vers =~ /1617|1930|Cist/ && $hora =~ /Matutinum/;

  if ($variant eq 'P') {
    $output .= par_c(<<"PrintTag");
<A HREF="Pofficium.pl?date1=$date1&command=prev&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
&darr;</A>
$date1
<A HREF="Pofficium.pl?date1=$date1&command=next&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
&uarr;</A>
PrintTag
  } else {
    $output .= par_c(<<"PrintTag");
$compone
&ensp;
<A HREF="#" onclick="callmissa();">Sancta Missa</A>
&ensp;
<LABEL FOR="date" CLASS="offscreen">Date</LABEL>
<INPUT TYPE="TEXT" ID="date" NAME="date" VALUE="$date1" SIZE="10">
<A HREF="#" onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE="submit" NAME="SUBMIT" VALUE=" " onclick="parchange();">
<A HREF="#" onclick="prevnext(1)">&uarr;</A>
&ensp;
<A HREF="#" onclick="callkalendar();">Ordo</A>
&ensp;
<A HREF="#" onclick="pset('parameters')">Options</A>
PrintTag
  }
}

sub mainpage {
  my $height = floor($screenheight * 7 / 14);
  my $height2 = floor($height / 2);
  return <<"PrintTag";
<TABLE BORDER="0" HEIGHT="$height"><TR>
<TD ALIGN="CENTER"><FONT COLOR="MAROON">Ordinarium</FONT></TD>
<TD ALIGN="CENTER"><FONT COLOR="MAROON">Psalterium</FONT></TD>
<TD ALIGN="CENTER"><FONT COLOR="MAROON">Proprium de Tempore</FONT></TD>
</TR><TR><TD ALIGN="CENTER" ROWSPAN="2">
<IMG SRC="$htmlurl/breviarium.jpg" HEIGHT="$height" ALT=""></TD>
<TD HEIGHT="50%" VALIGN="MIDDLE" ALIGN="CENTER">
<IMG SRC="$htmlurl/psalterium.jpg" HEIGHT="$height2" ALT=""></TD>
<TD HEIGHT="50%" VALIGN="MIDDLE" ALIGN="CENTER">
<IMG SRC="$htmlurl/tempore.jpg" HEIGHT=$height2 ALT=""></TD>
</TR><TR>
<TD HEIGHT="50%" VALIGN="MIDDLE" ALIGN="CENTER">
<IMG SRC="$htmlurl/commune.jpg" HEIGHT="$height2" ALT=""></TD>
<TD HEIGHT="50%" VALIGN="MIDDLE" ALIGN="CENTER">
<IMG SRC="$htmlurl/sancti.jpg" HEIGHT="$height2" ALT=""></TD>
</TR><TR>
<TD ALIGN="CENTER"><FONT COLOR="RED"></FONT></TD>
<TD ALIGN="CENTER"><FONT COLOR="MAROON">Commune Sanctorum</FONT></TD>
<TD ALIGN="CENTER"><FONT COLOR="MAROON">Proprium Sanctorum</FONT></TD>
</TR></TABLE>
<br/>
PrintTag
}

sub setplures {
  my $output = <<"PrintTag";
<H2>Elige horas</H2>
<TABLE WIDTH="75%" CELLPADDING="5" ALIGN="CENTER" $background>
PrintTag

  foreach (gethoras($votive eq 'C9')) {
    $output .=
        "<TR><TD WIDTH='50%' ALIGN='RIGHT'>$_</TD><TD ALIGN='LEFT'>"
      . htmlInput($_, 0 + ($plures =~ $_), 'checkbutton')
      . "</TD></TR>";
  }

  $output .= "</TABLE>";
  my $submit = <<"SubmitTag";
thisform = document.forms[0];
thisform.command.value = "pray";
for(i=0; i<thisform.elements.length; i++) {
  if (thisform.elements[i].checked) {  
    thisform.command.value += thisform.elements[i].name;
  }
}
thisform.target = "_self";
thisform.submit();
SubmitTag

  $output .= par_c("<INPUT TYPE=SUBMIT VALUE='Procede' ONCLICK='$submit'>");
}

# for Pofficium Options Sancta Missa Ordo
sub pmenu {
  return <<"PrintTag";
<A HREF="Pofficium.pl?date1=$date1&command=setupparameters&pcommand=$command&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
Options</A>&ensp;
<A HREF="#" onclick="callmissa();">Sancta Missa</A>&ensp;
<A HREF="#" onclick="callkalendar();">Ordo</A>
PrintTag
}

#common end for programs
sub hiddenfields {
  my $output = <<"PrintTag";
<INPUT TYPE="HIDDEN" NAME="expandnum" VALUE="">
<INPUT TYPE="HIDDEN" NAME="popup" VALUE="">
<INPUT TYPE="HIDDEN" NAME="popuplang" VALUE="">
<INPUT TYPE="HIDDEN" NAME="setup" VALUE="$setupsave">
<INPUT TYPE="HIDDEN" NAME="command" VALUE="$command">
<INPUT TYPE="HIDDEN" NAME="date1" VALUE="$date1">
<INPUT TYPE="HIDDEN" NAME="searchvalue" VALUE="0">
<INPUT TYPE="HIDDEN" NAME="officium" VALUE="$officium">
<INPUT TYPE="HIDDEN" NAME="browsertime" VALUE="$browsertime">
<INPUT TYPE="HIDDEN" NAME="version" VALUE="$version">
<INPUT TYPE="HIDDEN" NAME="version2" VALUE="$version2">
<INPUT TYPE="HIDDEN" NAME="caller" VALUE='0'>
<INPUT TYPE="HIDDEN" NAME="compare" VALUE=$Ck>
<INPUT TYPE="HIDDEN" NAME="plures" VALUE="$plures">
<INPUT TYPE="HIDDEN" NAME="kmonth" VALUE="">
</FORM>
</BODY></HTML>
PrintTag
}

sub buildscript {
  local ($_) = @_;
  s/[\n]+/<br\/>/g;
  s/\_//g;
  s/\,\,\,/\&ensp\;/g;
  return <<"PrintTag";
<TABLE $background BORDER="3" ALIGN="CENTER" WIDTH="60%" CELLPADDING="8"><TR><TD>
$_
</TD></TR><TABLE><br/>
PrintTag
}

sub par_c {
  "<P ALIGN=CENTER>@_</P>\n";
}

1;
