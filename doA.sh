#!/bin/bash
k=$1
ver=Q
DT=201910
pre=list$DT.$ver
cd $ver.$k
tac $pre.$k | while read i; do j=$(echo $i|sed 's|/|_|;s/^gh://'); [[ -d $j ]] || git clone --mirror gh:$i $j; done &
tac $pre.$k | while read i; do j=$(echo $i|sed 's|/|_|;s/^gh://'); [[ -d $j ]] || git clone --mirror gh:$i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|sed 's|/|_|;s/^gh://'); [[ -d $j ]] || git clone --mirror gh:$i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|sed 's|/|_|;s/^gh://'); [[ -d $j ]] || git clone --mirror gh:$i $j; done &
wait
cd ..
cat $ver.$k/$pre.$k | while read i; 
do r=$(echo $i|sed s'|/|_|;s/^gh://'); [[ -d $ver.$k/$r ]] && echo $r
done > $ver.$k/${pre}1.$k
