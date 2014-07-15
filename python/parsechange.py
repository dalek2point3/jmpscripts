#!/usr/bin/env python
import os
import sys
from lxml import etree
from datetime import datetime
from datetime import timedelta

''' This Program takes in a OSM changeset file in .osm format and spits out a csv'''
'''       you can also specify a BBOX if you want to clip the output             '''
''' **** **** **** **** **** **** **** **** **** **** **** **** **** **** **** **'''

def writefile(outfile, line):
    line = [x.replace('"','').strip() for x in line]
    line = [x.replace("'","").strip() for x in line]
    line = [x.replace("\t","").strip() for x in line]

    outfile.write("\t".join(line).encode("utf-8") + "\n")

def parseFile(changesetFile, bbox):

    with open("/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/changesets-may26-usa.csv","w") as outfile:
        parsedCount = 0
        startTime = datetime.now()
        context = etree.iterparse(changesetFile)
        action, root = context.next()

        print "Parsing started"

        line = ["id","uid","created_at","min_lat","max_lat","min_lon","max_lon","closed_at", "open", "num_changes", "user", "lat", "lon"]
        writefile(outfile, line)

        for action, elem in context:
            if(elem.tag != 'changeset'):
                continue

            parsedCount += 1

            line = [elem.attrib.get('id','-'), elem.attrib.get('uid', "-"), elem.attrib['created_at'], elem.attrib.get('min_lat', "-"),
                      elem.attrib.get('max_lat', "-"), elem.attrib.get('min_lon', "-"), elem.attrib.get('max_lon', "-"),
                      elem.attrib.get('closed_at', "-"), elem.attrib.get('open', "-"),
                      elem.attrib.get('num_changes', "-"), elem.attrib.get('user', "-")]

            try:
                point_lat = (float(line[3]) + float(line[4])) / 2
                point_lon = (float(line[5]) + float(line[6])) / 2
            except ValueError:
                ## sometimes lat / lon are not present
                point_lat = 1000
                point_lon = 1000

            ## bbox = [-125, 24.34, -66.9, 49.4]

            if (point_lon > bbox[0] and point_lon < bbox[2]):
                if(point_lat > bbox[1] and point_lat < bbox[3]):
                    line.append(str(point_lat))
                    line.append(str(point_lon))
                    writefile(outfile, line)

            if((parsedCount % 100000) == 0):
                print "parsed {0}".format(parsedCount)
                print "time passed {0} secs.".format(datetime.now()-startTime)
                print

            #clear everything we don't need from memory to avoid leaking
            elem.clear()
            while elem.getprevious() is not None:
                del elem.getparent()[0]

    print "parsing complete"
    print "parsed {0}".format(parsedCount)

def main():
    ## this is where you put the path to the changesets file
    with open("/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/changesets-latest.osm") as f:
        bbox = [-125, 24.34, -66.9, 49.4]
        bbox = [-200, -200, 200, 200]
        parseFile(f, bbox)

if __name__ == '__main__':
    main()
