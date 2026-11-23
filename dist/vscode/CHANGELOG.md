# Changelog

Gneiss is pre-1.0, so any release may change its colors. Every color change
is listed here.

## 0.1.0 (unreleased)

The first version. Gneiss began in a personal NixOS configuration and moved
here.

- The palette: Nord's text and accent colors on neutral grays.
  - `gneiss0` to `gneiss3` (`#1C1C1C`, `#2D2D2D`, `#383838`, `#424242`) keep
    Nord's contrast steps from `nord0` to `nord3`.
  - `gneiss-comment` (`#6E6E6E`) is as light as Nord's comment color.
  - The `fg-muted` role (`#A2A2A2`) is new: a gray just readable (4.5:1) on
    `gneiss2`.
- Ports:
  - Neovim, forked from nord.nvim's highlights.
  - VS Code, forked from Nord's VS Code theme 0.19.0.
  - Alacritty.
  - Vicinae.
  - Obsidian.
- The docs site, at gneiss-theme.github.io/gneiss.
- Changes from Nord in the ports:
  - Terminal bright black (color 8) is the comment gray, where Nord uses its
    border gray, which is too faint to read.
  - Vicinae's accent is `gneiss8`, where Vicinae's own Nord theme uses
    `nord9`.
