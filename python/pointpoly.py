import sys
# from shapely.geometry import Polygon, Point, MultiPoint
import timeit
# import ogr
import csv
import os
from math import floor

''' This script takes a shape file intersects it with an OSM changeset file '''

# some global variables are set here
start = timeit.default_timer()

# insert path for your shapefile here
filename = '/mnt/nfs6/wikipedia.proj/osm/rawdata/usa/msa.shp'

# load the shape file as a layer
# drv = ogr.GetDriverByName('ESRI Shapefile')
# ds_in = drv.Open(filename)

# if ds_in is None:
#     print 'Could not open %s' % (filename)
# else:
#     print 'Opened %s' % (filename)
#     lyr_in = ds_in.GetLayer(0)
#     featureCount = lyr_in.GetFeatureCount()
#     print "Number of features in %s: %d" % (os.path.basename(filename),featureCount)

# field index for which i want the data extracted 
# ("FIPS_CNTRY" was what i was looking for)
# idx_reg = lyr_in.GetLayerDefn().GetFieldIndex("id")

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

def readtilefile(infile):

    lookup = []
    with open(infile) as infileh:
        csvreader = csv.DictReader(infileh, delimiter = "\t", quotechar = '"')
        fields = csvreader.fieldnames
        cnt = 0
        for line in csvreader:
            lookup.append(line)
            cnt = cnt+1
            if cnt > 999999999: break
    return lookup

def writelog(logfileh, data):
    logfileh.write(data + "\n")

def gettile(lon, lat, lookup):
    lon_tmp = 0.01 * floor(lon/0.01)
    lat_tmp = 0.01 * floor(lat/0.01)
    tilename = str(lon_tmp) + " / " + str(lat_tmp)
    
    for item in lookup:
        if item["tilename"] == tilename:
            return item

def main(pointfile, outfilestub, lookup, startflag=0, step=10):

    startflag = (startflag-1) * 1000
    outfile = outfilestub + "_" + str(startflag) + "-" + str(startflag+step) + ".csv"
    count = startflag 
    logfile = outfilestub + "_" + str(startflag) + "-" + str(startflag+step) + ".log"
    logfileh = open(logfile, "w")

    with open(pointfile) as infileh:

        csvreader = csv.DictReader(infileh, delimiter = "\t")
        fields = csvreader.fieldnames
        fields.extend(['fips','geoid10', 'countyname', 'msaname'])
        
        for _ in xrange(startflag):
            next(csvreader)

        with open(outfile, "w") as fileh:
            csvwriter = csv.DictWriter(fileh, fields, delimiter="\t")

            for line in csvreader:
                count += 1
                if count < startflag + step:

                    pt_lon = float(line['@lon'])
                    pt_lat = float(line['@lat'])
                    
                    tile = gettile(pt_lon, pt_lat, lookup)
                    if tile != None:
                        line['geoid10'] = tile['geoid10'] 
                        line['fips'] = tile['fips'] 
                        line['msaname'] = tile['msaname'] 
                        line['countyname'] = tile['countyname'] 
                    else:
                        line['geoid10'] = "na"
                        line['fips'] = "na" 
                        line['msaname'] = "na" 
                        line['countyname'] = "na" 

                    # line['id'] = check(pt_lon, pt_lat)

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
    pointfile = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/us-northeast.csv"

    # specify start and end points here.
    startflag = int(sys.argv[1].strip())
    step = int(sys.argv[2].strip())

    # testing output file
    outfilestub = "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/ne"

    lookup = readtilefile("/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/tilelookup.csv")
    print "lookup finished slurping"
    
    # print gettile(-100.599, 40.203, lookup)

    main(pointfile, outfilestub, lookup, startflag, step)    


