#!/usr/bin/env python3

"""
This script will ingest a text file with IP addresses (one per line) and present
a GeoLite2 City map for geolocation. Requires the GeoLite2-City.mmdb file. 
Without the -d option, will assume the DB is in the current directory with this script.
With the -d option, you can specify the location of the DB.
"""
from argparse import ArgumentParser
import sys
import geoip2.database
import warnings
warnings.filterwarnings("ignore", category=UserWarning)
import folium

__author__ = 'Corey Forman'
__date__ = '23 Feb 2020'
__version__ = '1.1'
__description__ = 'IP address Geolocation visualization tool'

def createMap(infile, dbfile):
    reader = geoip2.database.Reader(dbfile)
    ip_addresses = open(infile, 'r+').read().splitlines()
    ip_map = folium.Map()
    for ip_address in ip_addresses:
        record = reader.city(ip_address)
        if record.location.latitude:
            popup = folium.Popup(ip_address)
            marker = folium.Marker([record.location.latitude,record.location.longitude],popup=popup)
            ip_map.add_child(marker)
    ip_map.save("index.html")
    print("[*] Finished creating map!")
        
if __name__ == "__main__":
    arg_parse = ArgumentParser(description="GeoIP Map creation", epilog="This script will generate a geolocation IP visualization map")
    arg_parse.add_argument("-i", metavar="<input_file>", help="Input file containing IP's on individual lines", required=True)
    arg_parse.add_argument("-d", metavar="<database>", help="GeoIP MMDB file", default="GeoLite2-City.mmdb")
    arg_parse.add_argument("-v", action="version", version='%(prog)s' + ' v' + str(__version__))
    args = arg_parse.parse_args()
    
    try:
        createMap(args.i, args.d)
    except IOError as e:
        print("Unable to read '%s': %s" % (args.i, e), file==sys.stderr)
        raise SystemExit(1)
    