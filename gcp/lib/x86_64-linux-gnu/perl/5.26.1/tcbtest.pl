#! /usr/bin/perl -w

#-------------------------------------------------------------------------------------------------
# The test cases of the B+ tree database API
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
    printf STDERR ("$0: test cases of the B+ tree database API\n");
    printf STDERR ("\n");
    printf STDERR ("usage:\n");
    printf STDERR ("  $0 write [-tl] [-td|-tb|-tt] [-nl|-nb] path rnum" .
                   " [lmemb [nmemb [bnum [apow [fpow]]]]]\n");
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
    my $lmemb = undef;
    my $nmemb = undef;
    my $bnum = undef;
    my $apow = undef;
    my $fpow = undef;
    my $opts = 0;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-tl"){
                $opts |= TokyoCabinet::BDB::TLARGE;
            } elsif($ARGV[$i] eq "-td"){
                $opts |= TokyoCabinet::BDB::TDEFLATE;
            } elsif($ARGV[$i] eq "-tb"){
                $opts |= TokyoCabinet::BDB::TBZIP;
            } elsif($ARGV[$i] eq "-tt"){
                $opts |= TokyoCabinet::BDB::TTCBS;
            } elsif($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::BDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::BDB::OLCKNB;
            } else {
                usage();
            }
        } elsif(!defined($path)){
            $path = $ARGV[$i];
        } elsif(!defined($rnum)){
            $rnum = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($lmemb)){
            $lmemb = TokyoCabinet::atoi($ARGV[$i]);
        } elsif(!defined($nmemb)){
            $nmemb = TokyoCabinet::atoi($ARGV[$i]);
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
    $lmemb = defined($lmemb) ? $lmemb : -1;
    $nmemb = defined($nmemb) ? $nmemb : -1;
    $bnum = defined($bnum) ? $bnum : -1;
    $apow = defined($apow) ? $apow : -1;
    $fpow = defined($fpow) ? $fpow : -1;
    my $rv = procwrite($path, $rnum, $lmemb, $nmemb, $bnum, $apow, $fpow, $opts, $omode);
    return $rv;
}


