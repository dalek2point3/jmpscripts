#!/bin/bash

#$ -cwd
#$ -j y
#$ -q all.q

#$ -l rh6=TRUE
#$ -t 1-488

source /mnt/nfs6/wikipedia.proj/gdalvenv/bin/activate
export LD_LIBRARY_PATH=/mnt/nfs6/wikipedia.proj/gdalvenv/lib:$LD_LIBRARY_PATH

## 488
python /mnt/nfs6/wikipedia.proj/jmp/jmpscripts/python/pointpoly_hist.py $SGE_TASK_ID 100000 way
##python /mnt/nfs6/wikipedia.proj/jmp/jmpscripts/python/pointpoly_hist.py $SGE_TASK_ID 100 way
