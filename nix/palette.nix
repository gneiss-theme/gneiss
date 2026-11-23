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

  # What a template can name in double braces: each base color, and the
  # version.
  fills = lib.mapAttrs' (name: color: lib.nameValuePair "{{${name}}}" color) base
    // { "{{version}}" = meta.version; };
in
assert lib.assertMsg (badBase == [ ])
  "palette.toml: the base colors ${toString badBase} must be hex colors";
assert lib.assertMsg (badRoles == [ ])
  "palette.toml: the roles ${toString badRoles} must be a hex color or one of the [base] colors";
{
  inherit meta base colors;

  # A template's text with everything in double braces filled in. Fails if
  # anything is left, such as a color that isn't one of the base colors.
  render = name: text:
    let
      rendered = lib.replaceStrings (lib.attrNames fills) (lib.attrValues fills) text;
    in
    assert lib.assertMsg (!lib.hasInfix "{{" rendered)
      "gneiss: ${name} names something in double braces that is neither a base color in palette.toml nor the version";
    rendered;
}
