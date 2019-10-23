#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

k=${2:-CRAN}
cloneDir=${3:-/lustre/haven/user/audris/$k}
Y=${4:-2018}
list=${5:-list}
base=${6:-New}
base=$base$Y$k
m=$1



cd $cloneDir

if [[ -f  $cloneDir/$base.$m.olist.00.gz ]]; then
echo do nothing $cloneDir/$base.$m.olist.00.gz exists
else
 nlines=$(zcat todo |wc -l)
 part=$(echo "$nlines/16 + 1"|bc)
 zcat todo | split -l $part -a2 -d  --filter='gzip > $FILE.gz' - $base.$m.olist. 
fi

echo starting "$m"
for l in {00..15}
do
  (gunzip -c $cloneDir/$base.$m.olist.$l.gz | perl -I $HOME/lib/perl5 $HOME/bin/grabGitI.perl $cloneDir/$base.$m.$l 2> $cloneDir/$base.$m.$l.err) &
done

echo extraced "$m"
wait
echo "after waiting df=$free "  $(date +"%s")

echo DONE $(date +"%s")

