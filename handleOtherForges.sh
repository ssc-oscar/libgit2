#!/usr/bin/bash
docker run -d -v /home/audris:/data/libgit2 -p443:22 --name libgit2 audris/libgit2 startDef.sh audris

docker run -d -v /home/audris:/data/gather -p444:22 --name libgit2 audris/gather startDef.sh audris



DT=201910
ver=Q
DT=202003
ver=R
PDT=202003
DT=202009
ver=S


for f in gitlab.gnome.org.$DT.heads  gl$DT.new.heads bitbucket$DT.new.*.heads git.debian.org.$DT.*.heads drupal.com.$DT.heads sf$DT.prj.*.heads repo.or.cz.$DT.heads gl$DT.new.heads git.zx2c4.com.$DT.heads git.savannah.nongnu.org.$DT.heads git.savannah.gnu.org.$DT.heads git.postgresql.org.$DT.heads git.kernel.org.$DT.heads git.eclipse.org.$DT.heads cgit.kde.org.$DT.heads bioconductor.org.$DT.heads android.googlesource.com.$DT.heads git.postgresql.org.$DT.heads
do zcat $f | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ssh da5 perl -I ~/lib64/perl5 ~/lookup/hasObj2.perl | cut -d\; -f3 | uniq 
done | sed 's|/a:a@|/|' > list$DT.Otr.$ver


split -n l/10 -a 2 --numeric-suffixes=10 list$DT.Otr.$ver.gl list$DT.Otr.$ver.


for f in gh$DT.u.*.heads gh$PDT.u.*.heads
do zcat $f | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ssh da5 perl -I ~/lib64/perl5 ~/lookup/hasObj2.perl | cut -d\; -f3 | uniq 
done | sed 's|/a:a@|/|' > list$DT.$ver

#do GH (make sure it fits in 100 bins)
split -l 170000 -a 2 -d list$DT.$ver list$DT.$ver.
for nn in {00..85}
do mkdir $ver.$nn
   cd $ver.$nn
   mv ../list$DT.$ver.$nn .
   cd ..
done 
######################
# run these batches on ACF servers: see doS1.sh, run.pbs (create todo, see belopw), then run1.pbs
######################
# see doS.sh 
# 
# echo $i|perl -ane 's|^gh:||;s|^bb:|bitbucket.org_|;s|^gl:|gitlab.com_|;s|^dr:|drupal.com_|;s!https://(git.zx2c4.com|git.savannah.gnu.org|git.savannah.nongnu.org|android.googlesource.com|git.bioconductor.org|git.code.sf.net|git.kernel.org|git.postgresql.org|repo.or.cz|git.eclipse.org)/!$1_!;s!^https://a:a\@(salsa.debian.org|gitlab.gnome.org)/!$1_!;s|$/||;s|/|_|;s|\.git$||;print'

# missing in 202009 
add https://pagure.io/ #does not look too active
0xacab.org/explore !update!
android.git.kernel.org # old
anongit.kde.org   # need complicated !update!
blitiri.com.ar #https://blitiri.com.ar/git/    update
code.ill.fr   # update
code.qt.io    # update
drupalcode.org   # old?
fedorapeople.org # update
forge.softwareheritage.org # need login
forgemia.inra.fr/explore #update 
framagit.org #update 
g-rave.nl #dead
gary.hai  #??? fix
gcc.gnu.org           #https://gcc.gnu.org/git/gitweb.cgi?p=gcc.git !update!
git.alpinelinux.org   # tiny !update!
git.apache.org        #https://gitbox.apache.org/repos/asf !update!
git.bde-insa-lyon.fr  # old
git.berlios.de        # old
gitweb.cairographics.org #no urls, need to know projects?
git.drupalcode.org   # old? 
git.freedesktop.org # !update!
git.gnu.io/explore   #  got to gitlab.freedesktop.org
git.openembedded.org # !update!
git.pleroma.social/explore # !update!
git.plt-scheme.org #dead?
git.sv.gnu.org  # fix -> http://git.savannah.gnu.org
git.torproject.org # !update!
git.unicaen.fr/explore # !update!
git.unistra.fr/explore # !update!
git.xfce.org   # !update!
git.yoctoproject.org # !update!
gite.lirmm.fr #https://gite.lirmm.fr/explore - !update!
github.com   # fix
gitlab.adullact.net  # not just git, e.g https://adullact.net/scm/?group_id=613
gitlab.cerema.fr/explore    #few projects
gitlab.common-lisp.net #https://gitlab.common-lisp.net/explore/projects - !update!
gitlab.fing.edu.uy/explore #- !update!
gitlab.freedesktop.org #https://gitlab.freedesktop.org/explore - !update!
gitlab.huma-num.fr/explore #!update!
gitlab.inria.fr/explore  #!update!
gitlab.irstea.fr/explore #!update!
gitlab.ow2.org  #https://gitlab.ow2.org/explore - !update!
gitorious.org  #old
jim.severino    #??
ninkendo.org    # dead?
notabug.org     #https://notabug.org/explore/repos - !update!
phabricator.wikimedia.org #see below
rubyforge.org #old
secure.phabricator.com  #https://secure.phabricator.com/project/ appears old?
source.winehq.org #old
sourceforge.net  # why no new updates?
www.happyassassin.net #appears old

split -n l/10 -a 1 -d list$DT.Otr.$ver.nogl list$DT.Otr.$ver.
for nn in {0..9}
do mkdir $ver.Otr.$nn
   cd $ver.Otr.$nn
   mv ../list$DT.Otr.$ver.$nn .
   cd ..
done 

#check fixP2.perl to make sure ver R and ver S have the same project names

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

DT=202009
ver=Otr.R
for nn in {0..8} 10
do cd ../$ver.$nn
   zcat *.olist.gz |grep ';commit;' | sed 's|/;|;|;s|\.git;|;|' | $HOME/lookup/Prj2CmtChk.perl /fast/p2cFullR 32 | lsort 30G -u -t\; -k1,2| gzip > New$DT.${ver}1.$nn.p2c
done   