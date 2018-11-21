#!/bin/bash

repo=$1
rp0=$(echo $repo|sed 's|.*//||')
rpn=$(echo $rp0|sed 's|[^/]*/||')
rpb=$(echo $rp0|sed 's|/[^/]*/[^/]*$||')
rpp=$(echo $rpn|sed 's|/|_|')
git clone --mirror $repo $rpp
/usr/bin/gitListSimp.sh $rpp | /usr/bin/classify $rpp 2>> $rpp.olist.err | gzip > $rpp.olist.gz

#now get p2c map
zcat $rpp.olist.gz | grep ';commit;' | cut -d\; -f1,3 | sort -T\. -t\; -k1b,2 | gzip > $rpp.p2c

# select only missing objects via /usr/bin/hasObj.perl
#zcat $rpp.olist.gz | /usr/bin/cleanBlb.perl | /usr/bin/hasObj.perl | gzip > $rpp.todo

zcat $rpp.olist.gz | /usr/bin/cleanBlb.perl | gzip > $rpp.todo
zcat $rpp.todo | /usr/bin/grabGitI.perl $rpp 2> $rpp.err
rm $rpp.todo $rpp.olist.gz
rm -rf $rpp
tar czf $rpp.tgz $rpp.*
#copy stuff back
scp $rpp.tgz -p443 audris@da0.eecs.utk.edu:/data/cloud
rm $rpp.*
