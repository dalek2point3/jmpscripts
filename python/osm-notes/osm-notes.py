#!/usr/bin/env python

"""osm-notes.py : Uses the OpenStreetMap Notes API to Search for Notes that came from Craigslist and writes data to a CSV file"""

__author__      = "dalek2point3"
__copyright__   = "MIT"

import urllib2
from xml.dom import minidom

def get_data(url, fname):
    with open(fname, "wb") as f:
        response = urllib2.urlopen(url)
        f.write(response.read())

def parse_data(fname):
    xmldoc = minidom.parse(fname)
    notes = xmldoc.getElementsByTagName('note')

    data = []

    for note in notes:
        date = note.getElementsByTagName('date_created')[0].childNodes[0].nodeValue
        id = note.getElementsByTagName('id')[0].childNodes[0].nodeValue
        status = note.getElementsByTagName('status')[0].childNodes[0].nodeValue

        lat = note.attributes['lat'].value
        lon = note.attributes['lon'].value
        url = "http://www.openstreetmap.org/note/" +  str(id)

        line = [date, id, lat, lon, url, status]
        data.append(line)

    print len(notes)
    return data

def write_data(data, fname):

    with open(fname, "wb") as f:

        header = ["date", "id","lat","lon", "url", "status"]
        f.write("\t".join(header) + "\n")

        for item in data:
            line = "\t".join(item)
            f.write(line + "\n")

def main():
    closed = "-1"
    limit = "5000"

    # all notes that come from CL have "bounds" in their text
    url = "http://api.openstreetmap.org/api/0.6/notes/search?q=bounds&closed=" + closed + "&limit=" + limit
    get_data(url, "craigslist.xml")
    data = parse_data("craigslist.xml")
    write_data(data, "cl_notes.csv")

if __name__=='__main__':
    main()



    

