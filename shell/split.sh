# split /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/us-northeast.csv -l 2000000 -d --verbose /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/nechunk/ne -a2

# split /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/us-west.csv -l 2000000 -d --verbose /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/wechunk/we -a3

split /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/us-south.csv -l 2000000 -d --verbose /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/sochunk/so -a3

# split /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/us-midwest.csv -l 2000000 -d --verbose /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/mwchunk/mw -a2

# cd /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/wechunk/
# find . -type f -exec mv '{}' '{}'.csv \;

cd /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/sochunk/
find . -type f -exec mv '{}' '{}'.csv \;

# cd /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/mwchunk/
# find . -type f -exec mv '{}' '{}'.csv \;


# for ((  i = 1 ;  i <= 9;  i++  ))
# do
#   mv /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/so0$i /mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/so$i.csv 
#   echo "Welcome $i times"
# done



