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
        lat = note.attributes['lat'].value
        lon = note.attributes['lon'].value
        line = [date, id, lat, lon]
        data.append(line)

    print len(notes)
    return data

def main():
    closed = "-1"
    limit = "10"
    url = "http://api.openstreetmap.org/api/0.6/notes/search?q=bounds&closed=" + closed + "&limit=" + limit
    # get_data(url, "test2.xml")
    data = parse_data("test2.xml")


if __name__=='__main__':
    main()

## http://api.openstreetmap.org/api/0.6/notes?bbox=-0.65094,51.312159,0.374908,51.669148




    

