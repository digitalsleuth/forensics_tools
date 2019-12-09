#!/usr/bin/env python

"""
The only purpose of this tool is to assist in parsing data blocks in applications or 
data blobs which may contain either the decimal or hex version of an IP address and
a port.

It's original intent was to serve some intermediate needs while doing script building.
"""
import socket, struct, sys
import logging
from argparse import ArgumentParser

__author__ = 'Corey Forman'
__date__ = '8 Dec 2019'
__version__ = '1.0'
__description__ = 'IP/Decimal/Hex conversion tool'

def ip2dec(ip):
    try:
        dec_out = struct.unpack('!L', socket.inet_aton(str(ip)))[0]
        return str(dec_out)
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)

def dec2ip(dec):
    try:
        output_ip = socket.inet_ntoa(struct.pack('!L', int(dec)))
        return output_ip
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)

def ip2hex(ip):
    try:
        output_hex = format(struct.unpack('!L', (socket.inet_aton(ip)))[0], 'x')
        return output_hex
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)

def hex2dec(hex):
    try:
        output_dec = int(hex, 16)
        return output_dec
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)

def dec2hex(dec):
    try:
        output_hex = format(int(dec), 'x')
        return output_hex
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)

def hex2ip(hex):
    try:
        output_ip = socket.inet_ntoa(struct.pack('!L', int(hex, 16)))
        return output_ip
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)


if __name__ == "__main__":
    arg_parse = ArgumentParser(description="IP Conversion Toolset")
    arg_parse.add_argument("--decin", help="Convert decimal value")
    arg_parse.add_argument("--ipin",  help="Convert IP address")
    arg_parse.add_argument("--hexin", help="Convert hex value (no leading 0x)")
    arg_parse.add_argument("--decout", action="store_true", help="Convert input to Decimal")
    arg_parse.add_argument("--ipout",  action="store_true", help="Convert input to IP")
    arg_parse.add_argument("--hexout", action="store_true", help="Convert input to Hex")
    arg_parse.add_argument("--all", action="store_true", help="Convert input to all other functions")
    arg_parse.add_argument("-q", action="store_true", help="Quiet mode, only output values, no headers")
    arg_parse.add_argument("-v", action="version", version='%(prog)s' +' v' + str(__version__))
    args = arg_parse.parse_args()
	
    try:
        if args.ipin and args.decout:
            dec_value = ip2dec(args.ipin)
            if args.q:
                print("%s\t%s" % (args.ipin, dec_value))
            else:
                print("IP: %s\tDecimal: %s"  % (args.ipin, dec_value))
        elif args.ipin and args.hexout:
            hex_value = ip2hex(args.ipin)
            if args.q:
                print("%s\t%s" % (args.ipin, hex_value))
            else:
                print("IP: %s\tHex: %s" % (args.ipin, hex_value))
        elif args.decin and args.ipout:
            ip_value = dec2ip(args.decin)
            if args.q:
                print("%s\t%s" % (args.decin, ip_value))
            else:
                print("Decimal: %s\tIP: %s" % (args.decin, ip_value))
        elif args.hexin and args.ipout:
            ip_value = hex2ip(args.hexin)
            if args.q:
                print("%s\t%s" % (args.hexin, ip_value))
            else:
                print("Hex: %s\tIP: %s" % (args.hexin, ip_value))
        elif args.ipin and args.all:
            dec_value = ip2dec(args.ipin)
            hex_value = ip2hex(args.ipin)
            if args.q:
                print("%s\t%s\t%s" % (args.ipin, dec_value, hex_value))
            else:
                print("IP: %s\tDecimal: %s\tHex: %s" % (args.ipin, dec_value, hex_value))
        elif args.decin and args.all:
            ip_value = dec2ip(args.decin)
            hex_value = dec2hex(args.decin)
            if args.q:
                print("%s\t%s\t%s" % (args.decin, ip_value, hex_value))
            else:
                print("Decimal: %s\tIP: %s\tHex: %s" % (args.decin, ip_value, hex_value))
        elif args.hexin and args.all:
            ip_value = hex2ip(args.hexin)
            dec_value = hex2dec(args.hexin)
            if args.q:
                print("%s\t%s\t%s" % (args.hexin, ip_value, dec_value))
            else:
                print("Hex: %s\tIP: %s\tDecimal: %s" % (args.hexin, ip_value, dec_value))
        elif (args.decin and args.decout) or (args.hexin and args.hexout) or (args.ipin and args.ipout):
            print("Cannot process object to itself. Please choose an alternate output method for your input")
            raise SystemExit(1)
        elif len(sys.argv)==1:
            arg_parse.print_help(sys.stderr)
            raise SystemExit(1)
        else:
            print("Please check your command and try again.")
            raise SystemExit(1)
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))
        raise SystemExit(1)