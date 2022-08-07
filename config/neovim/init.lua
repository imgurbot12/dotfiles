local config = {

  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "stable", -- "stable" or "nightly"
    version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "main", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
  },

  -- Set colorscheme
  colorscheme = "default_theme",

  -- set vim options here (vim.<first_key>.<second_key> =  value)
  options = {
    -- sets vim.opt.relativenumber
    opt = { relativenumber = false, },
    -- sets vim.g.mapleader
    g = { mapleader = " ", },
  },

  -- Default theme configuration
  default_theme = {
    diagnostics_style = { italic = true },
    -- Modify the color table
    colors = {},
    -- enable or disable extra plugin highlighting
    plugins = {},
  },

  -- Disable AstroNvim ui features
  ui = {},

  -- Configure plugins
  plugins = {},

  -- CMP Source Priorities
  -- modify here the priorities of default cmp sources
  -- higher value == higher priority
  -- The value can also be set to a boolean for disabling default sources:
  -- false == disabled
  -- true == 1000
  cmp = {
    source_priority = {},
  },

  -- Diagnostics configuration (for vim.diagnostics.config({}))
  diagnostics = {},

  -- Mapping data with "desc" stored directly by vim.keymap.set().
  --
  -- Please use this mappings table to set keyboard mapping since this is the
  -- lower level configuration and more robust one. (which-key will
  -- automatically pick-up stored data by this setting.)
  mappings = {
    -- first key is the mode
    n = {
      ["<C-f>"] = {
          function()
            require("telescope.builtin").live_grep({
              grep_open_files=true
            })
          end,
          desc = "Search words in file",
      },
      -- tab (buffer) navigation
      ["<Tab>"] = { "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer tab" },
      -- menu nagivation controls rework
      ["<C-Up>"]    = { "<C-w>k", desc = "Move to upper split" },
      ["<C-Down>"]  = { "<C-w>j", desc = "Move to lower split" },
      ["<C-Left>"]  = { "<C-w>h", desc = "Move to left split"  },
      ["<C-Right>"] = { "<C-w>l", desc = "Move to right split" },
      ["<S-Up>"]    = { "<cmd>resize +2<CR>",          desc = "Resize split up" },
      ["<S-Down>"]  = { "<cmd>resize -2<CR>",          desc = "Resize split down" },
      ["<S-Left>"]  = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" },
      ["<S-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" },
    },
  },

  -- Modify which-key registration (Use this with mappings table in the above.)
  ["which-key"] = {
    -- Add bindings which show up as group name
    register_mappings = {
      -- first key is the mode, n == normal mode
      n = {},
    },
  },

  -- This function is run last
  -- good place to configuring augroups/autocommands and custom filetypes
  polish = function() end,
}
return config
