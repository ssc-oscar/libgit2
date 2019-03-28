#!/usr/bin/perl -I /home/audris/lib/x86_64-linux-gnu/perl

use strict;
use warnings;
use Try::Tiny;
use Compress::Raw::Zlib;

use Compress::LZF;
my $fname = $ARGV[0];
open A, $fname; 
binmode(A);
my @stat = stat $fname;
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
  print "left = ".(length($str1))."\n";
  my $h = $t0 & 128;
  my $sz0 = $t0 & 0b1111;
  $t0 = ($t0 >> 4) & 0b111;
  my @a = ($sz0);
  while ($h){
    #printf "$h next %b\n", $sz0;
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
    #printf "i=%d %b %d\n", $i, $a[$i], $a[$i]*$mult;
  }
  printf "type=%b length=%d  ", $t0, $len1;
  if ($t0 < 5){
    my ($inf, $status) = new Compress::Raw::Zlib::Inflate( -Bufsize => 300 );
    my $code;
    print "compressed length Max=".(length($str1))." -- ";
    $status = $inf->inflate($str1, $code);
    print "length Left=".(length($str1))." status=$status -- uncompressed length = ".(length($code))."\n";
    print "$code\n";
  }else{
    if ($t0 == 7){
      print "left1 = ".(length($str1))."\n";
      my $hh = substr($str1, 0, 20);
      $sha = unpack "H*", $hh;
      print "base sha=$sha\n";
      $str1 = substr($str1, 20, length($str1)-20);
      my ($inf, $status) = new Compress::Raw::Zlib::Inflate( -Bufsize => 300 );
      my $code;
      $status = $inf->inflate($str1, $code);
      print "length Left=".(length($str1))." status=$status -- uncompressed length = ".(length($code))."\n";
      my ($do, $rest) = unpack "C a*", $code;
      my $add = ($do & 0b10000000) == 0;
      $code = $rest;
      if ($add){
        #take original object (length in $do) and append $rest
	#print "left2 = ".(length($str1))."\n";
	
	my ($of, $of1, $l, $l1, $rest) = unpack "C C C C a*", $code;
	$code = $rest;
        printf "do=%.8b do=%d of=%d of1=%d l=%d l1=%d code=%s\n", $do, $do, $of, $of1, $l, $l1, $code;
      }
    }else{
      if ($t0 == 6){
        print "left1 = ".(length($str1))."\n";
        my $sz0 = unpack "C a*", $str1;
	$h = $sz0 & 128;
	my @a = ($sz0 & 127);
	while ($h){
	  $sz0 = unpack "C a*", $str1;
	  $h = $sz0 & 128;
	  $str1 = substr ($str1, 1, length($str1)-1);
	  $sz0 = ($sz0 & 127);
	  push @a, $sz0;
	}
	my $len1 = 0;
	my $mult = 1;
	for my $i (0..$#a){
	  $mult = $mult * 128 if $i > 0;
	  $len1 += $a[$i] * $mult;
	}
	print "@a\n";
	my ($inf, $status) = new Compress::Raw::Zlib::Inflate( -Bufsize => 300 );
	my $code;
	$status = $inf->inflate($str1, $code);
	print "look backwards=".($len1)." length Left=".(length($str1))." status=$status -- uncompressed length = ".(length($code))."\n";
	#exit();
	my ($do, $rest) = unpack "C a*", $code;
	my $add = ($do & 0b10000000) == 0;
	printf "add=%.8b do=%b do=%d lCode=%d\n", $add, $do, $do, length ($rest);
	$code = $rest;
	if ($add){
	  my ($of, $of1, $l, $l1, $rest) = unpack "C C C C a*", $code;
	  $code = $rest;
	  printf "do=%d of=%d of1=%d l=%d l1=%d code=%s\n", $do, $of, $of1, $l, $l1, $code;
	}else{
          my ($of, $of1, $l, $rest) = unpack "C C C a*", $code;	
	  $code = $rest;
	  printf "of=%d of1=%d l=%d code=%s\n", $of, $of1, $l, $code;  
	}
      }
      # printf "do=%b add=%b %d\n", $do, $add, $do;
      #my ($do, $of, $of1, $l, $l1, $l2, $rest) = unpack "C C C C C C a*", $code;
      #printf "do=%b of=%d of1=%d l=%d l1=%d l2=%d str=%s\n", $do, $of, $of1, $l, $l1, $l2, $rest;
    }
  }
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

