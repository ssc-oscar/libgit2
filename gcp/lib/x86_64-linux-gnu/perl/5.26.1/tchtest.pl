#! /usr/bin/perl -w

#-------------------------------------------------------------------------------------------------
# The test cases of the hash database API
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
    printf STDERR ("$0: test cases of the hash database API\n");
    printf STDERR ("\n");
    printf STDERR ("usage:\n");
    printf STDERR ("  $0 write [-tl] [-td|-tb|-tt] [-nl|-nb] [-as] path rnum" .
                   " [bnum [apow [fpow]]]\n");
    printf STDERR ("  $0 read [-nl|-nb] path\n");
    printf STDERR ("  $0 remove [-nl|-nb] path\n");
    printf STDERR ("  $0 misc [-tl] [-td|-tb|-tt] [-nl|-nb] path rnum\n");
    printf STDERR ("\n");
    exit(1);
}


# parse arguments of write command
sub runwrite {
    my $path = undef;
    my $rnum = undef;
    my $bnum = undef;
    my $apow = undef;
    my $fpow = undef;
    my $opts = 0;
    my $omode = 0;
    my $as = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-tl"){
                $opts |= TokyoCabinet::HDB::TLARGE;
            } elsif($ARGV[$i] eq "-td"){
                $opts |= TokyoCabinet::HDB::TDEFLATE;
            } elsif($ARGV[$i] eq "-tb"){
                $opts |= TokyoCabinet::HDB::TBZIP;
            } elsif($ARGV[$i] eq "-tt"){
                $opts |= TokyoCabinet::HDB::TTCBS;
            } elsif($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::HDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::HDB::OLCKNB;
            } elsif($ARGV[$i] eq "-as"){
                $as = 1;
            } else {
                usage();
            }
        } elsif(!defined($path)){
            $path = $ARGV[$i];
        } elsif(!defined($rnum)){
            $rnum = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($bnum)){
            $bnum = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($apow)){
            $apow = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($fpow)){
            $fpow = TokyoCabinet::atoi($ARGV[$i]);
        } else {
            usage();
        }
    }
    usage() if(!defined($path) || !defined($rnum) || $rnum < 1);
    $bnum = defined($bnum) ? $bnum : -1;
    $apow = defined($apow) ? $apow : -1;
    $fpow = defined($fpow) ? $fpow : -1;
    my $rv = procwrite($path, $rnum, $bnum, $apow, $fpow, $opts, $omode, $as);
    return $rv;
}


# parse arguments of read command
sub runread {
    my $path = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::HDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::HDB::OLCKNB;
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
                $omode |= TokyoCabinet::HDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::HDB::OLCKNB;
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
    my $opts = 0;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-tl"){
                $opts |= TokyoCabinet::HDB::TLARGE;
            } elsif($ARGV[$i] eq "-td"){
                $opts |= TokyoCabinet::HDB::TDEFLATE;
            } elsif($ARGV[$i] eq "-tb"){
                $opts |= TokyoCabinet::HDB::TBZIP;
            } elsif($ARGV[$i] eq "-tt"){
                $opts |= TokyoCabinet::HDB::TTCBS;
            } elsif($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::HDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::HDB::OLCKNB;
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
    my $rv = procmisc($path, $rnum, $opts, $omode);
    return $rv;
}


# print error message of hash database
sub eprint {
    my $hdb = shift;
    my $func = shift;
    my $path = $hdb->path();
    printf STDERR ("%s: %s: %s: %s\n",
                   $0, defined($path) ? $path : "-", $func, $hdb->errmsg());
}


