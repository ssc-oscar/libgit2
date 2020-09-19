#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

list=list
Y=202009
ver=S
m=$1
l=$2
base=New$Y$ver
cd $ver.$m

nlines=$(zcat todo |wc -l)
part=$(echo "$nlines/4 + 1"|bc)
zcat todo | split -l $part -a1 -d  --filter='gzip > $FILE.gz' - $base.$m.$l.olist. 

for n in {0..3}
do
  (gunzip -c $base.$m.$l.olist.$n.gz | perl /usr/bin/grabGitI.perl $base.$m.$l.$n 2> $base.$m.$l.$n.err) &
done

wait

