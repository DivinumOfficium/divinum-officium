sub bodybegin {
  my $onload = $officium ne 'Pofficium.pl' && ' onload="startup();"';
  return << "PrintTag";
<BODY VLINK=$visitedlink LINK=$link BACKGROUND="$htmlurl/horasbg.jpg"$onload>
<FORM ACTION="$officium" METHOD=post TARGET=_self>
PrintTag
}

#*** daylineheader_c($head)
# return headline for main and pray for Compare
sub daylineheader_c {
  my($head, $version1, $version2) = @_;
  $version = $version2;
  precedence();
  my $daycolor = liturgical_color($dayname[1], $commune);
  my $head2 = daylineheader(setheadline(), '', $daycolor);
  '<CENTER><TABLE BORDER=1 CELLPADDING=5><TR>'
    . "<TD $background ALIGN=CENTER WIDTH=50%>$version1 : $head</TD>"
    . "<TD $background ALIGN=CENTER WIDTH=50%>$version2 : $head2</TD>"
    . '</TR></TABLE></CENTER>'
}

#*** daylineheader($day, $comment, $color) 
# return headline for main and pray
sub daylineheader {
  my ($day, $comment, $color) = @_;

  qq(<FONT COLOR=$color>$day<BR></FONT>\n$comment);
}

#*** headline($head) prints headline for main and pray
sub headline {
  my ($output, $variant) = @_;
  unless ($variant eq 'C') {
    $output = par_c($output);
    $output .= << "PrintTag";
<H1>
<FONT COLOR=MAROON SIZE=+1><B><I>Divinum Officium</I></B></FONT>&nbsp;
<FONT COLOR=RED SIZE=+1>$version</FONT>
</H1>
PrintTag
  }
  if ($variant eq 'P') {
    $output .= par_c(<< "PrintTag");
<A HREF="Pofficium.pl?date1=$date1&command=prev&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
&darr;</A>
$date1
<A HREF="Pofficium.pl?date1=$date1&command=next&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
&uarr;</A>
PrintTag
  } elsif ($variant eq 'C') {
    my $title = $command ? adhoram($command): 'Divinum Officium';
    $title =~ s/Vesper.*/Vesperas/;
    $output .= par_c(<< "PrintTag");
<FONT COLOR=MAROON SIZE=+1><B><I>$title</I></B></FONT>&nbsp;&nbsp;&nbsp;&nbsp;
<LABEL FOR=date CLASS=offscreen>Date</LABEL>
<INPUT TYPE=TEXT ID=date NAME=date VALUE="$date1" SIZE=10>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=submit NAME=SUBMIT VALUE=" " onclick="parchange();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Ordo</A>
PrintTag
  } else {
    $output .= par_c(<< "PrintTag");
<A HREF=# onclick="callcompare()">Compare</A>
&nbsp;&nbsp;&nbsp;<A HREF=# onclick="callmissa();">Sancta Missa</A>
&nbsp;&nbsp;&nbsp;
<LABEL FOR=date CLASS=offscreen>Date</LABEL>
<INPUT TYPE=TEXT ID=date NAME=date VALUE="$date1" SIZE=10>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE=submit NAME=SUBMIT VALUE=" " onclick="parchange();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Ordo</A>
&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="pset('parameters')">Options</A>
PrintTag
  }
}

