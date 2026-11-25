"""Checks that the Wayle theme has exactly the colors Wayle's theme files
take, each a hex color.

Usage: python3 wayle.py gneiss-wayle.toml

Wayle skips a theme file with a color missing, without saying why outside
its log, and ignores keys it doesn't know. So a misspelled key, such as the
config's fg-muted for the theme file's fg_muted, leaves the theme out of
Wayle's settings. The keys are Wayle 0.7.1's theme schema.
"""

import re
import sys
import tomllib

KEYS = {"bg", "surface", "elevated", "fg", "fg_muted", "primary", "red", "yellow", "green", "blue"}

with open(sys.argv[1], "rb") as file:
    theme = tomllib.load(file)

failures = []
missing, extra = KEYS - theme.keys(), theme.keys() - KEYS
if missing:
    failures.append(f"is missing {', '.join(sorted(missing))}")
if extra:
    failures.append(f"has keys Wayle doesn't read: {', '.join(sorted(extra))}")
for key, value in sorted(theme.items()):
    if not (isinstance(value, str) and re.fullmatch(r"#[0-9A-Fa-f]{6}", value)):
        failures.append(f"has {key} as {value!r}, not a hex color")
    else:
        print(f"ok    {key:9} {value}")

if failures:
    sys.exit("The Wayle theme " + "; ".join(failures) + ".")
