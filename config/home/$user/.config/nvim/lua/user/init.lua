
---- Variables

local WindowUp      = "<cmd>wincmd k<CR>"
local WindowDown    = "<cmd>wincmd j<CR>"
local WindowLeft    = "<cmd>wincmd h<CR>"
local WindowRight   = "<cmd>wincmd l<CR>"

local NextBuffer  = "<cmd>BufferLineCycleNext<cr>"
local PrevBuffer  = "<cmd>BufferLineCyclePrev<cr>"
local CloseBuffer = "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>"

local ToggleTermNum = "<cmd>exec v:count1 . 'ToggleTerm size=10 direction=horizontal'<CR>"

---- Functions

-- wrapper to call telescope grep on active buffer
local function telescope_grep()
  require("telescope.builtin").current_buffer_fuzzy_find()
end

-- wrapper to call telescope grep on the entire project
local function telescope_grep_all(settings)
  require("telescope.builtin").live_grep(settings)
end

-- wrapper to call telescope to search only open files
local function telescope_grep_open()
  telescope_grep_all({ grep_open_files=true })
end

---- Configuration

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
  plugins = {
    init = {
      { "junegunn/fzf", run = function() vim.fn['fzf#install']() end},
      { "kevinhwang91/nvim-bqf" },
      { "euclio/vim-markdown-composer", run = "cargo build --release" },
    },
    ["toggleterm"] = {
      start_in_insert = true,
    },
    ["session_manager"] = {
      sessions_dir = string.format("%s/sessions", vim.fn.stdpath('data')),
      autosave_last_session = true,
    },
    ["which-key"] = {
      silent = true,
      noremap = true,
    },
    ["neo-tree"] = {
      window = {
        mappings = {
          ["Z"] = "expand_all_nodes",
        },
      },
    },
  },

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
    i = {
      -- code navigation
      ["<A-Left>"]  = { "<C-o>^", desc = "Jump to Start of Line" },
      ["<A-Right>"] = { "<End>",  desc = "Jump to End of Line" },
      -- find utilities
      ["<C-f>"]  = { telescope_grep,     desc = "Grep current buffer" },
      ["<CA-f>"] = { telescope_grep_all, desc = "Grep project files" },
    },
    t = {
      -- improved terminal controls
      ["<C-l>"] = { '<C-l>', desc = "Clear Terminal Screen" },
      -- improved terminal window navigation
      ["<C-t>"]     = { ToggleTermNum, desc = "Spawn Additional Terminal(s)" },
      ["<C-Up>"]    = { WindowUp,      desc = "Move to upper window" },
      ["<C-Down>"]  = { WindowDown,    desc = "Move to lower window" },
      ["<C-Left>"]  = { WindowLeft,    desc = "Move to left window"  },
      ["<C-Right>"] = { WindowRight,   desc = "Move to right window" },
    },
    n = {
      -- quit shortcut
      ["<C-c>"] = { "<cmd>q<CR>" },
      -- terminal shortcuts
      ["t"] = { ToggleTermNum, desc = "Toggle Termimal By Number" },
      -- telescope search navigation
      ["<C-f>"]  = { telescope_grep,     desc = "Grep current buffer" },
      ["<CS-f>"] = { telescope_grep_all, desc = "Grep project files" },
      -- code navigation
      ["<A-Left>"]  = { "^", desc = "Jump to Start of Line" },
      ["<A-Right>"] = { "<End>",  desc = "Jump to End of Line" },
      -- tab (buffer) navigation
      ["<Tab>"]    = { NextBuffer,         desc = "Focus Next Buffer" },
      ["<C-Tab>"]  = { PrevBuffer,         desc = "Focus Prev Buffer" },
      ["<C-x>"]    = { CloseBuffer,        desc = "Close Current Tab" },
      ["<CS-Tab>"] = { "<cmd>vert sb<CR>", desc = "Move to Vertical Split" },
      -- menu nagivation controls rework
      ["!"]         = { "<cmd>1wincmd w <CR>", desc = "Move to first window" },
      ["@"]         = { "<cmd>2wincmd w<CR>", desc = "Move to window #2" },
      ["#"]         = { "<cmd>3wincmd w<CR>", desc = "Move to window #3" },
      ["$"]         = { "<cmd>4wincmd w<CR>", desc = "Move to window #4" },
      ["%"]         = { "<cmd>5wincmd w<CR>", desc = "Move to window #5" },
      ["<C-Up>"]    = { WindowUp,    desc = "Move to upper split" },
      ["<C-Down>"]  = { WindowDown,  desc = "Move to lower split" },
      ["<C-Left>"]  = { WindowLeft,  desc = "Move to left split"  },
      ["<C-Right>"] = { WindowRight, desc = "Move to right split" },
      ["<S-Up>"]    = { "<cmd>resize +2<CR>",          desc = "Resize split up" },
      ["<S-Down>"]  = { "<cmd>resize -2<CR>",          desc = "Resize split down" },
      ["<S-Left>"]  = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" },
      ["<S-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" },
      -- plugin commands
      ["<A-m>"] = { "<cmd>ComposerStart<CR>", desc = "Open Markdown Preview" },
      ["<A-s>"] = { "<cmd>SessionManager save_current_session<CR>", desc = "Save Session" },
      ["<A-l>"] = { "<cmd>SessionManager load_session<CR>", desc = "Load Dir Session" },
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
  polish = function()
    -- disable markdown-preview autostart
    vim.cmd("let g:markdown_composer_autostart = 0")
    -- update function keymapping for better-quick-fix
    require('bqf').setup({ func_map = {
      filter  = "<C-f>",
      filterr = "<C-d>",
    }})
  end,
}
return config
