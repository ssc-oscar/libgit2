#! /usr/bin/perl -w

#-------------------------------------------------------------------------------------------------
# The test cases of the fixed-length database API
#                                                                Copyright (C) 2006-2010 FAL Labs
# This file is part of Tokyo Cabinet.
# Tokyo Cabinet is free software; you can redistribute it and/or modify it under the terms of
# the GNU Lesser General Public License as published by the Free Software Foundation; either
# version 2.1 of the License or any later version.  Tokyo Cabinet is distributed in the hope
# that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
# You should have received a copy of the GNU Lesser General Public License along with Tokyo
# Cabinet; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA 02111-1307 USA.
#-------------------------------------------------------------------------------------------------


use lib qw(./blib/lib ./blib/arch);
use strict;
use warnings;
use ExtUtils::testlib;
use Time::HiRes qw(gettimeofday);
use Data::Dumper;
use TokyoCabinet;
$TokyoCabinet::DEBUG = 1;


# main routine
sub main {
    my $rv;
    scalar(@ARGV) >= 1 || usage();
    if($ARGV[0] eq "write"){
        $rv = runwrite();
    } elsif($ARGV[0] eq "read"){
        $rv = runread();
    } elsif($ARGV[0] eq "remove"){
        $rv = runremove();
    } elsif($ARGV[0] eq "misc"){
        $rv = runmisc();
    } else {
        usage();
    }
    return $rv;
}


# print the usage and exit
sub usage {
    printf STDERR ("$0: test cases of the fixed-length database API\n");
    printf STDERR ("\n");
    printf STDERR ("usage:\n");
    printf STDERR ("  $0 write [-nl|-nb] path rnum [width [limsiz]]\n");
    printf STDERR ("  $0 read [-nl|-nb] path\n");
    printf STDERR ("  $0 remove [-nl|-nb] path\n");
    printf STDERR ("  $0 misc [-nl|-nb] path rnum\n");
    printf STDERR ("\n");
    exit(1);
}


# parse arguments of write command
sub runwrite {
    my $path = undef;
    my $rnum = undef;
    my $width = undef;
    my $limsiz = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::FDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::FDB::OLCKNB;
            } else {
                usage();
            }
        } elsif(!defined($path)){
            $path = $ARGV[$i];
        } elsif(!defined($rnum)){
            $rnum = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($width)){
            $width = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($limsiz)){
            $limsiz = TokyoCabinet::atoi($ARGV[$i]);
        } else {
            usage();
        }
    }
    usage() if(!defined($path) || !defined($rnum) || $rnum < 1);
    $width = defined($width) ? $width : -1;
    $limsiz = defined($limsiz) ? $limsiz : -1;
    my $rv = procwrite($path, $rnum, $width, $limsiz, $omode);
    return $rv;
}


# parse arguments of read command
sub runread {
    my $path = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::FDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::FDB::OLCKNB;
            } else {
                usage();
            }
        } elsif(!defined($path)){
            $path = $ARGV[$i];
        } else {
            usage();
        }
    }
    usage() if(!defined($path));
    my $rv = procread($path, $omode);
    return $rv;
}


# parse arguments of remove command
sub runremove {
    my $path = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::FDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::FDB::OLCKNB;
            } else {
                usage();
            }
        } elsif(!defined($path)){
            $path = $ARGV[$i];
        } else {
            usage();
        }
    }
    usage() if(!defined($path));
    my $rv = procremove($path, $omode);
    return $rv;
}


# parse arguments of misc command
sub runmisc {
    my $path = undef;
    my $rnum = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::FDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::FDB::OLCKNB;
            } else {
                usage();
            }
        } elsif(!defined($path)){
            $path = $ARGV[$i];
        } elsif(!defined($rnum)){
            $rnum = TokyoCabinet::atoi($ARGV[$i]);
        } else {
            usage();
        }
    }
    usage() if(!defined($path) || !defined($rnum) || $rnum < 1);
    my $rv = procmisc($path, $rnum, $omode);
    return $rv;
}


