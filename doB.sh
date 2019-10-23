#!/bin/bash
k=$1
ver=Q
DT=201910
pre=list$DT.$ver



#scp -p da5:/data/update/$ver.$i/todo $ver.$i

cd $ver.$i
sed "s/NNN/$i/g" ~/lookup/run.pbs | qsub
