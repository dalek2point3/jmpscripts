#!/bin/bash

source /mnt/nfs6/wikipedia.proj/gdalvenv/bin/activate
export LD_LIBRARY_PATH=/mnt/nfs6/wikipedia.proj/gdalvenv/lib:$LD_LIBRARY_PATH

for ((  i = 0 ;  i <= 104;  i++  ))
do
    fname=$(printf "%03d" $i)
    echo "now processing $i"
    qsub -b y -cwd stata -b do /mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/match.do $fname we
done

# rm /mnt/nfs6/wikipedia.proj/jmp/jmpscripts/shell/stata*

