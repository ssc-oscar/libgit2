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
my $offset = 20;
my $strE = substr($c, $s-20, $s); 
my $sha = unpack "H*", $strE; 
my ($m, $v, $no, $str1) = unpack "a4 N N a*", $strB; 
$offset += 4+4;
my $left = length ($str1); 
print "rl=$rl s=$s $m version=$v nObj=$no $sha left=$left\n";


while (length ($str1) > 6){
  print "offset = $offset\n";
  my ($t0, $str0) = unpack "C a*", $str1;
  $offset += 1;
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
    $offset += 1;
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
    my $pre = length($str1);
    print "compressed length Max=$pre -- ";
    $status = $inf->inflate($str1, $code);
    my $left = length($str1);
    $offset += $pre-$left;
    print "length Left=$left status=$status -- uncompressed length = ".(length($code))."\n";
    print "$code\n";
  }else{
    if ($t0 == 7){
      print "left1 = ".(length($str1))."\n";
      my $hh = substr($str1, 0, 20);
      $sha = unpack "H*", $hh;
      print "base sha=$sha\n";
      $str1 = substr($str1, 20, length($str1)-20);
      $offset += 20;
      my ($inf, $status) = new Compress::Raw::Zlib::Inflate( -Bufsize => 300 );
      my $code;
      my $pre = length($str1);
      $status = $inf->inflate($str1, $code);
      print "length Left=$pre status=$status -- uncompressed length = ".(length($code))."\n";
      my $left = length($str1);
      $offset += $pre-$left;
      my ($sizO, $sizN, $do, $rest) = unpack "C C C a*", $code;
      my $nadd = ($do & 0b10000000);
      print "add=$nadd\n";
      $code = $rest;
      while (length($code)>0) {
        printf "do=%.8b sizO=%d sizN=%d\n", $do, $sizO, $sizN;
        $do = ($do & 0b01111111);
        if ($nadd){
          my $cnt = 0;
          for my $i (0..7){
	    if ($do & 0b1){
	      my ($of, $rest) = unpack "C a*", $code;
	      $code = $rest;
	      printf "i=%d of=%d ", $i, $of;
            }
	    $cnt += $do & 0b1;
	    $do = $do >> 1;
          } 
          print "cnt=$cnt left=".(length($code))."\n";
        }else{	
	  my $copy = substr($code, 0, $do);
	  $code = substr($code, $do, length($code)-$do);
	  print "len=$do copy=$copy\n";
	}
        if (length($code)>0){ 
          ($do, $rest) = unpack "C a*", $code;
          $nadd = ($do & 0b10000000);	  
          $code = $rest;
	  print "add=$nadd\n";
	}
      }
    }else{
      if ($t0 == 6){
        print "left1 = ".(length($str1))."\n";
        my $sz0 = unpack "C a*", $str1;
        $offset += 1;
	$h = $sz0 & 128;
	my @a = ($sz0 & 127);
	while ($h){
	  $sz0 = unpack "C a*", $str1;
	  $h = $sz0 & 128;
	  $str1 = substr ($str1, 1, length($str1)-1);
          $offset += 1;
	  $sz0 = ($sz0 & 127);
	  push @a, $sz0;
	}
	my $len1 = 0;
	my $mult = 1;
	for my $i (0..$#a){
	  $mult = $mult * 128 if $i > 0;
	  $len1 += $a[$i-$#a] * $mult;
	}
	print "@a\n";
	my ($inf, $status) = new Compress::Raw::Zlib::Inflate( -Bufsize => 300 );
	my $code;
        my $pre = length($str1);
	$status = $inf->inflate($str1, $code);
        my $left = length($str1);
	$offset += $pre - $left;
	print "look backwards=".($len1)." length Left=".(length($str1))." status=$status -- uncompressed length = ".(length($code))."\n";
	#exit();
	my ($do, $rest) = unpack "C a*", $code;
	my $add = ($do & 0b10000000) == 0;
	printf "add=%.8b do=%b do=%d lCode=%d\n", $add, $do, $do, length ($rest);
	$code = $rest;
	if ($add){
	  my ($of, $of1, $l, $l1, $rest) = unpack "C C C C a*", $code;
	  $code = $rest;
	  printf "add: of=%d of1=%d l=%d l1=%d code=%s\n", $of, $of1, $l, $l1, $code;
	}else{
          my ($of, $of1, $l, $l1, $rest) = unpack "C C C C a*", $code;	
	  $code = $rest;
	  printf " no: of=%d of1=%d l=%d l1=%d code=%s\n", $of, $of1, $l, $l1, $code;  
	}
	exit();
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