# parse arguments of read command
sub runread {
    my $path = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::BDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::BDB::OLCKNB;
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
                $omode |= TokyoCabinet::BDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::BDB::OLCKNB;
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
                $opts |= TokyoCabinet::BDB::TLARGE;
            } elsif($ARGV[$i] eq "-td"){
                $opts |= TokyoCabinet::BDB::TDEFLATE;
            } elsif($ARGV[$i] eq "-tb"){
                $opts |= TokyoCabinet::BDB::TBZIP;
            } elsif($ARGV[$i] eq "-tt"){
                $opts |= TokyoCabinet::BDB::TTCBS;
            } elsif($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::BDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::BDB::OLCKNB;
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


# print error message of B+ tree database
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
    my $lmemb = shift;
    my $nmemb = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    my $omode = shift;
    printf("<Writing Test>\n  path=%s  rnum=%d  lmemb=%d  nmemb=%d  bnum=%d  apow=%d  fpow=%d" .
           "  opts=%d  omode=%d\n\n",
           $path, $rnum, $lmemb, $nmemb, $bnum, $apow, $fpow, $opts, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $bdb = TokyoCabinet::BDB->new();
    if(!$bdb->tune($lmemb, $nmemb, $bnum, $apow, $fpow, $opts)){
        eprint($bdb, "tune");
        $err = 1;
    }
    if(!$bdb->open($path, $bdb->OWRITER | $bdb->OCREAT | $bdb->OTRUNC | $omode)){
        eprint($bdb, "open");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$bdb->put($buf, $buf)){
            eprint($bdb, "put");
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
    printf("record number: %llu\n", $bdb->rnum());
    printf("size: %llu\n", $bdb->fsiz());
    if(!$bdb->close()){
        eprint($bdb, "close");
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
    my $bdb = TokyoCabinet::BDB->new();
    if(!$bdb->open($path, $bdb->OREADER | $omode)){
        eprint($bdb, "open");
        $err = 1;
    }
    my $rnum = $bdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$bdb->get($buf)){
            eprint($bdb, "get");
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
    printf("record number: %llu\n", $bdb->rnum());
    printf("size: %llu\n", $bdb->fsiz());
    if(!$bdb->close()){
        eprint($bdb, "close");
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
    my $bdb = TokyoCabinet::BDB->new();
    if(!$bdb->open($path, $bdb->OWRITER | $omode)){
        eprint($bdb, "open");
        $err = 1;
    }
    my $rnum = $bdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$bdb->out($buf)){
            eprint($bdb, "out");
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
    printf("record number: %llu\n", $bdb->rnum());
    printf("size: %llu\n", $bdb->fsiz());
    if(!$bdb->close()){
        eprint($bdb, "close");
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
    my $bdb = TokyoCabinet::BDB->new();
    if(!$bdb->tune(10, 10, $rnum / 50, 2, -1, $opts)){
        eprint($bdb, "tune");
        $err = 1;
    }
    if(!$bdb->setcache(128, 256)){
        eprint($bdb, "setcache");
        $err = 1;
    }
    if(!$bdb->setxmsiz($rnum * 4)){
        eprint($bdb, "setxmsiz");
        $err = 1;
    }
    if(!$bdb->setdfunit(8)){
        eprint($bdb, "setdfunit");
        $err = 1;
    }
    if(!$bdb->open($path, $bdb->OWRITER | $bdb->OCREAT | $bdb->OTRUNC | $omode)){
        eprint($bdb, "open");
        $err = 1;
    }
    printf("writing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$bdb->put($buf, $buf)){
            eprint($bdb, "put");
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
        if(!$bdb->get($buf)){
            eprint($bdb, "get");
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
        if(int(rand(2)) == 0 && !$bdb->out($buf)){
            eprint($bdb, "out");
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
    printf("checking cursor:\n");
    my $cur = TokyoCabinet::BDBCUR->new($bdb);
    if(!$cur->first() && $bdb->ecode() != $bdb->ENOREC){
        eprint($bdb, "cur::first");
        $err = 1;
    }
    my $inum = 0;
    while(defined(my $key = $cur->key())){
        my $value = $cur->val();
        if(!defined($value)){
            eprint($bdb, "cur::val");
            $err = 1;
        }
        $cur->next();
        if($rnum > 250 && $inum % ($rnum / 250) == 0){
            print('.');
            if($inum == $rnum || $inum % ($rnum / 10) == 0){
                printf(" (%08d)\n", $inum);
            }
        }
        $inum++;
    }
    printf(" (%08d)\n", $inum) if($rnum > 250);
    if($bdb->ecode() != $bdb->ENOREC || $inum != $bdb->rnum()){
        eprint($bdb, "(validation)");
        $err = 1;
    }
    my $keys = $bdb->fwmkeys("0", 10);
    if($bdb->rnum() >= 10 && scalar(@$keys) != 10){
        eprint($bdb, "fwmkeys");
        $err = 1;
    }
    printf("checking counting:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$bdb->addint($buf, 1) && $bdb->ecode() != $bdb->EKEEP){
                eprint($bdb, "addint");
                $err = 1;
                last;
            }
        } else {
            if(!$bdb->adddouble($buf, 1) && $bdb->ecode() != $bdb->EKEEP){
                eprint($bdb, "adddouble");
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
    if(!$bdb->sync()){
        eprint($bdb, "sync");
        $err = 1;
    }
    if(!$bdb->optimize()){
        eprint($bdb, "optimize");
        $err = 1;
    }
    my $npath = $path . "-tmp";
    if(!$bdb->copy($npath)){
        eprint($bdb, "copy");
        $err = 1;
    }
    unlink($npath);
    if(!$bdb->vanish()){
        eprint($bdb, "vanish");
        $err = 1;
    }
    printf("random writing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", int(rand($i)));
        if(!$bdb->putdup($buf, $buf)){
            eprint($bdb, "put");
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
    printf("cursor updating:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        if(int(rand(10)) == 0){
            my $buf = sprintf("%08d", int(rand($rnum)));
            $cur->jump($buf);
            for(my $j = 1; $j <= 10; $j++){
                my $key = $cur->key();
                last if(!defined($key));
                if(int(rand(3)) == 0){
                    $cur->out();
                } else {
                    my $cpmode = $cur->CPCURRENT + int(rand(3));
                    $cur->put($buf, $cpmode);
                }
                $cur->next();
            }
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$bdb->tranbegin()){
        eprint($bdb, "put");
        $err = 1;
    }
    $bdb->putdup("::1", "1");
    $bdb->putdup("::2", "2a");
    $bdb->putdup("::2", "2b");
    $bdb->putdup("::3", "3");
    $cur->jump("::2");
    $cur->put("2A");
    $cur->put("2-", $cur->CPBEFORE);
    $cur->put("2+");
    $cur->next();
    $cur->next();
    $cur->put("mid", $cur->CPBEFORE);
    $cur->put("2C", $cur->CPAFTER);
    $cur->prev();
    $cur->out();
    my $vals = $bdb->getlist("::2");
    if(!defined($vals) || scalar(@$vals) != 4){
        eprint($bdb, "getlist");
        $err = 1;
    }
    my @pvals = ( "hop", "step", "jump" );
    if(!$bdb->putlist("::1", \@pvals)){
        eprint($bdb, "putlist");
        $err = 1;
    }
    if(!$bdb->outlist("::1")){
        eprint($bdb, "outlist");
        $err = 1;
    }
    if(!$bdb->trancommit()){
        eprint($bdb, "put");
        $err = 1;
    }
    if(!$bdb->tranbegin() || !$bdb->tranabort()){
        eprint($bdb, "put");
        $err = 1;
    }
    printf("record number: %llu\n", $bdb->rnum());
    printf("size: %llu\n", $bdb->fsiz());
    if(!$bdb->close()){
        eprint($bdb, "close");
        $err = 1;
    }
    printf("checking tied updating:\n");
    my %hash;
    if(!tie(%hash, "TokyoCabinet::BDB", $path, TokyoCabinet::BDB::OWRITER)){
        eprint($bdb, "tie");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)));
        my $rnd = int(rand(4));
        if($rnd == 0){
            $hash{$buf} = $buf;
        } elsif($rnd == 1){
            my $value = $hash{$buf}
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
