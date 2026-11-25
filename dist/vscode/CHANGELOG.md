# Changelog

Gneiss is pre-1.0, so any release may change its colors. Every color change
is listed here.

## 0.3.0 (2026-11-25)

- A Wayle port: a theme file for Wayle's themes folder, and
  `lib.wayle.palette` in the flake, its colors as Wayle's config takes them.
  - Text is `gneiss4` and secondary text is `fg-muted`, where Wayle's own
    Nord theme uses `nord6` and `nord4`.

## 0.2.0 (2026-11-25)

- Obsidian uses the accent less, so notes look calmer:
  - Headings are `gneiss6` (h1 and h2, and the note's title) and `gneiss5`
    (h3 to h6), where they were `gneiss8`.
  - Links are `gneiss9`, and `gneiss8` on hover.
  - Tags are `fg-muted`, and `gneiss8` on hover.
  - Bold text and callout titles are `gneiss6`; callouts keep their color
    on the edge and the icon.
  - Highlights are on `gneiss3`, where Obsidian tinted them yellow, and
    quotes are edged in `gneiss-comment` instead of the accent.

## 0.1.0 (2026-11-23)

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
- The docs site, at gneisstheme.com.
- Changes from Nord in the ports:
  - Terminal bright black (color 8) is the comment gray, where Nord uses its
    border gray, which is too faint to read.
  - Vicinae's accent is `gneiss8`, where Vicinae's own Nord theme uses
    `nord9`.
