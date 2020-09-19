#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

k=${2:-CRAN}
cloneDir=${3:-/lustre/haven/user/audris/$k}
Y=${4:-2018}
list=${5:-list}
base=${6:-New}
base=$base$Y$k
m=$1
l=${7:-0}
cd $cloneDir
#[[ -e All.sha1 ]] || ln -s /lustre/haven/user/audris/All.sha1 .

echo "k=$k"
echo "m=$m"
echo "cloneDir=$cloneDir"
echo "list=$list"
echo "base=$base"

(cat $cloneDir/CopyList.$k.$m.$l | while read repo; do [[ -d $cloneDir/$repo/ ]] &&  $HOME/bin/list $repo 2>> $cloneDir/$base.$m.$l.olist.err; done | gzip > $cloneDir/$base.$m.$l.olist.gz) &
wait

echo "after waiting df=$free "  $(date +"%s")

#rm CopyList.$k.$m 

echo DONE $(date +"%s")

