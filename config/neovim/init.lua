
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

-- configuration
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
      ["<C-f>"] = { telescope_grep, desc = "Grep current buffer" },
      ["<CA-f>"] = { telescope_grep_all, desc = "Grep project files" },
    },
    n = {
      -- quit shortcut
      ["<C-c>"] = { "<cmd>q<CR>" },
      -- terminal shortcuts
      ["t1"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc="Horizontal Term"},
      ['t2'] = { "<cmd>2ToggleTerm size=10 direction=horizontal<cr>", desc="Second Horizontal Term" },
      -- telescope search navigation
      ["<C-f>"] = { telescope_grep, desc = "Grep current buffer" },
      ["<CS-f>"] = { telescope_grep_all, desc = "Grep project files" },
      -- tab (buffer) navigation
      ["<Tab>"] = { "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer tab" },
      ["<C-x>"] = { "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>", desc = "Close Current Tab" },
      ["<CS-Tab>"] = { "<cmd>vert sb<CR>", desc = "Move to Vertical Split" },
      -- menu nagivation controls rework
      ["!"]         = { "<cmd>1wincmd w <CR>", desc = "Move to first window" },
      ["@"]         = { "<cmd>2wincmd w<CR>", desc = "Move to window #2" },
      ["#"]         = { "<cmd>3wincmd w<CR>", desc = "Move to window #3" },
      ["$"]         = { "<cmd>4wincmd w<CR>", desc = "Move to window #4" },
      ["%"]         = { "<cmd>5wincmd w<CR>", desc = "Move to window #5" },
      ["<C-Up>"]    = { "<C-w>k", desc = "Move to upper split" },
      ["<C-Down>"]  = { "<C-w>j", desc = "Move to lower split" },
      ["<C-Left>"]  = { "<C-w>h", desc = "Move to left split"  },
      ["<C-Right>"] = { "<C-w>l", desc = "Move to right split" },
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
