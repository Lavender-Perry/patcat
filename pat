#!/usr/bin/env python3
from sys import argv, stdin
from string import whitespace
import argparse
import os

# If the program is using too much memory, try decreasing this value
# If some text is getting cut off, try increasing this value
bytes_to_read = 1000000

line_str = lambda line: str(line).rjust(6, " ") + "  "
color_print = lambda red, green, blue, string: print(
    f"\033[38;2;{red};{green};{blue}m{string}", end=""
)

parser = argparse.ArgumentParser(description="Output text from files with color.")
parser.add_argument(
    "-n", "--number", action="store_true", help="number all output lines"
)
parser.add_argument(
    "-m",
    "--max_rgb_value",
    type=float,
    nargs="?",
    default=255,
    help="max value any r/g/b can have. 0 <= argument <= 255",
)
parser.add_argument(
    "-c",
    "--color_amount",
    type=int,
    nargs="?",
    default=300,
    help="amount of colors to output. arg is divisible by 3, 0 <= arg <= max * 3.",
)
parser.add_argument(
    "paths", nargs="*", default=["-"], help="a path to open ('-' for stdin)"
)

args = parser.parse_args()

# Checking arguments are valid
assert (
    0 <= args.max_rgb_value <= 255
    and args.color_amount <= args.max_rgb_value * 3
    and not args.color_amount % 3
), f"Invalid arguments.  Run `{argv[0]} -h` for help."

colors_per_stage = args.color_amount // 3
min_rgb_value = args.max_rgb_value - colors_per_stage
line = 1 if args.number else False
line_print_pending = False

# Windows command prompt / powershell support
if os.name == "nt":
    os.system("")

for path in args.paths:
    with stdin if path == "-" else open(path, "r") as file:
        read_result = file.read(bytes_to_read)
        changes = len(list(filter(lambda c: not c in whitespace, read_result))) - 1
        step = 0 if changes == 0 else (args.color_amount - 1) / changes
        index = 0

        if line:
            color_print(
                args.max_rgb_value, min_rgb_value, min_rgb_value, line_str(line)
            )

        for char in read_result:
            if line_print_pending:
                print(line_str(line), end="")
                line_print_pending = False

            if char in whitespace:
                print(char, end="")
                if line and char == "\n":
                    line += 1
                    line_print_pending = True
                continue

            color_value = round(index)
            value_modifier = color_value % colors_per_stage
            rgb_values = [
                min_rgb_value + value_modifier,
                args.max_rgb_value - value_modifier,
                min_rgb_value,
            ]
            [red, green, blue] = [
                [rgb_values[1], rgb_values[0], rgb_values[2]],
                rgb_values[::-1],
                [rgb_values[0], rgb_values[2], rgb_values[1]],
            ][color_value // colors_per_stage]

            color_print(red, green, blue, char)
            index += step
        line_print_pending = False
print("\033[0m", end="")
