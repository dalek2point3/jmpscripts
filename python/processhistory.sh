## ../osmconvert /media/data/rawdata/seattle.osh.pbf > seattle.osh
## ../osmconvert /media/data/rawdata/seattle.osh.pbf --csv="@oname @id @lon @lat @version @timestamp @changeset @uid @user highway name amenity building waterway natural oneway maxspeed place leisure foot access wheelchair cycleway gnis:feature_id gnis:fcode NHD:FCode addr:* import_uuid sidewalk " --csv-headline -o=/media/data/rawdata/seattle.csv --add-bbox-tags --all-to-nodes

## ../osmconvert /media/data/rawdata/mainland-usa.osh.pbf --csv="@oname @id @lon @lat @version @timestamp @changeset @uid @user highway name amenity building waterway natural oneway maxspeed place leisure foot access wheelchair cycleway gnis:feature_id gnis:fcode NHD:FCode addr:* import_uuid sidewalk " --csv-headline --add-bbox-tags --all-to-nodes --max-objects=1000000000 -B=/media/data/rawdata/us-northeast.poly -o=/media/data/rawdata/mainland-usa.csv

../osmconvert /media/data/rawdata/mainland-usa.osh.pbf --csv="@oname @id @lon @lat @version @timestamp @changeset @uid @user highway name amenity building waterway natural oneway maxspeed place leisure foot access wheelchair cycleway gnis:feature_id gnis:fcode NHD:FCode addr:* import_uuid sidewalk " --csv-headline --add-bbox-tags --all-to-nodes --max-objects=1000000000 -B=/media/data/rawdata/poly/us-midwest.poly -o=/media/data/rawdata/us-midwest.csv


# ../osmconvert /media/data/rawdata/mainland-usa.osh.pbf --csv="@oname @id @lon @lat @version @timestamp @changeset @uid @user highway name amenity building waterway natural oneway maxspeed place leisure foot access wheelchair cycleway gnis:feature_id gnis:fcode NHD:FCode addr:* import_uuid sidewalk " --csv-headline --add-bbox-tags --all-to-nodes --max-objects=1000000000 -B=/media/data/rawdata/poly/us-midwest.poly -o=/media/data/rawdata/us-midwest.csv

# echo "finished midwest"

# ../osmconvert /media/data/rawdata/mainland-usa.osh.pbf --csv="@oname @id @lon @lat @version @timestamp @changeset @uid @user highway name amenity building waterway natural oneway maxspeed place leisure foot access wheelchair cycleway gnis:feature_id gnis:fcode NHD:FCode addr:* import_uuid sidewalk " --csv-headline --add-bbox-tags --all-to-nodes --max-objects=1000000000 -B=/media/data/rawdata/poly/us-south.poly -o=/media/data/rawdata/us-south.csv

# echo "finished south"

# ../osmconvert /media/data/rawdata/mainland-usa.osh.pbf --csv="@oname @id @lon @lat @version @timestamp @changeset @uid @user highway name amenity building waterway natural oneway maxspeed place leisure foot access wheelchair cycleway gnis:feature_id gnis:fcode NHD:FCode addr:* import_uuid sidewalk " --csv-headline --add-bbox-tags --all-to-nodes --max-objects=1000000000 -B=/media/data/rawdata/poly/us-west.poly -o=/media/data/rawdata/us-west.csv

# echo "finished west"
