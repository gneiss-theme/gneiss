-- Loads the gneiss colorscheme headless and checks a few highlights against
-- the palette.
--
-- Usage: nvim --clean --headless --cmd "set rtp^=<plugin>" -l neovim.lua <base.json>
-- where base.json is palette.toml's [base] table.

local base = vim.json.decode(io.open(arg[1]):read("a"))

vim.o.termguicolors = true
vim.cmd.colorscheme("gneiss")

local failures = {}
local function expect(ok, message)
  io.stdout:write((ok and "ok    " or "FAIL  ") .. message .. "\n")
  if not ok then
    failures[#failures + 1] = message
  end
end

local function hex(value)
  return value and ("#%06X"):format(value) or "none"
end

local function check(group, key, color)
  local actual = hex(vim.api.nvim_get_hl(0, { name = group, link = false })[key])
  expect(actual == base[color]:upper(), ("%s %s is %s (%s), got %s"):format(group, key, color, base[color], actual))
end

expect(vim.g.colors_name == "gneiss", "the colorscheme is named gneiss")
expect(vim.v.errmsg == "", "it loads without errors" .. (vim.v.errmsg ~= "" and (": " .. vim.v.errmsg) or ""))

check("Normal", "bg", "gneiss0")
check("Normal", "fg", "gneiss4")
check("Comment", "fg", "gneiss-comment")
check("Keyword", "fg", "gneiss9")
check("Function", "fg", "gneiss8")
check("String", "fg", "gneiss14")
check("Number", "fg", "gneiss15")
check("DiagnosticError", "fg", "gneiss11")
check("DiagnosticWarn", "fg", "gneiss13")

local term8 = tostring(vim.g.terminal_color_8):upper()
expect(term8 == base["gneiss-comment"]:upper(), "terminal color 8 is gneiss-comment, got " .. term8)

if #failures > 0 then
  error(#failures .. " Neovim check(s) failed")
end
