#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office   popup

package horas;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use File::Basename;

$error = '';
$debug = '';

if (opendir(DIR, ".")) {
  my @a = readdir(DIR);
  closedir DIR;

  foreach $item (@a) {
    if ($item !~ /Psalm([0-9]+)\.txt/i) {next;}
    $num = $1;
    if ($num > 10 && $num < 147) {
      $num1 = $num - 1;
      if (open (OUT, ">Psalm$num1.txt")) {
        print "Psalm$num\n";
        open (INP, "$item");
        while ($line = <INP>) {
          $line =~ s/^$num\:/$num1\:/;
          print OUT $line;
        }
        close INP;
        close OUT;
      } else {print "Psalm$num.txt cannot open\n";}
    }
  }
} else {print "Directory cannot open\n";}
