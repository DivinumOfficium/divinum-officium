#!/usr/bin/perl
use utf8;

# áéíóöõúüûÁÉ  ‡
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
$a = 1;

#*** ordo()
# collects and prints the ordo
# first let specials to fill the chapters
# then break the text into units (separated by double newline)
# resolves the references (formatting characters, prayers hash references and subs)
#and prints the result
sub ordo {
  my $savesolemn = $solemn;
  if ($winner =~ /Quad6-[456]/i) { $solemn = 1; }
  $column = 1;
  if ($Ck) { $version = $version1; precedence(); }
  my (@script1, @script2);
  @script1 = getordinarium($lang1, $command);
  @script1 = specials(\@script1, $lang1);

  if (!$only) {
    $column = 2;
    if ($Ck) { $version = $version2; precedence(); }
    @script2 = getordinarium($lang2, $command);
    @script2 = specials(\@script2, $lang2);
  }
  $solemn = $savesolemn;
  $searchind = 0;

  if ($rule =~ /Full text/i) {
    @script1 = ();
    @script2 = ();
    $rule = 'Prelude';
  }

  if ($rule =~ /prelude/i) {
    my $str = $winner{Prelude};

    # $str = norubr1($str);
    unshift(@script1, split('_', $str), '');

    if (!$only) {
      $str = $winner2{Prelude};

      # $str = norubr1($str);
      unshift(@script2, split('_', $str), '');
    }
  }

  if ($rule =~ /Post Missam/i) {
    my $str = $winner{'Post Missam'};

    # $str = norubr1($str);
    push(@script1, split('_', $str));

    if (!$only) {
      $str = $winner2{'Post Missam'};

      # $str = norubr1($str);
      push(@script2, split('_', $str));
    }
  }

  print_content($lang1, \@script1, $lang2, \@script2, 1);
}

