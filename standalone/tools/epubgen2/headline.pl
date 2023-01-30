# Shared code for EofficiumXhtml.pl and Emissa.pl to generate XHTML headers and navigation menu.

# Outpus the entire navigation menu on the top of the files.
# (Includes links to hours, link to previous and next day, title of the day and comment)
sub headline {
  htmlHead();
  build_comment_line_xhtml();
  outputHeadlineCommentAndDate();
  navigationMenu();
}

# Generate XHTML header (including CSS link and HTML title).
sub htmlHead {
  print << "PrintTag";
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="la"><head> <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> <link href="s.css" rel="stylesheet" type="text/css"/><title>$title</title></head><body><div>
PrintTag
}

sub outputHeadlineCommentAndDate {
  my $daycolorclass = calculateDaycolor();
  my @horasfilenames = split(',', strictparam('horasfilenames'));
  my $firsthora = $horasfilenames[0];

  my $daten = prevnext($date1, 1);
  my $datep = prevnext($date1, -1);

    print << "PrintTag";
<p class="cen $daycolorclass">$headline<br />$comment</p>
<p class="cen"><span class="c">$head</span>&nbsp;&nbsp;&nbsp;<a href="$datep-$firsthora.html">&darr;</a> $date1 <a href="$daten-$firsthora.html">&uarr;</a><br /></p>
PrintTag
}

# Outputs the clickable navigation menu (Matutinum, Laudes, ..., Missa).
#
# Depends on parameters in the URL (horasnames, horasfilenames, horasindexlast).
sub navigationMenu {
     my @horasnames = split(',', strictparam('horasnames'));
     my @horasfilenames = split(',', strictparam('horasfilenames'));
     my $horasindexlast = strictparam('horasindexlast');

     print '<p class="cen">';

     unless ($horasindexlast == 0) {
      for my $i ( 0 .. $horasindexlast ) {
          $horasfilename = $horasfilenames[$i];
          $horasname = $horasnames[$i];

          print "<a href=\"$date1-$horasfilename.html\">$horasname</a>&nbsp;&nbsp;";
          
          #break line after every four items
          if($i % 4 == 3) {
              print "<br />";
          }
      }
     }

     print '</p>';
}

# Calculates $daycolorclass
sub calculateDaycolor() {
  my $daycolor =   ($commune =~ /(C1[0-9])/) ? "blue" :
    ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? "black" :
    ($dayname[1] =~ /duplex/i) ? "red" :
      "grey";

  #convert $daycolor to $daycolorclass
  my $daycolorclass=""; #rely on default being black font color
  if($daycolor eq "blue") {$daycolorclass="rb";}
  elsif($daycolor eq "gray") {$daycolorclass="rb";}
  elsif($daycolor eq "red") {$daycolorclass="rd";}
  return $daycolorclass;
}

#  Replacement for build_comment_line() from horascommon.pl
#
#  Sets $comment to the HTML for the comment line.
sub build_comment_line_xhtml()
{
  our @dayname;
  our ($comment, $marian_commem);

  my $commentcolor = ($dayname[2] =~ /(Feria)/i) ? '' : ($marian_commem && $dayname[2] =~ /^Commem/) ? ' rb' : ' m';
  $comment = ($dayname[2]) ? "<span class=\"s$commentcolor\">$dayname[2]</span>" : "";
}

# Calculate following / previous date.
sub prevnext {
  my $date1 = shift;
  my $inc = shift;

  $date1 =~ s/\//\-/g;
  my ($month,$day,$year) = split('-',$date1);

  my $d= date_to_days($day,$month-1,$year);

  my @d = days_to_date($d + $inc);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;
  return sprintf("%02i-%02i-%04i", $month, $day, $year);
}

1;
