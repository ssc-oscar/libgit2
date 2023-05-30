#!/bin/bash

k=$1
l=$2
base=New202303V.$k
cloneDir=/home/audris/V.$k
cd $cloneDir
if [[ -f CopyList.$k.15 ]]
then 
  echo have
else
  split -n l/16 --numeric-suffixes list202303.V1.$k CopyList.$k.
fi

for l in {00..15}
do 
 (cat CopyList.$k.$l | grep -Fvf $HOME/badprojects | while read repo; do [[ -d $repo/ ]] && $HOME/bin/gitListSimp.sh $repo | $HOME/bin/classify $repo 2>> $base.$l.olist.err; done | gzip > $base.$l.olist.gz;\
	 zcat $base.$l.olist.gz | ssh da5 '$HOME/lookup/cleanBlb.perl | $HOME/bin/hasObj.perl' | gzip > todo.$l)	 &
done 


wait
rsync -av *.olist.gz  da7:/mnt/corrino/data/All.blobs/home/update/V.$k/ &

todo=todo
for l in {00..15}; do zcat $todo.$l; done | gzip > todo

if [[ -f  olist.00.gz ]]; then
  echo do nothing olist.00.gz exists
else
  nlines=$(zcat $todo |wc -l)
  part=$(($nlines/16 + 1))
  zcat $todo | split -l $part -a2 -d  --filter='gzip > $FILE.gz' - olist. 
fi

for l in {00..15}
do zcat olist.$l.gz | perl -I $HOME/lib/x86_64-linux-gnu/perl $HOME/bin/grabGitI.perl $base.$l 2> $base.$l.err &
done

wait



echo DONE



