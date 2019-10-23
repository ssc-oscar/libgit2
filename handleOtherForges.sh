#!/usr/bin/bash

DT=201910
ver=Q
for f in drupal.com.$DT.heads sf$DT.prj.new.heads repo.or.cz.$DT.heads gl$DT.new.heads gitlab.gnome.org.$DT.heads git.zx2c4.com.$DT.heads git.savannah.gnu.org.$DT.heads git.postgresql.org.$DT.heads git.kernel.org.$DT.heads git.eclipse.org.$DT.heads cgit.kde.org.$DT.heads bioconductor.org.$DT.heads android.googlesource.com.$DT.heads git.postgresql.org.$DT.heads
do cat $f.get
done > list$DT.Otr.$ver

split -n l/10 -a 1 -d list$DT.Otr.$ver list$DT.Otr.$ver.
for i in {0..9}
do mkdir $ver.Otr.$nn
   cd $ver.Otr.$nn
   cat list$DT.Otr.$ver.$i |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|:|_|;s|/|_|;s|\.git$||'); r=$(echo $r|sed 's|//|//a:a@|'); git clone --mirror $r $rpp;done
   cat list$DT.Otr.$ver.$i |  while read r; do rpp=$(echo $r| sed 's|^https://||;s|:|_|;s|/|_|;s|\.git$||'); [[ -d "$rpp" ]] && echo $rpp; done > list$DT.Otr.${ver}1.$i
   cat list$Y$abr.${ver}1.$i | while read rpp; do ~/libgit2/gitListSimp.sh $rpp | /usr/bin/classify $rpp 2>> New$DT.Otr.${ver}1.$i.olist.err; done | gzip > New$DT.Otr.${ver}1.$i.olist.gz 
done

for i in {0..9}
do zcat New$DT.Otr.${ver}1.$i.olist.gz | grep ';commit;' | \
        ~/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullP 32  | lsort 3G -u -t\; -k1b,2| gzip > New$DT.Otr.${ver}1.$i.p2c & 
done
wait

for i in {0..9}; do
zcat New$DT.Otr.${ver}1.$i.olist.gz | ssh da4 '~/lookup/cleanBlb.perl | ~/bin/hasObj.perl' | gzip > NEW$DT.Otr.${ver}1.todo.$i &
done
wait

for i in {0..9}; do
zcat New$DT.Otr.${ver}1.todo.$i | perl -I ~/lib/x86_64-linux-gnu/perl ~/libgit2/grabGitI.perl New$DT.Otr.${ver}1.$i 2> New$DT.Otr${ver}1.$i.err &
done
wait

# check what path is in .idx
#sed -i 's/;gitlab.com_/;gl_/' New$Y$abr${ver}1.*.idx
