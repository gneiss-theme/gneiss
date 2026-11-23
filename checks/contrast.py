"""Checks the contrast ratios that palette.toml describes, then prints every
color's contrast with the background.

Usage: python3 contrast.py palette.toml

Ratios are WCAG 2 contrast ratios. Nord's colors below are the reference
Gneiss's grays were measured against, copied once: they don't follow Nord.
"""

import sys
import tomllib

NORD = {
    "nord0": "#2E3440",
    "nord1": "#3B4252",
    "nord2": "#434C5E",
    "nord3": "#4C566A",
    "nord-comment": "#616E88",
}


def luminance(color):
    channels = [int(color[i : i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4 for c in channels]
    return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]


def ratio(a, b):
    light, dark = sorted((luminance(a), luminance(b)), reverse=True)
    return (light + 0.05) / (dark + 0.05)


with open(sys.argv[1], "rb") as file:
    palette = tomllib.load(file)
base = palette["base"]
colors = {role: base.get(value, value) for role, value in palette["colors"].items()}
background = base["gneiss0"]

failures = []


def expect(ok, message):
    print(("ok    " if ok else "FAIL  ") + message)
    if not ok:
        failures.append(message)


# The background grays keep Nord's steps: nord1 to nord3 against nord0.
for step in (1, 2, 3):
    gneiss = ratio(base[f"gneiss{step}"], background)
    nord = ratio(NORD[f"nord{step}"], NORD["nord0"])
    expect(
        abs(gneiss - nord) <= 0.02,
        f"gneiss{step} is {gneiss:.2f}:1 against gneiss0, as nord{step} is {nord:.2f}:1 against nord0",
    )

# The comment gray is as light as Nord's comment color.
comment, nord_comment = luminance(base["gneiss-comment"]), luminance(NORD["nord-comment"])
expect(
    abs(comment - nord_comment) / nord_comment <= 0.02,
    f"gneiss-comment's lightness ({comment:.4f}) is within 2% of Nord's comment color ({nord_comment:.4f})",
)

# fg-muted is readable (4.5:1) on gneiss2.
muted = ratio(colors["fg-muted"], base["gneiss2"])
expect(muted >= 4.5, f"fg-muted is {muted:.2f}:1 on gneiss2, at least 4.5:1")

print()
print("Contrast with gneiss0:")
for name, color in list(base.items()) + [(f"role {r}", c) for r, c in colors.items()]:
    print(f"  {name:22} {color}  {ratio(color, background):5.2f}:1")

sys.stdout.flush()
if failures:
    sys.exit(f"\n{len(failures)} contrast check(s) failed.")
