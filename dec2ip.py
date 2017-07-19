#!/usr/bin/env python

import socket, struct
import sys
import logging

def dec2ip():
    try:
        output_ip = socket.inet_ntoa(struct.pack('!L', int(sys.argv[1])))
        print output_ip
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))

dec2ip()
