# forensics_tools
Various short scripts and tools used for Digital Forensics

- ip2dec - Convert an IP Address to a decimal number, commonly used in GeoIP CSV's
- dec2ip - Convert a decimal number to an IP address, for deciphering GeoIP CSV values
- iptools - Convert an IP to decimal or hex, and vice versa.
- pilfer.bat - Incident Response batch file for grabbing relevant available data on a live system.
- vssmount.cmd - A CMD script to be run in Windows to mount the local Volume Shadows, including any mounted devices which have Shadows
- gooloc.py - A Google Location JSON parser to export Google Location data to CSV and KML data.

rawccopy.exe is a pre-built binary from the source code at https://github.com/dr-anoroc/rawccopy and is intended to be used with pilfer, to extract locked files.