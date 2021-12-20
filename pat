#!/usr/bin/env python3
from enum import IntEnum
from sys import argv, stdin, stderr
import argparse
import os
import string


# If the program is using too much memory, try decreasing this value
# If some text is getting cut off, try increasing this value
bytes_to_read = 1000000

first_file = True

line_str = lambda line: str(line).rjust(8, ' ') + ' '
color_print = lambda red, green, blue, string: print(
    f"\x1b[38;2;{red};{green};{blue}m{string}",
    end='')

parser = argparse.ArgumentParser(description="Output text from files with color.")
parser.add_argument("-n", "--number",
        action="store_true",
        help="number all output lines")
parser.add_argument("-m", "--max_rgb_value",
        type=float, nargs='?', default=255,
        help="max value any r/g/b can have. 0 <= argument <= 255")
parser.add_argument("-c", "--color_amount",
        type=int, nargs='?', default=300,
        help="amount of colors to output. arg is divisible by 3, 0 <= arg <= max * 3.")
parser.add_argument("paths",
        nargs='*', default=['-'],
        help="a path to open ('-' for stdin)")

args = parser.parse_args()

# Checking arguments are valid
assert (
        0 <= args.max_rgb_value <= 255 and
        args.color_amount <= args.max_rgb_value * 3 and
        not args.color_amount % 3), f"Invalid arguments.  Run `{argv[0]} -h` for help."

class ColorInfo(IntEnum):
    AMOUNT = args.color_amount
    MAX_RGB_VALUE = args.max_rgb_value
    PER_STAGE = args.color_amount / 3
    MIN_RGB_VALUE = MAX_RGB_VALUE - PER_STAGE

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

    changes = len(list(filter(lambda c: not c in string.whitespace, read_result))) - 1

    step = 0 if changes == 0 else (ColorInfo.AMOUNT - 1) / changes
    index = 0

    if line and first_file:
        color_print(
                ColorInfo.MAX_RGB_VALUE,
                ColorInfo.MIN_RGB_VALUE,
                ColorInfo.MIN_RGB_VALUE,
                line_str(line))


    for char in read_result:
        if char in string.whitespace:
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
