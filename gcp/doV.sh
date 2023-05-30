#!/bin/bash
export LD_LIBRARY_PATH=/home/audris/lib

k=$1
part=$2
ver=V
DT=202303
dir=$ver.$k
part=0
pre=list$DT.$ver
[[ -d $dir ]] || (mkdir $dir; scp -p da5:/da0_data/gather/2303/list$DT.$dir $dir/)
cd $dir
#echo clone > stage.$part
echo clone > stage.$k
cat $pre.$k | sed 's|a:a@||' | while read i; do j=$(echo $i|perl -ane 's|^bb:([^/]+)/|bitbucket.org_$1_|;s|^gl:([^/]+)/|gitlab.com_$1_|;s|^dr:([^/]+)/|drupal.com_$1_|;s|^https://([^/]*)/([^/]*)/|$1_$2_|;s|^https://([^/]*)/|$1_|;s|^gh:([^/]*)/|${1}_|;print'); r=$(echo $i|sed 's|^https://|https://a:a@|'); [[ -d $j ]] || git clone --mirror $r $j; done &
cat $pre.$k | sed 's|a:a@||' |while read i; do j=$(echo $i|perl -ane 's|^bb:([^/]+)/|bitbucket.org_$1_|;s|^gl:([^/]+)/|gitlab.com_$1_|;s|^dr:([^/]+)/|drupal.com_$1_|;s|^https://([^/]*)/([^/]*)/|$1_$2_|;s|^https://([^/]*)/|$1_|;s|^gh:([^/]*)/|${1}_|;print'); r=$(echo $i|sed 's|^https://|https://a:a@|'); [[ -d $j ]] || git clone --mirror $r $j; done &
tac $pre.$k | sed 's|a:a@||' |while read i; do j=$(echo $i|perl -ane 's|^bb:([^/]+)/|bitbucket.org_$1_|;s|^gl:([^/]+)/|gitlab.com_$1_|;s|^dr:([^/]+)/|drupal.com_$1_|;s|^https://([^/]*)/([^/]*)/|$1_$2_|;s|^https://([^/]*)/|$1_|;s|^gh:([^/]*)/|${1}_|;print'); r=$(echo $i|sed 's|^https://|https://a:a@|'); [[ -d $j ]] || git clone --mirror $r $j; done &
tac $pre.$k | sed 's|a:a@||' | while read i; do j=$(echo $i|perl -ane 's|^bb:([^/]+)/|bitbucket.org_$1_|;s|^gl:([^/]+)/|gitlab.com_$1_|;s|^dr:([^/]+)/|drupal.com_$1_|;s|^https://([^/]*)/([^/]*)/|$1_$2_|;s|^https://([^/]*)/|$1_|;s|^gh:([^/]*)/|${1}_|;print'); r=$(echo $i|sed 's|^https://|https://a:a@|'); [[ -d $j ]] || git clone --mirror $r $j; done &
wait

cat $pre.$k | sed 's|a:a@||' | while read i; 
do r=$(echo $i|perl -ane 's|^bb:([^/]+)/|bitbucket.org_$1_|;s|^gl:([^/]+)/|gitlab.com_$1_|;s|^dr:([^/]+)/|drupal.com_$1_|;s|^https://([^/]*)/([^/]*)/|$1_$2_|;s|^https://([^/]*)/|$1_|;s|^gh:([^/]*)/|${1}_|;print'); \
	[[ -d $r ]] && echo $r; done > ${pre}1.$k
cat $pre.$k | perl -ane '$a=$_;s|^bb:([^/]+)/|bitbucket.org_$1_|;s|^gl:([^/]+)/|gitlab.com_$1_|;s|^dr:([^/]+)/|drupal.com_$1_|;s|^https://([^/]*)/([^/]*)/|$1_$2_|;s|^https://([^/]*)/|$1_|;s|\n$||;s|^gh:([^/]*)/|${1}_|;print "$_;$a"' | \
   lsort 1M -u -t\; -k1,1 | join -t\; -v1 - <(lsort 1M -u -t\; -k1,1 ${pre}1.$k) | grep -Ev ';(gl|bb):' | lsort 1M -t\; -R -k1,1  > miss.$k
cat miss.$k |sed 's|a:a@||' | while IFS=\; read d r; do r=$(echo $r|sed 's|^https://|https://a:a@|'); git clone --mirror $r.git $d; done
cut -d\; -f1 miss.$k | while read r; 
do [[ -d $r ]] && echo $r
done >> ${pre}1.$k

#echo list > stage.$part
echo list > stage.$k
#awk '{print $2}' ${pre}.$k.s > ${pre}.$k
cat ${pre}1.$k | while read i; do [[ -f $i/packed-refs ]] && echo $i/packed-refs;done | cpio -o | gzip > ../${pre}.$k.cpio.gz

rsync -av ../${pre}.$k.cpio.gz list$DT.*  da7:/mnt/corrino/data/All.blobs/home/update/V.$k/ &

listBatch.sh $k

cat  ${pre}1.$k | while read i; do [[ -d "$i" ]] && find "$i" -delete; done &

echo COPY > stage

rsync -av  ../${pre}.$k.cpio.gz list$DT.* *.olist.gz  *.{tag,tree,commit,blob}.{idx,bin} da7:/mnt/corrino/data/All.blobs/home/update/V.$k/

wait

echo DONE > stage
