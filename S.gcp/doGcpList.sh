#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

list=list
Y=202009
ver=S
m=$1
l=$2
base=New$Y$ver
cd $ver.$m
split -n l/4 -d -a1 list$Y.${ver}1.$m.$l list$Y.${ver}1.$m.$l.
cat list$Y.${ver}1.$m.$l.0 | while read repo; do [[ -d $repo/ ]] &&  /usr/bin/list $repo 2>> $base.$m.$l.0.olist.err; done | gzip > $base.$m.$l.0.olist.gz &
cat list$Y.${ver}1.$m.$l.1 | while read repo; do [[ -d $repo/ ]] &&  /usr/bin/list $repo 2>> $base.$m.$l.1.olist.err; done | gzip > $base.$m.$l.1.olist.gz &
cat list$Y.${ver}1.$m.$l.2 | while read repo; do [[ -d $repo/ ]] &&  /usr/bin/list $repo 2>> $base.$m.$l.2.olist.err; done | gzip > $base.$m.$l.2.olist.gz &
cat list$Y.${ver}1.$m.$l.3 | while read repo; do [[ -d $repo/ ]] &&  /usr/bin/list $repo 2>> $base.$m.$l.3.olist.err; done | gzip > $base.$m.$l.3.olist.gz &
wait
cd ..

echo DONE $(date +"%s")

