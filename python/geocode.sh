#!/bin/bash

#$ -cwd
#$ -j y
#$ -q all.q

#$ -l rh6=TRUE
#$ -t 1-2160

# 2160 is upper limit

source /mnt/nfs6/wikipedia.proj/gdalvenv/bin/activate
export LD_LIBRARY_PATH=/mnt/nfs6/wikipedia.proj/gdalvenv/lib:$LD_LIBRARY_PATH

python /mnt/nfs6/wikipedia.proj/jmp/jmpscripts/python/pointpoly.py $SGE_TASK_ID 10000 ne
