#!/bin/bash
k=$1
ver=S
DT=202009
pre=list$DT.$ver
dir=$ver.$k 
cd $dir
tac $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
tac $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
wait

cat $pre.$k | while read i; 
#do r=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $r ]] && du -ks $r
do r=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|/|_|;s|\.git$||;print'); [[ -d $r ]] && echo $r
done > ${pre}1.$k
#awk '{print $2}' ${pre}1.$k.s > ${pre}1.$k
cat ${pre}1.$k | while read i; do [[ -f $i/packed-refs ]] && echo $i/packed-refs;done | cpio -o | gzip > ../${pre}1.$k.cpio.gz
