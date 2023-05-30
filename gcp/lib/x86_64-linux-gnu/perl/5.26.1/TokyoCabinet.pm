#-------------------------------------------------------------------------------------------------
# Perl binding of Tokyo Cabinet
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


package TokyoCabinet;

use strict;
use warnings;
use bytes;
use Carp;

require Exporter;
require XSLoader;
use base qw(Exporter);
our $VERSION = '1.34';
our $DEBUG = 0;
XSLoader::load('TokyoCabinet', $VERSION);



#----------------------------------------------------------------
# utilities
#----------------------------------------------------------------


sub VERSION {
    return TokyoCabinet::tc_version();
}


sub atoi {
    my $str = shift;
    return 0 if(!defined($str));
    return tc_atoi($str);
}


sub atof {
    my $str = shift;
    return 0 if(!defined($str));
    return tc_atof($str);
}


sub bercompress {
    my $aryref = shift;
    if(scalar(@_) != 0 || !defined($aryref) || ref($aryref) ne "ARRAY"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return tc_bercompress($aryref);
}


sub beruncompress {
    my $selref = shift;
    if(scalar(@_) != 0 || !defined($selref) || ref($selref) ne "SCALAR"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return tc_beruncompress($selref);
}


sub diffcompress {
    my $aryref = shift;
    if(scalar(@_) != 0 || !defined($aryref) || ref($aryref) ne "ARRAY"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return tc_diffcompress($aryref);
}


sub diffuncompress {
    my $selref = shift;
    if(scalar(@_) != 0 || !defined($selref) || ref($selref) ne "SCALAR"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return tc_diffuncompress($selref);
}


sub strdistance {
    my $aref = shift;
    my $bref = shift;
    my $isutf = shift;
    if(scalar(@_) != 0 || !defined($aref) || ref($aref) ne "SCALAR" ||
       !defined($bref) || ref($bref) ne "SCALAR"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $isutf = 0 if(!defined($isutf));
    return tc_strdistance($aref, $bref, $isutf);
}



#----------------------------------------------------------------
# the hash database API
#----------------------------------------------------------------


package TokyoCabinet::HDB;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


use constant {
    ESUCCESS => 0,
    ETHREAD => 1,
    EINVALID => 2,
    ENOFILE => 3,
    ENOPERM => 4,
    EMETA => 5,
    ERHEAD => 6,
    EOPEN => 7,
    ECLOSE => 8,
    ETRUNC => 9,
    ESYNC => 10,
    ESTAT => 11,
    ESEEK => 12,
    EREAD => 13,
    EWRITE => 14,
    EMMAP => 15,
    ELOCK => 16,
    EUNLINK => 17,
    ERENAME => 18,
    EMKDIR => 19,
    ERMDIR => 20,
    EKEEP => 21,
    ENOREC => 22,
    EMISC => 9999,
};

use constant {
    TLARGE => 1 << 0,
    TDEFLATE => 1 << 1,
    TBZIP => 1 << 2,
    TTCBS => 1 << 3,
};

use constant {
    OREADER => 1 << 0,
    OWRITER => 1 << 1,
    OCREAT => 1 << 2,
    OTRUNC => 1 << 3,
    ONOLCK => 1 << 4,
    OLCKNB => 1 << 5,
    OTSYNC => 1 << 6,
};


sub new {
    my $class = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0];
    $$self[0] = TokyoCabinet::hdb_new();
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::hdb_del($$self[0]);
    return undef;
}


sub errmsg {
    my $self = shift;
    my $ecode = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $ecode = $self->ecode() if(!defined($ecode) || $ecode < 0);
    return TokyoCabinet::hdb_errmsg($ecode);
}


sub ecode {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_ecode($$self[0]);
}


sub tune {
    my $self = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $bnum = -1 if(!defined($bnum));
    $apow = -1 if(!defined($apow));
    $fpow = -1 if(!defined($fpow));
    $opts = 0 if(!defined($opts));
    return TokyoCabinet::hdb_tune($$self[0], $bnum, $apow, $fpow, $opts);
}


sub setcache {
    my $self = shift;
    my $rcnum = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $rcnum = -1 if(!defined($rcnum));
    return TokyoCabinet::hdb_setcache($$self[0], $rcnum);
}


sub setxmsiz {
    my $self = shift;
    my $xmsiz = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $xmsiz = -1 if(!defined($xmsiz));
    return TokyoCabinet::hdb_setxmsiz($$self[0], $xmsiz);
}


sub setdfunit {
    my $self = shift;
    my $dfunit = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $dfunit = -1 if(!defined($dfunit));
    return TokyoCabinet::hdb_setdfunit($$self[0], $dfunit);
}


sub open {
    my $self = shift;
    my $path = shift;
    my $omode = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $omode = OREADER if(!defined($omode));
    return TokyoCabinet::hdb_open($$self[0], $path, $omode);
}


sub close {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_close($$self[0]);
}


sub put {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_put($$self[0], $key, $value);
}


sub putkeep {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_putkeep($$self[0], $key, $value);
}


sub putcat {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_putcat($$self[0], $key, $value);
}


sub putasync {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_putasync($$self[0], $key, $value);
}


sub out {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_out($$self[0], $key);
}


sub get {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_get($$self[0], $key);
}


sub vsiz {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_vsiz($$self[0], $key);
}


sub iterinit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_iterinit($$self[0]);
}


sub iternext {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_iternext($$self[0]);
}


sub fwmkeys {
    my $self = shift;
    my $prefix = shift;
    my $max = shift;
    if(scalar(@_) != 0 || !defined($prefix)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $max = -1 if(!defined($max));
    return TokyoCabinet::hdb_fwmkeys($$self[0], $prefix, $max);
}


sub addint {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_addint($$self[0], $key, $num);
}


sub adddouble {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_adddouble($$self[0], $key, $num);
}


sub sync {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_sync($$self[0]);
}


sub optimize {
    my $self = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $bnum = -1 if(!defined($bnum));
    $apow = -1 if(!defined($apow));
    $fpow = -1 if(!defined($fpow));
    $opts = 0xff if(!defined($opts));
    return TokyoCabinet::hdb_optimize($$self[0], $bnum, $apow, $fpow, $opts);
}


sub vanish {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_vanish($$self[0]);
}


sub copy {
    my $self = shift;
    my $path = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_copy($$self[0], $path);
}


sub tranbegin {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_tranbegin($$self[0]);
}


sub trancommit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_trancommit($$self[0]);
}


sub tranabort {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_tranabort($$self[0]);
}


sub path {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_path($$self[0]);
}


sub rnum {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_rnum($$self[0]);
}


sub fsiz {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::hdb_fsiz($$self[0]);
}


sub TIEHASH {
    my $class = shift;
    my $path = shift;
    my $omode = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    my $rcnum = shift;
    my $hdb = $class->new();
    $hdb->tune($bnum, $apow, $fpow, $opts);
    $hdb->setcache($rcnum);
    return undef if(!$hdb->open($path, $omode));
    return $hdb;
}


sub UNTIE {
    my $self = shift;
    return $self->close();
}


sub STORE {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    return $self->put($key, $value);
}


sub DELETE {
    my $self = shift;
    my $key = shift;
    return $self->out($key);
}


sub FETCH {
    my $self = shift;
    my $key = shift;
    return $self->get($key);
}


sub EXISTS {
    my $self = shift;
    my $key = shift;
    return $self->vsiz($key) >= 0;
}


sub FIRSTKEY {
    my $self = shift;
    $self->iterinit();
    return $self->iternext();
}


sub NEXTKEY {
    my $self = shift;
    return $self->iternext();
}


sub CLEAR {
    my $self = shift;
    return $self->vanish();
}



#----------------------------------------------------------------
# the B+ tree database API
#----------------------------------------------------------------


package TokyoCabinet::BDB;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


use constant {
    ESUCCESS => 0,
    ETHREAD => 1,
    EINVALID => 2,
    ENOFILE => 3,
    ENOPERM => 4,
    EMETA => 5,
    ERHEAD => 6,
    EOPEN => 7,
    ECLOSE => 8,
    ETRUNC => 9,
    ESYNC => 10,
    ESTAT => 11,
    ESEEK => 12,
    EREAD => 13,
    EWRITE => 14,
    EMMAP => 15,
    ELOCK => 16,
    EUNLINK => 17,
    ERENAME => 18,
    EMKDIR => 19,
    ERMDIR => 20,
    EKEEP => 21,
    ENOREC => 22,
    EMISC => 9999,
};

use constant {
    CMPLEXICAL => "CMPLEXICAL",
    CMPDECIMAL => "CMPDECIMAL",
    CMPINT32 => "CMPINT32",
    CMPINT64 => "CMPINT64",
};

use constant {
    TLARGE => 1 << 0,
    TDEFLATE => 1 << 1,
    TBZIP => 1 << 2,
    TTCBS => 1 << 3,
};

use constant {
    OREADER => 1 << 0,
    OWRITER => 1 << 1,
    OCREAT => 1 << 2,
    OTRUNC => 1 << 3,
    ONOLCK => 1 << 4,
    OLCKNB => 1 << 5,
    OTSYNC => 1 << 6,
};


sub new {
    my $class = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0, 0];
    $$self[0] = TokyoCabinet::bdb_new();
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::bdb_del($$self[0]);
    return undef;
}


sub errmsg {
    my $self = shift;
    my $ecode = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $ecode = $self->ecode() if(!defined($ecode) || $ecode < 0);
    return TokyoCabinet::bdb_errmsg($ecode);
}


sub ecode {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_ecode($$self[0]);
}


sub setcmpfunc {
    my $self = shift;
    my $cmp = shift;
    if(scalar(@_) != 0 || !defined($cmp)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    if($cmp eq CMPLEXICAL){
        return TokyoCabinet::bdb_setcmpfunc($$self[0], 0);
    } elsif($cmp eq CMPDECIMAL){
        return TokyoCabinet::bdb_setcmpfunc($$self[0], 1);
    } elsif($cmp eq CMPINT32){
        return TokyoCabinet::bdb_setcmpfunc($$self[0], 2);
    } elsif($cmp eq CMPINT64){
        return TokyoCabinet::bdb_setcmpfunc($$self[0], 3);
    }
    return TokyoCabinet::bdb_setcmpfuncex($$self[0], $cmp);
}


sub tune {
    my $self = shift;
    my $lmemb = shift;
    my $nmemb = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $lmemb = -1 if(!defined($lmemb));
    $nmemb = -1 if(!defined($nmemb));
    $bnum = -1 if(!defined($bnum));
    $apow = -1 if(!defined($apow));
    $fpow = -1 if(!defined($fpow));
    $opts = 0 if(!defined($opts));
    return TokyoCabinet::bdb_tune($$self[0], $lmemb, $nmemb, $bnum, $apow, $fpow, $opts);
}


sub setcache {
    my $self = shift;
    my $lcnum = shift;
    my $ncnum = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $lcnum = -1 if(!defined($lcnum));
    $ncnum = -1 if(!defined($ncnum));
    return TokyoCabinet::bdb_setcache($$self[0], $lcnum, $ncnum);
}


sub setxmsiz {
    my $self = shift;
    my $xmsiz = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $xmsiz = -1 if(!defined($xmsiz));
    return TokyoCabinet::bdb_setxmsiz($$self[0], $xmsiz);
}


sub setdfunit {
    my $self = shift;
    my $dfunit = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $dfunit = -1 if(!defined($dfunit));
    return TokyoCabinet::bdb_setdfunit($$self[0], $dfunit);
}


sub open {
    my $self = shift;
    my $path = shift;
    my $omode = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $omode = OREADER if(!defined($omode));
    return TokyoCabinet::bdb_open($$self[0], $path, $omode);
}


sub close {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_close($$self[0]);
}


sub put {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_put($$self[0], $key, $value);
}


sub putkeep {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_putkeep($$self[0], $key, $value);
}


sub putcat {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_putcat($$self[0], $key, $value);
}


sub putdup {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_putdup($$self[0], $key, $value);
}


sub putlist {
    my $self = shift;
    my $key = shift;
    my $values = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($values) || ref($values) ne "ARRAY"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_putlist($$self[0], $key, $values);
}


sub out {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_out($$self[0], $key);
}


sub outlist {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_outlist($$self[0], $key);
}


sub get {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_get($$self[0], $key);
}


sub getlist {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_getlist($$self[0], $key);
}


sub vnum {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_vnum($$self[0], $key);
}


sub vsiz {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_vsiz($$self[0], $key);
}


sub range {
    my $self = shift;
    my $bkey = shift;
    my $binc = shift;
    my $ekey = shift;
    my $einc = shift;
    my $max = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $binc = 0 if(!defined($binc));
    $einc = 0 if(!defined($einc));
    $max = -1 if(!defined($max));
    return TokyoCabinet::bdb_range($$self[0], $bkey, $binc, $ekey, $einc, $max);
}


sub fwmkeys {
    my $self = shift;
    my $prefix = shift;
    my $max = shift;
    if(scalar(@_) != 0 || !defined($prefix)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $max = -1 if(!defined($max));
    return TokyoCabinet::bdb_fwmkeys($$self[0], $prefix, $max);
}


sub addint {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_addint($$self[0], $key, $num);
}


sub adddouble {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_adddouble($$self[0], $key, $num);
}


sub sync {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_sync($$self[0]);
}


sub optimize {
    my $self = shift;
    my $lmemb = shift;
    my $nmemb = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $lmemb = -1 if(!defined($lmemb));
    $nmemb = -1 if(!defined($nmemb));
    $bnum = -1 if(!defined($bnum));
    $apow = -1 if(!defined($apow));
    $fpow = -1 if(!defined($fpow));
    $opts = 0xff if(!defined($opts));
    return TokyoCabinet::bdb_optimize($$self[0], $lmemb, $nmemb, $bnum, $apow, $fpow, $opts);
}


sub vanish {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_vanish($$self[0]);
}


sub copy {
    my $self = shift;
    my $path = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_copy($$self[0], $path);
}


sub tranbegin {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_tranbegin($$self[0]);
}


sub trancommit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_trancommit($$self[0]);
}


sub tranabort {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_tranabort($$self[0]);
}


sub path {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_path($$self[0]);
}


sub rnum {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_rnum($$self[0]);
}


sub fsiz {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdb_fsiz($$self[0]);
}


sub TIEHASH {
    my $class = shift;
    my $path = shift;
    my $omode = shift;
    my $lmemb = shift;
    my $nmemb = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    my $lcnum = shift;
    my $ncnum = shift;
    my $bdb = $class->new();
    $bdb->tune($lmemb, $nmemb, $bnum, $apow, $fpow, $opts);
    $bdb->setcache($lcnum, $ncnum);
    return undef if(!$bdb->open($path, $omode));
    $$bdb[1] = TokyoCabinet::BDBCUR->new($bdb);
    return $bdb;
}


sub UNTIE {
    my $self = shift;
    return $self->close();
}


sub STORE {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    return $self->put($key, $value);
}


sub DELETE {
    my $self = shift;
    my $key = shift;
    return $self->out($key);
}


sub FETCH {
    my $self = shift;
    my $key = shift;
    return $self->get($key);
}


sub EXISTS {
    my $self = shift;
    my $key = shift;
    return $self->vsiz($key) >= 0;
}


sub FIRSTKEY {
    my $self = shift;
    my $cur = $$self[1];
    $cur->first();
    my $key = $cur->key();
    $cur->next();
    return $key;
}


sub NEXTKEY {
    my $self = shift;
    my $cur = $$self[1];
    my $key = $cur->key();
    $cur->next();
    return $key;
}


sub CLEAR {
    my $self = shift;
    return $self->vanish();
}


package TokyoCabinet::BDBCUR;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


use constant {
    CPCURRENT => 0,
    CPBEFORE => 1,
    CPAFTER => 2,
};


sub new {
    my $class = shift;
    my $bdb = shift;
    if(scalar(@_) != 0 || !defined($bdb) || ref($bdb) ne "TokyoCabinet::BDB"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0];
    $$self[0] = TokyoCabinet::bdbcur_new($$bdb[0]);
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::bdbcur_del($$self[0]);
    return undef;
}


sub first {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_first($$self[0]);
}


sub last {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_last($$self[0]);
}


sub jump {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_jump($$self[0], $key);
}


sub prev {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_prev($$self[0]);
}


sub next {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_next($$self[0]);
}


sub put {
    my $self = shift;
    my $value = shift;
    my $cpmode = shift;
    if(scalar(@_) != 0 || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $cpmode = CPCURRENT if(!defined($cpmode));
    return TokyoCabinet::bdbcur_put($$self[0], $value, $cpmode);
}


sub out {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_out($$self[0]);
}


sub key {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_key($$self[0]);
}


sub val {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::bdbcur_val($$self[0]);
}



#----------------------------------------------------------------
# the fixed-length database API
#----------------------------------------------------------------


package TokyoCabinet::FDB;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


use constant {
    ESUCCESS => 0,
    ETHREAD => 1,
    EINVALID => 2,
    ENOFILE => 3,
    ENOPERM => 4,
    EMETA => 5,
    ERHEAD => 6,
    EOPEN => 7,
    ECLOSE => 8,
    ETRUNC => 9,
    ESYNC => 10,
    ESTAT => 11,
    ESEEK => 12,
    EREAD => 13,
    EWRITE => 14,
    EMMAP => 15,
    ELOCK => 16,
    EUNLINK => 17,
    ERENAME => 18,
    EMKDIR => 19,
    ERMDIR => 20,
    EKEEP => 21,
    ENOREC => 22,
    EMISC => 9999,
};

use constant {
    OREADER => 1 << 0,
    OWRITER => 1 << 1,
    OCREAT => 1 << 2,
    OTRUNC => 1 << 3,
    ONOLCK => 1 << 4,
    OLCKNB => 1 << 5,
};


sub new {
    my $class = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0];
    $$self[0] = TokyoCabinet::fdb_new();
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::fdb_del($$self[0]);
    return undef;
}


sub errmsg {
    my $self = shift;
    my $ecode = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $ecode = $self->ecode() if(!defined($ecode) || $ecode < 0);
    return TokyoCabinet::fdb_errmsg($ecode);
}


sub ecode {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_ecode($$self[0]);
}


sub tune {
    my $self = shift;
    my $width = shift;
    my $limsiz = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $width = -1 if(!defined($width));
    $limsiz = -1 if(!defined($limsiz));
    return TokyoCabinet::fdb_tune($$self[0], $width, $limsiz);
}


sub open {
    my $self = shift;
    my $path = shift;
    my $omode = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $omode = OREADER if(!defined($omode));
    return TokyoCabinet::fdb_open($$self[0], $path, $omode);
}


sub close {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_close($$self[0]);
}


sub put {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_put($$self[0], $key, $value);
}


sub putkeep {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_putkeep($$self[0], $key, $value);
}


sub putcat {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_putcat($$self[0], $key, $value);
}


sub out {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_out($$self[0], $key);
}


sub get {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_get($$self[0], $key);
}


sub vsiz {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_vsiz($$self[0], $key);
}


sub iterinit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_iterinit($$self[0]);
}


sub iternext {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_iternext($$self[0]);
}


sub range {
    my $self = shift;
    my $interval = shift;
    my $max = shift;
    if(scalar(@_) != 0 || !defined($interval)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $max = -1 if(!defined($max));
    return TokyoCabinet::fdb_range($$self[0], $interval, $max);
}


sub addint {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_addint($$self[0], $key, $num);
}


sub adddouble {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_adddouble($$self[0], $key, $num);
}


sub sync {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_sync($$self[0]);
}


sub optimize {
    my $self = shift;
    my $width = shift;
    my $limsiz = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $width = -1 if(!defined($width));
    $limsiz = -1 if(!defined($limsiz));
    return TokyoCabinet::fdb_optimize($$self[0], $width, $limsiz);
}


sub vanish {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_vanish($$self[0]);
}


sub copy {
    my $self = shift;
    my $path = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_copy($$self[0], $path);
}


sub tranbegin {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_tranbegin($$self[0]);
}


sub trancommit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_trancommit($$self[0]);
}


sub tranabort {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_tranabort($$self[0]);
}


sub path {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_path($$self[0]);
}


sub rnum {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_rnum($$self[0]);
}


sub fsiz {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::fdb_fsiz($$self[0]);
}


sub TIEHASH {
    my $class = shift;
    my $path = shift;
    my $omode = shift;
    my $width = shift;
    my $limsiz = shift;
    my $fdb = $class->new();
    $fdb->tune($width, $limsiz);
    return undef if(!$fdb->open($path, $omode));
    return $fdb;
}


sub UNTIE {
    my $self = shift;
    return $self->close();
}


sub STORE {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    return $self->put($key, $value);
}


sub DELETE {
    my $self = shift;
    my $key = shift;
    return $self->out($key);
}


sub FETCH {
    my $self = shift;
    my $key = shift;
    return $self->get($key);
}


sub EXISTS {
    my $self = shift;
    my $key = shift;
    return $self->vsiz($key) >= 0;
}


sub FIRSTKEY {
    my $self = shift;
    $self->iterinit();
    return $self->iternext();
}


sub NEXTKEY {
    my $self = shift;
    return $self->iternext();
}


sub CLEAR {
    my $self = shift;
    return $self->vanish();
}



#----------------------------------------------------------------
# the table database API
#----------------------------------------------------------------


package TokyoCabinet::TDB;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


use constant {
    ESUCCESS => 0,
    ETHREAD => 1,
    EINVALID => 2,
    ENOFILE => 3,
    ENOPERM => 4,
    EMETA => 5,
    ERHEAD => 6,
    EOPEN => 7,
    ECLOSE => 8,
    ETRUNC => 9,
    ESYNC => 10,
    ESTAT => 11,
    ESEEK => 12,
    EREAD => 13,
    EWRITE => 14,
    EMMAP => 15,
    ELOCK => 16,
    EUNLINK => 17,
    ERENAME => 18,
    EMKDIR => 19,
    ERMDIR => 20,
    EKEEP => 21,
    ENOREC => 22,
    EMISC => 9999,
};

use constant {
    TLARGE => 1 << 0,
    TDEFLATE => 1 << 1,
    TBZIP => 1 << 2,
    TTCBS => 1 << 3,
};

use constant {
    OREADER => 1 << 0,
    OWRITER => 1 << 1,
    OCREAT => 1 << 2,
    OTRUNC => 1 << 3,
    ONOLCK => 1 << 4,
    OLCKNB => 1 << 5,
    OTSYNC => 1 << 6,
};

use constant {
  ITLEXICAL => 0,
  ITDECIMAL => 1,
  ITTOKEN => 2,
  ITQGRAM => 3,
  ITOPT => 9998,
  ITVOID => 9999,
  ITKEEP => 1 << 24,
};


sub new {
    my $class = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0];
    $$self[0] = TokyoCabinet::tdb_new();
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::tdb_del($$self[0]);
    return undef;
}


sub errmsg {
    my $self = shift;
    my $ecode = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $ecode = $self->ecode() if(!defined($ecode) || $ecode < 0);
    return TokyoCabinet::tdb_errmsg($ecode);
}


sub ecode {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_ecode($$self[0]);
}


sub tune {
    my $self = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $bnum = -1 if(!defined($bnum));
    $apow = -1 if(!defined($apow));
    $fpow = -1 if(!defined($fpow));
    $opts = 0 if(!defined($opts));
    return TokyoCabinet::tdb_tune($$self[0], $bnum, $apow, $fpow, $opts);
}


sub setcache {
    my $self = shift;
    my $rcnum = shift;
    my $lcnum = shift;
    my $ncnum = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $rcnum = -1 if(!defined($rcnum));
    $lcnum = -1 if(!defined($lcnum));
    $ncnum = -1 if(!defined($ncnum));
    return TokyoCabinet::tdb_setcache($$self[0], $rcnum, $lcnum, $ncnum);
}


sub setxmsiz {
    my $self = shift;
    my $xmsiz = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $xmsiz = -1 if(!defined($xmsiz));
    return TokyoCabinet::tdb_setxmsiz($$self[0], $xmsiz);
}


sub setdfunit {
    my $self = shift;
    my $dfunit = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $dfunit = -1 if(!defined($dfunit));
    return TokyoCabinet::tdb_setdfunit($$self[0], $dfunit);
}


sub open {
    my $self = shift;
    my $path = shift;
    my $omode = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $omode = OREADER if(!defined($omode));
    return TokyoCabinet::tdb_open($$self[0], $path, $omode);
}


sub close {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_close($$self[0]);
}


sub put {
    my $self = shift;
    my $pkey = shift;
    my $cols = shift;
    if(scalar(@_) != 0 || !defined($pkey) || !defined($cols) || ref($cols) ne "HASH"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_put($$self[0], $pkey, $cols);
}


sub putkeep {
    my $self = shift;
    my $pkey = shift;
    my $cols = shift;
    if(scalar(@_) != 0 || !defined($pkey) || !defined($cols) || ref($cols) ne "HASH"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_putkeep($$self[0], $pkey, $cols);
}


sub putcat {
    my $self = shift;
    my $pkey = shift;
    my $cols = shift;
    if(scalar(@_) != 0 || !defined($pkey) || !defined($cols) || ref($cols) ne "HASH"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_putcat($$self[0], $pkey, $cols);
}


sub out {
    my $self = shift;
    my $pkey = shift;
    if(scalar(@_) != 0 || !defined($pkey)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_out($$self[0], $pkey);
}


sub get {
    my $self = shift;
    my $pkey = shift;
    if(scalar(@_) != 0 || !defined($pkey)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_get($$self[0], $pkey);
}


sub vsiz {
    my $self = shift;
    my $pkey = shift;
    if(scalar(@_) != 0 || !defined($pkey)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_vsiz($$self[0], $pkey);
}


sub iterinit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_iterinit($$self[0]);
}


sub iternext {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_iternext($$self[0]);
}


sub fwmkeys {
    my $self = shift;
    my $prefix = shift;
    my $max = shift;
    if(scalar(@_) != 0 || !defined($prefix)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $max = -1 if(!defined($max));
    return TokyoCabinet::tdb_fwmkeys($$self[0], $prefix, $max);
}


sub addint {
    my $self = shift;
    my $pkey = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($pkey) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_addint($$self[0], $pkey, $num);
}


sub adddouble {
    my $self = shift;
    my $pkey = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($pkey) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_adddouble($$self[0], $pkey, $num);
}


sub sync {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_sync($$self[0]);
}


sub optimize {
    my $self = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $bnum = -1 if(!defined($bnum));
    $apow = -1 if(!defined($apow));
    $fpow = -1 if(!defined($fpow));
    $opts = 0xff if(!defined($opts));
    return TokyoCabinet::tdb_optimize($$self[0], $bnum, $apow, $fpow, $opts);
}


sub vanish {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_vanish($$self[0]);
}


sub copy {
    my $self = shift;
    my $path = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_copy($$self[0], $path);
}


sub tranbegin {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_tranbegin($$self[0]);
}


sub trancommit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_trancommit($$self[0]);
}


sub tranabort {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_tranabort($$self[0]);
}


sub path {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_path($$self[0]);
}


sub rnum {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_rnum($$self[0]);
}


sub fsiz {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_fsiz($$self[0]);
}


sub setindex {
    my $self = shift;
    my $name = shift;
    my $type = shift;
    if(scalar(@_) != 0 || !defined($name) || !defined($type)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_setindex($$self[0], $name, $type);
}


sub genuid {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdb_genuid($$self[0]);
}


sub TIEHASH {
    my $class = shift;
    my $path = shift;
    my $omode = shift;
    my $bnum = shift;
    my $apow = shift;
    my $fpow = shift;
    my $opts = shift;
    my $rcnum = shift;
    my $lcnum = shift;
    my $ncnum = shift;
    my $tdb = $class->new();
    $tdb->tune($bnum, $apow, $fpow, $opts);
    $tdb->setcache($rcnum, $lcnum, $ncnum);
    return undef if(!$tdb->open($path, $omode));
    return $tdb;
}


sub UNTIE {
    my $self = shift;
    return $self->close();
}


sub STORE {
    my $self = shift;
    my $pkey = shift;
    my $value = shift;
    return $self->put($pkey, $value);
}


sub DELETE {
    my $self = shift;
    my $pkey = shift;
    return $self->out($pkey);
}


sub FETCH {
    my $self = shift;
    my $pkey = shift;
    return $self->get($pkey);
}


sub EXISTS {
    my $self = shift;
    my $pkey = shift;
    return $self->vsiz($pkey) >= 0;
}


sub FIRSTKEY {
    my $self = shift;
    $self->iterinit();
    return $self->iternext();
}


sub NEXTKEY {
    my $self = shift;
    return $self->iternext();
}


sub CLEAR {
    my $self = shift;
    return $self->vanish();
}


package TokyoCabinet::TDBQRY;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


use constant {
  QCSTREQ => 0,
  QCSTRINC => 1,
  QCSTRBW => 2,
  QCSTREW => 3,
  QCSTRAND => 4,
  QCSTROR => 5,
  QCSTROREQ => 6,
  QCSTRRX => 7,
  QCNUMEQ => 8,
  QCNUMGT => 9,
  QCNUMGE => 10,
  QCNUMLT => 11,
  QCNUMLE => 12,
  QCNUMBT => 13,
  QCNUMOREQ => 14,
  QCFTSPH => 15,
  QCFTSAND => 16,
  QCFTSOR => 17,
  QCFTSEX => 18,
  QCNEGATE => 1 << 24,
  QCNOIDX => 1 << 25,
};

use constant {
  QOSTRASC => 0,
  QOSTRDESC => 1,
  QONUMASC => 2,
  QONUMDESC => 3,
};

use constant {
  QPPUT => 1 << 0,
  QPOUT => 1 << 1,
  QPSTOP => 1 << 24,
};

use constant {
  KWMUTAB => 1 << 0,
  KWMUCTRL => 1 << 1,
  KWMUBRCT => 1 << 2,
  KWNOOVER => 1 << 24,
  KWPULEAD => 1 << 25,
};

use constant {
  MSUNION => 0,
  MSISECT => 1,
  MSDIFF => 2,
};


sub new {
    my $class = shift;
    my $tdb = shift;
    if(scalar(@_) != 0 || !defined($tdb) || ref($tdb) ne "TokyoCabinet::TDB"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0];
    $$self[0] = TokyoCabinet::tdbqry_new($$tdb[0]);
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::tdbqry_del($$self[0]);
    return undef;
}


sub addcond {
    my $self = shift;
    my $name = shift;
    my $op = shift;
    my $expr = shift;
    if(scalar(@_) != 0 || !defined($name) || !defined($op) || !defined($expr)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    TokyoCabinet::tdbqry_addcond($$self[0], $name, $op, $expr);
    return undef;
}


sub setorder {
    my $self = shift;
    my $name = shift;
    my $type = shift;
    if(scalar(@_) != 0 || !defined($name)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $type = $self->QOSTRASC if(!defined($type));
    TokyoCabinet::tdbqry_setorder($$self[0], $name, $type);
    return undef;
}


sub setlimit {
    my $self = shift;
    my $max = shift;
    my $skip = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $max = -1 if(!defined($max));
    $skip = -1 if(!defined($skip));
    TokyoCabinet::tdbqry_setlimit($$self[0], $max, $skip);
    return undef;
}


sub search {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdbqry_search($$self[0]);
}


sub searchout {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdbqry_searchout($$self[0]);
}


sub proc {
    my $self = shift;
    my $proc = shift;
    if(scalar(@_) != 0 || !defined($proc)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdbqry_proc($$self[0], $proc);
}


sub hint {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::tdbqry_hint($$self[0]);
}


sub metasearch {
    my $self = shift;
    my $others = shift;
    my $type = shift;
    if(scalar(@_) != 0 || !defined($others) || ref($others) ne "ARRAY"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $type = $self->MSUNION if(!defined($type));
    return TokyoCabinet::tdbqry_metasearch($$self[0], $others, $type);
}


sub kwic {
    my $self = shift;
    my $cols = shift;
    my $name = shift;
    my $width = shift;
    my $opts = shift;
    if(scalar(@_) != 0 || !defined($cols) || ref($cols) ne "HASH"){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $name = "[[undef]]" if(!defined($name));
    $opts = 0 if(!defined($opts));
    if(!defined($width) || $width < 0){
        $width = 1 << 30;
        $opts |= $self->KWNOOVER | $self->KWPULEAD;
    }
    return TokyoCabinet::tdbqry_kwic($$self[0], $cols, $name, $width, $opts);
}


sub setmax {
    return setlimit(@_);
}



#----------------------------------------------------------------
# the abstract database API
#----------------------------------------------------------------


package TokyoCabinet::ADB;

use strict;
use warnings;
use bytes;
use Carp;
use Encode;


sub new {
    my $class = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    my $self = [0];
    $$self[0] = TokyoCabinet::adb_new();
    bless($self, $class);
    return $self;
}


sub DESTROY {
    my $self = shift;
    return undef unless($$self[0]);
    TokyoCabinet::adb_del($$self[0]);
    return undef;
}


sub open {
    my $self = shift;
    my $name = shift;
    if(scalar(@_) != 0 || !defined($name)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_open($$self[0], $name);
}


sub close {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_close($$self[0]);
}


sub put {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_put($$self[0], $key, $value);
}


sub putkeep {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_putkeep($$self[0], $key, $value);
}


sub putcat {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($value)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_putcat($$self[0], $key, $value);
}


sub out {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_out($$self[0], $key);
}


sub get {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_get($$self[0], $key);
}


sub vsiz {
    my $self = shift;
    my $key = shift;
    if(scalar(@_) != 0 || !defined($key)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_vsiz($$self[0], $key);
}


sub iterinit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_iterinit($$self[0]);
}


sub iternext {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_iternext($$self[0]);
}


sub fwmkeys {
    my $self = shift;
    my $prefix = shift;
    my $max = shift;
    if(scalar(@_) != 0 || !defined($prefix)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $max = -1 if(!defined($max));
    return TokyoCabinet::adb_fwmkeys($$self[0], $prefix, $max);
}


sub addint {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_addint($$self[0], $key, $num);
}


sub adddouble {
    my $self = shift;
    my $key = shift;
    my $num = shift;
    if(scalar(@_) != 0 || !defined($key) || !defined($num)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_adddouble($$self[0], $key, $num);
}


sub sync {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_sync($$self[0]);
}


sub optimize {
    my $self = shift;
    my $params = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $params = "" if(!defined($params));
    return TokyoCabinet::adb_optimize($$self[0], $params);
}


sub vanish {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_vanish($$self[0]);
}


sub copy {
    my $self = shift;
    my $path = shift;
    if(scalar(@_) != 0 || !defined($path)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_copy($$self[0], $path);
}


sub tranbegin {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_tranbegin($$self[0]);
}


sub trancommit {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_trancommit($$self[0]);
}


sub tranabort {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_tranabort($$self[0]);
}


sub path {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_path($$self[0]);
}


sub rnum {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_rnum($$self[0]);
}


sub size {
    my $self = shift;
    if(scalar(@_) != 0){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    return TokyoCabinet::adb_size($$self[0]);
}


sub misc {
    my $self = shift;
    my $name = shift;
    my $args = shift;
    if(scalar(@_) != 0 || !defined($name)){
        croak((caller(0))[3] . ": invalid parameter") if($TokyoCabinet::DEBUG);
        return undef;
    }
    $args = [] if(!defined($args) || ref($args) ne "ARRAY");
    return TokyoCabinet::adb_misc($$self[0], $name, $args);
}


sub TIEHASH {
    my $class = shift;
    my $name = shift;
    my $adb = $class->new();
    return undef if(!$adb->open($name));
    return $adb;
}


sub UNTIE {
    my $self = shift;
    return $self->close();
}


sub STORE {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    return $self->put($key, $value);
}


sub DELETE {
    my $self = shift;
    my $key = shift;
    return $self->out($key);
}


sub FETCH {
    my $self = shift;
    my $key = shift;
    return $self->get($key);
}


sub EXISTS {
    my $self = shift;
    my $key = shift;
    return $self->vsiz($key) >= 0;
}


sub FIRSTKEY {
    my $self = shift;
    $self->iterinit();
    return $self->iternext();
}


sub NEXTKEY {
    my $self = shift;
    return $self->iternext();
}


sub CLEAR {
    my $self = shift;
    return $self->vanish();
}



1;


# END OF FILE
