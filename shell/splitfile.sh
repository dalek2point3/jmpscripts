#!/usr/bin/bash

# Configuration stuff

fspec=/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/x_ne.csv
outfile=/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/nechunk/xx_ne
num_files=20

# Work out lines per file.

total_lines=$(cat ${fspec} | wc -l)
((lines_per_file = (total_lines + num_files - 1) / num_files))

# Split the actual file, maintaining lines.

split --lines=${lines_per_file} -d ${fspec} 

# Debug information

echo "Total lines     = ${total_lines}"
echo "Lines  per file = ${lines_per_file}"    
wc -l xx_ne.*


