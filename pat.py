#!/usr/bin/python
from sys import stdin, argv
from string import whitespace

# These next 2 lines of code are only for ANSI escape support on Windows cmd prompt/powershell
# If you do not use cmd/ps, you can comment them out or remove them
from os import system
system("")

color_info = {"amount": 299, "max_rgb_value": 255}
color_info["per_stage"] = (color_info["amount"] + 1) // 3
color_info["min_rgb_value"] = color_info["max_rgb_value"] - color_info["per_stage"]

if len(argv) == 1:
    argv.append("-")

for argument in argv[1:]:
    read_result = stdin.read() if argument == "-" else open(argument, "r").read()
    color_info["changes"] = len(list(filter(lambda c: not c in whitespace, read_result))) - 1
    color_info["step"] = (
        0
        if color_info["changes"] == 0
        else color_info["amount"] / color_info["changes"]
    )
    color_info["index"] = 0

    for character in read_result:
        if character in whitespace:
            print(character, end="")
            continue

        color_value = round(color_info["index"])
        value_modifier = color_value % color_info["per_stage"]
        rgb_values = [
            color_info["min_rgb_value"] + value_modifier,
            color_info["max_rgb_value"] - value_modifier,
            color_info["min_rgb_value"],
        ]
        [red, green, blue] = [
            [rgb_values[1], rgb_values[0], rgb_values[2]],
            rgb_values[::-1],
            [rgb_values[0], rgb_values[2], rgb_values[1]],
        ][color_value // color_info["per_stage"]]

        print("\x1b[38;2;%d;%d;%dm%s" % (red, green, blue, character), end="")
        color_info["index"] += color_info["step"]
