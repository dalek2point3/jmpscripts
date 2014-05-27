import sys
# from shapely.geometry import Polygon, Point, MultiPoint
from datetime import datetime
import timeit
import ogr
import csv
import os
from math import floor

''' This script takes a shape file intersects it with an OSM changeset file '''
''' It produces for each lat/lon point the MSA and the County that the point lies in '''

# some global variables are set here
start = timeit.default_timer()

# some more global

## TODO: remove harcoding

## county
filename_cty = '/mnt/nfs6/wikipedia.proj/osm/rawdata/usa/UScounties.shp'
drv_cty = ogr.GetDriverByName('ESRI Shapefile')
ds_cty = drv_cty.Open(filename_cty)
lyr_cty = ds_cty.GetLayer(0)
index_cty = lyr_cty.GetLayerDefn().GetFieldIndex("fips")

## msa
filename_msa = '/mnt/nfs6/wikipedia.proj/osm/rawdata/usa/cb_2012_us_uac10_500k.shp'
drv_msa = ogr.GetDriverByName('ESRI Shapefile')
ds_msa = drv_msa.Open(filename_msa)
lyr_msa = ds_msa.GetLayer(0)
index_msa = lyr_msa.GetLayerDefn().GetFieldIndex("GEOID10")

print len(lyr_cty), index_cty
print len(lyr_msa), index_msa
##

def check(lon, lat, mode):

    if mode == "cty":
        lyr = lyr_cty
        index = index_cty
    else:
        lyr = lyr_msa
        index = index_msa

    # create point geometry
    pt = ogr.Geometry(ogr.wkbPoint)
    pt.SetPoint_2D(0, lon, lat)
    lyr.SetSpatialFilter(pt)

    # go over all the polygons in the layer see if one include the point
    for feat_in in lyr:
        # roughly subsets features, instead of go over everything
        ply = feat_in.GetGeometryRef()
        if ply.Contains(pt):
            return feat_in.GetFieldAsString(index)

    return "NA"

def writelog(logfileh, data):
    logfileh.write(data + "\n")

def geocode(line):
    
    # latid = 'v3'
    # lonid = 'v4'

    latid = 'lat'
    lonid = 'lon'

    try:
        ## TODO: let this not be hardcoded to line format
        pt_lon = float(line[lonid]) ## v3 --> lon
        pt_lat = float(line[latid]) ## v4 --> lat
    except ValueError:
        return line

    line['fips']= check(pt_lon, pt_lat, "cty")
    line['geoid10']= check(pt_lon, pt_lat, "msa")

    return line

    # if line['fips'] == '' :
    # if line['geoid10'] == '' :


def main(pointfile, outfilestub, startflag=0, step=10):

    startflag = (startflag-1) * 10000
    outfile = outfilestub + "_" + str(startflag) + "-" + str(startflag+step) + ".csv"
    count = startflag 
    logfile = outfilestub + "_" + str(startflag) + "-" + str(startflag+step) + ".log"
    logfileh = open(logfile, "w")
    starttime = str(datetime.now())

    with open(pointfile) as infileh:

        csvreader = csv.DictReader(infileh, delimiter = "\t")
        fields = csvreader.fieldnames
        fields.append('fips')
        fields.append('geoid10')

        for _ in xrange(startflag):
            next(csvreader)

        with open(outfile, "w") as fileh:
            csvwriter = csv.DictWriter(fileh, fields, delimiter="\t")

            for line in csvreader:
                count += 1
                if count < startflag + step:

                    # if line['class'] == "both":
                    #    pass
                    # else:
                    line = geocode(line)

                    if (count % 1000) == 0:
                        stop = timeit.default_timer()
                        writelog(logfileh, str(round(stop-start,2)) + "(s) -- Finished " + str(count)) 
                    
                    try:
                        csvwriter.writerow(line)
                    except TypeError:
                        writelog(logfileh, "problem with writing line, skipped" + str(count))

                elif count > startflag + step:
                    break

    stop = timeit.default_timer()
    writelog(logfileh, "\n\nwrote " + str(count) + " items in " +  str(stop-start) + "(s) between " + starttime + " and " + str(datetime.now()))
    print "\n\nwrote " + str(count) + " items in " +  str(stop-start), "(s)"
    logfileh.close()

if __name__ == "__main__":

    ## this is where you set your input and output files. 
    ## use the other script in this package to convert changesets to csv
    ## pointfile = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/x_tmp.csv"
    pointfile = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/changesets-may26-usa.csv"

    # specify start and end points here.
    startflag = int(sys.argv[1].strip())
    step = int(sys.argv[2].strip())
    region = sys.argv[3].strip()

    # pointfile = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/x_"+region+".csv"

    region = "change"
    print "starting at:" + str(datetime.now())

    # testing output file
    outfilestub = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/" + region

    # setup envt
    os.system("source /mnt/nfs6/wikipedia.proj/gdalvenv/bin/activate")
    os.system("export LD_LIBRARY_PATH=/mnt/nfs6/wikipedia.proj/gdalvenv/lib:$LD_LIBRARY_PATH")


    main(pointfile, outfilestub, startflag, step)    


