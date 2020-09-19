#!/bin/bash
k=$1
ver=Otr.S
DT=202009
pre=list$DT.$ver
dir=$ver.$k 
cd $dir
tac $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(git.zx2c4.com|git.savannah.gnu.org|git.savannah.nongnu.org|android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|$/||;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
tac $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(git.zx2c4.com|git.savannah.gnu.org|git.savannah.nongnu.org|android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|$/||;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(git.zx2c4.com|git.savannah.gnu.org|git.savannah.nongnu.org|android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|$/||;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(git.zx2c4.com|git.savannah.gnu.org|git.savannah.nongnu.org|android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|$/||;s|/|_|;s|\.git$||;print'); [[ -d $j ]] || git clone --mirror $i $j; done &
wait
cd ..
cat $dir/$pre.$k | while read i; 
do r=$(echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(git.zx2c4.com|git.savannah.gnu.org|git.savannah.nongnu.org|android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|$/||;s|/|_|;s|\.git$||;print'); [[ -d $dir/$r ]] && echo $r
done > $dir/${pre}1.$k
cd $dir
cat ${pre}1.$k | while read i; do [[ -f $i/packed-refs ]] && echo $i/packed-refs;done | cpio -o | gzip > ../${pre}1.$k.cpio.gz
