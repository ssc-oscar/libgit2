#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

k=${2:-CRAN}
cloneDir=${3:-/lustre/haven/user/audris/$k}
Y=${4:-2018}
list=${5:-list}
base=${6:-New}
base=$base$Y$k
m=$1
off=${7:-0}
cd $cloneDir
#[[ -e All.sha1 ]] || ln -s /lustre/haven/user/audris/All.sha1 .

echo "k=$k"
echo "m=$m"
echo "cloneDir=$cloneDir"
echo "list=$list"
echo "base=$base"


if [[ -f CopyList.$k.$m.00 ]]; then
 echo "Do Nothing"
else
echo $list$Y.$k.$m
cat $list$Y.$k.$m  | while read l
do [[ -d $cloneDir/$l ]] && echo $l
done > CopyList.$k.$m 
echo CopyList.$k.$m $(wc -l CopyList.$k.$m)
nlines=$(cat CopyList.$k.$m |wc -l)
part=$(echo "$nlines/16 + 1"|bc)
cat CopyList.$k.$m | split -l $part --numeric-suffixes - CopyList.$k.$m.
fi

rm -f pids.$m
echo starting "$m"
for l in {0..15}
do l=$(($l+$off))
  [[ $l -lt 10 ]] && l="0$l" 
  if [[ -f CopyList.$k.$m.$l ]]; then 
     (cat $cloneDir/CopyList.$k.$m.$l | while read repo; do [[ -d $cloneDir/$repo/ ]] && $HOME/bin/gitListSimp.sh $repo | $HOME/bin/classify $repo 2>> $cloneDir/$base.$m.$l.olist.err; done | gzip > $cloneDir/$base.$m.$l.olist.gz) &
     #(cd /tmp/;cat $cloneDir/CopyList.$k.$m.$l | while read repo; do [[ -d $cloneDir/$repo/ ]] && (rsync -a $cloneDir/$repo/ .;$HOME/bin/gitListSimp.sh $repo | $HOME/bin/classify $repo 2>> $cloneDir/$base.$m.$l.olist.err); done | gzip > $cloneDir/$base.$m.$l.olist.gz) &
     #(cat CopyList.$k.$m.$l | while read repo; do [[ -d $cloneDir/$repo/ ]] && $HOME/bin/gitList.sh $repo | $HOME/bin/classify $repo 2>> $cloneDir/$base.$m.$l.olist.err; done | gzip > $cloneDir/$base.$m.$l.olist.gz; gunzip -c $cloneDir/$base.$m.$l.olist.gz | perl -I $HOME/lib/perl5 $HOME/bin/grabGit.perl $cloneDir/$base.$m.$l 2> $cloneDir/$base.$m.$l.err) &
     #(gunzip -c $cloneDir/$base.$m.$l.olist.gz | perl -I $HOME/lib/perl5 $HOME/bin/grabGit.perl $cloneDir/$base.$m.$l 2> $cloneDir/$base.$m.$l.err) &
     pid=$!
     echo "pid for $m.$l is $pid" $(date +"%s")
     echo "$pid" >> pids.$m
  fi
done
wait

echo "after waiting df=$free "  $(date +"%s")

#rm CopyList.$k.$m 

echo DONE $(date +"%s")

