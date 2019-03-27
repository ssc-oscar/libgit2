#!/usr/bin/perl -I /home/audris/lib/x86_64-linux-gnu/perl

use strict;
use warnings;
use Try::Tiny;
use Compress::Raw::Zlib;

use Compress::LZF;
open A, "packfile"; 
binmode(A);
my @stat = stat "packfile";
my $s = $stat[7];
my $c =""; 
my $rl=read (A, $c, $s); 
my $strB = substr($c, 0, $s-20); 
my $strE = substr($c, $s-20, $s); 
my $sha = unpack "H*", $strE; 
my ($m, $v, $no, $str1) = unpack "a4 N N a*", $strB; 
my $left = length ($str1); 
print "rl=$rl s=$s $m version=$v nObj=$no $sha left=$left\n";


while (length ($str1) > 6){
  my ($t0, $str0) = unpack "C a*", $str1;
  $str1 = $str0;
  my $h = $t0 & 128;
  my $sz0 = $t0 & 0b1111;
  $t0 = ($t0 >> 4) & 0b111;
  my @a = ($sz0);
  while ($h){
    printf "$h next %b\n", $sz0;
    $sz0 = unpack "C a*", $str1;
    $h = $sz0 & 128;
    $left -= 1;
    $str1 = substr ($str1, 1, length($str1)-1);
    $sz0 = ($sz0 & 127);
    push @a, $sz0;
  }
  my $len1 = 0;
  for my $i (0..$#a){
    my $mult = 1;
    $mult = 16 * (128**($i-1)) if $i > 1;  
    $len1 += $a[$i] * $mult;
    printf "i=%d %b %d\n", $i, $a[$i], $a[$i]*$mult;
  }
  printf "type=%b len1=%d\n", $t0, $len1;
  my ($inf, $status) = new Compress::Raw::Zlib::Inflate( -Bufsize => 300 );
  my $code;
  print "status=$status lB=".(length($str1))."\n";
  $status = $inf->inflate($str1, $code);
  print "lA=".(length($str1))."\n";
  print "$code\n";
}



sub safeDecomp {
   my ($codeC, $msg) = @_;
   eval {
     my $code = decompress ($codeC);
     return $code;
   } or do {
     my $ex = $@;
     #print STDERR "Error: $ex, $msg\n";
     return "";
  }
}

