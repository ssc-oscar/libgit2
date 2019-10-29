#!/usr/bin/bash

DT=201910
ver=Q

for f in bitbucket$DT.new.heads git.debian.org.$DT.heads drupal.com.$DT.heads sf$DT.prj.new.heads repo.or.cz.$DT.heads gl$DT.new.heads gitlab.gnome.org.$DT.heads git.zx2c4.com.$DT.heads git.savannah.gnu.org.$DT.heads git.postgresql.org.$DT.heads git.kernel.org.$DT.heads git.eclipse.org.$DT.heads cgit.kde.org.$DT.heads bioconductor.org.$DT.heads android.googlesource.com.$DT.heads git.postgresql.org.$DT.heads
do cat $f.get
done > list$DT.Otr.$ver

#do GH (make sure it fits in 100 bins)
split -l 900000 -a 2 -d gh$DT.u.heads.get list$DT.$ver.
# run these batches on ACF servers: see doA.sh

#run this anywhere
split -n l/10 -a 1 -d list$DT.Otr.$ver list$DT.Otr.$ver.
for nn in {0..9}
do mkdir $ver.Otr.$nn
   cd $ver.Otr.$nn
   mv ../list$DT.Otr.$ver.$nn .
   cd ..
done 

for nn in {0..9}
do cd $ver.Otr.$nn 
   cat list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|^a:a@||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d $rpp ]] || (git clone --mirror $r $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   tac list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|^a:a@||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d $rpp ]] || (git clone --mirror $r $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   cat list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|^a:a@||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d $rpp ]] || (git clone --mirror $r $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   tac list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|^a:a@||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d $rpp ]] || (git clone --mirror $r $rpp; [[ $r =~ salsa.debian ]] && sleep 20); done &
   wait
   cat list$DT.Otr.$ver.$nn |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d "$rpp" ]] && echo $rpp; done > list$DT.Otr.${ver}1.$nn
   cat list$DT.Otr.${ver}1.$nn | while read rpp; do $HOME/bin/gitListSimp.sh $rpp | $HOME/bin/classify $rpp 2>> New$DT.Otr.${ver}1.$nn.olist.err; done | gzip > New$DT.Otr.${ver}1.$nn.olist.gz
   cd ../
done
wait

for nn in {0..9}
do cd  $ver.Otr.$nn
  # fixP.perl in libgit2 is for keeping the mapping of the urls to project names consistent
  zcat New$DT.Otr.${ver}1.$nn.olist.gz | grep ';commit;' | ~/bin/fixP.perl | $HOME/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullP 32  | lsort 3G -u -t\; -k1b,2| gzip > New$DT.Otr.${ver}1.$nn.p2c & 
  # in case the olist is split into 16 pieces
  #for i in {00..15}; do zcat New$DT.Otr${ver}1.$nn.$i.olist.gz | grep ';commit;'; done ~/bin/fixP.perl | ~/lookup/Prj2CmtChk.perl /fast/p2cFullP 32 | lsort 30G -u -t\; -k1b,2| gzip > New$DT.Otr.${ver}1.$nn.p2c
  cd ..
done
wait

for nn in {0..9}
do cd $ver.Otr.$nn
   zcat New$DT.Otr.${ver}1.$nn.olist.gz | ssh da4 '$HOME/lookup/cleanBlb.perl | $HOME/bin/hasObj.perl' | gzip > New$DT.Otr.${ver}1.todo.$nn &
   cd ..
done
wait

for nn in {0..9}; do
  cd $ver.Otr.$nn
  zcat New$DT.Otr.${ver}1.todo.$nn | perl -I ~/lib/x86_64-linux-gnu/perl $HOME/bin/grabGitI.perl New$DT.Otr.${ver}1.$nn 2> New$DT.Otr${ver}1.$nn.err
#check if objects are correct
  for t in blob tag commit tree;do ls -f  *$nn.*$t.bin  | sed 's/\.bin$//' | while read i; do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i) &>> ../Otr$ver$nn.$t.err; done; done
  cd ..
done
wait

# check what path is in .idx
#sed -i 's/;gitlab.com_/;gl_/' New$Y$abr${ver}1.*.idx
