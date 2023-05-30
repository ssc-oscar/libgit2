#! /usr/bin/perl -w

#-------------------------------------------------------------------------------------------------
# The test cases of the table database API
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
    printf STDERR ("$0: test cases of the table database API\n");
    printf STDERR ("\n");
    printf STDERR ("usage:\n");
    printf STDERR ("  $0 write [-tl] [-td|-tb|-tt] [-ip|-is|-in|-it|-if|-ix] [-nl|-nb] path rnum" .
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
    my $iflags = 0;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-tl"){
                $opts |= TokyoCabinet::TDB::TLARGE;
            } elsif($ARGV[$i] eq "-td"){
                $opts |= TokyoCabinet::TDB::TDEFLATE;
            } elsif($ARGV[$i] eq "-tb"){
                $opts |= TokyoCabinet::TDB::TBZIP;
            } elsif($ARGV[$i] eq "-tt"){
                $opts |= TokyoCabinet::TDB::TTCBS;
            } elsif($ARGV[$i] eq "-ip"){
                $iflags |= 1 << 0;
            } elsif($ARGV[$i] eq "-is"){
                $iflags |= 1 << 1;
            } elsif($ARGV[$i] eq "-in"){
                $iflags |= 1 << 2;
            } elsif($ARGV[$i] eq "-it"){
                $iflags |= 1 << 3;
            } elsif($ARGV[$i] eq "-if"){
                $iflags |= 1 << 4;
            } elsif($ARGV[$i] eq "-ix"){
                $iflags |= 1 << 5;
            } elsif($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::TDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::TDB::OLCKNB;
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
    my $rv = procwrite($path, $rnum, $bnum, $apow, $fpow, $opts, $iflags, $omode);
    return $rv;
}


