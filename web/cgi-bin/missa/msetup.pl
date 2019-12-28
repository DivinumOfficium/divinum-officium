#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office  setup
$a = 1;

#*** setup($command)
# prints and handles $command item from missa.dialog hash (in www/horas folder)
# using horas.setup hash also from www/missa folder
sub setuptable {
  $command = shift;
  $title1 = $title;
  $title1 =~ s/Setup/Options/i;

  #*** set input table
  eval("$setup{$command}");
  setup($command, getsetuppar($command));
  print << "PrintTag";
<H1 ALIGN=CENTER><FONT COLOR=MAROON><B><I>$title1 Options</I></B></FONT></H1>
<TABLE WIDTH=75% BORDER=0 ALIGN=CENTER><TR><TD>
$input
</TD></TR></TABLE>
<P ALIGN=CENTER>
<INPUT TYPE=SUBMIT NAME='button' VALUE=OK>
</P>
PrintTag
  $command = "change" . $command;
}
