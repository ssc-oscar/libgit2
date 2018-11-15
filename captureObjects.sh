#!/bin/bash

repo=$1
rp0=$(echo $repo|sed 's|.*//||')
rpn=$(echo $rp0|sed 's|[^/]*/||')
rpb=$(echo $rp0|sed 's|/[^/]*/[^/]*$||')
rpp=$(echo $rp1|sed 's|/|_|')
git clone $repo $rpp
/usr/bin/gitListSimp.sh $rpp | /usr/bin/classify $rp 2>> $rpp.olist.err | gzip > $rpp.olist.gz
#now check
zcat $rpp.olist.gz | grep ';commit;' | cut -d\; -f3 | gzip > $rpp.cs
zcat $rpp.olist.gz | /usr/bin/cleanBlb.perl | /usr/bin/hasObj.perl | gzip > $rpp.todo
zcat $rpp.todo | /usr/bin/grabGitI.perl $rpp 2> $rpp.err

