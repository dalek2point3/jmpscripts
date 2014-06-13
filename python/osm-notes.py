import urllib2

def get_data(url, fname):
    with open(fname, "wb") as f:
        response = urllib2.urlopen(url)
        f.write(response.read())

def main():
    url = "http://api.openstreetmap.org/api/0.6/notes/search?q=bounds"
    get_data(url, "test.xml")


if __name__=='__main__':
    main()




    

