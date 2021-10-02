#!/usr/bin/env python3

import socket, struct
import sys
import logging

def ip2dec():
    try:
        input_ip = socket.inet_aton(sys.argv[1])
        dec_out = struct.unpack('!L', input_ip)[0]
        print(dec_out)
    except Exception as e:
        logging.error(str(type(e)) + "," + str(e))

if __name__ == "__main__":
    ip2dec()
