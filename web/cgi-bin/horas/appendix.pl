# print appendix
sub appendix {
  my $appendix = shift || 'Index';
  $appendix =~ s/appendix //i;

  our $lang1, $lang2, $version, $version1, $version2, $only, $expandind, $column;

  print "<H2 ID='${appendix}top'>Appendix - $appendix</H2>\n";

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
  print_content($lang1, \@script1, $lang2, \@script2);
}

1;