#*** resolve_refs($text_of_block, $lang)
#resolves $name &name references and special characters
#retuns the to be listed text
sub resolve_refs {
  my $t = shift;
  my $lang = shift;
  my @t = split("\n", $t);
  my $t = '';

  if ($t[0] =~ /(omit|elmarad)/i) {
    $t[0] =~ s/^\s*\#/\!x\!/;
  } else {
    $t[0] =~ s/^\s*\#/\!\!/;
  }

  my @resolved_lines;    # Array of blocks expanded from lines.
  my $merged_lines;      # Preceding continued lines.

  #cycle by lines
  for (my $it = 0; $it < @t; $it++) {
    $line = $t[$it];
    $line =~ s/\s+$//;
    $line =~ s/^\s+//;

    # Should this line be joined to the next? Strip off the continuation
    # character as we check.
    my $merge_with_next = ($line =~ s/~$//);

    # The first batch of transformations are performed on the current
    # input line only.
    #$ and & references
    if ($line !~ /(callpopup|rubrics)/i && $line =~ /^\s*[\$\&]/)    #??? was " /[\#\$\&]/)
    {
      $line =~ s/\.//g;

      #prepares reading the part of common w/ antiphona
      if ($line =~ /psalm/ && $t[$it - 1] =~ /^\s*Ant\. /i) {
        $line = expand($line, $lang, $t[$it - 1]);
      } else {
        $line = expand($line, $lang);
      }

      if ($line !~ /\<input/i) {
        $line = resolve_refs($line, $lang);
      }    #for special chars
    }

    #cross
    $line = setcross($line);

    #red prefix
    if ($line =~ /^\s*(R\.|V\.|S\.|P\.|M\.|A\.|O\.|C\.|D\.|Benedictio\.* |Absolutio\.* |Ant\. |Ps\. )(.*)/s) {
      my $h = setvrbar($1);
      my $l = $2;

      if ($h =~ /(Benedictio|Absolutio)/) {
        $h =~ s/(Benedictio|Absolutio)/ translate($str, $lang) /e;
      }
      $line = setfont($redfont, $h) . $l;
    }

    #Quad6 Gospels
    if ($winner =~ /Quad6/) {
      $line =~ s/(\b[A-Z]\.)/setfont($redfont, $1)/eg;
    }

    #consecration words
    if ($line =~ /\s*\!\[\:(.*?)\:\]/) {
      $line = $1;
      my $cfont = $redfont;
      $cfont =~ s/red/blue/i;
      $line = setfont($cfont, $line);
    } elsif ($line =~ /^\s*\!\!\!(.*)/s) {
      $line = $1;
    }

    #small omitted comment
    elsif ($line =~ /^\s*\!x\!\!(.*)/s) {
      $l = $1;
      $line = setfont($smallfont, $l);
    }

    #small omitted title
    elsif ($line =~ /^\s*\!x\!(.*)/s) {
      $l = $1;
      $line = setfont($smallblack, $l);
    }

    #large chapter title
    elsif ($line =~ /^\s*\!\!(.*)/s) {
      my $l = $1;
      my $suffix = '';

      if ($l =~ /\{.*?\}/) {
        $l =~ s/(\{.*?\})//;
        $suffix = $1;
        $suffix = setfont($smallblack, $suffix);
      }
      $line = setfont($largefont, $l) . " $suffix\n";
    }

    #red line
    elsif ($line =~ /^\s*\!(.*)/s) {
      $l = $1;
      $line = setfont($redfont, $l);
    }

    # Prepend any previous lines that tilde-connect to the current line.
    $line = "$line_prefix $line" if ($line_prefix);

    # The remaining transformations are peformed on the whole line as
    # built up from tilde-connected lines. Critically, these are
    # performed once for each line of input, so they should be
    # idempotent.
    # First letter red.
    $line =~ s/^\s*r\.\s*(.)(.*)/setfont($largefont, $1) . $2/em;

    # First letter initial.
    $line =~ s/
        (^|\{\:.*?\:\})      # Beginning of line or {::} construction.
        \s*v\.\s*(.)(.*)     # 'v.' plus a letter plus the rest.
      /
        $1 . setfont($initiale, $2) . $3
      /emx;

    # Connect lines marked by tilde.
    if ($merge_with_next && $it < $#t) {
      $merged_lines .= $line . ' ';
    } else {
      push @resolved_lines, $merged_lines . $line;
      $merged_lines = '';
    }
  }    #line by line cycle ends

  # Concatenate the expansions of the lines with a line break between each.
  push @resolved_lines, '';
  my $resolved_block = join "<br\/>\n", @resolved_lines;

  #removes occasional double linebreaks
  $resolved_block =~ s/\<br\/\>\s*\<br\/\>/\<br\/\>/ig;
  $resolved_block =~ s/<\/P>\s*<br\/>/<\/P>/gi;
  return $resolved_block;
}

#*** Alleluia($lang)
# return the text Alleluia or Laus tibi
sub Alleluia {
  my $lang = shift;
  my $text = prayer('Alleluia', $lang);
  my @text = split("\n", $text);
  $text = $text[0];

  #if ($dayname[0] =~ /Pasc/i) {$text = "Alleluia, alleluia, alleluia";}
  return $text;
}

#*** Benedicamus_Domino
# adds Alleluia, alleluia for Pasc0
sub Benedicamus_Domino {
  my $lang = shift;
  my $text = prayer('Benedicamus Domino', $lang);
  if ($dayname[0] !~ /Pasc0/i) { return $text; }
  my @text = split("\n", $text);
  return "$text[0]. Alleluia, alleluia\n$text[1]. Alleluia, alleluia\n";
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

#*** getordinarium($lang, $command)
# returns the full pathname of ordinarium for the language and hora
sub getordinarium {
  my $lang = shift;
  my @script;

  if ($Propers && (@script = do_read("$datafolder/Latin/Ordo/Propers.txt"))) {
    return @script;
  }
  my $fname = 'Ordo';
  if ($version =~ /1967/i) { $fname = 'Ordo67'; }

  #elsif ($version =~ /Praedicatorum/i) { $fname = 'OrdoOP'; }
  if ($NewMass) { $fname = ($column == 1) ? $ordos{$version1} : $ordos{$version2}; }
  $fname = checkfile($lang, "Ordo/$fname.txt");

  if (@script = do_read($fname)) {
    $_ = "$_\n" for @script;
  } else {
    $error = "$fname cannot open!";
  }
  return @script;
}

sub columnsel {
  my $lang = shift;
  if ($Ck || $NewMass) { return ($column == 1) ? 1 : 0; }
  return ($lang =~ /$lang1/i) ? 1 : 0;
}
