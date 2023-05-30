#! /usr/bin/perl -w

#-------------------------------------------------------------------------------------------------
# The test cases of the abstract database API
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
    printf STDERR ("$0: test cases of the abstract database API\n");
    printf STDERR ("\n");
    printf STDERR ("usage:\n");
    printf STDERR ("  $0 write name rnum\n");
    printf STDERR ("  $0 read name\n");
    printf STDERR ("  $0 remove name\n");
    printf STDERR ("  $0 misc name rnum\n");
    printf STDERR ("\n");
    exit(1);
}


# parse arguments of write command
sub runwrite {
    my $name = undef;
    my $rnum = undef;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($name) && $ARGV[$i] =~ /^-/){
            usage();
        } elsif(!defined($name)){
            $name = $ARGV[$i];
        } elsif(!defined($rnum)){
            $rnum = TokyoCabinet::atoi($ARGV[$i]);
        } else {
            usage();
        }
    }
    usage() if(!defined($name) || !defined($rnum) || $rnum < 1);
    my $rv = procwrite($name, $rnum);
    return $rv;
}


# parse arguments of read command
sub runread {
    my $name = undef;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($name) && $ARGV[$i] =~ /^-/){
            usage();
        } elsif(!defined($name)){
            $name = $ARGV[$i];
        } else {
            usage();
        }
    }
    usage() if(!defined($name));
    my $rv = procread($name);
    return $rv;
}


# parse arguments of remove command
sub runremove {
    my $name = undef;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($name) && $ARGV[$i] =~ /^-/){
            usage();
        } elsif(!defined($name)){
            $name = $ARGV[$i];
        } else {
            usage();
        }
    }
    usage() if(!defined($name));
    my $rv = procremove($name);
    return $rv;
}


# parse arguments of misc command
sub runmisc {
    my $name = undef;
    my $rnum = undef;
    for(my $i = 1; $i < scalar(@ARGV); $i++){
        if(!defined($name) && $ARGV[$i] =~ /^-/){
            usage();
        } elsif(!defined($name)){
            $name = $ARGV[$i];
        } elsif(!defined($rnum)){
            $rnum = TokyoCabinet::atoi($ARGV[$i]);
        } else {
            usage();
        }
    }
    usage() if(!defined($name) || !defined($rnum) || $rnum < 1);
    my $rv = procmisc($name, $rnum);
    return $rv;
}


# print error message of abstract database
sub eprint {
    my $adb = shift;
    my $func = shift;
    my $path = $adb->path();
    printf STDERR ("%s: %s: %s: error\n", $0, defined($path) ? $path : "-", $func);
}


