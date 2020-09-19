#!/bin/bash
k=$1
ver=S
DT=202009
pre=list$DT.$ver
dir=$ver.$k 
m=$2

cd $dir
[[ -f $pre.$k.$m ]] || split -n l/16 -d -a2 $pre.$k $pre.$k.

tac $pre.$k.$m | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
tac $pre.$k.$m | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k.$m | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k.$m | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
wait
cd ..
cat $dir/$pre.$k.$m | while read i; 
do r=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $dir/$r ]] && echo $r
done > $dir/${pre}1.$k.$m
cd $dir
cat ${pre}1.$k.$m | while read i; do [[ -f $i/packed-refs ]] && echo $i/packed-refs;done | cpio -o | gzip > ../${pre}1.$k.$m.cpio.gz
cd ..
scp -p ${pre}1.$k.$m.cpio.gz da0:/data/update/
./doGcpList.sh $k $m
#now filter and extract objects
cd $dir
scp -p *.olist.gz da0:/data/update/
zcat *.olist.gz | ssh da5.eecs.utk.edu '$HOME/lookup/cleanBlb.perl | $HOME/bin/hasObj.perl' | gzip > todo
cd ..
./doGcpExtr.sh $k $m 
cd $dir 
scp -p New*.{bin,idx,err} da0:/data/update/
rm New*.{bin,idx,err}
rm *.olist.gz *.olist.[0-9].gz
cat ${pre}1.$k.$m | while read i; do [[ -d $i ]] && find "$i" -delete; done