sub mainpage {
  my $height = floor($screenheight * 4 / 14);
  my $height2 = floor($height / 2);
  return << "PrintTag";
<TABLE BORDER=0 HEIGHT=$height><TR>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Ordinarium</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Psalterium</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Proprium de Tempore</FONT></TD>
</TR><TR><TD ALIGN=CENTER ROWSPAN=2>
<IMG SRC="$htmlurl/breviarium.jpg" HEIGHT=$height ALT=""></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/psalterium.jpg" HEIGHT=$height2 ALT=""></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/tempore.jpg" HEIGHT=$height2 ALT=""></TD>
</TR><TR>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/commune.jpg" HEIGHT=$height2 ALT=""></TD>
<TD HEIGHT=50% VALIGN=MIDDLE ALIGN=CENTER>
<IMG SRC="$htmlurl/sancti.jpg" HEIGHT=$height2 ALT=""></TD>
</TR><TR>
<TD ALIGN=CENTER><FONT COLOR=RED></FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Commune Sanctorum</FONT></TD>
<TD ALIGN=CENTER><FONT COLOR=MAROON>Proprium Sanctorum</FONT></TD>
</TR></TABLE>
<BR>
PrintTag
}

sub setplures {
  my $output = << "PrintTag";
<H2>Elige horas</H2>
<TABLE WIDTH=75% CELLPADDING=5 ALIGN=CENTER>
PrintTag

  foreach (gethoras($votive eq 'C9')) {
    $output .= "<TR><TD WIDTH='50%' ALIGN=RIGHT>$_</TD><TD ALIGN=LEFT>" 
             . htmlInput($_, 0 + ($plures =~ $_), 'checkbutton') ."</TD></TR>";
  }

  $output .= "</TABLE>";
  my $submit = << "SubmitTag";
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

  $output .= par_c("<INPUT TYPE=SUBMIT VALUE='Procede' ONCLICK='$submit'>")
}

# for Pofficium Options Sancta Missa Ordo
sub pmenu {
  return << "PrintTag";
<A HREF="Pofficium.pl?date1=$date1&command=setupparameters&pcommand=$command&version=$version&testmode=$testmode&lang2=$lang2&votive=$votive">
Options</A>&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callmissa();">Sancta Missa</A>&nbsp;&nbsp;&nbsp;
<A HREF=# onclick="callkalendar();">Ordo</A>
PrintTag
}

#common end for programs
sub bodyend { 
  my $output = '';
  if ($error) { $output .= par_c("<FONT COLOR=red>$error</FONT>"); }
  if ($debug) { $output .= par_c("<FONT COLOR=blue>$debug</FONT>"); }
  $output .= << "PrintTag";
<INPUT TYPE=HIDDEN NAME=expandnum VALUE="">
<INPUT TYPE=HIDDEN NAME=popup VALUE="">
<INPUT TYPE=HIDDEN NAME=popuplang VALUE="">
<INPUT TYPE=HIDDEN NAME=setup VALUE="$setupsave">
<INPUT TYPE=HIDDEN NAME=command VALUE="$command">
<INPUT TYPE=HIDDEN NAME=date1 VALUE="$date1">
<INPUT TYPE=HIDDEN NAME=searchvalue VALUE="0">
<INPUT TYPE=HIDDEN NAME=officium VALUE="$officium">
<INPUT TYPE=HIDDEN NAME=browsertime VALUE="$browsertime">
<INPUT TYPE=HIDDEN NAME=version1 VALUE="$version">
<INPUT TYPE=HIDDEN NAME=version2 VALUE="$version2">
<INPUT TYPE=HIDDEN NAME=caller VALUE='0'>
<INPUT TYPE=HIDDEN NAME=compare VALUE=$Ck>
<INPUT TYPE=HIDDEN NAME='notes' VALUE="$notes">
<INPUT TYPE=HIDDEN NAME='plures' VALUE='$plures'>
</FORM>
</BODY></HTML>
PrintTag
}

sub buildscript {
  local($_) = @_;
  s/[\n]+/<BR>/g;
  s/\_//g;
  s/\,\,\,/\&nbsp\;\&nbsp\;\&nbsp\;/g;
  return << "PrintTag";
<TABLE BORDER=3 ALIGN=CENTER WIDTH=60% CELLPADDING=8><TR><TD>
$_
</TD></TR><TABLE><BR>
PrintTag
}

sub par_c {
  "<P ALIGN=CENTER>@_</P>\n";
}

1;
