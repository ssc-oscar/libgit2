#! /usr/bin/perl

use lib qw(./blib/lib ./blib/arch);
use strict;
use warnings;
use TokyoCabinet;
use Time::HiRes qw(gettimeofday);

sub memoryusage {
    my $status = `cat /proc/$$/status`;
    my @lines = split("\n", $status);
    foreach my $line (@lines){
        if($line =~ /^VmRSS:/){
            $line =~ s/.*:\s*(\d+).*/$1/;
            return int($line) / 1024.0;
        }
    }
    return -1;
}

my $rnum = 1000000;
if(scalar(@ARGV) > 0){
    $rnum = int($ARGV[0]);
}

my %hash;
if(scalar(@ARGV) > 1){
    tie(%hash, "TokyoCabinet::ADB", $ARGV[1]) || die("tie failed");
}

my $stime = gettimeofday();
for(my $i = 0; $i < $rnum; $i++){
    my $buf = sprintf("%08d", $i);
    $hash{$buf} = $buf;
}
my $etime = gettimeofday();

printf("Time: %.3f sec.\n", $etime - $stime);
printf("Usage: %.3f MB\n", memoryusage());
