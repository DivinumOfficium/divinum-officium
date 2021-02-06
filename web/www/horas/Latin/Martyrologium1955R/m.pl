#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office  converts monthly files to daily files

package horas;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use File::Basename;


opendir (DIR, ".") or die "datafolder cannot open!";
 my @file = readdir(DIR);
 close DIR;

 foreach $file (@file) {
   if ($file !~ /^([0-9][0-9])\.txt/i) {next;}
   $month = $1;

   open (INP, "$month.txt") or die "$month.txt cannot open for input!";
   @a = <INP>;
   close INP;
   my $day = 0;
   my $text = '';
   foreach $line (@a) {
     $line = chompd($line);
     if (!$line || $line=~ /^\s*$/ || $line =~ /bissex/i || length($line) < 10) {next;}   
     
     if ($line =~ /^\s*([0-9]+)\s*?[a-z]+\s+(.*)\.\s*Lun/i) {  
       my $d = $1;
       my $name = $2;
       if ($day) {
         my $fname = sprintf("%02i-%02i", $month, $day);
         open (OUT, ">$fname.txt") or die "$fname.txt cannot open for output";
         print OUT $text;
         close OUT;
       }
       $text = "$name\n_\n";
       $day = $d;
    }
    if (!$day) {next;}
    if ($line =~ /[a-z][a-z][a-z]\.\s+[A-Z]/) {next;}
    $text .= "$line\n";
  }
  if ($day) {
    my $fname = sprintf("%02i-%02i", $month, $day);
    open (OUT, ">$fname.txt") or die "$fname.txt cannot open for output";
    print OUT $text;
    close OUT;
  }
}


sub chompd {
  my $a = shift;
  chomp($a);
  $a =~ s/\r//g;
  return $a;
}
