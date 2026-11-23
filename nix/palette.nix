# Gneiss's palette, read from palette.toml, and the renderer that fills in a
# port's template from it.
{ lib }:
let
  toml = builtins.fromTOML (builtins.readFile ../palette.toml);
  inherit (toml) meta base;

  isHex = color: builtins.match "#[0-9A-Fa-f]{6}" color != null;

  # Each role's color, with base color names resolved to hex.
  colors = lib.mapAttrs (_: color: base.${color} or color) toml.colors;

  badBase = lib.attrNames (lib.filterAttrs (_: color: !isHex color) base);
  badRoles = lib.attrNames (lib.filterAttrs (_: color: !isHex color) colors);
  sharedNames = lib.attrNames (builtins.intersectAttrs base colors);

  # A number to one decimal place, as text: 193.333 is "193.3".
  oneDecimal = x:
    let tenths = builtins.floor (x * 10 + 0.5);
    in "${toString (tenths / 10)}.${toString (lib.mod tenths 10)}";

  # A hex color's hue (degrees), saturation and lightness (percent), for
  # apps that take a color as HSL, such as Obsidian's accent.
  hsl = hex:
    let
      channel = i: lib.fromHexString (builtins.substring i 2 hex) / 255.0;
      r = channel 1;
      g = channel 3;
      b = channel 5;
      max = lib.max r (lib.max g b);
      min = lib.min r (lib.min g b);
      delta = max - min;
      l = (max + min) / 2;
      s = if delta == 0 then 0.0 else delta / (1 - (if 2 * l - 1 < 0 then 1 - 2 * l else 2 * l - 1));
      sector =
        if delta == 0 then 0.0
        else if max == r then (let x = (g - b) / delta; in if x < 0 then x + 6 else x)
        else if max == g then (b - r) / delta + 2
        else (r - g) / delta + 4;
    in
    { h = oneDecimal (60 * sector); s = oneDecimal (100 * s); l = oneDecimal (100 * l); };

  # What a template can name in double braces: each base color and role as
  # hex, such as {{gneiss8}} and {{fg-muted}}; each base color's HSL parts,
  # such as {{gneiss8-h}}, {{gneiss8-s}} and {{gneiss8-l}}; and the version.
  fills =
    lib.mapAttrs' (name: color: lib.nameValuePair "{{${name}}}" color) (base // colors)
    // lib.concatMapAttrs (name: color: with hsl color; {
      "{{${name}-h}}" = h;
      "{{${name}-s}}" = s;
      "{{${name}-l}}" = l;
    }) base
    // { "{{version}}" = meta.version; };
in
assert lib.assertMsg (badBase == [ ])
  "palette.toml: the base colors ${toString badBase} must be hex colors";
assert lib.assertMsg (badRoles == [ ])
  "palette.toml: the roles ${toString badRoles} must be a hex color or one of the [base] colors";
assert lib.assertMsg (sharedNames == [ ])
  "palette.toml: ${toString sharedNames} can't be both a base color and a role";
{
  inherit meta base colors;

  # A template's text with everything in double braces filled in. Fails if
  # anything is left, such as a color that isn't in palette.toml.
  render = name: text:
    let
      rendered = lib.replaceStrings (lib.attrNames fills) (lib.attrValues fills) text;
    in
    assert lib.assertMsg (!lib.hasInfix "{{" rendered)
      "gneiss: ${name} names something in double braces that isn't a base color, role, HSL part or the version";
    rendered;
}
