-- Final Configuration and Polish

-- Variables --

local telescope = require "telescope"
local whitespace = require "whitespace-nvim"

-- Functions --

local function set_transparency()
  -- assign transparent groups for heirline
  local heir_highlights = require("heirline.highlights").get_highlights()
  vim.g.transparent_groups = vim.list_extend(
    vim.g.transparent_groups or {},
    vim.tbl_map(function(v) return v end, vim.tbl_keys(heir_highlights))
  )
  -- assign transparent groups for neo-tree
  local tree_highlights = require "neo-tree.ui.highlights"
  vim.g.transparent_groups = vim.list_extend(
    vim.g.transparent_groups or {},
    vim.tbl_map(function(v) return v end, vim.tbl_values(tree_highlights))
  )
end

-- Init --

-- Neovide Settings
vim.g.neovide_transparency = 0.75

-- Final
telescope.load_extension "noice"
whitespace.highlight()
vim.defer_fn(set_transparency, 100)
