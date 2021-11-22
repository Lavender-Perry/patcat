#!/usr/bin/env python3
from enum import IntEnum
from sys import stdin, stderr
from string import whitespace
import argparse
import os

class ColorInfo(IntEnum):
    AMOUNT = 299 # Amount of colors to be outputted (must not be higher than PER_STAGE)
    MAX_RGB_VALUE = 255 # Max value any r/g/b can have
    # Do not change these next 2
    PER_STAGE = (AMOUNT + 1) // 3
    MIN_RGB_VALUE = MAX_RGB_VALUE - PER_STAGE

# If the program is using too much memory, try decreasing this value
# If some text is getting cut off, try increasing this value
bytes_to_read = 1000000

first_file = True

line_str = lambda line: str(line).rjust(8, ' ') + ' '
color_print = lambda red, green, blue, string: print(
        "\x1b[38;2;%d;%d;%dm%s" % (red, green, blue, string),
        end='')

parser = argparse.ArgumentParser(description="Output text from files with color.")
parser.add_argument(
        "paths",
        type=str,
        nargs='*',
        help="a path to open ('-' for stdin)",
        default=['-'])
parser.add_argument(
        "-n", "--number",
        help="number all output lines",
        action="store_true")
args = parser.parse_args()


line = 1 if args.number else False

# Windows command prompt / powershell support
if os.name == "nt":
    os.system('')

for path in args.paths:
    try:
        file = stdin if path == '-' else open(path, 'r')
        read_result = file.read(bytes_to_read)
    except Exception as e:
        print(f"Error reading {path}: {e}", file=stderr)
        continue

    changes = len(list(filter(lambda c: not c in whitespace, read_result))) - 1

    step = 0 if changes == 0 else ColorInfo.AMOUNT / changes
    index = 0

    if line and first_file:
        color_print(
                ColorInfo.MAX_RGB_VALUE,
                ColorInfo.MIN_RGB_VALUE,
                ColorInfo.MIN_RGB_VALUE,
                line_str(line))


    for char in read_result:
        if char in whitespace:
            print(char, end='')
            if line and char == '\n':
                line += 1
                print(line_str(line), end='')
            continue

        color_value = round(index)
        value_modifier = color_value % ColorInfo.PER_STAGE
        rgb_values = [
            ColorInfo.MIN_RGB_VALUE + value_modifier,
            ColorInfo.MAX_RGB_VALUE - value_modifier,
            ColorInfo.MIN_RGB_VALUE,
        ]
        [red, green, blue] = [
            [rgb_values[1], rgb_values[0], rgb_values[2]],
            rgb_values[::-1],
            [rgb_values[0], rgb_values[2], rgb_values[1]],
        ][color_value // ColorInfo.PER_STAGE]

        color_print(red, green, blue, char)
        index += step
print("\x1b[0m")