# perform write command
sub procwrite {
    my $path = shift;
    my $rnum = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    my $omode = shift;
    my $as = shift;
    printf("<Writing Test>\n  path=%s  rnum=%d  bnum=%d  apow=%d  fpow=%d  opts=%d" .
           "  omode=%d  as=%d\n\n", $path, $rnum, $bnum, $apow, $fpow, $opts, $omode, $as);
    my $err = 0;
    my $stime = gettimeofday();
    my $hdb = TokyoCabinet::HDB->new();
    if(!$hdb->tune($bnum, $apow, $fpow, $opts)){
        eprint($hdb, "tune");
        $err = 1;
    }
    if(!$hdb->open($path, $hdb->OWRITER | $hdb->OCREAT | $hdb->OTRUNC | $omode)){
        eprint($hdb, "open");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if($as){
            if(!$hdb->putasync($buf, $buf)){
                eprint($hdb, "putasync");
                $err = 1;
                last;
            }
        } else {
            if(!$hdb->put($buf, $buf)){
                eprint($hdb, "put");
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
    printf("record number: %llu\n", $hdb->rnum());
    printf("size: %llu\n", $hdb->fsiz());
    if(!$hdb->close()){
        eprint($hdb, "close");
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
    my $hdb = TokyoCabinet::HDB->new();
    if(!$hdb->open($path, $hdb->OREADER | $omode)){
        eprint($hdb, "open");
        $err = 1;
    }
    my $rnum = $hdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$hdb->get($buf)){
            eprint($hdb, "get");
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
    printf("record number: %llu\n", $hdb->rnum());
    printf("size: %llu\n", $hdb->fsiz());
    if(!$hdb->close()){
        eprint($hdb, "close");
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
    my $hdb = TokyoCabinet::HDB->new();
    if(!$hdb->open($path, $hdb->OWRITER | $omode)){
        eprint($hdb, "open");
        $err = 1;
    }
    my $rnum = $hdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$hdb->out($buf)){
            eprint($hdb, "out");
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
    printf("record number: %llu\n", $hdb->rnum());
    printf("size: %llu\n", $hdb->fsiz());
    if(!$hdb->close()){
        eprint($hdb, "close");
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
    my $opts = shift;
    my $omode = shift;
    printf("<Miscellaneous Test>\n  path=%s  rnum=%d  opts=%d  omode=%d\n\n",
           $path, $rnum, $opts, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $hdb = TokyoCabinet::HDB->new();
    if(!$hdb->tune($rnum / 50, 2, -1, $opts)){
        eprint($hdb, "tune");
        $err = 1;
    }
    if(!$hdb->setcache($rnum / 10)){
        eprint($hdb, "setcache");
        $err = 1;
    }
    if(!$hdb->setxmsiz($rnum * 4)){
        eprint($hdb, "setxmsiz");
        $err = 1;
    }
    if(!$hdb->setdfunit(8)){
        eprint($hdb, "setdfunit");
        $err = 1;
    }
    if(!$hdb->open($path, $hdb->OWRITER | $hdb->OCREAT | $hdb->OTRUNC | $omode)){
        eprint($hdb, "open");
        $err = 1;
    }
    printf("writing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$hdb->put($buf, $buf)){
            eprint($hdb, "put");
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
        if(!$hdb->get($buf)){
            eprint($hdb, "get");
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
        if(int(rand(2)) == 0 && !$hdb->out($buf)){
            eprint($hdb, "out");
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
    if(!$hdb->iterinit()){
        eprint($hdb, "iterinit");
        $err = 1;
    }
    my $inum = 0;
    while(defined(my $key = $hdb->iternext())){
        $inum++;
        my $value = $hdb->get($key);
        if(!defined($value)){
            eprint($hdb, "get");
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
    if($hdb->ecode() != $hdb->ENOREC || $inum != $hdb->rnum()){
        eprint($hdb, "(validation)");
        $err = 1;
    }
    my $keys = $hdb->fwmkeys("0", 10);
    if($hdb->rnum() >= 10 && scalar(@$keys) != 10){
        eprint($hdb, "fwmkeys");
        $err = 1;
    }
    printf("checking counting:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$hdb->addint($buf, 1) && $hdb->ecode() != $hdb->EKEEP){
                eprint($hdb, "addint");
                $err = 1;
                last;
            }
        } else {
            if(!$hdb->adddouble($buf, 1) && $hdb->ecode() != $hdb->EKEEP){
                eprint($hdb, "adddouble");
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
    if(!$hdb->sync()){
        eprint($hdb, "sync");
        $err = 1;
    }
    if(!$hdb->optimize()){
        eprint($hdb, "optimize");
        $err = 1;
    }
    my $npath = $path . "-tmp";
    if(!$hdb->copy($npath)){
        eprint($hdb, "copy");
        $err = 1;
    }
    unlink($npath);
    if(!$hdb->vanish()){
        eprint($hdb, "vanish");
        $err = 1;
    }
    printf("checking transaction commit:\n");
    if(!$hdb->tranbegin()){
        eprint($hdb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%d", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$hdb->putcat($buf, $buf)){
                eprint($hdb, "putcat");
                $err = 1;
                last;
            }
        } else {
            if(!$hdb->out($buf) && $hdb->ecode() != $hdb->ENOREC){
                eprint($hdb, "out");
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
    if(!$hdb->trancommit()){
        eprint($hdb, "trancommit");
        $err = 1;
    }
    printf("checking transaction abort:\n");
    my $ornum = $hdb->rnum();
    my $ofsiz = $hdb->fsiz();
    if(!$hdb->tranbegin()){
        eprint($hdb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%d", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$hdb->putcat($buf, $buf)){
                eprint($hdb, "putcat");
                $err = 1;
                last;
            }
        } else {
            if(!$hdb->out($buf) && $hdb->ecode() != $hdb->ENOREC){
                eprint($hdb, "out");
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
    if(!$hdb->tranabort()){
        eprint($hdb, "tranabort");
        $err = 1;
    }
    if($hdb->rnum() != $ornum || $hdb->fsiz() != $ofsiz){
        eprint($hdb, "(validation)");
        $err = 1;
    }
    printf("record number: %llu\n", $hdb->rnum());
    printf("size: %llu\n", $hdb->fsiz());
    if(!$hdb->close()){
        eprint($hdb, "close");
        $err = 1;
    }
    printf("checking tied updating:\n");
    my %hash;
    if(!tie(%hash, "TokyoCabinet::HDB", $path, TokyoCabinet::HDB::OWRITER)){
        eprint($hdb, "tie");
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
