package SourceLib;

# Reading what a translator hands in.
#
# The martyrology is printed a day to a page, and that is how it reaches
# us: a folder of day files, or one document for a month or the year in
# which every page is the next day.  Either can be plain text or Word.
#
#     read_pages($path)        a .txt or .docx as its pages, each a list
#                              of lines; a .txt breaks pages on form feed
#     page_lines(\@lines)      a page as a day file: heading, '_', one
#                              elogium per line
#     read_source($src, $m)    the days in a folder or a paged file, as
#                              { MM-DD => [lines] }
#
# Word is read with nothing but core Perl, so it works wherever the rest
# of the tools do: the .docx is a zip, and only its main document part is
# wanted.

use strict;
use warnings;
use utf8;
use Exporter 'import';
use IO::Uncompress::Unzip qw(unzip $UnzipError);

use MartyrLib qw(all_days do_read_lines);

our @EXPORT_OK = qw(read_pages page_lines read_source docx_pages);

my @DMAX = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

my %ENTITY = (amp => '&', lt => '<', gt => '>', quot => '"', apos => "'");

sub _unxml {
  my $s = shift;
  $s =~ s/&(?:(amp|lt|gt|quot|apos)|#(\d+)|#x([0-9a-fA-F]+));/
    defined $1 ? $ENTITY{$1} : defined $2 ? chr($2) : chr(hex($3))/ge;
  return $s;
}

#*** docx_pages($xml)
# word/document.xml as pages of paragraphs.
#
# A page ends at a hard page break, at a paragraph marked to start a new
# page, and at a section break that starts one.  The breaks Word records
# where its own layout happened to turn the page (lastRenderedPageBreak)
# are not the author's and are ignored.  A line break inside a paragraph
# is the paragraph wrapping, not a new elogium, and reads as a space.
sub docx_pages {
  my $xml = shift;

  # what Word keeps for programs that cannot read the main copy, and text
  # a tracked change moved away, would otherwise be read twice
  $xml =~ s{<mc:Fallback\b.*?</mc:Fallback>}{}gs;
  $xml =~ s{<w:moveFrom\b.*?</w:moveFrom>}{}gs;

  my @pages = ([]);

  while ($xml =~ m{<w:p\b[^>]*?(?:/>|>(.*?)</w:p>)}gs) {
    my $p = defined $1 ? $1 : '';
    # the paragraph's own properties hold its tab stops, which are not text
    my $ppr = $p =~ s{(<w:pPr\b.*?</w:pPr>)}{}s ? $1 : '';

    push @pages, [] if $ppr =~ m{<w:pageBreakBefore(?:\s+w:val="(?:true|1|on)")?\s*/>} && @{$pages[-1]};

    my $text = '';

    while ($p =~ m{<w:t(?:\s[^>]*)?>([^<]*)</w:t>|<w:t\s*/>|(<w:br\b[^>]*/>)|(<w:cr\s*/>)|(<w:tab\s*/>)|(<w:noBreakHyphen\s*/>)}g) {
      if (defined $1) { $text .= _unxml($1) }
      elsif (defined $2) {
        if ($2 =~ /w:type="page"/) {
          push @{$pages[-1]}, $text;
          push @pages, [];
          $text = '';
        } else {
          $text .= ' ';
        }
      }
      elsif (defined $3) { $text .= ' ' }
      elsif (defined $4) { $text .= "\t" }
      elsif (defined $5) { $text .= '-' }
    }
    push @{$pages[-1]}, $text;

    # a section break is written in the last paragraph of the section;
    # without a type it starts a new page
    if ($ppr =~ m{<w:sectPr\b(.*?)</w:sectPr>}s) {
      my $sect = $1;
      my ($type) = $sect =~ m{<w:type\s+w:val="(\w+)"};
      push @pages, [] unless $type && $type eq 'continuous';
    }
  }
  return @pages;
}

#*** read_pages($path)
# A .txt or .docx file as a list of pages, each a list of lines.
sub read_pages {
  my $path = shift;
  my @pages;

  if ($path =~ /\.docx$/i) {
    my $xml;
    unzip($path => \$xml, Name => 'word/document.xml', BinModeOut => 1)
      or die "$path: not a Word document ($UnzipError)\n";
    utf8::decode($xml) or die "$path: word/document.xml is not UTF-8\n";
    @pages = docx_pages($xml);

    # a few stray no-break spaces, where the typing ran into French
    # spacing; the day files have none
    foreach my $pg (@pages) { s/\x{a0}/ /g foreach @$pg }
  } else {
    my @lines = do_read_lines($path);
    my @cur;

    foreach my $l (@lines) {
      my @parts = $l eq '' ? ('') : split(/\f/, $l, -1);
      push @cur, shift @parts;

      foreach my $rest (@parts) {
        push @pages, [@cur];
        @cur = ($rest);
      }
    }
    push @pages, [@cur];
  }

  foreach my $pg (@pages) { s/\s+$// foreach @$pg }

  # a document that ends on a page break leaves an empty page after it
  pop @pages while @pages && !grep { /\S/ } @{$pages[-1]};
  return @pages;
}

#*** page_lines(\@lines)
# A page as a day file.  The heading is everything above the first blank
# line, or above a '_' if the page has one; a page with neither has its
# first line for a heading, since every page of the book opens on its
# date.  Below it, one elogium per line, and the blank lines a document
# puts between paragraphs are dropped: in a day file they would read as
# entries.
sub page_lines {
  my @lines = @{shift()};
  shift @lines while @lines && $lines[0] !~ /\S/;
  pop @lines while @lines && $lines[-1] !~ /\S/;
  return () unless @lines;

  my $cut;

  for my $i (0 .. $#lines) {
    (my $bare = $lines[$i]) =~ s/^\s+|\s+$//g;
    if ($bare eq '_' || $bare eq '') { $cut = $i; last }
  }
  $cut = 1 unless defined $cut && $cut > 0;
  my @heading = @lines[0 .. $cut - 1];
  my $sep = '_';

  if ($cut <= $#lines) {
    (my $bare = $lines[$cut]) =~ s/^\s+|\s+$//g;
    $sep = $lines[$cut] if $bare eq '_';
    $cut++ if $bare eq '_' || $bare eq '';
  }
  my @body = grep { /\S/ } @lines[$cut .. $#lines];
  return (@heading, $sep, @body);
}

#*** read_source($src, $month)
# What --src names, as ({ MM-DD => [lines] }, { MM-DD => problem }).
#
# A folder holds one file per day, MM-DD.txt or MM-DD.docx.  A day file in
# text is taken as it is written, the way the tools always have; a Word
# day file goes through page_lines, as it has paragraphs and not lines.
#
# A file holds a month or the year, one day to a page.  Which month is
# --month, or the two digits its name starts with (01.docx); a file with
# a page for every day of the year is the year.  The pages must come out
# to the days exactly, or nothing is read: a page too many or too few
# puts every day after it on the wrong date.
sub read_source {
  my ($src, $month) = @_;
  my (%days, %bad);

  if (-d $src) {
    my %known = map { $_ => 1 } all_days();
    opendir(my $dh, $src) or die "cannot read $src: $!\n";
    my @files = sort grep { /\.(txt|docx)$/i } readdir $dh;
    closedir $dh;
    my %from;

    foreach my $f (@files) {
      my ($day, $ext) = $f =~ /^(.*)\.(txt|docx)$/i;
      next unless $known{$day};
      die "$src: $day is given twice, as $from{$day} and $f\n" if $from{$day};
      $from{$day} = $f;
      my @lines = eval {
        lc $ext eq 'docx'
          ? page_lines([map {@$_} read_pages("$src/$f")])
          : do_read_lines("$src/$f");
      };

      if ($@) { $bad{$day} = $@ =~ /UTF-8|utf8/ ? 'not valid UTF-8' : $@; chomp $bad{$day}; next }
      $days{$day} = \@lines;
    }
    return (\%days, \%bad);
  }

  die "$src: no such file or folder\n" unless -f $src;
  die "$src: only .txt and .docx can be read\n" unless $src =~ /\.(txt|docx)$/i;

  my @pages = read_pages($src);
  my @all = all_days();
  my @dates;

  if (!$month) {
    (my $base = $src) =~ s{.*[/\\]}{};
    $month = $1 + 0 if $base =~ /^(\d\d)(?!\d)/ && $1 >= 1 && $1 <= 12;
  }

  if ($month) {
    die "--month must be 1 to 12\n" unless $month =~ /^\d+$/ && $month >= 1 && $month <= 12;
    @dates = map { sprintf('%02d-%02d', $month, $_) } 1 .. $DMAX[$month - 1];
  } elsif (@pages == @all) {
    @dates = @all;
  } else {
    die sprintf("%s: %d pages, which is not the year (%d); for a month, say which with --month\n",
      $src, scalar @pages, scalar @all);
  }

  if (@pages != @dates) {
    my @head = map { my ($h) = grep { /\S/ } @{$pages[$_]}; sprintf('    %3d  %s', $_ + 1, $h // '') }
      0 .. $#pages;
    die sprintf("%s: %d pages for %d days (%s to %s); each page has to be one day:\n%s\n",
      $src, scalar @pages, scalar @dates, $dates[0], $dates[-1], join("\n", @head));
  }

  for my $i (0 .. $#dates) {
    my @lines = page_lines($pages[$i]);
    if (@lines) { $days{$dates[$i]} = \@lines } else { $bad{$dates[$i]} = 'empty page' }
  }
  return (\%days, \%bad);
}

1;