# parse arguments of read command
sub runread {
    my $path = undef;
    my $omode = 0;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($path) && $ARGV[$i] =~ /^-/){
            if($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::TDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::TDB::OLCKNB;
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
                $omode |= TokyoCabinet::TDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::TDB::OLCKNB;
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
                $opts |= TokyoCabinet::TDB::TLARGE;
            } elsif($ARGV[$i] eq "-td"){
                $opts |= TokyoCabinet::TDB::TDEFLATE;
            } elsif($ARGV[$i] eq "-tb"){
                $opts |= TokyoCabinet::TDB::TBZIP;
            } elsif($ARGV[$i] eq "-tt"){
                $opts |= TokyoCabinet::TDB::TTCBS;
            } elsif($ARGV[$i] eq "-nl"){
                $omode |= TokyoCabinet::TDB::ONOLCK;
            } elsif($ARGV[$i] eq "-nb"){
                $omode |= TokyoCabinet::TDB::OLCKNB;
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


# print error message of table database
sub eprint {
    my $tdb = shift;
    my $func = shift;
    my $path = $tdb->path();
    printf STDERR ("%s: %s: %s: %s\n",
                   $0, defined($path) ? $path : "-", $func, $tdb->errmsg());
}


# perform write command
sub procwrite {
    my $path = shift;
    my $rnum = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    my $iflags = shift;
    my $omode = shift;
    printf("<Writing Test>\n  path=%s  rnum=%d  bnum=%d  apow=%d  fpow=%d  opts=%d  iflags=%d" .
           "  omode=%d\n\n", $path, $rnum, $bnum, $apow, $fpow, $opts, $iflags, $omode);
    my $err = 0;
    my $stime = gettimeofday();
    my $tdb = TokyoCabinet::TDB->new();
    if(!$tdb->tune($bnum, $apow, $fpow, $opts)){
        eprint($tdb, "tune");
        $err = 1;
    }
    if(!$tdb->open($path, $tdb->OWRITER | $tdb->OCREAT | $tdb->OTRUNC | $omode)){
        eprint($tdb, "open");
        $err = 1;
    }
    if(($iflags & (1 << 0)) && !$tdb->setindex("", $tdb->ITDECIMAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(($iflags & (1 << 1)) && !$tdb->setindex("str", $tdb->ITLEXICAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(($iflags & (1 << 2)) && !$tdb->setindex("num", $tdb->ITDECIMAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(($iflags & (1 << 3)) && !$tdb->setindex("type", $tdb->ITDECIMAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(($iflags & (1 << 4)) && !$tdb->setindex("flag", $tdb->ITTOKEN)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(($iflags & (1 << 5)) && !$tdb->setindex("text", $tdb->ITQGRAM)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $id = $tdb->genuid();
        my $cols = {
            str => $id,
            num => int(rand($id)) + 1,
            type => int(rand(32)) + 1,
        };
        my $vbuf = "";
        my $num = int(rand(5));
        my $pt = 0;
        for(my $j = 0; $j < $num; $j++){
            $pt += int(rand(5)) + 1;
            $vbuf .= "," if(length($vbuf) > 0);
            $vbuf .= $pt;
        }
        if(length($vbuf) > 0){
            $cols->{flag} = $vbuf;
            $cols->{text} = $vbuf;
        }
        if(!$tdb->put($id, $cols)){
            eprint($tdb, "put");
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
    printf("record number: %llu\n", $tdb->rnum());
    printf("size: %llu\n", $tdb->fsiz());
    if(!$tdb->close()){
        eprint($tdb, "close");
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
    my $tdb = TokyoCabinet::TDB->new();
    if(!$tdb->open($path, $tdb->OREADER | $omode)){
        eprint($tdb, "open");
        $err = 1;
    }
    my $rnum = $tdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        if(!$tdb->get($i)){
            eprint($tdb, "get");
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
    printf("record number: %llu\n", $tdb->rnum());
    printf("size: %llu\n", $tdb->fsiz());
    if(!$tdb->close()){
        eprint($tdb, "close");
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
    my $tdb = TokyoCabinet::TDB->new();
    if(!$tdb->open($path, $tdb->OWRITER | $omode)){
        eprint($tdb, "open");
        $err = 1;
    }
    my $rnum = $tdb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        if(!$tdb->out($i)){
            eprint($tdb, "out");
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
    printf("record number: %llu\n", $tdb->rnum());
    printf("size: %llu\n", $tdb->fsiz());
    if(!$tdb->close()){
        eprint($tdb, "close");
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
    my $tdb = TokyoCabinet::TDB->new();
    if(!$tdb->tune($rnum / 50, 2, -1, $opts)){
        eprint($tdb, "tune");
        $err = 1;
    }
    if(!$tdb->setcache($rnum / 10, 128, 256)){
        eprint($tdb, "setcache");
        $err = 1;
    }
    if(!$tdb->setxmsiz($rnum * 4)){
        eprint($tdb, "setxmsiz");
        $err = 1;
    }
    if(!$tdb->setdfunit(8)){
        eprint($tdb, "setdfunit");
        $err = 1;
    }
    if(!$tdb->open($path, $tdb->OWRITER | $tdb->OCREAT | $tdb->OTRUNC | $omode)){
        eprint($tdb, "open");
        $err = 1;
    }
    if(!$tdb->setindex("", $tdb->ITDECIMAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(!$tdb->setindex("str", $tdb->ITLEXICAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(!$tdb->setindex("num", $tdb->ITDECIMAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(!$tdb->setindex("type", $tdb->ITDECIMAL)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(!$tdb->setindex("flag", $tdb->ITTOKEN)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    if(!$tdb->setindex("text", $tdb->ITQGRAM)){
        eprint($tdb, "setindex");
        $err = 1;
    }
    printf("writing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $id = $tdb->genuid();
        my $cols = {
            str => $id,
            num => int(rand($id)) + 1,
            type => int(rand(32)) + 1,
        };
        my $vbuf = "";
        my $num = int(rand(5));
        my $pt = 0;
        for(my $j = 0; $j < $num; $j++){
            $pt += int(rand(5)) + 1;
            $vbuf .= "," if(length($vbuf) > 0);
            $vbuf .= $pt;
        }
        if(length($vbuf) > 0){
            $cols->{flag} = $vbuf;
            $cols->{text} = $vbuf;
        }
        if(!$tdb->put($id, $cols)){
            eprint($tdb, "put");
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
        if(!$tdb->get($i)){
            eprint($tdb, "get");
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
        if(int(rand(2)) == 0 && !$tdb->out($i)){
            eprint($tdb, "out");
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
    if(!$tdb->iterinit()){
        eprint($tdb, "iterinit");
        $err = 1;
    }
    my $inum = 0;
    while(defined(my $pkey = $tdb->iternext())){
        $inum++;
        my $cols = $tdb->get($pkey);
        if(!defined($cols)){
            eprint($tdb, "get");
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
    if($tdb->ecode() != $tdb->ENOREC || $inum != $tdb->rnum()){
        eprint($tdb, "(validation)");
        $err = 1;
    }
    my $keys = $tdb->fwmkeys("1", 10);
    printf("checking counting:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("i:%d", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$tdb->addint($buf, 1)){
                eprint($tdb, "addint");
                $err = 1;
                last;
            }
        } else {
            if(!$tdb->adddouble($buf, 1)){
                eprint($tdb, "adddouble");
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
    if(!$tdb->sync()){
        eprint($tdb, "sync");
        $err = 1;
    }
    if(!$tdb->optimize()){
        eprint($tdb, "optimize");
        $err = 1;
    }
    my $npath = $path . "-tmp";
    if(!$tdb->copy($npath)){
        eprint($tdb, "copy");
        $err = 1;
    }
    foreach my $tnpath (glob("$npath.idx.*")){
        unlink($tnpath);
    }
    unlink($npath);
    printf("searching:\n");
    my $qry = TokyoCabinet::TDBQRY->new($tdb);
    my @names = ( "", "str", "num", "type", "flag", "text", "c1" );
    my @ops = ( $qry->QCSTREQ, $qry->QCSTRINC, $qry->QCSTRBW, $qry->QCSTREW, $qry->QCSTRAND,
                $qry->QCSTROR, $qry->QCSTROREQ, $qry->QCSTRRX, $qry->QCNUMEQ, $qry->QCNUMGT,
                $qry->QCNUMGE, $qry->QCNUMLT, $qry->QCNUMLE, $qry->QCNUMBT, $qry->QCNUMOREQ );
    my @ftsops = ( $qry->QCFTSPH, $qry->QCFTSAND, $qry->QCFTSOR, $qry->QCFTSEX );
    my @types = ( $qry->QOSTRASC, $qry->QOSTRDESC, $qry->QONUMASC, $qry->QONUMDESC );
    for(my $i = 1; $i <= $rnum; $i++){
        $qry = TokyoCabinet::TDBQRY->new($tdb) if(int(rand(10)) > 0);
        my $cnum = int(rand(4));
        for(my $j = 0; $j < $cnum; $j++){
            my $name = $names[int(rand(scalar(@names)))];
            my $op = $ops[int(rand(scalar(@ops)))];
            $op = $ftsops[int(rand(scalar(@ftsops)))] if(int(rand(10)) == 0);
            $op |= $qry->QCNEGATE if(int(rand(20)) == 0);
            $op |= $qry->QCNOIDX if(int(rand(20)) == 0);
            my $expr = int(rand($i));
            $expr .= "," . int(rand($i)) if(int(rand(10)) == 0);
            $expr .= "," . int(rand($i)) if(int(rand(10)) == 0);
            $qry->addcond($name, $op, $expr);
        }
        if(int(rand(3)) != 0){
            my $name = $names[int(rand(scalar(@names)))];
            my $type = $types[int(rand(scalar(@types)))];
            $qry->setorder($name, $type);
        }
        $qry->setlimit(int(rand($i)), int(rand(10))) if(int(rand(3)) != 0);
        my $res = $qry->search();
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    $qry = TokyoCabinet::TDBQRY->new($tdb);
    $qry->addcond("", $qry->QCSTRBW, "i:");
    $qry->setorder("_num", $qry->QONUMDESC);
    my $ires = $qry->search();
    my $irnum = scalar(@$ires);
    my $itnum = $tdb->rnum();
    my $icnt = 0;
    my $iter = sub {
        my $pkey = shift;
        my $cols = shift;
        $cols->{icnt} = ++$icnt;
        $qry->QPPUT;
    };
    if(!$qry->proc($iter)){
        eprint($tdb, "qry::proc");
        $err = 1;
    }
    $qry->addcond("icnt", $qry->QCNUMGT, 0);
    my $mures = $qry->metasearch([ $qry, $qry ], $qry->MSUNION);
    if(scalar(@$mures) != $irnum){
        eprint($tdb, "qry::metasearch");
        $err = 1;
    }
    my $mires = $qry->metasearch([ $qry, $qry ], $qry->MSISECT);
    if(scalar(@$mires) != $irnum){
        eprint($tdb, "qry::metasearch");
        $err = 1;
    }
    my $mdres = $qry->metasearch([ $qry, $qry ], $qry->MSDIFF);
    if(scalar(@$mdres) != 0){
        eprint($tdb, "qry::metasearch");
        $err = 1;
    }
    if(!$qry->searchout()){
        eprint($tdb, "qry::searchout");
        $err = 1;
    }
    if($tdb->rnum() != $itnum - $irnum){
        eprint($tdb, "(validation)");
        $err = 1;
    }
    $qry = TokyoCabinet::TDBQRY->new($tdb);
    $qry->addcond("text", $qry->QCSTRBW, "1");
    $qry->setlimit(100, 1);
    $ires = $qry->search();
    for(my $i = 0; $i < scalar(@$ires); $i++){
        my $cols = $tdb->get($ires->[$i]);
        if(defined($cols)){
            my $texts = $qry->kwic($cols, "text", -1, $qry->KWMUBRCT);
            if(scalar($texts) > 0){
                for(my $j = 0; $j < scalar(@$texts); $j++){
                    if(index($texts->[$j], "1") < 0){
                        eprint($tdb, "(validation)");
                        $err = 1;
                        last;
                    }
                }
            } else {
                eprint($tdb, "(validation)");
                $err = 1;
                last;
            }
        } else {
            eprint($tdb, "get");
            $err = 1;
            last;
        }
    }
    if(!$tdb->vanish()){
        eprint($tdb, "vanish");
        $err = 1;
    }
    printf("checking transaction commit:\n");
    if(!$tdb->tranbegin()){
        eprint($tdb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $id = int(rand($rnum)) + 1;
        if(int(rand(2)) == 0){
            if(!$tdb->addint($id, 1)){
                eprint($tdb, "addint");
                $err = 1;
                last;
            }
        } else {
            if(!$tdb->out($id) && $tdb->ecode() != $tdb->ENOREC){
                eprint($tdb, "out");
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
    if(!$tdb->trancommit()){
        eprint($tdb, "trancommit");
        $err = 1;
    }
    printf("checking transaction abort:\n");
    my $ornum = $tdb->rnum();
    my $ofsiz = $tdb->fsiz();
    if(!$tdb->tranbegin()){
        eprint($tdb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $id = int(rand($rnum)) + 1;
        if(int(rand(2)) == 0){
            if(!$tdb->addint($id, 1)){
                eprint($tdb, "addint");
                $err = 1;
                last;
            }
        } else {
            if(!$tdb->out($id) && $tdb->ecode() != $tdb->ENOREC){
                eprint($tdb, "out");
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
    if(!$tdb->tranabort()){
        eprint($tdb, "tranabort");
        $err = 1;
    }
    if($tdb->rnum() != $ornum || $tdb->fsiz() != $ofsiz){
        eprint($tdb, "(validation)");
        $err = 1;
    }
    printf("record number: %llu\n", $tdb->rnum());
    printf("size: %llu\n", $tdb->fsiz());
    if(!$tdb->close()){
        eprint($tdb, "close");
        $err = 1;
    }
    printf("checking tied updating:\n");
    my %hash;
    if(!tie(%hash, "TokyoCabinet::TDB", $path, TokyoCabinet::TDB::OWRITER)){
        eprint($tdb, "tie");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)));
        my $rnd = int(rand(4));
        if($rnd == 0){
            my $cols = {
                name => $buf,
                num => $i,
            };
            $hash{$buf} = $cols;
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
