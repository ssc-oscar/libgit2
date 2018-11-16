#!/bin/bash

repo=$1
ohead=$2
rp0=$(echo $repo|sed 's|.*//||')
rpn=$(echo $rp0|sed 's|[^/]*/||')
rpb=$(echo $rp0|sed 's|/[^/]*/[^/]*$||')
rpp=$(echo $rpn|sed 's|/|_|')

head=$(echo $repo | /usr/bin/get_last | cut -d\; -f2)
echo $rpp,$repo,$ohead,$head | /usr/bin/get_new_commits 

/usr/bin/gitListSimp.sh $rpp/.git | /usr/bin/classify $rpp/.git 2>> $rpp.olist.err | gzip > $rpp.olist.gz
#now check
zcat $rpp.olist.gz | grep ';commit;' | cut -d\; -f3 | gzip > $rpp.cs
#zcat $rpp.olist.gz | /usr/bin/cleanBlb.perl | /usr/bin/hasObj.perl | gzip > $rpp.todo
zcat $rpp.olist.gz | /usr/bin/cleanBlb.perl | gzip > $rpp.todo
zcat $rpp.todo | /usr/bin/grabGitI.perl $rpp 2> $rpp.err

