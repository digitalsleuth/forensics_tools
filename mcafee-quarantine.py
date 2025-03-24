#!/usr/bin/python3

#This little script is meant to assist in the recovery of files from the McAfee Quarantine .bup 'format'.
#It essentially xor's the contents of the bup file (Details and File_0) with 0x6A

#Provided by Corey Forman (fetchered [at] gmail [dot] com)

import sys

def xor():
    try:
        byte=bytearray(open(sys.argv[1], 'rb').read())
        for i in range(len(byte)):
            byte[i] ^= 0x6A
        open(sys.argv[2], 'wb').write(byte)
    except:
        print('\033[1;31m[!] Check your inputs and try again\033[1;31m')

if __name__ == "__main__":
    xor()
