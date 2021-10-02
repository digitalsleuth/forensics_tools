#!/usr/bin/env python3

"""
This script is designed to ingest JSON data from the exported Google Location json file
from a Google Takeout export. When using Google to track your location, this data is saved and 
can be exported from your profile.

Only input required is the json file, will export a CSV and a KML file which can be imported into
Google Maps (maps.google.com -> Your Places -> Maps -> Create Map - Import) or Google Earth Pro
(both CSV and KML files).

"""
from argparse import ArgumentParser, RawTextHelpFormatter
import json
import csv
from datetime import datetime as dt
import os, sys

__author__ = 'Corey Forman'
__date__ = '22 Dec 2019'
__version__ = '1.0'
__description__ = 'Google Location JSON parser'


def ingest(json_file):
    results = json.load(json_file)
    return results

def export_csv(parsed_json, out_csv):
    fieldnames=["latitude","longitude","unix_ms_timestamp","timestamp_converted_UTC"]
    writer = csv.DictWriter(out_csv, fieldnames)
    writer.writeheader()
    for location in parsed_json['locations']:
        converted_time = dt.utcfromtimestamp(int(location['timestampMs'])/1000).strftime('%Y-%m-%d' + 'T' + '%H:%M:%S.%f' + 'Z') # Resulting date is YYYY-MM-DD HH:MM:SS
        row={}
        row['latitude'] = (float(location['latitudeE7']) / 10000000 )
        row['longitude'] = (float(location['longitudeE7']) / 10000000)
        row['unix_ms_timestamp'] = (float(location['timestampMs']))
        row['timestamp_converted_UTC'] = converted_time
        writer.writerow(row)
    return writer

def export_kml(parsed_json, out_kml):
    header = ["<?xml version='1.0' encoding='UTF-8'?>\n","<kml xmlns='http://www.opengis.net/kml/2.2' xmlns:gx='http://www.google.com/kml/ext/2.2'>\n"," <Document>\n","  <name>Google KML Output from JSON</name>\n","  <Placemark>\n","   <open>1</open>\n","   <gx:Track>\n","    <altitudeMode>clampToGround</altitudeMode>\n"]
    footer = ["   </gx:Track>\n","  </Placemark>\n"," </Document>\n","</kml>"]
    for field in header:
        out_kml.write(field)
    open_coord = "    <gx:coord>"
    closed_coord = " 0</gx:coord>\n"
    open_when = "    <when>"
    closed_when = "</when>\n"
    for item in parsed_json['locations']:
        converted_time = dt.utcfromtimestamp(int(item['timestampMs'])/1000).strftime('%Y-%m-%d' + 'T' + '%H:%M:%S.%f' + 'Z')
        longitude = (float(item['longitudeE7']) / 10000000)
        latitude = (float(item['latitudeE7']) / 10000000)
        coord_output = open_coord + str(longitude) + ' ' + str(latitude) + closed_coord
        when_time = open_when + converted_time + closed_when
        out_kml.write(when_time)
        out_kml.write(coord_output)
    for field in footer:
        out_kml.write(field)
    return out_kml

def main():
    cwd = os.getcwd()
    arg_parse = ArgumentParser(description="Google Location JSON Parser", epilog="This script will parse out the geo-location information including timestamps,\nfrom the Google Location History JSON file exported from a user's profile.", formatter_class=RawTextHelpFormatter)
    arg_parse.add_argument("-i", metavar="<json_file>", help="Input file including path (if necessary)", required=True)
    arg_parse.add_argument("-o", metavar="<output_directory>", help="Output directory, default is " + cwd + ".", default=(cwd + "\\"))
    arg_parse.add_argument("-v", action="version", version='%(prog)s' +' v' + str(__version__))
    args = arg_parse.parse_args()

    try:
        input_file = open(args.i, 'rb')
        output_csv = open(args.o + 'google_location.csv', 'w', newline='')
        output_kml = open(args.o + 'google_location.kml', 'w')
    except IOError as e:
        print("Unable to read '%s': %s" % (args.i, e), file=sys.stderr)
        raise SystemExit(1)

    try:
        if args.i:
            input_json = ingest(input_file)
            processed_csv = export_csv(input_json, output_csv)
            processed_kml = export_kml(input_json, output_kml)
            try:
                output_csv.close()
                output_kml.close()
                print("Files: google_location.csv and google_location.kml successfully written.")
            except IOError as e:
                print("Unable to write out: %s" % (e), file=sys.stderr)
        else:
            print("Please select the -i parameter and provide an input file for processing.")
            raise SystemExit(0)
    except Exception as e:
        print("Unable to perform operations on file '%s': %s" % (args.i, e), file=sys.stderr)

if __name__ == '__main__':
    main()
