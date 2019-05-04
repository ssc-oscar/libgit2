use strict;
use warnings;
use Compress::LZF ();
use Digest::SHA qw (sha1_hex sha1);


#########################
# create code to versions database
#########################
use TokyoCabinet;

sub fromHex { 
	return pack "H*", $_[0]; 
} 

my $sections = 128;

my $dir = $ARGV[0];
my $fbase = $ARGV[1];
#my (%fhv, 
my (%fhb, %fhi, %size);

my $parts = 1;
my $type = "commit";
open $fhi{$type}, '>', "${fbase}.idx"  or die ($!);
open $fhb{$type}, '>', "${fbase}.bin"  or die ($!);
$size{$type} = 0;

my %cmd;	
while(<STDIN>){
  chop();
  my ($sha, $head) = split (/\s/, $_, -1);
  $head =~ s|^refs/heads/||;
  $cmd{$sha} = $head;
}
output ();

sub output {
  my $dir1 = $dir; 
  $dir1 =~ s|/|_|g;
  my $fnam = "${fbase}.$dir1";
  open A, ">$fnam";
  while (my ($k, $v) = each %cmd){
    print A "$k\n";
  }
  open A, "cat $fnam | $ENV{HOME}/bin/grabc $dir |";
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
  close A;
  unlink $fnam;
}

sub dump_commit {
  my ($code, $hsha1, $sec, $dir) = @_;
  my $len = length($code);
  return if $len == 0;

  my $sha1 = fromHex ($hsha1);
	#if (defined $fhos{commit}{$sec}{$sha1}){
	#	return unpack 'w', $fhos{commit}{$sec}{$sha1};
	#}

  my $hshaFull = sha1_hex ("commit $len\0$code");

  if ($hsha1 ne $hshaFull){ print STDERR "sha do not match: $dir: $hsha1 vs $hshaFull, $len\n$code"; }

  #my $codeC = safeComp ($code);
  my $codeC = $code;
  my $lenC = length($codeC);
  #my $hsha1C = sha1_hex($codeC);

  my $fi = $fhi{commit}; 
  my $fb = $fhb{commit}; 
  print $fi "$hsha1;$cmd{$hsha1};$size{commit};$lenC\n";
  print $fb $codeC;
  $size{commit} += $lenC;
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


