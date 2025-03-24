#!/usr/bin/env python3
''' Windows Product Key Parser '''
import argparse
import sys
from binascii import unhexlify
from Registry import Registry

__version__ = '1.0.0'


def read_key(all_args):
    ''' Load the SOFTWARE hive and read proper key '''
    hive = Registry.Registry(all_args['reg'])
    key = hive.open("Microsoft\\Windows NT\\CurrentVersion")
    dig_prod_id = key.value('DigitalProductId')
    curr_ver = key.value('CurrentVersion')
    dig_prod_data = dig_prod_id.value()
    win_ver = curr_ver.value()
    major_ver = int(win_ver.split('.')[0])
    minor_ver = int(win_ver.split('.')[1])
    parse_value(dig_prod_data, major_ver, minor_ver, all_args)


def parse_value(dig_prod_data, major_ver, minor_ver, all_args):
    ''' Determine Windows version and parse accordingly '''
    key_offset = 52
    key_output = []
    key_chars = "BCDFGHJKMPQRTVWXY2346789"
    hex_val = bytes.hex(dig_prod_data)
    id_list = list(unhexlify(hex_val))
    if (major_ver == 6 and minor_ver >= 2) or major_ver > 6:
        if not all_args['V']:
            os_ver = ''
        else:
            os_ver = f" - Windows 8 and above - {major_ver}.{minor_ver}"
        file_index = 24
        win_8_above = (id_list[66] // 6) & 1
        id_list[66] = ((id_list[66] & 0xf7) | (win_8_above & 2) * 4)
        n_split = 0
        while file_index >= 0:
            idx_pos = 0
            start_pos = 14
            while start_pos >= 0:
                idx_pos = idx_pos * 256
                idx_pos = id_list[start_pos + key_offset] + idx_pos
                id_list[start_pos + key_offset] = (idx_pos // 24)
                idx_pos = idx_pos % 24
                n_split = idx_pos
                start_pos = start_pos - 1
            file_index = file_index - 1
            key_output.insert(0, key_chars[idx_pos])
        if n_split == 1:
            key_left = ''.join(key_output[1]) + 'N'
        else:
            key_left = ''.join(key_output[1:n_split + 1]) + 'N'
        key_right = key_output[(n_split + 1):]
        key_output = f"{''.join(key_left)}{''.join(key_right)}"
    else:
        if not all_args['V']:
            os_ver = ''
        else:
            os_ver = f" - Windows 7 and below - {major_ver}.{minor_ver}"
        file_index = 28
        while file_index >= 0:
            idx_pos = 0
            start_pos = 14
            while start_pos >= 0:
                idx_pos = idx_pos * 256
                idx_pos = id_list[start_pos + key_offset] + idx_pos
                id_list[start_pos + key_offset] = (idx_pos // 24) & 255
                idx_pos = idx_pos % 24
                start_pos = start_pos - 1
            file_index = file_index - 1
            key_output.insert(0, key_chars[idx_pos])
            if ((29 - file_index) % 6) == 0 and file_index != - 1:
                file_index = file_index - 1
    key_output = f"{''.join(key_output[0:5])}-"\
                f"{''.join(key_output[5:10])}-"\
                f"{''.join(key_output[10:15])}-"\
                f"{''.join(key_output[15:20])}-"\
                f"{''.join(key_output[20:])}"\
                f"{os_ver}"

    print(key_output)


def main():
    ''' Argument Parsing '''
    arg_parse = argparse.ArgumentParser(
        description='Windows Product Key Extractor v'
        + str(__version__),
        formatter_class=argparse.RawTextHelpFormatter)
    arg_parse.add_argument('reg',
                           help='SOFTWARE registry hive')
    arg_parse.add_argument('-V', help='verbose mode, display OS',
                           action='store_true')
    if len(sys.argv[1:]) == 0:
        arg_parse.print_help()
        arg_parse.exit()

    args = arg_parse.parse_args()
    all_args = vars(args)
    read_key(all_args)


if __name__ == '__main__':
    main()
