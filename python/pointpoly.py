import sys
# from shapely.geometry import Polygon, Point, MultiPoint
import timeit
import ogr
import csv
import os
from math import floor

''' This script takes a shape file intersects it with an OSM changeset file '''

# some global variables are set here
start = timeit.default_timer()

# insert path for your shapefile here
filename = '/mnt/nfs6/wikipedia.proj/osm/rawdata/usa/msa.shp'

# load the shape file as a layer
drv = ogr.GetDriverByName('ESRI Shapefile')
ds_in = drv.Open(filename)

if ds_in is None:
    print 'Could not open %s' % (filename)
else:
    print 'Opened %s' % (filename)
    lyr_in = ds_in.GetLayer(0)
    featureCount = lyr_in.GetFeatureCount()
    print "Number of features in %s: %d" % (os.path.basename(filename),featureCount)

# field index for which i want the data extracted 
# ("FIPS_CNTRY" was what i was looking for)
idx_reg = lyr_in.GetLayerDefn().GetFieldIndex("id")

def check(lon, lat):
    # create point geometry
    pt = ogr.Geometry(ogr.wkbPoint)
    pt.SetPoint_2D(0, lon, lat)
    lyr_in.SetSpatialFilter(pt)

    # go over all the polygons in the layer see if one include the point
    for feat_in in lyr_in:
        # roughly subsets features, instead of go over everything
        ply = feat_in.GetGeometryRef()
        if ply.Contains(pt):
            return feat_in.GetFieldAsString(idx_reg)

def writelog(logfileh, data):
    logfileh.write(data + "\n")

def geocode(line):

    pt_lon = float(line['v3']) ## v3 --> lon
    pt_lat = float(line['v4']) ## v4 --> lat

    # TODO: it should geocode both msa and county at once

    fips= check(pt_lon, pt_lat)

    if fips != None:
        print "found fips" + fips
        line['fips'] = fips

    return line

def main(pointfile, outfilestub, startflag=0, step=10):

    startflag = (startflag-1) * 1000
    outfile = outfilestub + "_" + str(startflag) + "-" + str(startflag+step) + ".csv"
    count = startflag 
    logfile = outfilestub + "_" + str(startflag) + "-" + str(startflag+step) + ".log"
    logfileh = open(logfile, "w")

    with open(pointfile) as infileh:

        csvreader = csv.DictReader(infileh, delimiter = "\t")
        fields = csvreader.fieldnames

        for _ in xrange(startflag):
            next(csvreader)

        with open(outfile, "w") as fileh:
            csvwriter = csv.DictWriter(fileh, fields, delimiter="\t")
            
            for line in csvreader:
                count += 1
                if count < startflag + step:

                    if line['class'] == "both":
                        print "already geocoded: " + line['geoid10'] + "\t" + line['fips']
                    else:
                        # print "geocoding now ..."
                        line = geocode(line)

                    if (count % 1000) == 0:
                        stop = timeit.default_timer()
                        writelog(logfileh, str(round(stop-start,2)) + "(s) -- Finished " + str(count)) 
                    
                    csvwriter.writerow(line)

                elif count > startflag + step:
                    break

    stop = timeit.default_timer()
    writelog(logfileh, "\n\nwrote " + str(count) + " items in " +  str(stop-start) + "(s)")
    print "\n\nwrote " + str(count) + " items in " +  str(stop-start), "(s)"
    logfileh.close()

if __name__ == "__main__":

    ## this is where you set your input and output files. 
    ## use the other script in this package to convert changesets to csv
    pointfile = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/x_tmp.csv"

    # specify start and end points here.
    startflag = int(sys.argv[1].strip())
    step = int(sys.argv[2].strip())

    print "starting"

    # testing output file
    outfilestub = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/ne"

    main(pointfile, outfilestub, startflag, step)    