# print error message of fixed-length database
sub eprint {
    my $fdb = shift;
    my $func = shift;
    my $path = $fdb->path();
    printf STDERR ("%s: %s: %s: %s\n",
                   $0, defined($path) ? $path : "-", $func, $fdb->errmsg());
}


# perform write command
sub procwrite {
    my $path = shift;
    my $rnum = shift;
    my $width = shift;
    my $limsiz = shift;
    my $omode = shift;
    printf("<Writing Test>\n  path=%s  rnum=%d  width=%d  limsiz=%d  omode=%d\n\n",
           $path, $rnum, $width, $limsiz, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $fdb = TokyoCabinet::FDB->new();
    if(!$fdb->tune($width, $limsiz)){
        eprint($fdb, "tune");
        $err = 1;
    }
    if(!$fdb->open($path, $fdb->OWRITER | $fdb->OCREAT | $fdb->OTRUNC | $omode)){
        eprint($fdb, "open");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$fdb->put($buf, $buf)){
            eprint($fdb, "put");
            $err = 1;
            last;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("record number: %llu\n", $fdb->rnum());
    printf("size: %llu\n", $fdb->fsiz());
    if(!$fdb->close()){
        eprint($fdb, "close");
        $err = 1;
    }
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# perform read command
sub procread {
    my $path = shift;
    my $omode = shift;
    printf("<Reading Test>\n  path=%s  omode=%d\n\n", $path, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $fdb = TokyoCabinet::FDB->new();
    if(!$fdb->open($path, $fdb->OREADER | $omode)){
        eprint($fdb, "open");
        $err = 1;
    }
    my $rnum = $fdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$fdb->get($buf)){
            eprint($fdb, "get");
            $err = 1;
            last;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("record number: %llu\n", $fdb->rnum());
    printf("size: %llu\n", $fdb->fsiz());
    if(!$fdb->close()){
        eprint($fdb, "close");
        $err = 1;
    }
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# perform remove command
sub procremove {
    my $path = shift;
    my $omode = shift;
    printf("<Removing Test>\n  path=%s  omode=%d\n\n", $path, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $fdb = TokyoCabinet::FDB->new();
    if(!$fdb->open($path, $fdb->OWRITER | $omode)){
        eprint($fdb, "open");
        $err = 1;
    }
    my $rnum = $fdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$fdb->out($buf)){
            eprint($fdb, "out");
            $err = 1;
            last;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("record number: %llu\n", $fdb->rnum());
    printf("size: %llu\n", $fdb->fsiz());
    if(!$fdb->close()){
        eprint($fdb, "close");
        $err = 1;
    }
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# perform misc command
sub procmisc {
    my $path = shift;
    my $rnum = shift;
    my $omode = shift;
    printf("<Miscellaneous Test>\n  path=%s  rnum=%d  omode=%d\n\n", $path, $rnum, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $fdb = TokyoCabinet::FDB->new();
    if(!$fdb->tune(10, 1024 + 32 * $rnum)){
        eprint($fdb, "tune");
        $err = 1;
    }
    if(!$fdb->open($path, $fdb->OWRITER | $fdb->OCREAT | $fdb->OTRUNC | $omode)){
        eprint($fdb, "open");
        $err = 1;
    }
    printf("writing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$fdb->put($buf, $buf)){
            eprint($fdb, "put");
            $err = 1;
            last;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("reading:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$fdb->get($buf)){
            eprint($fdb, "get");
            $err = 1;
            last;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("removing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(int(rand(2)) == 0 && !$fdb->out($buf)){
            eprint($fdb, "out");
            $err = 1;
            last;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("checking iterator:\n");
    if(!$fdb->iterinit()){
        eprint($fdb, "iterinit");
        $err = 1;
    }
    my $inum = 0;
    while(defined(my $key = $fdb->iternext())){
        $inum++;
        my $value = $fdb->get($key);
        if(!defined($value)){
            eprint($fdb, "get");
            $err = 1;
        }
        if($rnum > 250 && $inum % ($rnum / 250) == 0){
            print('.');
            if($inum == $rnum || $inum % ($rnum / 10) == 0){
                printf(" (%08d)\n", $inum);
            }
        }
    }
    printf(" (%08d)\n", $inum) if($rnum > 250);
    if($fdb->ecode() != $fdb->ENOREC || $inum != $fdb->rnum()){
        eprint($fdb, "(validation)");
        $err = 1;
    }
    my $keys = $fdb->range("[min,max]", 10);
    if($fdb->rnum() >= 10 && scalar(@$keys) != 10){
        eprint($fdb, "range");
        $err = 1;
    }
    printf("checking counting:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)) + 1);
        if(int(rand(2)) == 0){
            if(!$fdb->addint($buf, 1) && $fdb->ecode() != $fdb->EKEEP){
                eprint($fdb, "addint");
                $err = 1;
                last;
            }
        } else {
            if(!$fdb->adddouble($buf, 1) && $fdb->ecode() != $fdb->EKEEP){
                eprint($fdb, "adddouble");
                $err = 1;
                last;
            }
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$fdb->sync()){
        eprint($fdb, "sync");
        $err = 1;
    }
    if(!$fdb->optimize()){
        eprint($fdb, "optimize");
        $err = 1;
    }
    my $npath = $path . "-tmp";
    if(!$fdb->copy($npath)){
        eprint($fdb, "copy");
        $err = 1;
    }
    unlink($npath);
    if(!$fdb->vanish()){
        eprint($fdb, "vanish");
        $err = 1;
    }
    printf("checking transaction commit:\n");
    if(!$fdb->tranbegin()){
        eprint($fdb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%d", int(rand($rnum)) + 1);
        if(int(rand(2)) == 0){
            if(!$fdb->putcat($buf, $buf)){
                eprint($fdb, "putcat");
                $err = 1;
                last;
            }
        } else {
            if(!$fdb->out($buf) && $fdb->ecode() != $fdb->ENOREC){
                eprint($fdb, "out");
                $err = 1;
                last;
            }
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$fdb->trancommit()){
        eprint($fdb, "trancommit");
        $err = 1;
    }
    printf("checking transaction abort:\n");
    my $ornum = $fdb->rnum();
    my $ofsiz = $fdb->fsiz();
    if(!$fdb->tranbegin()){
        eprint($fdb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%d", int(rand($rnum)) + 1);
        if(int(rand(2)) == 0){
            if(!$fdb->putcat($buf, $buf)){
                eprint($fdb, "putcat");
                $err = 1;
                last;
            }
        } else {
            if(!$fdb->out($buf) && $fdb->ecode() != $fdb->ENOREC){
                eprint($fdb, "out");
                $err = 1;
                last;
            }
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$fdb->tranabort()){
        eprint($fdb, "tranabort");
        $err = 1;
    }
    if($fdb->rnum() != $ornum || $fdb->fsiz() != $ofsiz){
        eprint($fdb, "(validation)");
        $err = 1;
    }
    printf("record number: %llu\n", $fdb->rnum());
    printf("size: %llu\n", $fdb->fsiz());
    if(!$fdb->close()){
        eprint($fdb, "close");
        $err = 1;
    }
    printf("checking tied updating:\n");
    my %hash;
    if(!tie(%hash, "TokyoCabinet::FDB", $path, TokyoCabinet::FDB::OWRITER)){
        eprint($fdb, "tie");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)));
        my $rnd = int(rand(4));
        if($rnd == 0){
            $hash{$buf} = $buf;
        } elsif($rnd == 1){
            my $value = $hash{$buf};
        } elsif($rnd == 2){
            my $res = exists($hash{$buf});
        } elsif($rnd == 3){
            delete($hash{$buf});
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("checking tied iterator:\n");
    $inum = 0;
    while(my ($key, $value) = each(%hash)){
        $inum++;
        if($rnum > 250 && $inum % ($rnum / 250) == 0){
            print('.');
            if($inum == $rnum || $inum % ($rnum / 10) == 0){
                printf(" (%08d)\n", $inum);
            }
        }
    }
    printf(" (%08d)\n", $inum) if($rnum > 250);
    %hash = ();
    untie(%hash);
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("version: %s\n", TokyoCabinet::VERSION);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# execute main
$| = 1;
$0 =~ s/.*\///;
exit(main());



# END OF FILE
