#!/usr/bin/perl -I $HOME/lib/x86_64-linux-gnu/perl

use strict;
use warnings;
use Compress::LZF ();
use Digest::SHA qw (sha1_hex sha1);


#########################
# create code to versions database
#########################
# Type-selective variant of grabGitI.perl.
#  ARGV[0] = output file base (same as grabGitI.perl)
#  ARGV[1] = comma-separated list of object types to (re)dump:
#            tag,tree,commit,blob   (defaults to all four)
# Only the .idx/.bin files for the requested types are opened and written;
# all other type files are left untouched.  Use this to redo only the
# messed-up tags/trees of a shard without re-dumping (and overwriting) the
# commit/blob outputs.
use TokyoCabinet;

sub fromHex {
 return pack "H*", $_[0];
}

my $sections = 128;

my $fbase = $ARGV[0];

my @types = ("tag", "tree", "commit", "blob");
if (defined $ARGV[1] && $ARGV[1] ne ""){
 @types = split /,/, $ARGV[1];
}
my %want = map { $_ => 1 } @types;
#my (%fhv,
my (%fhb, %fhi, %size);
#my (%fhos); do not check, assume only new objects are prefeltered, get them all

my $parts = 1;
for my $type (@types){
 open $fhi{$type}, '>', "${fbase}.$type.idx"  or die ($!);
 open $fhb{$type}, '>', "${fbase}.$type.bin"  or die ($!);
 $size{$type} = 0;
# open  $fhv{$type}, '>', "${fbase}.$type.vs" or die ($!);
}

my %cmd;
my $dir = "";
while(<STDIN>){
 chop();
 my ($dir0, $type, $sha, $file) = split (/\;/, $_, -1);
 if ($dir0 ne $dir){
  if ($dir ne ""){
   output ();
  }
  $dir = $dir0;
  %cmd = ();
 }
 next unless (defined $type && $want{$type});
 if ($type eq "blob"){
  #$cmd{$type}{$sha}{$file}++;
  $cmd{$type}{$sha}++;
 }else{
  $cmd{$type}{$sha}++;
 }
}
output ();

sub output {
 for my $type (@types){
                my $dir1 = $dir; $dir1 =~ s|/|_|g;
  my $fnam = "${fbase}.$type.$dir1";
  open A, ">$fnam";
  while (my ($k, $v) = each %{$cmd{$type}}){
   if ($type eq "blob"){
    #for my $h (keys %{$v}){
    #	print A "$k;$h\n";
    #}
    print A "$k\n";
   }else{
    print A "$k\n";
   }
  } 
    close A;

  if ($type eq "tree"){
   open A, "cat $fnam | /usr/bin/grabft $dir |";
   my $state = 0;
     my ($rem, $line) = ("", "");
     while (<A>){
        if ($state == 0){
     $rem = $_;
           $state = 1;
        } else {
          if ($state == 1){
            if ($rem eq "$_"){
               $state = 0;
               chop ($rem);
       chop ($line);
               my ($cnst,$hsha1, $entries, $cnst1) = split(/\;/, $rem, -1);
       my $sec = hex (substr($hsha1, 0, 2)) % $sections;
       if (length ($line) == 0){
        #print STDERR "Empty:$hsha1;$dir/$f/$cmt\n";
        next;
       }
               my $res = dump_tree ($line, $hsha1, $sec, "$dir");
       if ($res ne "new"){
        #my $fv = $fhv{$type};
        #print $fv "$res;".(length ($line)).";$hsha1;$dir\n";
       }
               $line = "";
             }else{
               $line .= $_;
            }
     }
    }
   }
   }
  if ($type eq "commit"){
   open A, "cat $fnam | /usr/bin/grabc $dir |";
      my $state = 0;
      my ($rem, $line) = ("", "");
        while (<A>){
        if ($state == 0){
     $rem = $_;
              $state = 1;
          } else {
           if ($state == 1){
              if ($_ =~ s|$rem$||){
                  $state = 0;
                  $line .= $_ if $_ ne "";

                  my ($hsha1, $tr, $p, $t) = split(/\;/, $rem, -1);
       $t =~ s/\n$//;
       my $sec = hex (substr($hsha1,0,2)) % $sections;
       if (length ($line) == 0){
        #print STDERR "Empty:$hsha1;$dir/$f/$cmt\n";
        next;
       }
                  my $res = dump_commit ($line, $hsha1, $sec, "$dir;$tr;$p;$t");
       if ($res ne "new"){
        #my $fv = $fhv{$type};
        #print $fv "$res;".(length ($line)).";$hsha1;$dir;$tr;$p;$t\n";
       }
                  $line = "";
              }else{
                  $line .= $_;
              }
     }
          }
   }
  }
  if ($type eq "tag"){
   open A, "cat $fnam  | /usr/bin/grabtag $dir |";
     my $state = 0;
    my ($rem, $line) = ("", "");
      while (<A>){
          if ($state == 0){
     $rem = $_;
     $state = 1;
    } else {
     if ($state == 1){
              if ($_ =~ s|\Q$rem\E$||){
                  $state = 0;
       $line .= "$_" if $_ ne "";
                  #my ($cnst, $dir1, $tag, $hsha1) = split(/\;/, $rem, -1);
                  my ($cnst, $dir1, @rest) = split(/\;/, $rem, -1);
                                                        my $hsha1 = pop @rest;
                                                        my $tag = join ';', @rest;
       $hsha1 =~ s/\n$//;
       my $sec = hex (substr($hsha1, 0, 2)) % $sections;
       if (length ($line) == 0){
        #print STDERR "Empty:$hsha1;$dir/$f/$cmt\n";
        next;
       }
                  my $res = dump_tag ("$line", $hsha1, $sec, "$dir;$tag");
       if ($res ne "new"){
        #my $fv = $fhv{$type};
        #print $fv "$res:$sec;".(length ($line)).";$hsha1;$dir;$tag\n";
       }
                  $line = "";
              }else{
                  $line .= $_;
              }
     }
          }
      }
      close A;
  }
  if ($type eq "blob"){
   open A, "cat $fnam  | /usr/bin/grabf $dir |";
   my $state = 0;
     my ($rem, $line) = ("", "");
     while (<A>){
        if ($state == 0){
     $rem = $_;
           $state = 1;
        } else {
         if ($state == 1){
            if ($rem eq "$_"){
               $state = 0;
               chop ($rem);
               my ($hsha1, $dir, $fname, $rawsize) = split(/\;/, $rem, -1);
       my $sec = hex (substr ($hsha1,0,2)) % $sections;
               chop ($line);
       if (length ($line) == 0){
        next;
       }
                my $res = dump_file ($line, $hsha1, $sec, "$dir;$fname");
       if ($res ne "new"){
        #my $fv = $fhv{$type};
        #print $fv "$res;".(length ($line)).";$hsha1;$dir;$fname\n";
       }
               $line = "";
            }else{
               $line .= $_;
            }
     }  
        }
     }
     close A;
  }
  unlink $fnam;
 }
}

