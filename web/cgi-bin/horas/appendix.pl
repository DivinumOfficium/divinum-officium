# print appendix
sub appendix {
  my $appendix = shift || 'Index';
  $appendix =~ s/appendix //i;

  our $lang1, $lang2, $version, $version1, $version2, $only, $expandind, $column;

  our %translate;
  $translate{$lang1} = setupstring($lang1, "Psalterium/Translate.txt");
  $translate{$lang2} = setupstring($lang2, "Psalterium/Translate.txt");
  cache_prayers();
  my $fname = "Appendix/$appendix.txt";
  my %a1 = %{setupstring($lang1, $fname)};
  my @script1 = split("\n", $a1{$appendix});
  @script1 = specials(\@script1, $lang1);
  my @script2;
  if (!$only) {
    my %a2 = %{setupstring($lang2, $fname)};
    @script2 = split("\n", $a2{$appendix});
    @script2 = specials(\@script2, $lang2);
  }
  print "<H2 ID='${appendix}top'>Appendix - $appendix</H2>\n";

  my($ind1, $ind2);

  table_start();
  while ($ind1 < @script1 || $ind2 < @script2) {
    $expandind++;

    $column = 1;
    $version = $version1 if $Ck;
    ($text, $ind1) = getunit(\@script1, $ind1);
    $text = resolve_refs($text, $lang1);
    setcell($text, $lang1);
    if (!$only) {
      $column = 2;
      $version = $version2 if $Ck;
      ($text, $ind2) = getunit(\@script2, $ind2);
      $text = resolve_refs($text, $lang2);
      setcell($text, $lang2);
    }
  }
  table_end();
}

1;
