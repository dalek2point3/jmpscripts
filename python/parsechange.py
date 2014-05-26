#!/usr/bin/env python
import os
import sys
from lxml import etree
from datetime import datetime
from datetime import timedelta

''' This Program takes in a OSM changeset file in .osm format and spits out a csv'''
''' **** **** **** **** **** **** **** **** **** **** **** **** **** **** **** **'''

def writefile(outfile, line):
    line = [x.replace('"','').strip() for x in line]
    line = [x.replace("'","").strip() for x in line]

    outfile.write("\t".join(line).encode("utf-8") + "\n")

def parseFile(changesetFile):

    with open("/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/tmp.osm","w") as outfile:
        parsedCount = 0
        startTime = datetime.now()
        context = etree.iterparse(changesetFile)
        action, root = context.next()

        print "Parsing started"

        line = ["id","uid","created_at","min_lat","max_lat","min_lon","max_lon","closed_at", "open", "num_changes", "user"]
        writefile(outfile, line)

        for action, elem in context:
            if(elem.tag != 'changeset'):
                continue

            parsedCount += 1

            line = [elem.attrib.get('id','-'), elem.attrib.get('uid', "-"), elem.attrib['created_at'], elem.attrib.get('min_lat', "-"),
                      elem.attrib.get('max_lat', "-"), elem.attrib.get('min_lon', "-"), elem.attrib.get('max_lon', "-"),
                      elem.attrib.get('closed_at', "-"), elem.attrib.get('open', "-"),
                      elem.attrib.get('num_changes', "-"), elem.attrib.get('user', "-")]

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
    with open("/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/tmp.osm") as f:
        parseFile(f)

if __name__ == '__main__':
    main()
