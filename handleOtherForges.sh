#!/usr/bin/bash
docker run -d -v /home/audris:/data/libgit2 -p443:22 --name libgit2 audris/libgit2 startDef.sh audris

docker run -d -v /home/audris:/data/gather -p444:22 --name libgit2 audris/gather startDef.sh audris



DT=201910
ver=Q
DT=202003
ver=R

for f in bitbucket$DT.new.*.heads git.debian.org.$DT.*.heads drupal.com.$DT.heads sf$DT.prj.*.heads repo.or.cz.$DT.heads gl$DT.new.heads git.zx2c4.com.$DT.heads git.savannah.gnu.org.$DT.heads git.postgresql.org.$DT.heads git.kernel.org.$DT.heads git.eclipse.org.$DT.heads cgit.kde.org.$DT.heads bioconductor.org.$DT.heads android.googlesource.com.$DT.heads git.postgresql.org.$DT.heads
do zcat $f | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ssh da5 perl -I ~/lib64/perl5 ~/lookup/hasObj2.perl | cut -d\; -f3 | uniq 
done | sed 's|/a:a@|/|' > list$DT.Otr.$ver.nogl

for f in gitlab.gnome.org.$DT.heads  gl$DT.new.heads
do zcat $f | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ssh da5 perl -I ~/lib64/perl5 ~/lookup/hasObj2.perl | cut -d\; -f3 | uniq
done > list$DT.Otr.$ver.gl


split -n l/10 -a 2 --numeric-suffixes=10 list$DT.Otr.$ver.gl list$DT.Otr.$ver.


for f in gh$DT.u.[03-5][0-9].heads
do zcat $f | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ssh da5 perl -I ~/lib64/perl5 ~/lookup/hasObj2.perl | cut -d\; -f3 | uniq 
done | sed 's|/a:a@|/|' > list$DT.$ver.no10-20

for f in gh$DT.u.[12][0-9].heads1
do zcat $f | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ssh da5 perl -I ~/lib64/perl5 ~/lookup/hasObj2.perl | cut -d\; -f3 | uniq 
done | sed 's|/a:a@|/|' > list$DT.$ver.10-20


#do GH (make sure it fits in 100 bins)
split -l 170000 -a 2 -d list$DT.$ver.no10-20 list$DT.$ver.
for nn in {00..19}
do mkdir $ver.$nn
   cd $ver.$nn
   mv ../list$DT.$ver.$nn .
   cd ..
done 
split -l 170000 -a 2 --numeric-suffixes=20 list$DT.$ver.10-20 list$DT.$ver.
######################
# run these batches on ACF servers: see doA.sh, run.sh (create todo, see belopw), then run1.sh
######################


#Otherwise run this anywhere
split -n l/10 -a 1 -d list$DT.Otr.$ver.nogl list$DT.Otr.$ver.
for nn in {0..9}
do mkdir $ver.Otr.$nn
   cd $ver.Otr.$nn
   mv ../list$DT.Otr.$ver.$nn .
   cd ..
done 

for nn in {0..9}
do cd $ver.Otr.$nn 
   cat list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|a:a@||;s|^https://||;s|:|_|;s|/|_|;s|\.git$||');rr=$(echo $r| sed 's|a:a@||;s|^https://|https://a:a@|'); [[ -d $rpp ]] || (git clone --mirror "$rr" $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   tac list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|a:a@||;s|^https://||;s|:|_|;s|/|_|;s|\.git$||'); rr=$(echo $r| sed 's|a:a@||;s|^https://|https://a:a@|');[[ -d $rpp ]] || (git clone --mirror "$rr" $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   cat list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|a:a@||;s|^https://||;s|:|_|;s|/|_|;s|\.git$||'); rr=$(echo $r| sed 's|a:a@||;s|^https://|https://a:a@|');[[ -d $rpp ]] || (git clone --mirror "$rr" $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   tac list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|a:a@||;s|^https://||;s|:|_|;s|/|_|;s|\.git$||'); rr=$(echo $r| sed 's|a:a@||;s|^https://|https://a:a@|'); [[ -d $rpp ]] || (git clone --mirror "$rr" $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   wait
   cat list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d "$rpp" ]] && echo $rpp; done > list$DT.Otr.${ver}1.$nn
   #cat list$DT.Otr.${ver}1.$nn | while read rpp; do $HOME/bin/gitListSimp.sh $rpp | $HOME/bin/classify $rpp 2>> New$DT.Otr.${ver}1.$nn.olist.err; done | gzip > New$DT.Otr.${ver}1.$nn.olist.gz
   #sed "s/NNN/1/;s/MACHINE/beacon/;s/=23/=13/" run.pbs | qsub
   cat list$DT.Otr.${ver}1.$nn | while read rpp; do $HOME/bin/list $rpp 2>> New$DT.Otr.${ver}1.$nn.olist.err; done | gzip > New$DT.Otr.${ver}1.$nn.olist.gz
   cd ../
done
wait

for nn in {0..9}
do cd  $ver.Otr.$nn
  # fixP.perl in libgit2 is for keeping the mapping of the urls to project names consistent
  zcat New$DT.Otr.${ver}1.$nn.olist.gz | grep ';commit;' | ~/lookup/fixP2.perl 0 | $HOME/lookup/Prj2CmtChk.perl /fast/p2cFull$pVer 32  | lsort 3G -u -t\; -k1b,2| gzip > New$DT.Otr.${ver}1.$nn.p2c & 
  cat list$DT.Otr.${ver}1.$nn | while read i; do [[ -f $i/packed-refs ]] && echo $i/packed-refs;done | cpio -o | gzip > ../list$DT.Otr.${ver}1.$nn.cpio.gz &
  # in case the olist is split into 16 pieces
  #for i in {00..15}; do zcat New$DT.Otr${ver}1.$nn.$i.olist.gz | grep ';commit;'; done ~/bin/fixP.perl | ~/lookup/Prj2CmtChk.perl /fast/p2cFullP 32 | lsort 30G -u -t\; -k1b,2| gzip > New$DT.Otr.${ver}1.$nn.p2c
  cd ..
done
wait

for nn in {0..9}
do cd $ver.Otr.$nn
   zcat New$DT.Otr.${ver}1.$nn.olist.gz | ssh da4 '$HOME/lookup/cleanBlb.perl | /usr/bin/hasObj.perl' | gzip > New$DT.Otr.${ver}1.todo.$nn &
   cd ..
done
wait

for nn in {0..9}; do
  cd $ver.Otr.$nn
  zcat New$DT.Otr.${ver}1.todo.$nn | perl -I ~/lib/x86_64-linux-gnu/perl /usr/bin/grabGitI.perl New$DT.Otr.${ver}1.$nn 2> New$DT.Otr${ver}1.$nn.err
#check if objects are correct
  for t in blob tag commit tree;do ls -f  *$nn.*$t.bin  | sed 's/\.bin$//' | while read i; do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i) &>> ../Otr$ver$nn.$t.err; done; done
  cd ..
done
wait

# check what path is in .idx
#sed -i 's/;gitlab.com_/;gl_/' New$Y$abr${ver}1.*.idx