sub dump_tree {
 my ($code, $hsha1, $sec, $dir) = @_;
 my $len = length($code);
 return if $len == 0;

 my $sha1 = fromHex ($hsha1);
 #if (defined $fhos{tree}{$sec}{$sha1}){
 # return unpack 'w', $fhos{tree}{$sec}{$sha1};
 #}

 my $hshaFull = sha1_hex ("tree $len\0$code");

 if ($hsha1 ne $hshaFull){ print STDERR "sha do not match: $dir: $hsha1 vs $hshaFull, $len\n$code"; }

 my $codeC = safeComp ($code);
 my $lenC = length($codeC);
 #my $hsha1C = sha1_hex($codeC);

 my $fi = $fhi{tree};
 my $fb = $fhb{tree};
 print $fi "$size{tree};$lenC;$sec;$hsha1;$dir\n";
 print $fb $codeC;
 $size{tree} += $lenC;
 return "new";
}

sub dump_commit {
 my ($code, $hsha1, $sec, $dir) = @_;
 my $len = length($code);
 return if $len == 0;

 my $sha1 = fromHex ($hsha1);
 #if (defined $fhos{commit}{$sec}{$sha1}){
 # return unpack 'w', $fhos{commit}{$sec}{$sha1};
 #}

 my $hshaFull = sha1_hex ("commit $len\0$code");

 if ($hsha1 ne $hshaFull){ print STDERR "sha do not match: $dir: $hsha1 vs $hshaFull, $len\n$code"; }

 my $codeC = safeComp ($code);
 my $lenC = length($codeC);
 #my $hsha1C = sha1_hex($codeC);

 my $fi = $fhi{commit};
 my $fb = $fhb{commit};
 print $fi "$size{commit};$lenC;$sec;$hsha1;$dir\n";
 print $fb $codeC;
 $size{commit} += $lenC;
 return "new";
}

sub dump_tag {
 my ($code, $hsha1, $sec, $dir) = @_;
 my $len = length($code);
 return if $len == 0;

 my $sha1 = fromHex ($hsha1);
 #if (defined $fhos{tag}{$sec}{$sha1}){
 # return unpack 'w', $fhos{tag}{$sec}{$sha1};
 #}

 my $hshaFull = sha1_hex ("tag $len\0$code");

 if ($hsha1 ne $hshaFull){ print STDERR "sha do not match: $hsha1 vs $hshaFull, $len\n$dir\n$code"; }

 my $codeC = safeComp ($code);
 my $lenC = length($codeC);
 #my $hsha1C = sha1_hex($codeC);

 my $fi = $fhi{tag};
 my $fb = $fhb{tag};
 print $fi "$size{tag};$lenC;$sec;$hsha1;$dir\n";
 print $fb $codeC;
 $size{tag} += $lenC;
 return "new";
}

sub dump_file {
 my ($code, $hsha1, $sec, $dir) = @_;
 my $len = length($code);
 return if $len == 0;

 my $sha1 = fromHex ($hsha1);
 #if (defined $fhos{blob}{$sec}{$sha1}){
 # return unpack 'w', $fhos{blob}{$sec}{$sha1};
 #}

 my $hshaFull = sha1_hex ("blob $len\0$code");
 if ($hsha1 ne $hshaFull){ die "sha do not match: $dir: $hsha1 vs $hshaFull, $len\n$code"; }
        my $codeC = $code;
        #if ($len >= 3623132146 4147483647){
        #           3623132146
        if ($len >= 2147483647){
           print STDERR "blob too long to compress: $len;$hshaFull;$sec;$dir\n";
        }else{
   $codeC = safeComp ($code);
        }
 my $lenC = length($codeC);
 my $hsha1C = sha1_hex($codeC);

 my $fb = $fhb{blob};
 my $fi = $fhi{blob};
 print $fi "$size{blob};$lenC;$sec;$hshaFull;$dir\n";
 print $fb $codeC;
 $size{blob} += $lenC;
 return "new";
}


sub safeDecomp {
 my ($codeC, @rest) = @_;
 try {
  my $code = Compress::LZF::decompress ($codeC);
  return $code;
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
 }
}

sub safeComp {
 my ($code, @rest) = @_;
 try {
                my $len = length($code);
  if ($len >= 2147483647){
   print STDERR "Too long to compress: $len\n";
   return $code;
  }
  my $codeC = Compress::LZF::compress ($code);
  return $codeC;
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
 }
}