# perform write command
sub procwrite {
    my $name = shift;
    my $rnum = shift;
    printf("<Writing Test>\n  name=%s  rnum=%d\n\n", $name, $rnum);
    my $err = 0;
    my $stime = gettimeofday();
    my $adb = TokyoCabinet::ADB->new();
    if(!$adb->open($name)){
        eprint($adb, "open");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$adb->put($buf, $buf)){
            eprint($adb, "put");
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
    printf("record number: %llu\n", $adb->rnum());
    printf("size: %llu\n", $adb->size());
    if(!$adb->close()){
        eprint($adb, "close");
        $err = 1;
    }
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# perform read command
sub procread {
    my $name = shift;
    printf("<Reading Test>\n  name=%s\n\n", $name);
    my $err = 0;
    my $stime = gettimeofday();
    my $adb = TokyoCabinet::ADB->new();
    if(!$adb->open($name)){
        eprint($adb, "open");
        $err = 1;
    }
    my $rnum = $adb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$adb->get($buf)){
            eprint($adb, "get");
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
    printf("record number: %llu\n", $adb->rnum());
    printf("size: %llu\n", $adb->size());
    if(!$adb->close()){
        eprint($adb, "close");
        $err = 1;
    }
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# perform remove command
sub procremove {
    my $name = shift;
    my $omode = shift;
    printf("<Removing Test>\n  name=%s\n\n", $name);
    my $err = 0;
    my $stime = gettimeofday();
    my $adb = TokyoCabinet::ADB->new();
    if(!$adb->open($name)){
        eprint($adb, "open");
        $err = 1;
    }
    my $rnum = $adb->rnum();
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$adb->out($buf)){
            eprint($adb, "out");
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
    printf("record number: %llu\n", $adb->rnum());
    printf("size: %llu\n", $adb->size());
    if(!$adb->close()){
        eprint($adb, "close");
        $err = 1;
    }
    printf("time: %.3f\n", gettimeofday() - $stime);
    printf("%s\n\n", $err ? "error" : "ok");
    return $err ? 1 : 0;
}


# perform misc command
sub procmisc {
    my $name = shift;
    my $rnum = shift;
    printf("<Miscellaneous Test>\n  name=%s  rnum=%d\n\n", $name, $rnum);
    my $err = 0;
    my $stime = gettimeofday();
    my $adb = TokyoCabinet::ADB->new();
    if(!$adb->open($name)){
        eprint($adb, "open");
        $err = 1;
    }
    printf("writing:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%08d", $i);
        if(!$adb->put($buf, $buf)){
            eprint($adb, "put");
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
        if(!$adb->get($buf)){
            eprint($adb, "get");
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
        if(int(rand(2)) == 0 && !$adb->out($buf)){
            eprint($adb, "out");
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
    if(!$adb->iterinit()){
        eprint($adb, "iterinit");
        $err = 1;
    }
    my $inum = 0;
    while(defined(my $key = $adb->iternext())){
        $inum++;
        my $value = $adb->get($key);
        if(!defined($value)){
            eprint($adb, "get");
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
    if($inum != $adb->rnum()){
        eprint($adb, "(validation)");
        $err = 1;
    }
    my $keys = $adb->fwmkeys("0", 10);
    if($adb->rnum() >= 10 && scalar(@$keys) != 10){
        eprint($adb, "fwmkeys");
        $err = 1;
    }
    printf("checking counting:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("[%d]", int(rand($rnum)));
        if(int(rand(2)) == 0){
            $adb->addint($buf, 1);
        } else {
            $adb->adddouble($buf, 1);
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    printf("checking versatile functions:\n");
    for(my $i = 1; $i <= $rnum; $i++){
        my $rnd = int(rand(3));
        my $name;
        if($rnd == 0){
            $name = "putlist";
        } elsif($rnd == 1){
            $name = "outlist";
        } else {
            $name = "getlist";
        }
        if(!defined($adb->misc($name, [int(rand($rnum)), int(rand($rnum))]))){
            eprint($adb, "misc");
            $err = 1;
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$adb->sync()){
        eprint($adb, "sync");
        $err = 1;
    }
    if(!$adb->optimize()){
        eprint($adb, "optimize");
        $err = 1;
    }
    my $npath = $adb->path() . "-tmp";
    if(!$adb->copy($npath)){
        eprint($adb, "copy");
        $err = 1;
    }
    unlink($npath);
    if(!$adb->vanish()){
        eprint($adb, "vanish");
        $err = 1;
    }
    printf("checking transaction commit:\n");
    if(!$adb->tranbegin()){
        eprint($adb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%d", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$adb->putcat($buf, $buf)){
                eprint($adb, "putcat");
                $err = 1;
                last;
            }
        } else {
            $adb->out($buf);
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$adb->trancommit()){
        eprint($adb, "trancommit");
        $err = 1;
    }
    printf("checking transaction abort:\n");
    my $ornum = $adb->rnum();
    my $ofsiz = $adb->size();
    if(!$adb->tranbegin()){
        eprint($adb, "tranbegin");
        $err = 1;
    }
    for(my $i = 1; $i <= $rnum; $i++){
        my $buf = sprintf("%d", int(rand($rnum)));
        if(int(rand(2)) == 0){
            if(!$adb->putcat($buf, $buf)){
                eprint($adb, "putcat");
                $err = 1;
                last;
            }
        } else {
            $adb->out($buf);
        }
        if($rnum > 250 && $i % ($rnum / 250) == 0){
            print('.');
            if($i == $rnum || $i % ($rnum / 10) == 0){
                printf(" (%08d)\n", $i);
            }
        }
    }
    if(!$adb->tranabort()){
        eprint($adb, "tranabort");
        $err = 1;
    }
    if($adb->rnum() != $ornum || $adb->size() != $ofsiz){
        eprint($adb, "(validation)");
        $err = 1;
    }
    printf("record number: %llu\n", $adb->rnum());
    printf("size: %llu\n", $adb->size());
    if(!$adb->close()){
        eprint($adb, "close");
        $err = 1;
    }
    printf("checking tied updating:\n");
    my %hash;
    if(!tie(%hash, "TokyoCabinet::ADB", $name)){
        eprint($adb, "tie");
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
